# Runbook — Drill 4: check-gateway, failover estático de enlace

## Objetivo

Comparar el failover de BGP con el de rutas estáticas con `check-gateway=ping`. Se agregan en EDGE dos defaults estáticas temporales, con menor distancia que las de BGP para que sean las que se usan, y se repite la falla del drill 3. El drill es bueno si se mide el tiempo del check-gateway y al final no queda ninguna estática.

## Roles

| Rol | Quién | Qué hace |
| :-- | :-- | :-- |
| Operador | | Agrega y borra las estáticas en EDGE, apaga y prende `ether1` en ISP-1 |
| Observador | | Corre el ping en DIST-1 y mira las rutas de EDGE |

## Antes de empezar

- [ ] **Backup "antes":** los `_f4` de EDGE y el `_traceroute` de ISP-1 reflejan el estado actual (memoria §6.2). Si hubo cambios, tomar `/export file=<ROUTER>_<AAAAMMDD>_pre-drill4`.
- [ ] **Preparación** (en EDGE, solo para el drill):

```
/ip route add dst-address=0.0.0.0/0 gateway=192.0.2.1 distance=1 check-gateway=ping comment="drill4 ISP-1"
/ip route add dst-address=0.0.0.0/0 gateway=192.0.2.5 distance=2 check-gateway=ping comment="drill4 ISP-2"
```

- [ ] **Estado normal verificado:**

| Dónde | Comando | Resultado esperado |
| :-- | :-- | :-- |
| EDGE | `/ip route print where dst-address=0.0.0.0/0` | Activa la estática por ISP-1 (`As`, distancia 1); las de BGP quedan sin usar |
| DIST-1 | `/ping 198.51.100.1 src-address=10.10.10.2 count=3` | Responde |

## Falla

| Paso | Dónde | Comando | Cuándo |
| :-- | :-- | :-- | :-- |
| 1 | DIST-1 | `/ping 198.51.100.1 src-address=10.10.10.2 interval=1s` | Arranca la medición |
| 2 | ISP-1 | `/interface disable ether1` | Con el ping respondiendo |

## Detección

EDGE le hace ping al gateway de cada estática cada 10 s y la marca inactiva cuando deja de responder.

| Dónde | Comando | Qué se ve |
| :-- | :-- | :-- |
| EDGE | `/ip route print where dst-address=0.0.0.0/0` | La estática por ISP-1 en `I` (inactiva) |

## Respuesta

Automática: queda activa la estática por ISP-2 (`As`, distancia 2).

## Recuperación

| Paso | Dónde | Comando | Qué se ve |
| :-- | :-- | :-- | :-- |
| 1 | ISP-1 | `/interface enable ether1` | La estática por ISP-1 vuelve a activa en unos 13 s (primer ping del check-gateway que contesta) |

## Medición

- **Corte:** pings perdidos en DIST-1 desde que se apaga `ether1` hasta que vuelve a responder `198.51.100.1`.
- **Capturas:** `capturas/f4/dist1-drill4-ping.png` (ping) y `edge-drill4-check-gateway.png` (rutas de EDGE).

## Limpieza

Obligatoria: las estáticas no forman parte del diseño.

```
/ip route remove [ find comment~"drill4" ]
/ip route print where dst-address=0.0.0.0/0
```

Tiene que quedar solo la default por BGP, como antes del drill. Las estáticas temporales se registran en el change log como fila "sin commit".

## Historial de corridas

| Fecha | Operador | Corte | Vuelta | Capturas | Notas |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 28/10/2026 | R1 | 29 s (pings 12 a 40 de 60) | Estática activa en 13 s | `edge-drill4-check-gateway.png`, `dist1-drill4-ping.png` | Estáticas borradas al terminar |

## Post-mortem

El check-gateway es más lento que BGP con los timers ajustados (29 s contra 8 s) y solo prueba que el gateway responde: si ISP-1 contesta el ping pero pierde la sesión BGP, la estática sigue activa y la vuelta no llega porque ISP-1 ya no conoce las LANs. Por eso en el diseño final no quedan estáticas. Análisis completo en la memoria §4.2.
