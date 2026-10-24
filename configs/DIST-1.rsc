# DIST-1 - distribucion (VRRP en F2: master vrid 10, backup vrid 20) - router-id 10.255.255.4
# Cableado en GNS3:
#   ether1 -> CORE-1   ether2 -> CORE-2   ether3 -> LAN USERS   ether4 -> LAN SERVERS
# Si en el proyecto quedaron en otro orden, cambiar los nombres antes de importar.
# Importar solo sobre un CHR limpio (/system reset-configuration no-defaults=yes):
# los add fallan con "already exists" si se vuelve a importar y /import corta en el primer error.
# F2 (OSPF y VRRP) y F3 (plano de gestion) van despues del hardening; el usuario monitor sigue al final.

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

# ---------- F2: OSPF area 0 (memoria 1.3: MD5, una clave por area) ----------
# Misma convencion que EDGE (#13): instancia ospf-v2, router-id = loopback, area backbone;
# enlaces de transito /30 type=ptp con MD5 auth-id=1; loopback y LANs (ether3 y ether4, lista ACCESS) passive,
# asi se anuncian las LANs sin armar adyacencias hacia los hosts.
# Si el router ya tiene F1, pegar solo los bloques de F2.
# La clave MD5 NO va en este archivo y RouterOS 7.24 no acepta auth=md5 sin auth-key, asi que
# la plantilla de transito se crea deshabilitada y se activa por consola, ya con MD5:
#   /routing ospf interface-template set [ find comment="ospf-transito" ] auth=md5 auth-id=1 auth-key=<clave del gestor> disabled=no

/routing ospf instance
add name=ospf-v2 version=2 router-id=10.255.255.4 comment="area 0 del grupo"

/routing ospf area
add name=backbone area-id=0.0.0.0 instance=ospf-v2

/routing ospf interface-template
add area=backbone interfaces=ether1,ether2 type=ptp disabled=yes comment="ospf-transito"
add area=backbone interfaces=loopback passive comment="ospf-loopback"
add area=backbone interfaces=ether3,ether4 passive comment="ospf-lans"

# ---------- F2: VRRP (memoria 1.2: load-sharing; 1.3: auth simple, una clave por grupo) ----------
# vrid 10 en LAN USERS (ether3) y vrid 20 en LAN SERVERS (ether4), VIP .1 en cada LAN.
# DIST-1: master de vrid 10 (priority 150) y backup de vrid 20 (priority 100).
# La auth de VRRP solo existe en version=2. Las claves NO van en este archivo (distintas por
# grupo, maximo 8 caracteres): los grupos se crean deshabilitados y se activan por consola:
#   /interface vrrp set [ find name=vrrp10 ] authentication=simple password=<clave vrid 10> disabled=no
#   /interface vrrp set [ find name=vrrp20 ] authentication=simple password=<clave vrid 20> disabled=no

/interface vrrp
add name=vrrp10 interface=ether3 vrid=10 priority=150 version=2 disabled=yes comment="gateway LAN USERS"
add name=vrrp20 interface=ether4 vrid=20 priority=100 version=2 disabled=yes comment="gateway LAN SERVERS"

/ip address
add address=10.10.10.1/32 interface=vrrp10 comment="VIP LAN USERS (vrid 10)"
add address=10.10.20.1/32 interface=vrrp20 comment="VIP LAN SERVERS (vrid 20)"

# Verificacion (con el otro DIST configurado):
#   /routing ospf neighbor print     -> 10.255.255.1 y 10.255.255.2 en state=Full
#   /interface vrrp print            -> vrrp10 master (M), vrrp20 backup
#   desde PC-USER: ping 10.10.10.1 / desde SRV: ping 10.10.20.1

# ---------- F3: plano de gestion (firewall de input) ----------
# Misma convencion que EDGE (f3-bgp-edge-isp): el router solo atiende lo que necesita.
# input: OSPF y gestion (ssh/winbox) solo por los enlaces a los CORE (lista LAN); VRRP solo por
# las LANs (lista ACCESS); ping desde cualquier lado (los hosts prueban su gateway). Desde las LANs
# no se llega a ssh/winbox ni a ningun otro servicio del router.
# VRRP tiene que estar aceptado: si se descartan los anuncios del otro DIST, los dos quedan master.
# La sesion de consola de GNS3 no pasa por el firewall: se puede aplicar sin perder acceso.

/ip firewall address-list
add list=gestion address=10.0.0.0/24 comment="enlaces internos"
add list=gestion address=10.255.255.0/24 comment="loopbacks"

/ip firewall filter
add chain=input connection-state=established,related,untracked action=accept comment="input: respuestas"
add chain=input connection-state=invalid action=drop comment="input: invalidos"
add chain=input protocol=icmp action=accept comment="input: ping y diagnostico"
add chain=input in-interface-list=LAN protocol=ospf action=accept comment="input: OSPF desde los CORE"
add chain=input in-interface-list=ACCESS protocol=vrrp action=accept comment="input: VRRP del otro DIST (LANs)"
add chain=input in-interface-list=LAN src-address-list=gestion protocol=tcp dst-port=22,8291 action=accept comment="input: ssh y winbox solo desde gestion"
add chain=input in-interface-list=LAN protocol=udp dst-port=5678 action=accept comment="input: descubrimiento de vecinos (solo LAN)"
add chain=input action=drop comment="input: todo lo demas"

# Verificacion:
#   /ip firewall filter print stats   -> los accept de OSPF y VRRP suman paquetes; el drop final, lo no esperado
#   /routing ospf neighbor print      -> CORE-1 y CORE-2 siguen en Full
#   /interface vrrp print             -> vrrp10 master, vrrp20 backup (un solo master por grupo)
#   desde PC-USER: ping 10.10.10.1 responde; ping 10.10.10.2 -P 6 -p 22 (ssh) no

# Usuario de solo lectura. Va al final a proposito: si el script se pega en la consola,
# RouterOS 7.24 pide la clave del usuario en este paso y, si hubiera mas lineas despues,
# se comeria la siguiente como clave. Escribir la clave de monitor cuando la pida y despues:
#   /user set monitor disabled=no
/user add name=monitor group=read disabled=yes comment="solo lectura / consultas"
