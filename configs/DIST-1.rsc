# DIST-1 - distribucion (VRRP en F2: master vrid 10, backup vrid 20) - router-id 10.255.255.4
# Cableado en GNS3:
#   ether1 -> CORE-1   ether2 -> CORE-2   ether3 -> LAN USERS   ether4 -> LAN SERVERS
# Si en el proyecto quedaron en otro orden, cambiar los nombres antes de importar.
# Importar solo sobre un CHR limpio (/system reset-configuration no-defaults=yes):
# los add fallan con "already exists" si se vuelve a importar y /import corta en el primer error.
# OSPF y VRRP se configuran en F2, no van en este archivo.

# ---------- F1: identidad, IPs de enlace y loopback ----------

/system identity set name=DIST-1

# CHR trae un dhcp-client en ether1 por defecto: no va en este diseno
/ip dhcp-client remove [ find ]

/interface ethernet
set [ find default-name=ether1 ] comment="to CORE-1"
set [ find default-name=ether2 ] comment="to CORE-2"
set [ find default-name=ether3 ] comment="to LAN USERS (SW-USERS)"
set [ find default-name=ether4 ] comment="to LAN SERVERS (SW-SERVERS)"

/interface bridge
add name=loopback protocol-mode=none comment="loopback / router-id"

/interface list
add name=LAN comment="enlaces internos"
add name=ACCESS comment="LANs de usuarios y servidores"

/interface list member
add list=LAN interface=ether1
add list=LAN interface=ether2
add list=ACCESS interface=ether3
add list=ACCESS interface=ether4
add list=LAN interface=loopback

/ip address
add address=10.0.0.14/30 interface=ether1 comment="CORE-1"
add address=10.0.0.22/30 interface=ether2 comment="CORE-2"
add address=10.10.10.2/24 interface=ether3 comment="LAN USERS (IP fisica; la VIP de VRRP va en F2)"
add address=10.10.20.2/24 interface=ether4 comment="LAN SERVERS (IP fisica; la VIP de VRRP va en F2)"
add address=10.255.255.4/32 interface=loopback comment="loopback"

# Verificacion (vecinos directos):
#   /ping 10.0.0.13 count=3      (CORE-1)
#   /ping 10.0.0.21 count=3      (CORE-2)
#   /ping 10.10.10.3 count=3      (DIST-2 por LAN USERS)
#   /ping 10.10.20.3 count=3      (DIST-2 por LAN SERVERS)

# ---------- F1: hardening (politica de seguridad, memoria 1.3) ----------
# Las claves NO van en este archivo. Despues de importar, desde la consola:
#   /password                                   (clave de admin, del gestor del grupo)
#   /user set monitor password=<clave> disabled=no   (si no se cargo al pegar, ver el final)

# gestion solo desde enlaces internos y loopbacks, no desde las LANs USERS/SERVERS
/ip service
set [ find name=telnet ] disabled=yes
set [ find name=ftp ] disabled=yes
set [ find name=www ] disabled=yes
set [ find name=www-ssl ] disabled=yes
set [ find name=api ] disabled=yes
set [ find name=api-ssl ] disabled=yes
set [ find name=reverse-proxy ] disabled=yes
set [ find name=ssh ] available-from=10.0.0.0/24,10.255.255.0/24
set [ find name=winbox ] available-from=10.0.0.0/24,10.255.255.0/24

/ip ssh set strong-crypto=yes

/ip socks set enabled=no
/ip upnp set enabled=no
/ip proxy set enabled=no
# 7.24: ddns-enabled=no ya no es valido y cloud no esta soportado en CHR free
/ip cloud set update-time=no
/ip dns set allow-remote-requests=no
/tool bandwidth-server set enabled=no

# sin descubrimiento de vecinos ni acceso por MAC desde las LANs de usuarios/servidores
/ip neighbor discovery-settings set discover-interface-list=LAN
/tool mac-server set allowed-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN

# Usuario de solo lectura. Va al final a proposito: si el script se pega en la consola,
# RouterOS 7.24 pide la clave del usuario en este paso y, si hubiera mas lineas despues,
# se comeria la siguiente como clave. Escribir la clave de monitor cuando la pida y despues:
#   /user set monitor disabled=no
/user add name=monitor group=read disabled=yes comment="solo lectura / consultas"
