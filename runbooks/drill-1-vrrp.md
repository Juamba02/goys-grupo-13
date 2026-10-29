# Runbook — Drill 1: VRRP, se cae el gateway

## Objetivo

Se cae el master VRRP de la LAN USERS (DIST-1, vrid 10) y DIST-2 tiene que tomar la VIP 10.10.10.1 sin que PC-USER cambie nada. Al volver DIST-1, recupera el master por preemption. El drill es bueno si el corte es del orden del *master down interval* (≈3,6 s como máximo) y la vuelta no pierde pings.

## Roles

| Rol | Quién | Qué hace |
| :-- | :-- | :-- |
| Operador | | Apaga y prende `ether3` en DIST-1 |
| Observador | | Corre el ping en PC-USER y mira el log de DIST-2 |

## Antes de empezar

- [ ] **Backup "antes":** `DIST-1_20261023_f3.rsc` y `DIST-2_20261023_f3.rsc` reflejan el estado actual (memoria §6.2). Si hubo cambios, tomar `/export file=<ROUTER>_<AAAAMMDD>_pre-drill1`.
- [ ] **Estado normal verificado:**

| Dónde | Comando | Resultado esperado |
| :-- | :-- | :-- |
| DIST-1 | `/interface vrrp print` | `vrrp10` en `RM` (priority 150), `vrrp20` en `B` |
| DIST-2 | `/interface vrrp print` | `vrrp10` en `B` (priority 100), `vrrp20` en `RM` |
| PC-USER | `ping 10.10.10.1` | Responde la VIP |

## Falla

| Paso | Dónde | Comando | Cuándo |
| :-- | :-- | :-- | :-- |
| 1 | PC-USER | `ping 10.10.20.10 -c 25` (1 por segundo hacia SRV, sale por la VIP 10.10.10.1) | Arranca la medición |
| 2 | DIST-1 | `/interface ethernet disable ether3` (puerto de la LAN USERS) | En el ping 5 |

## Detección

DIST-2 deja de recibir los anuncios de DIST-1 en la LAN USERS y pasa a master al vencer el *master down interval*: 3 × 1 s + skew de 0,61 s (prioridad 100).

| Dónde | Comando | Qué se ve |
| :-- | :-- | :-- |
| DIST-2 | `/log print where message~"vrrp10"` | `vrrp10 now MASTER, master down timer` |
| DIST-2 | `/interface vrrp print` | `vrrp10` en `RM` |

## Respuesta

Automática. DIST-2 toma la VIP 10.10.10.1 con la misma MAC virtual (`00:00:5E:00:01:0A`) y manda ARP gratuito: PC-USER sigue usando el mismo gateway. Hacia adentro, DIST-1 deja de anunciar 10.10.10.0/24 por OSPF y la vuelta entra por DIST-2.

## Recuperación

| Paso | Dónde | Comando | Qué se ve |
| :-- | :-- | :-- | :-- |
| 1 | DIST-1 | `/interface ethernet enable ether3` (en el ping 15) | DIST-1 vuelve a master por preemption (prioridad 150) |
| 2 | DIST-2 | `/log print where message~"vrrp10"` | `vrrp10 now BACKUP, got higher priority 150 from 10.10.10.2` |

Al terminar, repetir la tabla de "Estado normal verificado".

## Medición

- **Corte:** pings perdidos en PC-USER entre el ping 5 y el primero que vuelve a responder. **Vuelta:** pings perdidos después del paso 1 de la recuperación.
- **Capturas:** `capturas/f4/pc-user-drill1-ping.png` (ping) y `dist2-drill1-vrrp.png` (log de DIST-2).

## Limpieza

No hay: el drill solo apaga y prende una interfaz.

## Historial de corridas

| Fecha | Operador | Corte | Vuelta | Capturas | Notas |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 28/10/2026 | R3/R4 | 4 pings de 40 (~4 s) | 0 de 30 | `dist2-drill1-vrrp.png` | Primera corrida, sin captura del ping |
| 28/10/2026 | R3/R4 | 2 pings de 25 (~2 s) | 0 | `pc-user-drill1-ping.png`, `dist2-drill1-vrrp.png` | La diferencia con la primera depende de en qué momento del intervalo de anuncios cae la falla |

## Post-mortem

Funciona porque el gateway de los hosts es una IP virtual: el cambio de master es invisible para PC-USER, y el tiempo queda dentro del teórico de VRRP con `interval=1s`. Bajar el intervalo acortaría el corte pero hace más probable un doble master. VRRP no se entera si el master pierde los uplinks y no la LAN (hallazgo de la memoria §5). Análisis completo en la memoria §4.2.
