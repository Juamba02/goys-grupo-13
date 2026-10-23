# DIST-2 - distribucion (VRRP en F2: master vrid 20, backup vrid 10) - router-id 10.255.255.5
# Cableado en GNS3:
#   ether1 -> CORE-1   ether2 -> CORE-2   ether3 -> LAN USERS   ether4 -> LAN SERVERS
# Si en el proyecto quedaron en otro orden, cambiar los nombres antes de importar.
# Importar solo sobre un CHR limpio (/system reset-configuration no-defaults=yes):
# los add fallan con "already exists" si se vuelve a importar y /import corta en el primer error.
# F2 (OSPF y VRRP) va despues del hardening; el usuario monitor sigue al final.

# ---------- F1: identidad, IPs de enlace y loopback ----------

/system identity set name=DIST-2

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
add address=10.0.0.18/30 interface=ether1 comment="CORE-1"
add address=10.0.0.26/30 interface=ether2 comment="CORE-2"
add address=10.10.10.3/24 interface=ether3 comment="LAN USERS (IP fisica; la VIP de VRRP va en F2)"
add address=10.10.20.3/24 interface=ether4 comment="LAN SERVERS (IP fisica; la VIP de VRRP va en F2)"
add address=10.255.255.5/32 interface=loopback comment="loopback"

# Verificacion (vecinos directos):
#   /ping 10.0.0.17 count=3      (CORE-1)
#   /ping 10.0.0.25 count=3      (CORE-2)
#   /ping 10.10.10.2 count=3      (DIST-1 por LAN USERS)
#   /ping 10.10.20.2 count=3      (DIST-1 por LAN SERVERS)

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

# ---------- F2: OSPF area 0 (memoria 1.3: MD5, una clave por area) ----------
# Misma convencion que EDGE (#13): instancia ospf-v2, router-id = loopback, area backbone;
# enlaces de transito /30 type=ptp con MD5 auth-id=1; loopback y LANs (ether3 y ether4, lista ACCESS) passive,
# asi se anuncian las LANs sin armar adyacencias hacia los hosts.
# Si el router ya tiene F1, pegar solo los bloques de F2.
# La clave MD5 NO va en este archivo y RouterOS 7.24 no acepta auth=md5 sin auth-key, asi que
# la plantilla de transito se crea deshabilitada y se activa por consola, ya con MD5:
#   /routing ospf interface-template set [ find comment="ospf-transito" ] auth=md5 auth-id=1 auth-key=<clave del gestor> disabled=no

/routing ospf instance
add name=ospf-v2 version=2 router-id=10.255.255.5 comment="area 0 del grupo"

/routing ospf area
add name=backbone area-id=0.0.0.0 instance=ospf-v2

/routing ospf interface-template
add area=backbone interfaces=ether1,ether2 type=ptp disabled=yes comment="ospf-transito"
add area=backbone interfaces=loopback passive comment="ospf-loopback"
add area=backbone interfaces=ether3,ether4 passive comment="ospf-lans"

# ---------- F2: VRRP (memoria 1.2: load-sharing; 1.3: auth simple, una clave por grupo) ----------
# vrid 10 en LAN USERS (ether3) y vrid 20 en LAN SERVERS (ether4), VIP .1 en cada LAN.
# DIST-2: master de vrid 20 (priority 150) y backup de vrid 10 (priority 100).
# La auth de VRRP solo existe en version=2. Las claves NO van en este archivo (distintas por
# grupo, maximo 8 caracteres): los grupos se crean deshabilitados y se activan por consola:
#   /interface vrrp set [ find name=vrrp10 ] authentication=simple password=<clave vrid 10> disabled=no
#   /interface vrrp set [ find name=vrrp20 ] authentication=simple password=<clave vrid 20> disabled=no

/interface vrrp
add name=vrrp10 interface=ether3 vrid=10 priority=100 version=2 disabled=yes comment="gateway LAN USERS"
add name=vrrp20 interface=ether4 vrid=20 priority=150 version=2 disabled=yes comment="gateway LAN SERVERS"

/ip address
add address=10.10.10.1/32 interface=vrrp10 comment="VIP LAN USERS (vrid 10)"
add address=10.10.20.1/32 interface=vrrp20 comment="VIP LAN SERVERS (vrid 20)"

# Verificacion (con el otro DIST configurado):
#   /routing ospf neighbor print     -> 10.255.255.1 y 10.255.255.2 en state=Full
#   /interface vrrp print            -> vrrp20 master (M), vrrp10 backup
#   desde PC-USER: ping 10.10.10.1 / desde SRV: ping 10.10.20.1

# Usuario de solo lectura. Va al final a proposito: si el script se pega en la consola,
# RouterOS 7.24 pide la clave del usuario en este paso y, si hubiera mas lineas despues,
# se comeria la siguiente como clave. Escribir la clave de monitor cuando la pida y despues:
#   /user set monitor disabled=no
/user add name=monitor group=read disabled=yes comment="solo lectura / consultas"
