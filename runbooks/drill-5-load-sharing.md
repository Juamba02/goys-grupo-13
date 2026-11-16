# Runbook — Drill 5: load-sharing VRRP, ambos DIST activos

## Objetivo

Comprobar que en estado normal cada DIST mueve el tráfico de una LAN (load-sharing con prioridades cruzadas) y que, si uno se queda sin las dos LANs, el otro absorbe los dos grupos y se vuelve al reparto por preemption. El drill es bueno si cada LAN sale por su master en estado normal, el corte es de pocos pings y el reparto vuelve solo.

## Roles

| Rol | Quién | Qué hace |
| :-- | :-- | :-- |
| Operador | | Apaga y prende `ether3` y `ether4` en DIST-2 |
| Observador | | Corre el ping y el trace en SRV y mira VRRP en DIST-1 |

## Antes de empezar

- [ ] **Backup "antes":** `DIST-1_20261023_f3.rsc` y `DIST-2_20261023_f3.rsc` reflejan el estado actual (memoria §6.2). Si hubo cambios, tomar `/export file=<ROUTER>_<AAAAMMDD>_pre-drill5`.
- [ ] **Estado normal verificado:**

| Dónde | Comando | Resultado esperado |
| :-- | :-- | :-- |
| DIST-1 | `/interface vrrp print` | `vrrp10` en `RM` (150), `vrrp20` en `B` (100) |
| DIST-2 | `/interface vrrp print` | `vrrp10` en `B` (100), `vrrp20` en `RM` (150) |
| PC-USER | `trace 10.10.20.10` | Primer salto 10.10.10.2 (DIST-1) |
| SRV | `trace 10.10.10.10` | Primer salto 10.10.20.3 (DIST-2) |

## Falla

| Paso | Dónde | Comando | Cuándo |
| :-- | :-- | :-- | :-- |
| 1 | SRV | `ping 10.10.10.10 -c 25` | Arranca la medición |
| 2 | DIST-2 | `/interface ethernet disable ether3,ether4` (pierde las dos LANs) | En el ping 5 |

## Detección

DIST-1 deja de recibir los anuncios del vrid 20 y pasa a master al vencer el *master down timer*.

| Dónde | Comando | Qué se ve |
| :-- | :-- | :-- |
| DIST-1 | `/log print where message~"vrrp20"` | `vrrp20 now MASTER, master down timer` |

## Respuesta

Automática.

| Dónde | Comando | Qué se ve |
| :-- | :-- | :-- |
| DIST-1 | `/interface vrrp print` | `vrrp10` y `vrrp20` en `RM` |
| SRV | `trace 10.10.10.10` | Primer salto 10.10.20.2 (DIST-1) |

## Recuperación

| Paso | Dónde | Comando | Qué se ve |
| :-- | :-- | :-- | :-- |
| 1 | DIST-2 | `/interface ethernet enable ether3,ether4` (en el ping 15) | DIST-2 recupera el vrid 20 por preemption |
| 2 | DIST-1 | `/log print where message~"vrrp20"` | `vrrp20 now BACKUP, got higher priority 150 from 10.10.20.3` |

Al terminar, repetir la tabla de "Estado normal verificado": el reparto tiene que quedar como al principio.

## Medición

- **Corte:** pings perdidos en SRV después del ping 5. **Vuelta:** pings perdidos después del paso 1 de la recuperación.
- **Capturas:** `capturas/f4/srv-drill5-ping.png` (trace por DIST-2 y ping) y `dist1-drill5-vrrp.png` (log de DIST-1).

## Limpieza

No hay: el drill solo apaga y prende interfaces.

## Historial de corridas

| Fecha | Operador | Corte | Vuelta | Capturas | Notas |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 28/10/2026 | R3/R4 | 2 pings de 30 (9 y 10) | 0 de 30 | `dist1-drill5-vrrp.png` | Primera corrida, sin captura del ping |
| 28/10/2026 | R3/R4 | 2 pings de 25 (6 y 7) | 0 | `srv-drill5-ping.png`, `dist1-drill5-vrrp.png` | |

## Post-mortem

El reparto funciona porque cada grupo tiene un master distinto con prioridades cruzadas y cada DIST es backup del otro: cuando cae uno, el otro absorbe todo y la preemption devuelve el reparto. El costo es que un DIST tiene que poder con las dos LANs mientras dure la falla, y las prioridades son fijas: VRRP no se entera si el master pierde los uplinks. Análisis completo en la memoria §4.2.
