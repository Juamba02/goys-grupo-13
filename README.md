# GOYS — Failover Routing: "la red que no se cae"

**Materia:** Gestión Operativa y Seguridad en Redes (GOYS) — UTN FR La Plata
**Modalidad:** Grupal, trabajo asincrónico en GNS3 (MikroTik CHR / RouterOS 7)

## Integrantes y roles

> La consigna está pensada para 5 integrantes (R1-R5). Nuestro grupo es de **3 personas**, así que repartimos los 5 roles en 3 personas agrupando por afinidad técnica (quién ya comparte protocolo/enlace con quién). Mantenemos las etiquetas R1-R5 en el backlog porque son las que usa la consigna/rúbrica; cada persona cubre dos (o uno) de esos roles.

| Persona | Roles que cubre | Responsabilidad |
| :-- | :-- | :-- |
| Joaquin Mazza | R1 Líder/Edge-WAN + R2 Proveedores | EDGE + ISP-1 + ISP-2: eBGP x2, BGP MD5, default-originate, hardening de los 3 routers de borde, firewall |
| Juan Bautista Aramberri | R3 Core + R4 Distribución | CORE-1/CORE-2 + DIST-1/DIST-2: OSPF área 0 completo (incluido core-core, con MD5), VRRP en distribución (con auth), gateways |
| Tomas Costa | R5 Hosts / QA / Ops | Hosts, backlog, change log, backups, runbooks, ejecución y documentación de los 5 drills |


**Por qué esta repartición:** R1+R2 ya trabajan codo a codo (son las dos puntas de las mismas sesiones eBGP) y R3+R4 corren el mismo proceso OSPF de punta a punta, así que agruparlos no mezcla cosas que no se relacionen. R5 queda solo porque es el 20% de "gestión operativa" de la rúbrica y conviene que una sola persona sea dueña consistente del backlog/change log/backups en vez de repartirlo.

**Rotación F4:** la consigna pide rotación obligatoria R1↔R2; como Joaquin ya cubre ambos, ese requisito queda cumplido de entrada. Para que no se pierda el espíritu de la regla (que nadie termine viendo solo "su" mitad de la red), en F4 Joaquin y Juan intercambian por un rato: Juan revisa/ajusta algo del lado Edge-ISP y Joaquin revisa OSPF/VRRP. Esto además ayuda para F5, donde cada integrante tiene que explicar su parte **y** una parte ajena.

## Resumen del laboratorio

Diseñar, implementar, operar y asegurar una red empresarial jerárquica de 5 capas (Internet → Edge → Core → Distribución → Acceso) con redundancia de primer salto (VRRP), de IGP (OSPF) y de proveedor (BGP multi-homing), capaz de sobrevivir a fallas de enlace y de nodo. El diseño corrige 5 defectos de un diagrama de referencia visto en clase (SPOF de firewall, subredes solapadas, falta de enlace core-core, HSRP en el core, Route Reflector mal ubicado) — ver `docs/memoria.md` sección 1.

El trabajo se organiza en 6 epics (F0 a F5, ver `backlog.md` y el cronograma de la consigna):

| Epic | Contenido | Vence |
| :-: | :-- | :-: |
| F0 | Diseño + políticas + repo | vie 2/10 |
| F1 | Topología + hardening + backup | vie 9/10 |
| F2 | VRRP + OSPF | vie 16/10 |
| F3 | BGP + firewall | vie 16/10 |
| F4 | Drills + monitoreo | mar 20/10 |
| F5 | Memoria + defensa | vie 23/10 |

## Estructura del repositorio

```
goys-failover-<grupo>/
├── README.md          # este archivo
├── backlog.md         # backlog: tareas con estado (pendiente / en curso / hecho)
├── CHANGELOG.md        # change log de cambios de configuración (refleja los commits)
├── docs/
│   ├── memoria.md      # plantilla de documentación (F0: secciones 1-4 completas)
│   └── diagramas/
│       └── topologia.md  # diagrama de la topología corregida (mermaid)
├── configs/            # .rsc finales por router (se completa desde F1)
├── backups/            # /export de cada router, por fecha (se completa desde F1)
├── runbooks/           # un .md por drill de failover (se completa desde F4)
└── capturas/           # screenshots organizados por drill (se completa desde F4)
```

## Convención de commits

Conventional Commits: `tipo(alcance): descripción breve`

| Tipo | Cuándo se usa |
| :-- | :-- |
| `feat` | Agregan algo nuevo (una config, una feature) |
| `fix` | Corrigen algo roto |
| `docs` | Documentación (memoria, diagramas, runbooks) |
| `ops` | Operación (backup, change log) |
| `chore` | Mantenimiento (estructura, .gitignore) |

Un commit por cambio lógico. `main` siempre funciona: los cambios rotos se arreglan antes de mergear.

## Estado actual

**F0 — Diseño y gestión de cambio** (vence 2/10): direccionamiento, corrección del diagrama, política de seguridad y política de operación definidos en `docs/memoria.md`; estructura de repo creada. Ver `backlog.md` para el detalle de tareas.
