# Change log

Formato definido en `docs/memoria.md` sección 1.4. Cada fila corresponde a un commit (o grupo de commits de un mismo cambio lógico) del historial de git — no se completa "a mano" sin relación con los commits reales.

Los PR #3, #4 y #6 se mergearon con *squash*: sus commits originales no existen en `main`. En esas filas la columna Commit lleva el hash del squash en `main` y, entre paréntesis, el commit original de la rama (`f1-isp` / `f1-capturas` / `f1-capturas-review`) para trazabilidad. Los cambios hechos solo en el router (sin commit) se registran igual, marcados como tales.

| Fecha | Autor (Rol) | Commit | Descripción | Sistemas afectados | Plan de rollback |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 01/10/2026 | Juan Bautista Aramberri (R3/R4) | `ba572d2` | Estructura inicial del repo (README, carpetas, .gitignore) | repo | Revertir el commit |
| 01/10/2026 | Juan Bautista Aramberri (R3/R4) | `ac53f5a` | Memoria F0: corrección del diagrama, IPAM, políticas de seguridad y operación | `docs/memoria.md` | Revertir el commit |
| 01/10/2026 | Juan Bautista Aramberri (R3/R4) | `2ffe3bb` | Formato de change log y política de backup | `CHANGELOG.md` | Revertir el commit |
| 01/10/2026 | Juan Bautista Aramberri (R3/R4) | `4f9212f` | Backlog con tareas F0 a F5 | `backlog.md` | Revertir el commit |
| 01/10/2026 | Juan Bautista Aramberri (R3/R4) | `d73cfca`, `b211f46` | README: resumen del lab, reparto de roles y correcciones | `README.md` | Revertir los commits |
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
| 15/10/2026 | Tomas Costa (R5) | `a5f8819` | Backup base F1 (`/export`) de EDGE, ISP-1 e ISP-2, tomado por R1/R2 el 15/10 | `backups/` | No aplica (solo respaldo) |
| 15/10/2026 | Tomas Costa (R5) | `752989e` | Memoria §6.2: registro de los backups base y procedimiento de restore | `docs/memoria.md` | Revertir el commit |
| 15/10/2026 | Tomas Costa (R5) | `191de4a` | Change log de F0 y F1 en `CHANGELOG.md` y memoria §6.1; referencia al formato corregida (sección 1.4) | `CHANGELOG.md`, `docs/memoria.md` | Revertir el commit |
| 15/10/2026 | Tomas Costa (R5) | `590dc01` | Backlog: estado de F1 tras el merge de EDGE, ISP-1 e ISP-2; tareas nuevas de hosts y restore probado | `backlog.md` | Revertir el commit |
| 15/10/2026 | Tomas Costa (R5) | `ec7ba15` | Diagrama: la referencia a la tabla de IPs apunta a la memoria 1.2 | `docs/diagramas/topologia.md` | Revertir el commit |
| 15/10/2026 | Tomas Costa (R5) | `3398fa9` | Hosts PC-USER (10.10.10.10/24) y SRV (10.10.20.10/24) en el IPAM y config VPCS; `10.10.254.0/24` queda sin uso | `configs/*.vpc`, `docs/memoria.md` | Revertir el commit y en VPCS `clear ip` |
| 15/10/2026 | Tomas Costa (R5) | `39d680f` | Hashes de los commits de R5 actualizados tras reescribir la rama (se quitó la atribución automática de los mensajes) | `CHANGELOG.md`, `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Joaquin Mazza (R1/R2) | `d04a437` (`8547104`) | Capturas post-review: monitor en ISP-2, servicios de EDGE (reemplaza la de 10.0.0.0/8) y de ISP-1 | `capturas/f1/` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `e75babe` | Capturas de la verificación de hardening de R5: servicios de ISP-2, descubrimiento/mac-server/mac-winbox en ISP-1 e ISP-2, mac-winbox en EDGE | `capturas/f1/` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `107f0ce` | Memoria §5: verificación de hardening de R5 en EDGE, ISP-1 e ISP-2 y recomendación de apagar `ether2-4` en los ISP | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `fabf518` | Backlog: verificación de hardening hecha en EDGE, ISP-1 e ISP-2 (falta CORE/DIST) | `backlog.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | sin commit (solo lab) | Hosts PC-USER (10.10.10.10/24) y SRV (10.10.20.10/24) configurados en VPCS con gateway VRRP y `save` | PC-USER, SRV | En VPCS: `clear ip` y `save` |
| 16/10/2026 | Tomas Costa (R5) | `ac3a6d6` | Capturas `show ip` de PC-USER y SRV | `capturas/f1/` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `258c692` | Backlog: hosts hechos; restore probado movido a F4. Memoria 3.8 con la referencia a las capturas | `backlog.md`, `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `511ed47` | Change log: registro de la configuración de los hosts | `CHANGELOG.md`, `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `b48e84f` | Merge de `main` en la rama del PR #7 (trae #6) antes de mergear, sin conflictos (review R1/R2) | rama `r5-f1-registro` | `git revert -m 1 b48e84f` |
| 16/10/2026 | Tomas Costa (R5) | `1574b05` | Fechas en hora local de los commits del 15/10 y rol (R3/R4) en las filas de F0 (review R1/R2) | `CHANGELOG.md`, `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `48e1b4c` | Memoria 6.2: restore sin IP (pegar el backup en la consola) y encabezado; 3.8 con el contenido de `configs/*.vpc` (review R1/R2) | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `6b9c9b5` | Capturas propias de IPs y ping al vecino en EDGE, ISP-1 e ISP-2 (log de login de EDGE tapado) | `capturas/f1/` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `559b7fe` | Memoria §5: la fila de IPs y ping usa la evidencia propia de R5 (review R1/R2) | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | sin commit (solo lab) | ISP-1 e ISP-2 quedaron en estado *saved* de VirtualBox al apagar la PC y GNS3 no los arrancaba; se descartó el estado guardado (`VBoxManage discardstate`) | lab de R5 (ISP-1, ISP-2) | No aplica: la config de RouterOS está en disco |

