# Change log

Formato definido en `docs/memoria.md` sección 1.4. Cada fila corresponde a un commit (o grupo de commits de un mismo cambio lógico) del historial de git — no se completa "a mano" sin relación con los commits reales.

Los PR #3 y #4 se mergearon con *squash*: sus commits originales no existen en `main`. En esas filas la columna Commit lleva el hash del squash en `main` y, entre paréntesis, el commit original de la rama (`f1-isp` / `f1-capturas`) para trazabilidad. Los cambios hechos solo en el router (sin commit) se registran igual, marcados como tales.

| Fecha | Autor (Rol) | Commit | Descripción | Sistemas afectados | Plan de rollback |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 01/10/2026 | Juan Bautista Aramberri | `ba572d2` | Estructura inicial del repo (README, carpetas, .gitignore) | repo | Revertir el commit |
| 01/10/2026 | Juan Bautista Aramberri | `ac53f5a` | Memoria F0: corrección del diagrama, IPAM, políticas de seguridad y operación | `docs/memoria.md` | Revertir el commit |
| 01/10/2026 | Juan Bautista Aramberri | `2ffe3bb` | Formato de change log y política de backup | `CHANGELOG.md` | Revertir el commit |
| 01/10/2026 | Juan Bautista Aramberri | `4f9212f` | Backlog con tareas F0 a F5 | `backlog.md` | Revertir el commit |
| 01/10/2026 | Juan Bautista Aramberri | `d73cfca`, `b211f46` | README: resumen del lab, reparto de roles y correcciones | `README.md` | Revertir los commits |
| 15/10/2026 | Joaquin Mazza (R1) | `cf78733` | IPs de enlace y loopback en EDGE, listas WAN/LAN | EDGE | Revertir el commit y en el router `/ip address remove` de las direcciones agregadas |
| 15/10/2026 | Joaquin Mazza (R2) | `a98d0f2` (`6f14db3`) | IPs de enlace y loopback en ISP-1 e ISP-2, lista CUSTOMER | ISP-1, ISP-2 | Revertir el commit y en el router `/ip address remove` de las direcciones agregadas |
| 15/10/2026 | Joaquin Mazza (R2) | `a98d0f2` (`3936eb5`) | Hardening de ISP-1 e ISP-2: usuario monitor, servicios apagados, sin MNDP ni mac-server | ISP-1, ISP-2 | Revertir el commit y reactivar los servicios con `/ip service enable` |
| 15/10/2026 | Joaquin Mazza (R1) | `80d9d7d` | Hardening de EDGE: usuario monitor, servicios apagados, MNDP y mac-server solo en LAN | EDGE | Revertir el commit y reactivar los servicios con `/ip service enable` |
| 15/10/2026 | Joaquin Mazza (R1) | `ef7bbdf` | Servicios de EDGE con `find` por nombre (RouterOS 7.24 no los encontraba) y reverse-proxy apagado | EDGE | Revertir el commit (la versión anterior del script no apagaba los servicios) |
| 15/10/2026 | Joaquin Mazza (R1) | `4c44a91` | Se borra el dhcp-client que CHR trae por defecto en ether1 | EDGE | `/ip dhcp-client add interface=ether1` |
| 15/10/2026 | Joaquin Mazza (R2) | `a98d0f2` (`ad545c5`) | Servicios de ISP-1 e ISP-2 con `find` por nombre y reverse-proxy apagado | ISP-1, ISP-2 | Revertir el commit (la versión anterior del script no apagaba los servicios) |
| 15/10/2026 | Joaquin Mazza (R2) | `a98d0f2` (`57be045`) | Se borra el dhcp-client que CHR trae por defecto en ether1 | ISP-1, ISP-2 | `/ip dhcp-client add interface=ether1` |
| 15/10/2026 | Joaquin Mazza (R1/R2) | sin commit (solo router) | Al pasar los nodos a VMs fijas de VirtualBox las placas aparecieron como ether5-8; se renombran a ether1-4 y se reasignan IPs y listas | EDGE, ISP-1, ISP-2 | Restaurar el backup base `<router>_20261015_base.rsc` |
| 15/10/2026 | Joaquin Mazza (R1/R2) | `619164b` (`b610656`) | Capturas de verificación de F1 (topología, pings, servicios, monitor en ISP-1) | `capturas/f1/` | Revertir el commit |
| 15/10/2026 | Joaquin Mazza (R1) | `9c3c2cc` | ssh y winbox de EDGE acotados a 10.0.0.0/24 y 10.255.255.0/24 (review R5) | EDGE | Revertir el commit y volver a `available-from=10.0.0.0/8` |
| 15/10/2026 | Joaquin Mazza (R1) | `253e0f3` | Notas en el script de EDGE: import sobre CHR limpio y desvío de cloud en 7.24 (review R5) | EDGE (solo script) | Revertir el commit |
| 15/10/2026 | Joaquin Mazza (R1/R2) | `e8ac4ae` | Memoria §5: hardening de F1 y desvíos de la política 1.3 | `docs/memoria.md` | Revertir el commit |
| 15/10/2026 | Joaquin Mazza (R2) | `a98d0f2` (`7d6e431`) | Notas en los scripts de ISP-1 e ISP-2: import sobre CHR limpio y desvío de cloud (review R5) | ISP-1, ISP-2 (solo script) | Revertir el commit |
| 15/10/2026 | Joaquin Mazza (R1) | `619164b` (`a27df8a`) | Captura de monitor sin permisos de escritura en EDGE | `capturas/f1/` | Revertir el commit |
| 15/10/2026 | Joaquin Mazza (R2) | `a98d0f2` (`768642c`) | ISP-1 e ISP-2 gestionados solo por consola (ssh/winbox a la /32 propia) y comentario de monitor sin SNMP (review R5) | ISP-1, ISP-2 | Revertir el commit y volver a `available-from=203.0.113.0/24` |
| 15/10/2026 | Joaquin Mazza (R1/R2) | `16af715` | Comentario de monitor sin SNMP en EDGE y memoria §5 actualizada para los ISP | EDGE, `docs/memoria.md` | Revertir el commit |
| 15/10/2026 | Tomas Costa (R5) | `68028ba` | Merge del PR #2 (F1 de EDGE) con merge commit, tras la review de R5 | `main` | `git revert -m 1 68028ba` |
| 16/10/2026 | Tomas Costa (R5) | `a5f8819` | Backup base F1 (`/export`) de EDGE, ISP-1 e ISP-2, tomado por R1/R2 el 15/10 | `backups/` | No aplica (solo respaldo) |
| 16/10/2026 | Tomas Costa (R5) | `752989e` | Memoria §6.2: registro de los backups base y procedimiento de restore | `docs/memoria.md` | Revertir el commit |

**Pendiente de `main`:** `9c2a899` (capturas post-review: monitor en ISP-2, servicios de EDGE e ISP-1) se pusheó a `f1-capturas` después del merge del PR #4 y no está en `main`. Se carga acá cuando entre por un PR nuevo.
