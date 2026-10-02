# Memoria del Laboratorio — Failover Routing

**Grupo:** 13 **Materia:** Gestión Operativa y Seguridad en Redes (GOYS) **Fecha de entrega:** viernes 23/10/2026

## Integrantes y roles

> Grupo de **3 personas** repartiendo los 5 roles de la consigna: Persona A cubre R1+R2, Persona B cubre R3+R4, Persona C cubre R5 (ver justificación de la repartición en `README.md`).

| Integrante | Rol |
| :---- | :---- |
| Joaquin Mazza | R1 — Líder / Edge-WAN |
| Joaquin Mazza | R2 — Proveedores |
| Juan Bautista Aramberri | R3 — Core |
| Juan Bautista Aramberri | R4 — Distribución |
| Tomas Costa | R5 — Hosts / QA / Operación |

---

## 1. Diseño (F0)

### 1.1 Corrección del diagrama

Del diagrama "Enterprise Network Design (Cisco)" visto en clase, se corrigen 5 defectos (la consigna pide documentar un mínimo de 3; se incluyen los 5 por completitud):

| # | Defecto detectado | Corrección aplicada | Justificación |
| :---: | :---- | :---- | :---- |
| 1 | Firewall perimetral sin par de alta disponibilidad (SPOF) | El perímetro lo cumple EDGE, multihomed a dos proveedores (ISP-1, ISP-2) por dos sesiones eBGP independientes; se documenta que en producción ese firewall debería ir en par activo/pasivo con sincronización de estado | Eliminar el SPOF del perímetro es prioridad máxima de disponibilidad: por ahí pasa el 100% del tráfico hacia/desde Internet, perderlo es una caída total, no parcial |
| 2 | Subredes solapadas entre sitios | Plan de direccionamiento único y documentado (sección 1.2): cada enlace, LAN y loopback pertenece a un bloque reservado que no se repite en ningún otro punto | El solapamiento rompe el ruteo (rutas ambiguas, resúmenes incorrectos) y es una de las causas más comunes de incidentes reales; resolverlo en F0 evita rehacer direccionamiento después |
| 3 | Sin enlace core-core | Se agrega el enlace CORE-1 ↔ CORE-2, formando malla completa entre core y distribución | El core es la capa de tránsito de toda la organización; sin enlace directo entre sus dos nodos, la falla de un core puede particionar la red en vez de converger por un camino alternativo en milisegundos |
| 4 | HSRP en el core (diseño "collapsed") | El FHRP (VRRP, no HSRP) se mueve a distribución (DIST-1/DIST-2); el core queda como tránsito puro, solo OSPF | Mezclar core y distribución limita la escalabilidad y complica el troubleshooting; separar las capas respeta el modelo jerárquico y permite que cada una se opere de forma independiente |
| 5 | Route Reflector de iBGP mal ubicado | Se usa eBGP puro en el borde (EDGE↔ISP-1, EDGE↔ISP-2), sin Route Reflector; con un único router EDGE no hace falta distribuir rutas iBGP | Agregar un RR donde no hace falta introduce un componente adicional a asegurar y operar sin beneficio real |

### 1.2 Plan de direccionamiento (IPAM)

Principios: espacio privado RFC 1918 (`10.0.0.0/8`) para toda la infraestructura interna; rangos de documentación IANA (RFC 5737: `192.0.2.0/24` y `203.0.113.0/24`) para simular direccionamiento "público" en los enlaces y loopbacks de los ISP, sin usar espacio público real. Cada bloque tiene un propósito único — **cero solapamiento** (verificado programáticamente, ver nota al final de la sección).

| Enlace / Red | Subred | Dispositivo A (IP/iface) | Dispositivo B (IP/iface) |
| :---- | :---: | :---- | :---- |
| ISP-1 ↔ EDGE | 192.0.2.0/30 | ISP-1: 192.0.2.1 | EDGE: 192.0.2.2 |
| ISP-2 ↔ EDGE | 192.0.2.4/30 | ISP-2: 192.0.2.5 | EDGE: 192.0.2.6 |
| EDGE ↔ CORE-1 | 10.0.0.0/30 | EDGE: 10.0.0.1 | CORE-1: 10.0.0.2 |
| EDGE ↔ CORE-2 | 10.0.0.4/30 | EDGE: 10.0.0.5 | CORE-2: 10.0.0.6 |
| CORE-1 ↔ CORE-2 (core-core) | 10.0.0.8/30 | CORE-1: 10.0.0.9 | CORE-2: 10.0.0.10 |
| CORE ↔ DIST-1 (×2) | CORE-1↔DIST-1: 10.0.0.12/30<br>CORE-2↔DIST-1: 10.0.0.20/30 | CORE-1: 10.0.0.13<br>CORE-2: 10.0.0.21 | DIST-1: 10.0.0.14<br>DIST-1: 10.0.0.22 |
| CORE ↔ DIST-2 (×2) | CORE-1↔DIST-2: 10.0.0.16/30<br>CORE-2↔DIST-2: 10.0.0.24/30 | CORE-1: 10.0.0.17<br>CORE-2: 10.0.0.25 | DIST-2: 10.0.0.18<br>DIST-2: 10.0.0.26 |
| USERS (gateway VRRP) | 10.10.10.0/24 | DIST-1: 10.10.10.2 | DIST-2: 10.10.10.3 |
| SERVERS (gateway VRRP) | 10.10.20.0/24 | DIST-1: 10.10.20.2 | DIST-2: 10.10.20.3 |

**VRRP:**

| Grupo | VRID | Master | Priority | IP virtual |
| :---- | :---: | :---: | :---: | :---: |
| USERS | 10 | DIST-1 | 150 (DIST-1) / 100 (DIST-2) | 10.10.10.1 |
| SERVERS | 20 | DIST-2 | 150 (DIST-2) / 100 (DIST-1) | 10.10.20.1 |

Load-sharing: DIST-1 es master del grupo 10 y backup del grupo 20; DIST-2 es master del grupo 20 y backup del grupo 10 — así ambos distribución cursan tráfico en operación normal.

**Router-IDs:**

| Nodo | Router-ID |
| :---- | :---- |
| CORE-1 | 10.255.255.1 |
| CORE-2 | 10.255.255.2 |
| EDGE | 10.255.255.3 |
| DIST-1 | 10.255.255.4 |
| DIST-2 | 10.255.255.5 |
| ISP-1 | 203.0.113.1 |
| ISP-2 | 203.0.113.2 |

**Notas adicionales (fuera del mínimo del template, para F4/monitoreo):** gestión fuera de banda de los switches en `10.10.254.0/24` (SW-USERS: `.1`, SW-SERVERS: `.2`).

**Verificación de no solapamiento:** los bloques `10.255.255.0/24` (loopbacks), `10.0.0.0/24` (enlaces internos), `10.10.10.0/24` y `10.10.20.0/24` (LANs), `10.10.254.0/24` (mgmt) y los rangos de documentación `192.0.2.0/24` / `203.0.113.0/24` (enlaces y loopbacks de ISP) son disjuntos entre sí; se verificó con `ipaddress` de Python que ningún par de bloques ni de subredes derivadas se superpone.

### 1.3 Política de seguridad

- **Usuarios y privilegios:** dos cuentas locales por router: `admin` (grupo `full`, contraseña fuerte individual, uso exclusivo para cambios de configuración) y `monitor` (grupo `read`, solo lectura, para consultas/SNMP). Se elimina o renombra cualquier cuenta por defecto sin contraseña. Acceso de gestión (SSH/Winbox) restringido por firewall a la red de gestión del grupo.
- **Servicios que se deshabilitan** (los 7 routers): `telnet`, `ftp`, `www`, `www-ssl` (salvo necesidad puntual), `api`/`api-ssl`, `socks`, `upnp`, `bandwidth-server`, `ddns`, `cloud`, y descubrimiento de vecinos (MNDP/CDP) en interfaces hacia el ISP. Se mantienen `ssh` (único canal de gestión remota) y `winbox` restringido a la red de gestión.
- **Claves de autenticación:**
  - **OSPF** (área 0): MD5, una clave por área, igual en los 5 routers internos (EDGE, CORE-1, CORE-2, DIST-1, DIST-2).
  - **BGP** (eBGP): TCP-MD5 (RFC 2385), una clave distinta por sesión (EDGE↔ISP-1 y EDGE↔ISP-2), nunca reutilizada entre sesiones.
  - **VRRP:** autenticación simple, una clave por grupo (vrid 10 y vrid 20), distinta entre sí.
  - Ninguna clave real se escribe en este documento ni se commitea al repo; se generan y distribuyen por el canal que defina el grupo (gestor de contraseñas compartido) y se rotan si un integrante deja de tener acceso. El drill de seguridad de F4 verifica que una clave incorrecta hace **fallar** la adyacencia/sesión.

### 1.4 Política de operación

- **Formato del change log (convención de commits):** Conventional Commits (`tipo(alcance): descripción breve`, tipos `feat`/`fix`/`docs`/`ops`/`chore`, ver `README.md`). Cada cambio de configuración relevante se registra además en `CHANGELOG.md` con columnas Fecha · Autor (Rol) · Commit · Descripción · Sistemas afectados · Plan de rollback. El change log debe reflejar el historial real de git (una fila por commit o grupo de commits de un mismo cambio lógico), no completarse aparte sin relación con los commits.
- **Política de backup (cuándo y cómo):** se respalda el `/export` completo de cada router. Un snapshot **BASE** apenas cada router queda desplegado (F1), antes de tocar VRRP/OSPF/BGP; un backup antes y después de cada cambio relevante; un backup adicional antes de cada drill (F4). Se guardan en `backups/<router>_<AAAAMMDD>_<fase-o-motivo>.rsc`, sin borrar backups anteriores (retención total durante el laboratorio). Al menos una vez se restaura un backup para confirmar que es válido ("backup probado"), documentando el resultado en F1/F4.

---

## 2. Topología

> Pegar acá la captura del proyecto GNS3 (o el diagrama) con las 5 capas identificadas — **pendiente de F1** (requiere los nodos desplegados). El diagrama de diseño corregido ya está en `docs/diagramas/topologia.md`.

```
[INTERNET] [EDGE] [CORE] [DISTRIBUTION] [ACCESS]
<!-- insertar diagrama/captura en F1 -->
```

---

## 3. Configuración

> Un bloque por dispositivo — **pendiente de F1/F2/F3** (se completa a medida que cada router queda configurado). Se puede referenciar el archivo `.rsc` del repo y pegar el contenido final.

### 3.1 ISP-1

```routeros
<!-- config final -->
```

### 3.2 ISP-2

```routeros
<!-- config final -->
```

### 3.3 EDGE

```routeros
<!-- config final -->
```

### 3.4 CORE-1

```routeros
<!-- config final -->
```

### 3.5 CORE-2

```routeros
<!-- config final -->
```

### 3.6 DIST-1

```routeros
<!-- config final -->
```

### 3.7 DIST-2

```routeros
<!-- config final -->
```

### 3.8 Hosts (PC-USER / SRV)

```sh
<!-- config final de los hosts -->
```

---

## 4. Verificación

> **Pendiente de F1/F2/F3** (requiere los equipos desplegados y configurados).

### 4.1 Conectividad básica

| Prueba | Comando | Resultado |
| :---- | :---- | :---- |
| ping intra-LAN (PC-USER ↔ SRV) | <!-- --> | <!-- --> |
| traceroute a ISP (loopback) | <!-- --> | <!-- --> |

> Pegar capturas de las tablas: `/routing/route/print`, `/interface/vrrp/print`, `/routing/bgp/session/print`.

### 4.2 Los 5 drills de failover

> **Pendiente de F4.** Para cada drill, documentar con la estructura detección → respuesta → recuperación → post-mortem y el tiempo medido.

#### Drill 1 — VRRP: se cae el gateway

- **Detección:** <!-- -->
- **Respuesta:** <!-- -->
- **Recuperación:** <!-- -->
- **Tiempo medido:** <!-- -->
- **Post-mortem** (¿por qué funcionó? ¿qué aprendieron?): <!-- -->

#### Drill 2 — OSPF: se corta el camino interno

- **Detección:** <!-- -->
- **Respuesta:** <!-- -->
- **Recuperación:** <!-- -->
- **Tiempo medido:** <!-- -->
- **Post-mortem:** <!-- -->

#### Drill 3 — BGP: se cae el proveedor

- **Detección:** <!-- -->
- **Respuesta:** <!-- -->
- **Recuperación:** <!-- -->
- **Tiempo medido:** <!-- -->
- **Post-mortem:** <!-- -->

#### Drill 4 — check-gateway: failover estático de enlace

- **Detección:** <!-- -->
- **Respuesta:** <!-- -->
- **Recuperación:** <!-- -->
- **Tiempo medido:** <!-- -->
- **Post-mortem:** <!-- -->

#### Drill 5 — Load-sharing VRRP: ambos DIST activos

- **Detección:** <!-- -->
- **Respuesta:** <!-- -->
- **Recuperación:** <!-- -->
- **Post-mortem:** <!-- -->

---

## 5. Seguridad aplicada

> **Pendiente de F2/F3/F4** (la política está definida en 1.3; esto documenta la verificación real una vez aplicada).

| Mecanismo | Dónde se aplicó | Verificación (¿cómo probaron que funciona?) |
| :---- | :---- | :---- |
| Hardening (usuarios/servicios) | <!-- --> | <!-- --> |
| OSPF MD5 | <!-- --> | <!-- --> |
| BGP TCP-MD5 | <!-- --> | <!-- --> |
| VRRP auth | <!-- --> | <!-- --> |
| Firewall/ACL (edge) | <!-- --> | <!-- --> |

> Prueba de seguridad obligatoria: adyacencia OSPF / sesión BGP debe **fallar** con clave incorrecta. Documentar el resultado.

---

## 6. Gestión operativa

### 6.1 Change log

> El formato está definido en 1.4 y vive también en `CHANGELOG.md` (debe reflejar los commits del repo). Se completa a medida que haya commits reales.

| Fecha | Responsable | Cambio | Motivo | Cómo se revierte |
| :---- | :---- | :---- | :---- | :---- |
| <!-- --> | <!-- --> | <!-- --> | <!-- --> | <!-- --> |

### 6.2 Backups

> Evidencia de backup (`/export` + `/system backup save`) y de **restore probado** — **pendiente de F1/F4**.

<!-- pegar evidencia -->

### 6.3 Monitoreo

> Qué se monitorea (enlaces, vecinos OSPF, sesiones BGP, VRRP) y con qué (SNMP, chequeos) — **pendiente de F4**.

<!-- -->

---

## 7. Capturas

> Listar o enlazar la carpeta de capturas (drills, tablas, failover) — **pendiente de F4/F5**.

<!-- -->

---

## 8. Conclusiones y lecciones aprendidas

> Post-mortem global — **pendiente de F5**.

<!-- -->

---

## 9. Referencias

> Lecturas y videos efectivamente consultados.

- <!-- -->
- <!-- -->

---

## 10. Checklist de entrega

> Marcar todo antes de entregar. Si algo no está, el lab no está completo.

### Diseño (F0)

- [x] IPAM completo y sin solapamiento
- [x] Corrección del diagrama justificada (≥ 3 defectos)
- [x] Política de seguridad definida (usuarios, servicios, claves)
- [x] Política de operación definida (change log + backup)

### Redes

- [ ] 7 CHR + 2 switches + 2 hosts levantados y cableados
- [ ] VRRP operativo (2 grupos, load-sharing)
- [ ] OSPF área 0 con adyacencias (incluido core–core)
- [ ] BGP eBGP ×2 establecido (multi-homing)
- [ ] Los 5 drills ejecutados y documentados (runbook + post-mortem + tiempo)

### Seguridad

- [ ] Hardening aplicado (password, usuario mínimo, servicios apagados)
- [ ] OSPF MD5 funcionando
- [ ] BGP TCP-MD5 funcionando
- [ ] VRRP auth funcionando
- [ ] Firewall edge aplicado
- [ ] Prueba con clave incorrecta → debe **fallar** (documentado)

### Operación

- [ ] Change log completo (refleja los commits del repo)
- [ ] Backups con restore probado
- [ ] Monitoreo habilitado y documentado
- [ ] Runbook por drill + post-mortem global

### Entrega

- [ ] Memoria completa (todas las secciones de esta plantilla)
- [ ] Repo git con la estructura correcta y commits por rol
- [ ] `backlog.md` con todas las tareas en "done"
- [ ] Capturas en la carpeta `capturas/`
- [ ] Cada integrante puede defender su parte **y** una parte ajena
