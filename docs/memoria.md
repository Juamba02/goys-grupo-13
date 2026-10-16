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
| Host USERS (PC-USER, VPCS) | 10.10.10.0/24 | PC-USER: 10.10.10.10 | gateway: 10.10.10.1 (VIP vrid 10) |
| Host SERVERS (SRV, VPCS) | 10.10.20.0/24 | SRV: 10.10.20.10 | gateway: 10.10.20.1 (VIP vrid 20) |

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

**Hosts:** cada LAN reserva `.1` para la IP virtual VRRP, `.2`/`.3` para DIST-1/DIST-2 y `.10` en adelante para hosts. Los hosts usan como gateway la IP virtual, nunca la IP real de un DIST, para que el failover sea transparente.

**Gestión de switches (descartado):** en F0 se había reservado `10.10.254.0/24` para gestión fuera de banda de los switches. En el proyecto GNS3 los switches son *Ethernet switch* nativos (no gestionables, sin IP), así que ese bloque queda **sin uso**. Se mantiene reservado para no reasignarlo.

**Verificación de no solapamiento:** los bloques `10.255.255.0/24` (loopbacks), `10.0.0.0/24` (enlaces internos), `10.10.10.0/24` y `10.10.20.0/24` (LANs), `10.10.254.0/24` (reservado, sin uso) y los rangos de documentación `192.0.2.0/24` / `203.0.113.0/24` (enlaces y loopbacks de ISP) son disjuntos entre sí; se verificó con `ipaddress` de Python que ningún par de bloques ni de subredes derivadas se superpone.

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

Hosts VPCS de GNS3. Config versionada en `configs/PC-USER.vpc` y `configs/SRV.vpc`, idéntica al `startup.vpc` que genera `save` en el proyecto:

```sh
# configs/PC-USER.vpc (LAN USERS)
set pcname PC-USER
ip 10.10.10.10 10.10.10.1 24

# configs/SRV.vpc (LAN SERVERS)
set pcname SRV
ip 10.10.20.10 10.10.20.1 24
```

Para cargarla a mano en la consola del VPCS se puede tipear lo mismo, o la forma equivalente `ip 10.10.10.10/24 10.10.10.1`, y después `save` para que persista.

Verificación: `show ip` en cada host (capturas `capturas/f1/pc-user-ip.png` y `srv-ip.png`, 16/10/2026, R5). El ping al gateway (`ping 10.10.10.1` / `ping 10.10.20.1`) recién responde cuando VRRP esté activo en DIST-1/DIST-2 (F2).

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
| Hardening (usuarios/servicios) | EDGE, ISP-1, ISP-2 (F1). CORE/DIST pendiente (R3/R4) | `/user print` y `/ip service print` en cada router; login como `monitor` e intento de cambiar la identidad → `not enough permissions`. Capturas en `capturas/f1/` |
| OSPF MD5 | <!-- --> | <!-- --> |
| BGP TCP-MD5 | <!-- --> | <!-- --> |
| VRRP auth | <!-- --> | <!-- --> |
| Firewall/ACL (edge) | <!-- --> | <!-- --> |

**Desvíos respecto de la política 1.3 (F1):**

- **ddns / cloud:** en RouterOS 7.24 `ddns-enabled=no` ya no es un valor válido y los servicios cloud no están soportados en CHR con licencia free. Solo se deja `update-time=no`.
- **Red de gestión:** el IPAM no define una red de gestión para los routers. SSH y Winbox se limitan a los enlaces internos y las loopbacks (`10.0.0.0/24`, `10.255.255.0/24`) en EDGE; las LANs USERS y SERVERS quedan afuera y en F3 se refuerza con el firewall del EDGE. ISP-1 e ISP-2 se gestionan solo por consola de GNS3: SSH y Winbox quedan limitados a su propia loopback (`203.0.113.1/32` y `203.0.113.2/32`), así que ni el cliente ni el otro proveedor tienen acceso.
- **Usuario `monitor`:** es solo para consultas en modo lectura (SSH, Winbox, consola). SNMP no usa los usuarios de `/user`; se configura aparte en F4 (monitoreo, R5).
- **reverse-proxy:** servicio nuevo de RouterOS 7.24 que no estaba en la lista de la política; también se apaga.
- **dhcp-client:** CHR trae uno por defecto en ether1 que no forma parte del diseño; se borra.

**Verificación independiente de R5 (QA) — 16/10/2026:**

Hecha por Tomas Costa (R5) en su propia copia del lab (OVA del Drive del grupo, CHR 7.24.5, MAC conservadas), separada de la evidencia de implementación que tomó R1/R2. Se comparó la salida en vivo de cada router contra su script de `configs/` y contra esta política.

| Control | EDGE | ISP-1 | ISP-2 | Evidencia |
| :---- | :----: | :----: | :----: | :---- |
| `admin` con clave (`full`) y `monitor` habilitado (`read`) | ✅ | ✅ | ✅ | `edge-monitor-solo-lectura`, `isp1-monitor-solo-lectura`, `isp2-monitor-solo-lectura` |
| `monitor` no puede cambiar la config (`not enough permissions`) | ✅ | ✅ | ✅ | ídem |
| Solo `ssh` y `winbox` habilitados, gestión acotada | ✅ | ✅ | ✅ | `edge-servicios`, `isp1-servicios`, `isp2-servicios` |
| Descubrimiento de vecinos y `mac-server` (`LAN` en EDGE, `none` en ISP) | ✅ | ✅ | ✅ | `edge-neighbor-macserver`, `isp1-neighbor-macserver`, `isp2-neighbor-macserver` |
| `mac-winbox` (`LAN` en EDGE, `none` en ISP) | ✅ | ✅ | ✅ | `edge-mac-winbox`, `isp1-neighbor-macserver`, `isp2-neighbor-macserver` |
| IPs según IPAM 1.2 y ping al vecino | ✅ | ✅ | ✅ | `edge-ips-ping`, `isp1-ips-ping`, `isp2-ips-ping` |

Resultado: **EDGE, ISP-1 e ISP-2 cumplen la política 1.3.** CORE-1/2 y DIST-1/2 quedan pendientes hasta que R3/R4 los configuren.

Observaciones:

- **Recomendación (no es incumplimiento):** en ISP-1 e ISP-2, `ether2`–`ether4` están habilitadas sin uso (sin cableado; se ven en `isp1-neighbor-macserver` / `isp2-neighbor-macserver`). La política no exige apagar puertos sin uso, pero es buena práctica de hardening: `/interface ethernet disable ether2,ether3,ether4`. Decisión de R2.
- Las capturas de `monitor` de EDGE e ISP-1 (de #4) muestran el comentario anterior "consultas y SNMP": son previas a la review. En la verificación de R5 los routers ya tienen "solo lectura / consultas", igual que el script.
- El servicio dinámico `discover` (5678/udp) que aparece en EDGE es el descubrimiento de vecinos de RouterOS; queda limitado a la lista `LAN`. En los ISP no aparece porque el descubrimiento está en `none`.

> Prueba de seguridad obligatoria: adyacencia OSPF / sesión BGP debe **fallar** con clave incorrecta. Documentar el resultado.

---

## 6. Gestión operativa

### 6.1 Change log

> El formato está definido en 1.4 y vive también en `CHANGELOG.md` (debe reflejar los commits del repo). Se completa a medida que haya commits reales.

| Fecha | Responsable | Cambio | Motivo | Cómo se revierte |
| :---- | :---- | :---- | :---- | :---- |
| 01/10/2026 | Juan Bautista Aramberri (R3/R4) | Estructura del repo, memoria F0, formato de change log, backlog y README (`ba572d2`…`b211f46`) | F0: diseño, políticas y repo | Revertir los commits |
| 15/10/2026 | Joaquin Mazza (R1) | IPs de enlace y loopback en EDGE (`cf78733`) | F1: direccionamiento según IPAM 1.2 | Revertir el commit y borrar las direcciones en el router |
| 15/10/2026 | Joaquin Mazza (R2) | IPs de enlace y loopback en ISP-1 e ISP-2 (`a98d0f2` / `6f14db3`) | F1: direccionamiento según IPAM 1.2 | Revertir el commit y borrar las direcciones en el router |
| 15/10/2026 | Joaquin Mazza (R2) | Hardening de ISP-1 e ISP-2 (`a98d0f2` / `3936eb5`) | F1: política de seguridad 1.3 | Revertir el commit y reactivar los servicios |
| 15/10/2026 | Joaquin Mazza (R1) | Hardening de EDGE (`80d9d7d`) | F1: política de seguridad 1.3 | Revertir el commit y reactivar los servicios |
| 15/10/2026 | Joaquin Mazza (R1/R2) | Servicios con `find` por nombre en EDGE, ISP-1 e ISP-2 (`ef7bbdf`, `a98d0f2` / `ad545c5`) | Bug de RouterOS 7.24: `set telnet ...` no encontraba el servicio | Revertir el commit |
| 15/10/2026 | Joaquin Mazza (R1/R2) | Se borra el dhcp-client por defecto en EDGE, ISP-1 e ISP-2 (`4c44a91`, `a98d0f2` / `57be045`) | CHR lo trae en ether1 y no forma parte del diseño | `/ip dhcp-client add interface=ether1` |
| 15/10/2026 | Joaquin Mazza (R1/R2) | Renombrado ether5-8 → ether1-4 y reasignación de IPs (sin commit, solo en el router) | Al migrar los nodos a VMs fijas de VirtualBox cambiaron las MAC | Restaurar el backup base |
| 15/10/2026 | Joaquin Mazza (R1/R2) | Capturas de verificación de F1 (`619164b` / `b610656`, `a27df8a`) | Evidencia para las secciones 2, 4 y 5 | Revertir el commit |
| 15/10/2026 | Joaquin Mazza (R1/R2) | Gestión acotada: EDGE a `10.0.0.0/24,10.255.255.0/24`, ISP solo por consola (`9c3c2cc`, `a98d0f2` / `768642c`) | Review R5: `10.0.0.0/8` incluía las LANs de usuarios | Revertir el commit y volver al rango anterior |
| 15/10/2026 | Joaquin Mazza (R1/R2) | Notas de import y de cloud en los scripts, memoria §5 con los desvíos (`253e0f3`, `a98d0f2` / `7d6e431`, `e8ac4ae`, `16af715`) | Review R5: documentar desvíos de la política | Revertir los commits |
| 15/10/2026 | Tomas Costa (R5) | Merge del PR #2 con merge commit (`68028ba`) | Review de R5 aprobada | `git revert -m 1 68028ba` |
| 15/10/2026 | Tomas Costa (R5) | Backup base F1 de EDGE, ISP-1 e ISP-2 (`a5f8819`) y registro en §6.2 (`752989e`) | Política de backup 1.4: snapshot BASE | No aplica (solo respaldo) |
| 15/10/2026 | Tomas Costa (R5) | Change log, backlog, referencia del diagrama y hosts PC-USER/SRV en el IPAM (`191de4a`, `590dc01`, `ec7ba15`, `3398fa9`, `39d680f`) | Registro operativo de F1 y hosts (R5) | Revertir los commits |
| 16/10/2026 | Joaquin Mazza (R1/R2) | Capturas post-review de EDGE, ISP-1 e ISP-2 (`d04a437` / `8547104`) | Evidencia tras la review de R5 | Revertir el commit |
| 16/10/2026 | Tomas Costa (R5) | Verificación de hardening de R5 en EDGE, ISP-1 e ISP-2: capturas, memoria §5 y backlog (`e75babe`, `107f0ce`, `fabf518`) | QA independiente de F1 | Revertir los commits |
| 16/10/2026 | Tomas Costa (R5) | Hosts PC-USER y SRV configurados en VPCS (solo lab) y evidencia (`ac3a6d6`, `258c692`) | F1: 2 hosts levantados | En VPCS `clear ip`; revertir los commits |

> Detalle completo, una fila por commit, en `CHANGELOG.md`. Los PR #3, #4 y #6 se mergearon con *squash*: se cita el hash de `main` y, separado por `/`, el commit original de la rama.

### 6.2 Backups

> Evidencia de backup (`/export`) y de **restore probado** — backups BASE de F1 hechos para EDGE, ISP-1 e ISP-2; restore pendiente de F4. La política 1.4 pide solo el `/export`; el backup binario (`/system backup save`) no se toma.

**Backups versionados** (política 1.4, `backups/<router>_<AAAAMMDD>_<motivo>.rsc`):

| Archivo | Router | Fase / motivo | Tomado por | Contenido |
| :---- | :---- | :---- | :---- | :---- |
| `EDGE_20261015_base.rsc` | EDGE | Snapshot BASE (F1) | Joaquin Mazza (R1) | IPs de enlace, loopback, listas WAN/LAN, hardening |
| `ISP-1_20261015_base.rsc` | ISP-1 | Snapshot BASE (F1) | Joaquin Mazza (R2) | IP de enlace, loopback, lista CUSTOMER, hardening |
| `ISP-2_20261015_base.rsc` | ISP-2 | Snapshot BASE (F1) | Joaquin Mazza (R2) | IP de enlace, loopback, lista CUSTOMER, hardening |
| _CORE-1, CORE-2, DIST-1, DIST-2_ | | Snapshot BASE (F1) | _pendiente (R3/R4)_ | |

Los tres BASE ya incluyen los cambios de la review de R5 (gestión de EDGE acotada a `10.0.0.0/24,10.255.255.0/24` y de los ISP a su loopback `/32`). La fecha del encabezado de cada archivo (`2026-10-16 01:38`) es la hora UTC del router; en hora local corresponde al 15/10 22:38.

**Qué NO trae un `/export` (a tener en cuenta en el restore):**

- **Contraseñas:** RouterOS 7 no las exporta, por eso los archivos se pueden versionar.
- **Usuarios:** `/user` no forma parte del `/export`; el usuario `monitor` no aparece en ninguno de los tres archivos. Después de importar hay que **crearlo**, no solo activarlo: `/user add name=monitor group=read password=<clave>`, y fijar la clave de `admin` con `/password`.
- **Valores por defecto:** el export es compacto y solo lista lo que difiere del default (por ejemplo, `socks`, `upnp` o `proxy` apagados no aparecen porque ya vienen así).

**Restore probado:** pendiente (F4). Procedimiento:

1. Dejar el CHR limpio: `/system reset-configuration no-defaults=yes skip-backup=yes`. El router reinicia **sin ninguna IP** y con `admin` sin clave (pide una nueva en el primer login).
2. Como no tiene IP, no se le puede subir el `.rsc` por red para usar `/import file-name=...`. En GNS3 se abre la consola del nodo y se **pega el contenido del backup** (conviene pegarlo por bloques, sección por sección, para que la consola no pierda caracteres).
   - Alternativa: darle a mano solo la IP de un enlace (por ejemplo `/ip address add address=192.0.2.2/30 interface=ether1` en EDGE), subir el archivo desde un vecino y recién ahí `/import file-name=<archivo>.rsc`.
3. Recrear usuarios (el `/export` no los trae): `/password` para `admin` y `/user add name=monitor group=read password=<clave>`.
4. Verificar con `/ip address print`, `/ip service print` y ping al vecino; captura en `capturas/`.

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
