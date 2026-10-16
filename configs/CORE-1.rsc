# CORE-1 - core (transito puro) - router-id 10.255.255.1
# Cableado en GNS3:
#   ether1 -> EDGE   ether2 -> CORE-2   ether3 -> DIST-1   ether4 -> DIST-2
# Si en el proyecto quedaron en otro orden, cambiar los nombres antes de importar.
# Importar solo sobre un CHR limpio (/system reset-configuration no-defaults=yes):
# los add fallan con "already exists" si se vuelve a importar y /import corta en el primer error.
# OSPF se configura en F2, no van en este archivo.

# ---------- F1: identidad, IPs de enlace y loopback ----------

/system identity set name=CORE-1

# CHR trae un dhcp-client en ether1 por defecto: no va en este diseno
/ip dhcp-client remove [ find ]

/interface ethernet
set [ find default-name=ether1 ] comment="to EDGE"
set [ find default-name=ether2 ] comment="to CORE-2 (core-core)"
set [ find default-name=ether3 ] comment="to DIST-1"
set [ find default-name=ether4 ] comment="to DIST-2"

/interface bridge
add name=loopback protocol-mode=none comment="loopback / router-id"

/interface list
add name=LAN comment="enlaces internos"

/interface list member
add list=LAN interface=ether1
add list=LAN interface=ether2
add list=LAN interface=ether3
add list=LAN interface=ether4
add list=LAN interface=loopback

/ip address
add address=10.0.0.2/30 interface=ether1 comment="EDGE"
add address=10.0.0.9/30 interface=ether2 comment="CORE-2"
add address=10.0.0.13/30 interface=ether3 comment="DIST-1"
add address=10.0.0.17/30 interface=ether4 comment="DIST-2"
add address=10.255.255.1/32 interface=loopback comment="loopback"

# Verificacion (vecinos directos):
#   /ping 10.0.0.1 count=3      (EDGE)
#   /ping 10.0.0.10 count=3      (CORE-2)
#   /ping 10.0.0.14 count=3      (DIST-1)
#   /ping 10.0.0.18 count=3      (DIST-2)

# ---------- F1: hardening (politica de seguridad, memoria 1.3) ----------
# Las claves NO van en este archivo. Despues de importar, desde la consola:
#   /password                                   (clave de admin, del gestor del grupo)
#   /user set monitor password=<clave> disabled=no   (si no se cargo al pegar, ver el final)

# gestion solo desde enlaces internos y loopbacks
/ip service
set [ find name=telnet ] disabled=yes
set [ find name=ftp ] disabled=yes
set [ find name=www ] disabled=yes
set [ find name=www-ssl ] disabled=yes
set [ find name=api ] disabled=yes
set [ find name=api-ssl ] disabled=yes
set [ find name=reverse-proxy ] disabled=yes
set [ find name=ssh ] address=10.0.0.0/24,10.255.255.0/24
set [ find name=winbox ] address=10.0.0.0/24,10.255.255.0/24

/ip ssh set strong-crypto=yes

/ip socks set enabled=no
/ip upnp set enabled=no
/ip proxy set enabled=no
# 7.24: ddns-enabled=no ya no es valido y cloud no esta soportado en CHR free
/ip cloud set update-time=no
/ip dns set allow-remote-requests=no
/tool bandwidth-server set enabled=no

# descubrimiento de vecinos y acceso por MAC solo en enlaces internos
/ip neighbor discovery-settings set discover-interface-list=LAN
/tool mac-server set allowed-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN

# Usuario de solo lectura. Va al final a proposito: si el script se pega en la consola,
# RouterOS 7.24 pide la clave del usuario en este paso y, si hubiera mas lineas despues,
# se comeria la siguiente como clave. Escribir la clave de monitor cuando la pida y despues:
#   /user set monitor disabled=no
/user add name=monitor group=read disabled=yes comment="solo lectura / consultas"
