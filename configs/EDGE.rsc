# EDGE - AS 65000 - router-id 10.255.255.3
# Cableado en GNS3:
#   ether1 -> ISP-1   ether2 -> ISP-2   ether3 -> CORE-1   ether4 -> CORE-2
# Si en el proyecto quedaron en otro orden, cambiar los nombres antes de importar.
# Importar solo sobre un CHR limpio (/system reset-configuration no-defaults=yes):
# los add fallan con "already exists" si se vuelve a importar y /import corta en el primer error.

# ---------- F1: identidad, IPs de enlace y loopback ----------

/system identity set name=EDGE

# CHR trae un dhcp-client en ether1 por defecto: no va en este diseno
/ip dhcp-client remove [ find ]

/interface ethernet
set [ find default-name=ether1 ] comment="to ISP-1"
set [ find default-name=ether2 ] comment="to ISP-2"
set [ find default-name=ether3 ] comment="to CORE-1"
set [ find default-name=ether4 ] comment="to CORE-2"

/interface bridge
add name=loopback protocol-mode=none comment="loopback / router-id"

/interface list
add name=WAN comment="enlaces a proveedores"
add name=LAN comment="enlaces internos"

/interface list member
add list=WAN interface=ether1
add list=WAN interface=ether2
add list=LAN interface=ether3
add list=LAN interface=ether4
add list=LAN interface=loopback

/ip address
add address=192.0.2.2/30 interface=ether1 comment="ISP-1"
add address=192.0.2.6/30 interface=ether2 comment="ISP-2"
add address=10.0.0.1/30 interface=ether3 comment="CORE-1"
add address=10.0.0.5/30 interface=ether4 comment="CORE-2"
add address=10.255.255.3/32 interface=loopback comment="loopback"

# Verificacion:
#   /ping 192.0.2.1 count=3
#   /ping 192.0.2.5 count=3
#   /ping 10.0.0.2 count=3
#   /ping 10.0.0.6 count=3

# ---------- F1: hardening (politica de seguridad, memoria 1.3) ----------
# Las claves NO van en este archivo. Despues de importar, desde la consola:
#   /password                                   (clave de admin, del gestor del grupo)
#   /user set monitor password=<clave> disabled=no

/user
add name=monitor group=read disabled=yes comment="solo lectura / consultas"

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

# sin descubrimiento de vecinos ni acceso por MAC hacia los proveedores
/ip neighbor discovery-settings set discover-interface-list=LAN
/tool mac-server set allowed-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN

# ---------- F2: OSPF area 0 (memoria 1.3: MD5, una clave por area) ----------
# Convencion comun para EDGE, CORE-1, CORE-2, DIST-1 y DIST-2:
#   instancia ospf-v2 (version 2) con router-id = loopback; area backbone (0.0.0.0)
#   enlaces de transito /30: type=ptp, comment="ospf-transito"; MD5 con auth-id=1
#   loopback (y en los DIST las LANs de la lista ACCESS): passive
# La clave MD5 NO va en este archivo y RouterOS 7.24 no acepta auth=md5 sin auth-key, asi que
# la plantilla de transito se crea deshabilitada y se activa por consola, ya con MD5:
#   /routing ospf interface-template set [ find comment="ospf-transito" ] auth=md5 auth-id=1 auth-key=<clave del gestor> disabled=no
# Hacia los ISP (ether1, ether2) no se corre OSPF: ahi va eBGP en F3.

/routing ospf instance
add name=ospf-v2 version=2 router-id=10.255.255.3 comment="area 0 del grupo"

/routing ospf area
add name=backbone area-id=0.0.0.0 instance=ospf-v2

/routing ospf interface-template
add area=backbone interfaces=ether3,ether4 type=ptp disabled=yes comment="ospf-transito"
add area=backbone interfaces=loopback passive comment="ospf-loopback"

# Verificacion (con CORE-1 y CORE-2 configurados):
#   /routing ospf neighbor print     -> 10.255.255.1 y 10.255.255.2 en state=Full
#   /ip route print where ospf       -> loopbacks y enlaces internos aprendidos por OSPF
