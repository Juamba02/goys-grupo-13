# Runbook — Drill 2: OSPF, se corta el camino interno

## Objetivo

Se corta el enlace CORE-1–DIST-1 y DIST-1 tiene que seguir llegando al core por CORE-2, que ya tenía calculado como segundo camino (ECMP). Al volver el enlace, recupera los dos caminos. El drill es bueno si el corte es de 1 o 2 pings y la vuelta no pierde ninguno.

## Roles

| Rol | Quién | Qué hace |
| :-- | :-- | :-- |
| Operador | | Apaga y prende `ether3` en CORE-1 |
| Observador | | Corre el ping y los trace en PC-USER y mira las rutas de DIST-1 |

## Antes de empezar

- [ ] **Backup "antes":** `CORE-1_20261023_f3.rsc` y `DIST-1_20261023_f3.rsc` reflejan el estado actual (memoria §6.2). Si hubo cambios, tomar `/export file=<ROUTER>_<AAAAMMDD>_pre-drill2`.
- [ ] **Estado normal verificado:**

| Dónde | Comando | Resultado esperado |
| :-- | :-- | :-- |
| CORE-1 | `/routing ospf neighbor print` | 4 vecinos en `Full`, DIST-1 (10.255.255.4) por `ether3` |
| DIST-1 | `/ip route print where dst-address=10.255.255.3/32` | Dos caminos (ECMP): por CORE-1 y por CORE-2 (10.0.0.21) |
| PC-USER | `trace 10.255.255.3 -m 3` | Salto 2 por CORE-1 (`10.0.0.17`, la IP con la que responde CORE-1) |

## Falla

| Paso | Dónde | Comando | Cuándo |
| :-- | :-- | :-- | :-- |
| 1 | PC-USER | `ping 10.255.255.3 -c 20` (loopback de EDGE) | Arranca la medición |
| 2 | CORE-1 | `/interface ethernet disable ether3` (enlace CORE1–DIST1, 10.0.0.12/30) | En el ping 5 |

Se corta del lado de CORE-1 a propósito: para DIST-1 el enlace sigue arriba, como cuando se cae el equipo de la otra punta y no el cable.

## Detección

CORE-1 ve caer su interfaz al instante y genera un LSA sin el enlace a DIST-1, que le llega a DIST-1 por CORE-2. En el SPF el enlace a CORE-1 deja de ser bidireccional y DIST-1 lo descarta sin esperar el *dead interval*. El vecino recién cae por `timeout` unos 35 s después.

| Dónde | Comando | Qué se ve |
| :-- | :-- | :-- |
| DIST-1 | `/log print where message~"timeout"` | `neighbor { router-id: 10.255.255.1 state: Full } timeout` |

## Respuesta

Automática.

| Dónde | Comando | Qué se ve |
| :-- | :-- | :-- |
| DIST-1 | `/ip route print where dst-address=10.255.255.3/32` | Un solo camino, por CORE-2 (`10.0.0.21%ether2`) |
| PC-USER | `trace 10.255.255.3 -m 3` | Salto 2 por CORE-2 (`10.0.0.21`) |

## Recuperación

| Paso | Dónde | Comando | Qué se ve |
| :-- | :-- | :-- | :-- |
| 1 | CORE-1 | `/interface ethernet enable ether3` | La adyacencia con DIST-1 vuelve a `Full` |
| 2 | DIST-1 | `/ip route print where dst-address=10.255.255.3/32` | Vuelven los dos caminos |

Al terminar, repetir la tabla de "Estado normal verificado".

## Medición

- **Corte:** pings perdidos en PC-USER después del ping 5. **Vuelta:** pings perdidos después del paso 1 de la recuperación.
- **Capturas:** `capturas/f4/pc-user-drill2-ping.png` (trace antes, ping y trace después), `dist1-drill2-ruta.png` (un solo camino durante la falla) y `dist1-drill2-ospf.png` (log del timeout y vecinos).

## Limpieza

No hay: el drill solo apaga y prende una interfaz.

## Historial de corridas

| Fecha | Operador | Corte | Vuelta | Capturas | Notas |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 28/10/2026 | R3/R4 | 1 ping de 75 (~1 s) | 0 de 60 | `dist1-drill2-ospf.png` | Primera corrida, sin captura del ping |
| 28/10/2026 | R3/R4 | 1 ping de 20 (~1 s) | 0 de 20 | `pc-user-drill2-ping.png`, `dist1-drill2-ruta.png`, `dist1-drill2-ospf.png` | |

## Post-mortem

Funciona porque cada DIST tiene dos caminos al core y OSPF ya los tenía calculados, y es rápido porque uno de los dos extremos vio caer el enlace. Si ninguno lo ve (un switch en el medio que deja de pasar tráfico), la detección depende del *dead interval* de 40 s: con un enlace real convendría BFD o bajar `hello-interval`/`dead-interval` en `ospf-transito`. Análisis completo en la memoria §4.2.
