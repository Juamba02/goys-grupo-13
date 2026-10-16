# ============================================
# DIST-2 - Failover Routing Lab (GOYS)
# F1: direccionamiento IP + loopback + hardening base
# VRRP (vrid 10/20) y OSPF se configuran en F2 - no incluidos aca.
# Las IPs de LAN de abajo son la interfaz FISICA de DIST-2; el gateway
# virtual VRRP (10.10.10.1 / 10.10.20.1) se agrega en F2.
# ============================================
# IMPORTANTE: ajustar los nombres de interfaz (etherX) al mapeo real de tu
# proyecto GNS3 antes de aplicar. Orden asumido: ether1=CORE-1, ether2=CORE-2,
# ether3=LAN USERS, ether4=LAN SERVERS.

/system identity set name=DIST-2

# --- Direccionamiento (IPAM, ver docs/memoria.md seccion 1.2) ---
/ip address add address=10.0.0.18/30 interface=ether1 comment="enlace a CORE-1"
/ip address add address=10.0.0.26/30 interface=ether2 comment="enlace a CORE-2"
/ip address add address=10.10.10.3/24 interface=ether3 comment="LAN USERS (fisica, backup vrid 10 en F2)"
/ip address add address=10.10.20.3/24 interface=ether4 comment="LAN SERVERS (fisica, master vrid 20 en F2)"

# --- Loopback / Router-ID ---
/interface bridge add name=loopback0
/ip address add address=10.255.255.5/32 interface=loopback0

# --- Hardening (ver docs/memoria.md seccion 1.3) ---
# Las passwords de abajo son placeholders: cambiarlas por las reales del
# gestor de contrasenas del grupo ANTES de aplicar esta config. No commitear
# nunca la password real en este archivo.
/user set [find name=admin] password="CAMBIAR-ANTES-DE-APLICAR"
/user group add name=monitor-ro policy=read,test,winbox,ssh
/user add name=monitor group=monitor-ro password="CAMBIAR-ANTES-DE-APLICAR"

/ip service disable telnet,ftp,www,www-ssl,api,api-ssl
/ip service set ssh port=22
/ip cloud set ddns-enabled=no
/tool bandwidth-server set enabled=no
/ip upnp set enabled=no
/ip socks set enabled=no

# --- Verificacion (hacer en GNS3 una vez aplicado, no simulado aca) ---
# ping 10.0.0.17 -> CORE-1
# ping 10.0.0.25 -> CORE-2
# ping 10.10.10.2 -> DIST-1 (misma LAN USERS)
# ping 10.10.20.2 -> DIST-1 (misma LAN SERVERS)
