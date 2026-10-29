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
| 16/10/2026 | Tomas Costa (R5) | `b48e84f` | Merge de `main` en la rama del PR #7 (trae #6) antes de mergear, sin conflictos (review R1/R2) | rama `r5-f1-registro` | No aplica (merge de sincronización; se revierte junto con el merge del PR, `git revert -m 1 eb54f13`) |
| 16/10/2026 | Tomas Costa (R5) | `1574b05` | Fechas en hora local de los commits del 15/10 y rol (R3/R4) en las filas de F0 (review R1/R2) | `CHANGELOG.md`, `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `48e1b4c` | Memoria 6.2: restore sin IP (pegar el backup en la consola) y encabezado; 3.8 con el contenido de `configs/*.vpc` (review R1/R2) | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `6b9c9b5` | Capturas propias de IPs y ping al vecino en EDGE, ISP-1 e ISP-2 (log de login de EDGE tapado) | `capturas/f1/` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `559b7fe` | Memoria §5: la fila de IPs y ping usa la evidencia propia de R5 (review R1/R2) | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | sin commit (solo lab) | ISP-1 e ISP-2 quedaron en estado *saved* de VirtualBox al apagar la PC y GNS3 no los arrancaba; se descartó el estado guardado (`VBoxManage discardstate`) | lab de R5 (ISP-1, ISP-2) | No aplica: la config de RouterOS está en disco |
| 15/10/2026 | Juan Bautista Aramberri (R3/R4) | `6ac4ffe` | IPs de enlace, loopback y hardening base de CORE-1, CORE-2, DIST-1 y DIST-2 | CORE-1, CORE-2, DIST-1, DIST-2 | Revertir el commit y en el router `/ip address remove` de las direcciones agregadas |
| 15/10/2026 | Juan Bautista Aramberri (R3/R4) | `a4f8ac8` | Memoria: configuración de CORE/DIST (pendiente de verificar en GNS3) | `docs/memoria.md` | Revertir el commit |
| 15/10/2026 | Juan Bautista Aramberri (R3/R4) | `4c04972` | Backlog: avance de R3/R4 en F1 (se saca después en `35587af`) | `backlog.md` | Revertir el commit |
| 15/10/2026 | Juan Bautista Aramberri (R3/R4) | `e0744f6` | Merge de `main` en la rama del PR #8 | rama `f1/core-distribucion` | No aplica (merge de sincronización; se revierte junto con el merge del PR, `git revert -m 1 2362d2c`) |
| 15/10/2026 | Juan Bautista Aramberri (R3/R4) | `3ad25d4` | Scripts de CORE/DIST con la misma estructura que EDGE/ISP: claves por consola y servicios con `find` para 7.24 (review R1/R2) | CORE-1, CORE-2, DIST-1, DIST-2 (solo script) | Revertir el commit |
| 15/10/2026 | Juan Bautista Aramberri (R3/R4) | `082152d` | Memoria §3: configs de CORE/DIST actualizadas | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Juan Bautista Aramberri (R3/R4) | `20ab13a` | Usuario `monitor` al final de los scripts de CORE/DIST (al pegar, RouterOS pedía la clave y se comía la línea siguiente) | CORE-1, CORE-2, DIST-1, DIST-2 (solo script) | Revertir el commit |
| 16/10/2026 | Juan Bautista Aramberri (R3/R4) | sin commit (solo router) | En CORE-1 se perdió una línea al pegar el script y se aplicó de nuevo el bloque `/ip service` | CORE-1 | Restaurar el backup `CORE-1_20261016_base.rsc` |
| 16/10/2026 | Joaquin Mazza (R2) | `50ff3c1` | `ether2`–`ether4` sin uso apagadas en ISP-1 e ISP-2 (recomendación de R5) | ISP-1, ISP-2 | `/interface ethernet enable ether2,ether3,ether4` |
| 16/10/2026 | Juan Bautista Aramberri (R3/R4) | `5916e9f` | Capturas de IPs, servicios, monitor y pings de CORE/DIST | `capturas/f1/` | Revertir el commit |
| 16/10/2026 | Juan Bautista Aramberri (R3/R4) | `314143e` | Backlog: F1 de R3/R4 en hecho (se saca después en `35587af`); memoria §5 con la seguridad de CORE/DIST | `backlog.md`, `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Juan Bautista Aramberri (R3/R4) | `9a35806` | Captura de ping de EDGE a CORE-1 y CORE-2 con la topología completa | `capturas/f1/` | Revertir el commit |
| 16/10/2026 | Joaquin Mazza (R2) | `13f1c41` | Capturas de `ether2`–`ether4` deshabilitadas en ISP-1 e ISP-2 (review R5) | `capturas/f1/` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `8be9a7c` | Merge del PR #9 con merge commit, tras la review de R5 | `main` | `git revert -m 1 8be9a7c` |
| 16/10/2026 | Joaquin Mazza (R1/R2) | `fbe5bca` | Memoria §2 (topología en GNS3) y §4.1 (pruebas de conectividad de EDGE e ISP) | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Joaquin Mazza (R1/R2) | `6a69d78` | Memoria §3.1–3.3: configuración de ISP-1, ISP-2 y EDGE | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Juan Bautista Aramberri (R3/R4) | `35587af` | Se saca `backlog.md` del PR #8 porque lo lleva R5 (review R5) | `backlog.md` | Revertir el commit |
| 16/10/2026 | Juan Bautista Aramberri (R3/R4) | `96f005d` | Memoria §3: referencia a `configs/` y resumen por router; nota inicial actualizada (review R1/R2) | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Juan Bautista Aramberri (R3/R4) | `b182efc` | `.gitignore`: se ignora `CLAUDE.md` (contexto local) | `.gitignore` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `2362d2c` | Merge del PR #8 con merge commit, tras las reviews de R1/R2 y R5 | `main` | `git revert -m 1 2362d2c` |
| 16/10/2026 | Joaquin Mazza (R1/R2) | `22c271d` | Merge de `main` en la rama del PR #10 | rama `f1-memoria-edge-isp` | No aplica (merge de sincronización; se revierte junto con el merge del PR, `git revert -m 1 0f94199`) |
| 16/10/2026 | Juan Bautista Aramberri (R3/R4) | `45e7813` | `available-from=` en lugar de `address=` (deprecado en 7.24) en `ssh`/`winbox` de los 7 scripts (review R5) | Los 7 routers (solo script) | Revertir el commit |
| 16/10/2026 | Joaquin Mazza (R1/R2) | `832ea9f` | Merge del PR #11 con merge commit | `main` | `git revert -m 1 832ea9f` |
| 16/10/2026 | Joaquin Mazza (R1/R2) | `c42a112` | Memoria §3.1–3.3 con el mismo formato que CORE/DIST, lista `CUSTOMER` y `ether2`–`ether4` (review R3/R4) | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Juan Bautista Aramberri (R3/R4) | `0f94199` | Merge del PR #10 con merge commit | `main` | `git revert -m 1 0f94199` |
| 16/10/2026 | Tomas Costa (R5) | sin commit (solo lab) | `lab-CORE-1` quedó en estado *aborted* de VirtualBox y GNS3 no lo arrancaba; se arrancó y apagó con `VBoxManage` para dejarlo en `poweroff` | lab de R5 (CORE-1) | No aplica |
| 16/10/2026 | Tomas Costa (R5) | sin commit (solo lab) | CORE-1, CORE-2, DIST-1 y DIST-2 cargados en el lab de R5 pegando `configs/<ROUTER>.rsc` por consola, y reiniciados para la verificación | lab de R5 (CORE/DIST) | `/system reset-configuration no-defaults=yes` |
| 16/10/2026 | Tomas Costa (R5) | `3f8bd42` | Backups BASE de CORE-1/2 y DIST-1/2 (tomados por R3/R4) y `_puertos` de ISP-1/ISP-2 (tomados por R2) | `backups/` | No aplica (solo respaldo) |
| 16/10/2026 | Tomas Costa (R5) | `e73d3ff` | Memoria §6.2: registro de los 6 backups nuevos y la hora de cada encabezado | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `38a281c` | Capturas de la verificación de R5 en CORE/DIST y topología con los 11 nodos encendidos | `capturas/f1/` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `1a53199` | Memoria: verificación de hardening de los 7 routers (§5), topología completa (§2), pings de R5 (§4.1) y checklist (§10) | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `1a48996` | Backlog: F1 completo | `backlog.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `983dcfb` | Change log: registro de los PR #8 a #11 y del cierre de F1 de R5 | `CHANGELOG.md`, `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `5133e61` | Capturas de los servicios de DIST-1 justo después de reiniciar y pasados 12 minutos | `capturas/f1/` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `ead42d8` | Memoria §5: `dhcpclient` dinámico transitorio en DIST-1 después del reinicio | `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `fd744f6` | Change log: registro de las capturas de DIST-1 y la corrección de la §5 | `CHANGELOG.md`, `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `363f22a` | Rollback de los merges de sincronización (`b48e84f`, `e0744f6`, `22c271d`): se revierten junto con el merge de su PR (review R1/R2) | `CHANGELOG.md`, `docs/memoria.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `186e10e` | Backlog: F0 con repo remoto, commits iniciales, aprobación del docente y claves en el gestor, confirmados por R1 (review R1/R2) | `backlog.md` | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | `dd21fa0` | Merge del PR #12 (cierre de F1 de R5) con merge commit | `main` | `git revert -m 1 dd21fa0` |
| 22/10/2026 | Joaquin Mazza (R1) | `3e655a9` | OSPF área 0 con MD5 en EDGE hacia CORE-1 y CORE-2 (instancia `ospf-v2`, plantilla `ospf-transito`) | EDGE | `/routing ospf interface-template set [ find comment="ospf-transito" ] disabled=yes` y revertir el commit |
| 22/10/2026 | Joaquin Mazza (R1) | sin commit (solo router) | Clave MD5 de OSPF cargada por consola en la plantilla `ospf-transito` | EDGE | Deshabilitar la plantilla |
| 22/10/2026 | Joaquin Mazza (R1) | `731d907` | Memoria §3.3 (OSPF de EDGE) y §4.1 (adyacencias y ping entre loopbacks) | `docs/memoria.md` | Revertir el commit |
| 22/10/2026 | Joaquin Mazza (R1) | `970888c` | Captura de vecinos y rutas OSPF de EDGE | `capturas/f2/` | Revertir el commit |
| 22/10/2026 | Juan Bautista Aramberri (R3) | `3a24ff7` | OSPF área 0 con MD5 en CORE-1 y CORE-2 | CORE-1, CORE-2 | `/routing ospf interface-template set [ find comment="ospf-transito" ] disabled=yes` y revertir el commit |
| 22/10/2026 | Juan Bautista Aramberri (R4) | `85d3c20` | OSPF área 0 con MD5 y VRRP vrid 10/20 con auth simple en DIST-1 y DIST-2 | DIST-1, DIST-2 | `/interface vrrp disable [ find ]`, deshabilitar la plantilla de tránsito y revertir el commit |
| 22/10/2026 | Juan Bautista Aramberri (R3/R4) | sin commit (solo router) | Clave MD5 de OSPF y claves de VRRP (una por grupo) cargadas por consola | CORE-1, CORE-2, DIST-1, DIST-2 | Deshabilitar la plantilla de tránsito y los grupos VRRP |
| 22/10/2026 | Juan Bautista Aramberri (R3/R4) | `86f58ab` | Memoria §3: OSPF y VRRP de F2 en CORE/DIST | `docs/memoria.md` | Revertir el commit |
| 22/10/2026 | Juan Bautista Aramberri (R3/R4) | `6084671` | Capturas de OSPF en Full, VRRP master/backup, MD5 y pings desde los hosts | `capturas/f2/` | Revertir el commit |
| 23/10/2026 | Joaquin Mazza (R1) | `6742ec3` | Capturas de MD5 de OSPF en EDGE y CORE-1 y ping entre loopbacks (review R5) | `capturas/f2/`, `docs/memoria.md` | Revertir el commit |
| 23/10/2026 | Joaquin Mazza (R1/R2) | `d1b54d2` | Merge del PR #13 con merge commit | `main` | `git revert -m 1 d1b54d2` |
| 23/10/2026 | Juan Bautista Aramberri (R3/R4) | `89c3252` | Merge de `main` en la rama del PR #14 | rama `f2/core-dist-ospf-vrrp` | No aplica (merge de sincronización; se revierte junto con el merge del PR, `git revert -m 1 f007fac`) |
| 23/10/2026 | Juan Bautista Aramberri (R3/R4) | `1d9e5ea` | Memoria §4.1: filas de F2 de CORE/DIST (adyacencias, VRRP, gateway virtual e intra-LAN) (review R1/R2) | `docs/memoria.md` | Revertir el commit |
| 23/10/2026 | Juan Bautista Aramberri (R3/R4) | `24ffb6a` | Memoria §3: "Resumen de F1 y F2" y el mismo rótulo de F2 que EDGE (review R5) | `docs/memoria.md` | Revertir el commit |
| 23/10/2026 | Juan Bautista Aramberri (R3/R4) | `6c89f53` | Capturas de CORE-1 con los 4 vecinos OSPF, rutas de EDGE y auth de VRRP en los DIST (review R1/R2) | `capturas/f2/` | Revertir el commit |
| 23/10/2026 | Juan Bautista Aramberri (R3/R4) | `cb612c7` | Memoria §4.1 con la topología completa y §5 con OSPF MD5 y VRRP auth (review R1/R2) | `docs/memoria.md` | Revertir el commit |
| 23/10/2026 | Joaquin Mazza (R1/R2) | `f007fac` | Merge del PR #14 con merge commit | `main` | `git revert -m 1 f007fac` |
| 23/10/2026 | Juan Bautista Aramberri (R4) | `63dce5c` | Plano de gestión de DIST-1 y DIST-2 con firewall de input, VRRP aceptado solo desde las LANs | DIST-1, DIST-2 | `/ip firewall filter disable [ find ]` y revertir el commit |
| 23/10/2026 | Juan Bautista Aramberri (R3) | `cfce954` | Plano de gestión de CORE-1 y CORE-2 con firewall de input | CORE-1, CORE-2 | `/ip firewall filter disable [ find ]` y revertir el commit |
| 23/10/2026 | Juan Bautista Aramberri (R3/R4) | `12ec9e3` | Memoria §3, §4.1 y §5: plano de gestión de CORE/DIST | `docs/memoria.md` | Revertir el commit |
| 23/10/2026 | Juan Bautista Aramberri (R3/R4) | `503e5af` | Capturas del firewall de input en CORE-1 y DIST-1 y gestión bloqueada desde PC-USER | `capturas/f3/` | Revertir el commit |
| 23/10/2026 | Joaquin Mazza (R2) | `9a37edc` | eBGP con TCP-MD5 y `default-originate` en ISP-1 e ISP-2 | ISP-1, ISP-2 | `/routing bgp connection disable [ find name=to-EDGE ]` y revertir el commit |
| 23/10/2026 | Joaquin Mazza (R1) | `3b1d9b2` | eBGP multi-homing con TCP-MD5 en EDGE, redistribución de las LANs y default por OSPF | EDGE | Deshabilitar `to-ISP-1` / `to-ISP-2`, `originate-default=never` y revertir el commit |
| 23/10/2026 | Joaquin Mazza (R1/R2) | sin commit (solo router) | Claves TCP-MD5 cargadas por consola en las dos sesiones | EDGE, ISP-1, ISP-2 | Deshabilitar las sesiones |
| 23/10/2026 | Joaquin Mazza (R1/R2) | `358a0bf` | Memoria §3, §4.1 y §5 con BGP y sus capturas | `docs/memoria.md`, `capturas/f3/` | Revertir el commit |
| 23/10/2026 | Joaquin Mazza (R1) | `fdb4cc3` | Firewall del EDGE: filtro de entrada, plano de gestión y antispoofing | EDGE | `/ip firewall filter disable [ find ]` y `/ip firewall raw disable [ find ]`; revertir el commit |
| 23/10/2026 | Joaquin Mazza (R2) | `a3e0782` | Plano de gestión de ISP-1 e ISP-2 con firewall de input | ISP-1, ISP-2 | `/ip firewall filter disable [ find ]` y revertir el commit |
| 23/10/2026 | Joaquin Mazza (R1/R2) | `610e417` | Memoria §3, §4.1 y §5 con el firewall y sus capturas | `docs/memoria.md`, `capturas/f3/` | Revertir el commit |
| 23/10/2026 | Joaquin Mazza (R1/R2) | `a93d09e` | Usuario `monitor` al final de los scripts de EDGE, ISP-1 e ISP-2 (igual que CORE/DIST) | EDGE, ISP-1, ISP-2 (solo script) | Revertir el commit |
| 28/10/2026 | Joaquin Mazza (R2) | `3c48e29` | Timers de BGP en 9s y destino de prueba 198.51.100.1 en ISP-1 e ISP-2 | ISP-1, ISP-2 | `hold-time=3m keepalive-time=1m`, borrar la IP y revertir el commit |
| 28/10/2026 | Joaquin Mazza (R1) | `4424874` | Hold-time de BGP en 9s en EDGE (post-mortem del drill 3) | EDGE | `hold-time=3m keepalive-time=1m` y revertir el commit |
| 28/10/2026 | Joaquin Mazza (R1) | sin commit (solo router) | Drill 4: estáticas con `check-gateway` agregadas y borradas al terminar | EDGE | Ya borradas |
| 28/10/2026 | Joaquin Mazza (R1/R2) | `c38b27e` | Memoria §3 y §4.2 con los drills 3 y 4 y sus capturas | `docs/memoria.md`, `capturas/f4/` | Revertir el commit |
| 28/10/2026 | Joaquin Mazza (R1/R2) | `dd5d692` | Memoria §5 con la prueba de clave TCP-MD5 incorrecta y sus capturas | `docs/memoria.md`, `capturas/f4/` | Revertir el commit |
| 28/10/2026 | Joaquin Mazza (R1/R2) | `e2f7e3e` | Merge del PR #16 con merge commit | `main` | `git revert -m 1 e2f7e3e` |
| 28/10/2026 | Tomas Costa (R5) | `62aa60a` | Backups post-cambio de F2, F3 y F4 de los 7 routers (tomados por R1/R2 y R3/R4) | `backups/` | No aplica (solo respaldo) |
| 28/10/2026 | Tomas Costa (R5) | `97d88dd` | Memoria §6.2: registro de los 15 backups nuevos, hora de cada encabezado y revisión de R5 | `docs/memoria.md` | Revertir el commit |
| 28/10/2026 | Tomas Costa (R5) | `d2b4066` | Backlog: estado de F2, F3 y F4 | `backlog.md` | Revertir el commit |
| 28/10/2026 | Joaquin Mazza (R2) | `87f26c9` | ISP-1 e ISP-2 rechazan UDP con port-unreachable en vez de descartarlo, para que el `trace` de los hosts llegue al último salto (review R5) | ISP-1, ISP-2 | `/ip firewall filter remove [ find comment="input: UDP rechazado (traceroute)" ]` y revertir el commit |
| 28/10/2026 | Joaquin Mazza (R1/R2) | `9602c0b` | `198.51.100.1/32` en el IPAM de la memoria 1.2 (review R5) | `docs/memoria.md` | Revertir el commit |
| 28/10/2026 | Joaquin Mazza (R1/R2) | `3c5bddb` | Merge de `f3-bgp-edge-isp` en la rama del PR #18 (trae `87f26c9`) | rama `f4-drills-edge-isp` | No aplica (merge de sincronización; se revierte junto con el merge del PR, `git revert -m 1 dd52628`) |
| 28/10/2026 | Tomas Costa (R5) | `9848a0f` | Merge del PR #17 con merge commit | `main` | `git revert -m 1 9848a0f` |
| 28/10/2026 | Tomas Costa (R5) | `dd52628` | Merge del PR #18 con merge commit | `main` | `git revert -m 1 dd52628` |
| 28/10/2026 | Tomas Costa (R5) | `d443c55` | Backups de ISP-1 e ISP-2 con el rechazo de UDP para el traceroute (tomados por R2 después de `87f26c9`) y registro en §6.2 | `backups/`, `docs/memoria.md` | No aplica (solo respaldo); revertir el commit |
| 28/10/2026 | Juan Bautista Aramberri (R3/R4) | `e35d475` | Capturas de los drills 1, 2 y 5 y de la prueba de clave incorrecta en OSPF y VRRP | `capturas/f4/` | Revertir el commit |
| 28/10/2026 | Juan Bautista Aramberri (R3/R4) | `3782ec7` | Memoria §4.2 (drills 1, 2 y 5) y §5 (prueba de clave incorrecta de OSPF y VRRP) | `docs/memoria.md` | Revertir el commit |
| 28/10/2026 | Juan Bautista Aramberri (R3/R4) | sin commit (solo router) | Drills 1, 2 y 5: interfaces de DIST-1, CORE-1 y DIST-2 apagadas y vueltas a encender | DIST-1, CORE-1, DIST-2 | Ya restauradas (`/interface ethernet enable`) |
| 28/10/2026 | Juan Bautista Aramberri (R3/R4) | sin commit (solo router) | Prueba de seguridad: clave incorrecta de OSPF (`ospf-transito`) y de VRRP (vrrp10) cargadas por consola en DIST-2 y restauradas con las del gestor | DIST-2 | Ya restauradas: volver a cargar las claves del gestor |
| 28/10/2026 | Tomas Costa (R5) | `2c76ff7` | Backlog: F3 de EDGE/ISP hecho y drills 3 y 4 tras el merge de los PR #17 y #18 | `backlog.md` | Revertir el commit |
| 28/10/2026 | Juan Bautista Aramberri (R3/R4) | `2df7642` | Merge de `main` en la rama del PR #20 (resuelve el conflicto de la §5 con el #18) | rama `f4/core-dist-drills` | No aplica (merge de sincronización; se revierte junto con el merge del PR, `git revert -m 1 899e903`) |
| 28/10/2026 | Juan Bautista Aramberri (R3/R4) | `9453121` | Capturas del ping de los drills 1, 2 y 5 y de la ruta de DIST-1 con el enlace a CORE-1 cortado (review R5) | `capturas/f4/` | Revertir el commit |
| 28/10/2026 | Juan Bautista Aramberri (R3/R4) | `78e6bb6` | Memoria §4.2: tiempos de los drills 1, 2 y 5 con las capturas del ping y del trace (review R5) | `docs/memoria.md` | Revertir el commit |
| 28/10/2026 | Tomas Costa (R5) | `bff8a63` | Merge del PR #19 con merge commit | `main` | `git revert -m 1 bff8a63` |
| 28/10/2026 | Tomas Costa (R5) | `899e903` | Merge del PR #20 con merge commit | `main` | `git revert -m 1 899e903` |
