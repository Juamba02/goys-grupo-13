# Runbook — Drill 3: BGP, se cae el proveedor

## Objetivo

Se cae ISP-1 sin que se caiga el enlace del lado del EDGE, y la salida a Internet tiene que pasar a ISP-2, cuya sesión y default ya están cargadas. El drill es bueno si el corte queda cerca del hold-time configurado (9 s) y la red interna no cambia nada.

## Roles

| Rol | Quién | Qué hace |
| :-- | :-- | :-- |
| Operador | | Apaga y prende `ether1` en ISP-1 |
| Observador | | Corre el ping en DIST-1 y mira el log y las rutas de EDGE |

## Antes de empezar

- [ ] **Backup "antes":** los `_f4` de EDGE y el `_traceroute` de ISP-1 e ISP-2 reflejan el estado actual (memoria §6.2). Si hubo cambios, tomar `/export file=<ROUTER>_<AAAAMMDD>_pre-drill3`.
- [ ] **Estado normal verificado:**

| Dónde | Comando | Resultado esperado |
| :-- | :-- | :-- |
| EDGE | `/routing bgp session print` | `to-ISP-1` y `to-ISP-2` en `E`, con `hold-time=9s keepalive-time=3s` |
| EDGE | `/ip route print where dst-address=0.0.0.0/0` | Dos defaults por BGP; la activa (`DAb`) es la de ISP-1 (192.0.2.1) |
| DIST-1 | `/ping 198.51.100.1 src-address=10.10.10.2 count=3` | Responde (el destino de prueba lo tienen los dos ISP) |

## Falla

| Paso | Dónde | Comando | Cuándo |
| :-- | :-- | :-- | :-- |
| 1 | DIST-1 | `/ping 198.51.100.1 src-address=10.10.10.2 interval=1s` | Arranca la medición |
| 2 | ISP-1 | `/interface disable ether1` (del lado del proveedor: el enlace de EDGE sigue arriba) | Con el ping respondiendo |

## Detección

EDGE no ve caer el enlace: solo deja de recibir keepalives de ISP-1 y se entera al vencer el hold-time.

| Dónde | Comando | Qué se ve |
| :-- | :-- | :-- |
| EDGE | `/log print where topics~"bgp"` | `HoldTimer expired to-ISP-1` |
| EDGE | `/routing bgp session print` | Solo `to-ISP-2` en `E` |

## Respuesta

Automática. EDGE retira la default y las rutas de ISP-1 y queda activa la de ISP-2. La default entra a OSPF con `originate-default=if-installed`, así que CORE y DIST siguen mandando todo al EDGE sin cambios. Hacia adentro, ISP-2 ya tenía las dos LANs por BGP.

| Dónde | Comando | Qué se ve |
| :-- | :-- | :-- |
| EDGE | `/ip route print where dst-address=0.0.0.0/0` | La default activa es la de ISP-2 (192.0.2.5) |

## Recuperación

| Paso | Dónde | Comando | Qué se ve |
| :-- | :-- | :-- | :-- |
| 1 | ISP-1 | `/interface enable ether1` | `to-ISP-1` vuelve a `E` en unos 8 s |
| 2 | EDGE | `/ip route print where dst-address=0.0.0.0/0` | Vuelven las dos defaults |

Al terminar, repetir la tabla de "Estado normal verificado". La default activa puede quedar la de ISP-2 (las dos tienen distancia 20 y queda la primera que se aprendió): no es una falla.

## Medición

- **Corte:** pings perdidos en DIST-1 desde que se apaga `ether1` hasta que vuelve a responder `198.51.100.1`.
- **Capturas:** `capturas/f4/dist1-drill3-ping-<N>.png` (ping) y `edge-drill3-holdtimer*.png` (log de EDGE).

## Limpieza

No hay: el drill solo apaga y prende una interfaz.

## Historial de corridas

| Fecha | Operador | Corte | Vuelta | Capturas | Notas |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 28/10/2026 | R1/R2 | 164 s (pings 14 a 177 de 260) | — | `edge-drill3-holdtimer.png`, `dist1-drill3-ping-1.png` | Timers por defecto (hold-time 3m, keepalive 1m) |
| 28/10/2026 | R1/R2 | 8 s (pings 13 a 20 de 60) | Sesión en `E` en 8 s | `edge-drill3-holdtimer-9s.png`, `dist1-drill3-ping-2.png` | Con hold-time 9s y keepalive 3s (post-mortem de la primera corrida) |

## Post-mortem

Cuando falla el proveedor y no el enlace, BGP solo se entera por el hold-time: con los timers por defecto el corte duró casi lo mismo que el hold-time. Se bajaron a 9s/3s en EDGE, ISP-1 e ISP-2 (`configs/*.rsc`, bloque F4) y el corte pasó a 8 s; el costo es una sesión más sensible a pérdidas en el enlace. Con un enlace real la alternativa es BFD. Análisis completo en la memoria §4.2.
