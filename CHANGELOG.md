# Change log

Formato definido en `docs/memoria.md` sección 4.1. Cada fila corresponde a un commit (o grupo de commits de un mismo cambio lógico) del historial de git — no se completa "a mano" sin relación con los commits reales.

| Fecha | Autor (Rol) | Commit | Descripción | Sistemas afectados | Plan de rollback |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 15/10/2026 | Joaquin Mazza (R1) | `cf78733` | IPs de enlace y loopback en EDGE, listas WAN/LAN | EDGE | Revertir el commit y en el router `/ip address remove` de las direcciones agregadas |
| 15/10/2026 | Joaquin Mazza (R2) | `6f14db3` | IPs de enlace y loopback en ISP-1 e ISP-2, lista CUSTOMER | ISP-1, ISP-2 | Revertir el commit y en el router `/ip address remove` de las direcciones agregadas |
| 15/10/2026 | Joaquin Mazza (R2) | `3936eb5` | Hardening de ISP-1 e ISP-2: usuario monitor, servicios apagados, sin MNDP ni mac-server | ISP-1, ISP-2 | Revertir el commit y reactivar los servicios con `/ip service enable` |
| 15/10/2026 | Joaquin Mazza (R1) | `80d9d7d` | Hardening de EDGE: usuario monitor, servicios apagados, MNDP y mac-server solo en LAN | EDGE | Revertir el commit y reactivar los servicios con `/ip service enable` |
| 15/10/2026 | Joaquin Mazza (R1) | `ef7bbdf` | Servicios de EDGE con `find` por nombre (RouterOS 7.24 no los encontraba) y reverse-proxy apagado | EDGE | Revertir el commit (la versión anterior del script no apagaba los servicios) |
| 15/10/2026 | Joaquin Mazza (R1) | `4c44a91` | Se borra el dhcp-client que CHR trae por defecto en ether1 | EDGE | `/ip dhcp-client add interface=ether1` |
| 15/10/2026 | Joaquin Mazza (R2) | `ad545c5` | Servicios de ISP-1 e ISP-2 con `find` por nombre y reverse-proxy apagado | ISP-1, ISP-2 | Revertir el commit (la versión anterior del script no apagaba los servicios) |
| 15/10/2026 | Joaquin Mazza (R2) | `57be045` | Se borra el dhcp-client que CHR trae por defecto en ether1 | ISP-1, ISP-2 | `/ip dhcp-client add interface=ether1` |
| 15/10/2026 | Joaquin Mazza (R1/R2) | sin commit (solo router) | Al pasar los nodos a VMs fijas de VirtualBox las placas aparecieron como ether5-8; se renombran a ether1-4 y se reasignan IPs y listas | EDGE, ISP-1, ISP-2 | Restaurar el backup base `<router>_20261015_base.rsc` |
| 15/10/2026 | Joaquin Mazza (R1/R2) | `b610656` | Capturas de verificación de F1 (topología, pings, servicios, monitor) | `capturas/f1/` | Revertir el commit |
