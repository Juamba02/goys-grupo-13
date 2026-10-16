# ============================================
# CORE-2 - Failover Routing Lab (GOYS)
# F1: direccionamiento IP + loopback + hardening base
# OSPF (area 0, MD5) se configura en F2 - no incluido aca
# ============================================
# IMPORTANTE: ajustar los nombres de interfaz (etherX) al mapeo real de tu
# proyecto GNS3 antes de aplicar. Orden asumido: ether1=EDGE, ether2=CORE-1
# (core-core), ether3=DIST-1, ether4=DIST-2.

/system identity set name=CORE-2

# --- Direccionamiento (IPAM, ver docs/memoria.md seccion 1.2) ---
/ip address add address=10.0.0.6/30 interface=ether1 comment="enlace a EDGE"
/ip address add address=10.0.0.10/30 interface=ether2 comment="enlace core-core a CORE-1"
/ip address add address=10.0.0.21/30 interface=ether3 comment="enlace a DIST-1"
/ip address add address=10.0.0.25/30 interface=ether4 comment="enlace a DIST-2"

# --- Loopback / Router-ID ---
/interface bridge add name=loopback0
/ip address add address=10.255.255.2/32 interface=loopback0

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
# ping 10.0.0.5  -> EDGE
# ping 10.0.0.9  -> CORE-1 (core-core)
# ping 10.0.0.22 -> DIST-1
# ping 10.0.0.26 -> DIST-2
