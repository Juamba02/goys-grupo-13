# Backlog — Laboratorio Failover Routing

**Grupo:** 13 · **Vencimiento final:** vie 23/10

> Grupo de 3 personas (ver `README.md`): **Persona A = R1+R2**, **Persona B = R3+R4**, **Persona C = R5**. Se mantienen las etiquetas `[R1]`...`[R5]` de la consigna en cada tarea para trazabilidad con la rúbrica; cada persona asume las tareas de los roles que le tocan.

## Leyenda de estado

- `[ ]` pendiente · `[~]` en curso · `[x]` hecho
- Cada tarea lleva **dueño** (rol): `[R1]` … `[R5]`.
- **"Hecho" = criterio de aceptación cumplido** (ver spec, sección 6). No "más o menos".

---

## Epic F0 — Diseño y gestión de cambio · *vence vie 2/10*

### IPAM / direccionamiento

- [x] [R1] Definir bloques reservados sin solapamiento (loopbacks, enlaces, LANs, enlaces ISP)
- [x] [R1] Completar tabla de enlaces, LANs, VRRP y router-ids en `docs/memoria.md`
- [ ] [R1] [R3] [R4] Revisar la tabla en grupo y confirmar que cada uno entiende su rango de IPs

### Corrección del diagrama (≥ 3 defectos)

- [x] [R1] Documentar los 5 defectos del diagrama original con corrección y justificación
- [ ] [R1] [R3] [R4] [R5] Revisar en grupo que las justificaciones sean defendibles oralmente (pensando en F5)

### Política de seguridad

- [x] [R5] Definir modelo de usuarios/privilegios (admin + monitor)
- [x] [R5] Definir lista de servicios a deshabilitar en los 7 routers
- [x] [R1] [R5] Definir mecanismo y alcance de claves de autenticación (OSPF MD5, BGP MD5, VRRP auth)
- [x] [R1] [R3] [R4] [R5] Acordar dónde se guardan las claves reales (gestor de contraseñas del grupo, fuera del repo) — en el gestor del grupo (confirmado por R1 en la review del #12)

### Política de operación (change log + backup)

- [x] [R5] Definir formato de change log (y convención de commits)
- [x] [R5] Definir política de backup (qué, cuándo, dónde, retención)
- [ ] [R5] Acordar quién corre el backup post-cambio en cada sesión de trabajo

### Repositorio git

- [x] [R5] Crear estructura (README + backlog.md + carpetas docs/configs/backups/runbooks/capturas)
- [x] [R1] Crear el repo remoto del grupo (fork del repo base o repo nuevo) y dar acceso al docente — `Juamba02/goys-grupo-13`, con acceso del docente (confirmado por R1 en la review del #12)
- [x] [R1] [R3] [R4] [R5] Hacer los commits iniciales (estructura + memoria F0), cada uno commiteando lo suyo — los commits de F0 los hizo R3/R4 (`ba572d2`…`b211f46`); desde F1 cada uno commitea lo suyo
- [x] [R1] Confirmar con el docente la aprobación de F0 antes de tocar un nodo en GNS3 — aprobada (confirmado por R1 en la review del #12)

---

## Epic F1 — Topología + hardening + backup · *vence vie 9/10*

### Despliegue (7 CHR + 2 switches + 2 hosts)

- [x] [R1] [R3] [R4] Levantar y cablear los 7 CHR + 2 switches + 2 hosts según el diagrama, cada uno sus equipos — proyecto GNS3 con los 11 nodos y 15 enlaces; EDGE, ISP-1 e ISP-2 (R1/R2) y CORE/DIST (R3/R4, #8) levantados; cableado confirmado por R5 con `/ip neighbor print`; captura `topologia-gns3-completa`
- [x] [R5] Configurar los hosts PC-USER y SRV (VPCS) y agregar sus IPs al IPAM — PC-USER 10.10.10.10/24 y SRV 10.10.20.10/24 con gateway VRRP, guardado con `save`; capturas `pc-user-ip` y `srv-ip`

### IPs de enlace + loopbacks

- [x] [R1] [R3] [R4] Configurar IPs de enlace + loopbacks según IPAM; verificar ping entre vecinos directos — EDGE, ISP-1 e ISP-2 (R1/R2) y CORE/DIST (R3/R4, #8); pings OK en los 7 (memoria §4.1)

### Snapshot BASE

- [x] [R5] Tomar y documentar snapshot BASE de los 7 routers — 7/7 en `backups/` y memoria §6.2 (EDGE/ISP del 15/10, CORE/DIST del 16/10)

### Hardening (los 7 routers)

- [x] [R1] [R3] [R4] Password admin + usuario `monitor` + servicios apagados en los routers de cada uno — EDGE, ISP-1 e ISP-2 (R1/R2) y CORE/DIST (R3/R4, #8); `available-from=` en los 7 scripts (#11)
- [x] [R5] Verificar que el hardening esté aplicado en los 7 routers — los 7 verificados en vivo el 16/10 (usuarios, servicios, descubrimiento, mac-server, mac-winbox, IPs y ping; CORE/DIST después de reiniciar); ver memoria §5 y `capturas/f1/`

### Backup inicial (`/export`)

- [x] [R5] Backup inicial (`/export`) de cada router versionado en `backups/` — 7/7, más el backup post-cambio de ISP-1/ISP-2 (`_puertos`, #9)

---

## Epic F2 — VRRP + OSPF · *vence vie 16/10*

### VRRP (2 grupos, load-sharing, auth)

- [x] [R4] configurar VRRP vrid 10 en DIST-1 (master) — priority 150, VIP 10.10.10.1 (#14)
- [x] [R4] configurar VRRP vrid 20 en DIST-2 (master) — priority 150, VIP 10.10.20.1 (#14)
- [x] [R4] activar auth simple en ambos grupos — `version=2`, una clave por grupo (#14; capturas `dist1/dist2-vrrp-auth`)
- [x] [R5] verificar master/backup con `/interface vrrp print` — verificado por R5 en su lab el 29/10 (`dist1-vrrp-r5`, `dist2-vrrp-r5`)

### OSPF área 0 (con MD5, incluido core–core)

- [x] [R1] [R3] [R4] Configurar OSPF en edge/core/dist, incluido el enlace core-core, con MD5 — EDGE (#13) y CORE/DIST (#14), `auth=md5 auth-id=1`
- [x] [R5] Verificar adyacencias FULL edge↔core↔dist — verificado por R5 en su lab el 29/10: CORE-1 y CORE-2 con 4 vecinos en Full cada uno (`core1-ospf-vecinos-r5`, `core2-ospf-vecinos-r5`)

### Verificación L3 (ping intra-LAN + gateway virtual)

- [x] [R5] Verificar ping intra-LAN y respuesta del gateway virtual VRRP en ambas LANs — verificado por R5 en su lab el 29/10 (`pc-user-ping-r5`, `srv-ping-r5`)

---

## Epic F3 — BGP + firewall · *vence vie 16/10*

### eBGP multi-homing (2 sesiones, TCP-MD5)

- [x] [R1] Configurar eBGP EDGE↔ISP-1 y EDGE↔ISP-2 con TCP-MD5 — #17, una clave por sesión
- [x] [R1] Verificar sesiones Established — #17 (`edge-bgp-sesiones`)

### Redistribución OSPF→BGP

- [x] [R1] Redistribuir OSPF→BGP para anunciar las LANs a los ISP — #17 (filtro `bgp-out-isp`)

### Salida a "Internet" (host → loopback ISP)

- [x] [R5] Verificar que el host alcanza el loopback del ISP — ping y trace desde PC-USER y SRV a 203.0.113.1 y 203.0.113.2, verificado por R5 el 29/10 (memoria §4.1)

### Firewall edge (filtro + plano de gestión)

- [x] [R1] Configurar filtro de entrada en EDGE — #17 (input, forward y antispoofing en `raw`)
- [x] [R1] [R3] [R4] Proteger el plano de gestión en los 7 routers — CORE/DIST (#16) y EDGE/ISP (#17)

---

## Epic F4 — Drills + monitoreo · *vence mar 20/10*

### Los 5 drills (runbook + post-mortem + tiempo)

- [x] [R5] Diseñar la plantilla de runbook (detección → respuesta → recuperación → post-mortem) — `runbooks/plantilla.md` y un runbook por drill (`drill-1` a `drill-5`), enlazados desde la memoria §4.2
- [x] [R1] [R3] [R4] [R5] Ejecutar cada drill y medir tiempo de convergencia, rotando quién opera — drills 3 (8 s) y 4 (29 s) operados por R1/R2 (#18); drills 1 (~2 s), 2 (~1 s) y 5 (2 pings) operados por R3/R4 (#20)

### Restore probado (política de backup 1.4)

- [ ] [R5] Restore probado de al menos un backup sobre un CHR limpio (ver memoria §6.2)

### Monitoreo (SNMP/chequeos)

- [x] [R5] Habilitar y documentar SNMP/chequeos de monitoreo — SNMPv3 authPriv en los 5 routers del grupo (bloque F4 de `configs/`), probado en el lab de R5 (memoria §6.3). Queda pendiente la consulta v3 con claves desde un NMS real: el cliente de RouterOS no completa v3

### Verificación de seguridad (clave incorrecta falla)

- [x] [R1] [R3] [R4] Ejecutar y documentar la prueba de seguridad: adyacencia/sesión con clave incorrecta debe fallar — BGP (#18, R1), OSPF y VRRP (#20, R3/R4)
- [ ] Intercambio Persona A ↔ Persona B (equivale a la rotación R1↔R2 de la consigna; A ya cubre R1+R2, así que el intercambio real es A revisando OSPF/VRRP y B revisando Edge-ISP, para que ambos puedan defender la parte del otro en F5)

---

## Epic F5 — Memoria + defensa · *vence vie 23/10*

### Mejoras detectadas en F4

- [ ] [R4] Evaluar bajar la prioridad VRRP del DIST cuando pierde los uplinks (netwatch o script): hallazgo de la prueba de clave incorrecta de OSPF (memoria §5), sugerido por R1/R2 en la review del #20. Documentarlo en §8 aunque no se aplique

### Memoria (plantilla completa)

- [ ] [R1] [R3] [R4] [R5] Completar todas las secciones de `docs/memoria.md`, cada uno su parte

### Backlog cerrado (todo en "hecho")

- [ ] [R1] [R3] [R4] [R5] Cerrar todas las tareas de este backlog en "hecho"

### Defensa oral (parte propia + ajena)

- [ ] [R1] [R3] [R4] [R5] Preparar defensa oral: cada integrante explica su parte y una parte ajena
