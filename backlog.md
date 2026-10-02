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
- [ ] [R1] [R3] [R4] [R5] Acordar dónde se guardan las claves reales (gestor de contraseñas del grupo, fuera del repo)

### Política de operación (change log + backup)

- [x] [R5] Definir formato de change log (y convención de commits)
- [x] [R5] Definir política de backup (qué, cuándo, dónde, retención)
- [ ] [R5] Acordar quién corre el backup post-cambio en cada sesión de trabajo

### Repositorio git

- [x] [R5] Crear estructura (README + backlog.md + carpetas docs/configs/backups/runbooks/capturas)
- [ ] [R1] Crear el repo remoto del grupo (fork del repo base o repo nuevo) y dar acceso al docente
- [ ] [R1] [R3] [R4] [R5] Hacer los commits iniciales (estructura + memoria F0), cada uno commiteando lo suyo
- [ ] [R1] Confirmar con el docente la aprobación de F0 antes de tocar un nodo en GNS3

---

## Epic F1 — Topología + hardening + backup · *vence vie 9/10*

### Despliegue (7 CHR + 2 switches + 2 hosts)

- [ ] [R1] [R3] [R4] Levantar y cablear los 7 CHR + 2 switches + 2 hosts según el diagrama, cada uno sus equipos

### IPs de enlace + loopbacks

- [ ] [R1] [R3] [R4] Configurar IPs de enlace + loopbacks según IPAM; verificar ping entre vecinos directos

### Snapshot BASE

- [ ] [R5] Tomar y documentar snapshot BASE de los 7 routers

### Hardening (los 7 routers)

- [ ] [R1] [R3] [R4] Password admin + usuario `monitor` + servicios apagados en los routers de cada uno
- [ ] [R5] Verificar que el hardening esté aplicado en los 7 routers

### Backup inicial (`/export`)

- [ ] [R5] Backup inicial (`/export`) de cada router versionado en `backups/`

---

## Epic F2 — VRRP + OSPF · *vence vie 16/10*

### VRRP (2 grupos, load-sharing, auth)

- [ ] [R4] configurar VRRP vrid 10 en DIST-1 (master)
- [ ] [R4] configurar VRRP vrid 20 en DIST-2 (master)
- [ ] [R4] activar auth simple en ambos grupos
- [ ] [R5] verificar master/backup con `/interface vrrp print`

### OSPF área 0 (con MD5, incluido core–core)

- [ ] [R1] [R3] [R4] Configurar OSPF en edge/core/dist, incluido el enlace core-core, con MD5
- [ ] [R5] Verificar adyacencias FULL edge↔core↔dist

### Verificación L3 (ping intra-LAN + gateway virtual)

- [ ] [R5] Verificar ping intra-LAN y respuesta del gateway virtual VRRP en ambas LANs

---

## Epic F3 — BGP + firewall · *vence vie 16/10*

### eBGP multi-homing (2 sesiones, TCP-MD5)

- [ ] [R1] Configurar eBGP EDGE↔ISP-1 y EDGE↔ISP-2 con TCP-MD5
- [ ] [R1] Verificar sesiones Established

### Redistribución OSPF→BGP

- [ ] [R1] Redistribuir OSPF→BGP para anunciar las LANs a los ISP

### Salida a "Internet" (host → loopback ISP)

- [ ] [R5] Verificar que el host alcanza el loopback del ISP

### Firewall edge (filtro + plano de gestión)

- [ ] [R1] Configurar filtro de entrada en EDGE
- [ ] [R1] [R3] [R4] Proteger el plano de gestión en los 7 routers

---

## Epic F4 — Drills + monitoreo · *vence mar 20/10*

### Los 5 drills (runbook + post-mortem + tiempo)

- [ ] [R5] Diseñar la plantilla de runbook (detección → respuesta → recuperación → post-mortem)
- [ ] [R1] [R3] [R4] [R5] Ejecutar cada drill y medir tiempo de convergencia, rotando quién opera

### Monitoreo (SNMP/chequeos)

- [ ] [R5] Habilitar y documentar SNMP/chequeos de monitoreo

### Verificación de seguridad (clave incorrecta falla)

- [ ] [R1] [R3] [R4] Ejecutar y documentar la prueba de seguridad: adyacencia/sesión con clave incorrecta debe fallar
- [ ] Intercambio Persona A ↔ Persona B (equivale a la rotación R1↔R2 de la consigna; A ya cubre R1+R2, así que el intercambio real es A revisando OSPF/VRRP y B revisando Edge-ISP, para que ambos puedan defender la parte del otro en F5)

---

## Epic F5 — Memoria + defensa · *vence vie 23/10*

### Memoria (plantilla completa)

- [ ] [R1] [R3] [R4] [R5] Completar todas las secciones de `docs/memoria.md`, cada uno su parte

### Backlog cerrado (todo en "hecho")

- [ ] [R1] [R3] [R4] [R5] Cerrar todas las tareas de este backlog en "hecho"

### Defensa oral (parte propia + ajena)

- [ ] [R1] [R3] [R4] [R5] Preparar defensa oral: cada integrante explica su parte y una parte ajena
