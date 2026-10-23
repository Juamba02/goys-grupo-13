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

# ---------- F3: eBGP multi-homing con ISP-1 e ISP-2 (memoria 1.3: TCP-MD5, una clave distinta por sesion) ----------
# EDGE (AS 65000) redistribuye OSPF -> BGP pero solo anuncia las dos LANs (sin transito entre ISPs),
# acepta de los ISP solo la ruta por defecto y sus loopbacks, y mete la default en OSPF.
# Las claves TCP-MD5 NO van en este archivo: las sesiones se crean deshabilitadas y se activan por consola:
#   /routing bgp connection set [ find name=to-ISP-1 ] tcp-md5-key=<clave EDGE-ISP-1> disabled=no
#   /routing bgp connection set [ find name=to-ISP-2 ] tcp-md5-key=<clave EDGE-ISP-2> disabled=no

/routing filter rule
add chain=bgp-out-isp rule="if (dst == 10.10.10.0/24 || dst == 10.10.20.0/24) { accept }" comment="solo las LANs del grupo"
add chain=bgp-out-isp rule="reject" comment="nada mas: no somos transito entre ISPs"
add chain=bgp-in-isp rule="if (dst == 0.0.0.0/0 || dst in 203.0.113.0/24) { accept }" comment="default y loopbacks de los ISP"
add chain=bgp-in-isp rule="reject"

# en 7.24 el AS y el router-id van en /routing bgp instance; las conexiones apuntan a la instancia
/routing bgp instance
add name=bgp-edge as=65000 router-id=10.255.255.3 comment="AS 65000"

/routing bgp connection
add name=to-ISP-1 instance=bgp-edge local.address=192.0.2.2 local.role=ebgp remote.address=192.0.2.1 remote.as=65001 output.redistribute=ospf output.filter-chain=bgp-out-isp input.filter=bgp-in-isp disabled=yes comment="eBGP con ISP-1"
add name=to-ISP-2 instance=bgp-edge local.address=192.0.2.6 local.role=ebgp remote.address=192.0.2.5 remote.as=65002 output.redistribute=ospf output.filter-chain=bgp-out-isp input.filter=bgp-in-isp disabled=yes comment="eBGP con ISP-2"

# la ruta por defecto aprendida por BGP se propaga al resto de la red por OSPF
/routing ospf instance set [ find name=ospf-v2 ] originate-default=if-installed

# Verificacion:
#   /routing bgp session print       -> to-ISP-1 y to-ISP-2 en established
#   /ip route print where bgp        -> 0.0.0.0/0, 203.0.113.1/32 y 203.0.113.2/32
#   en ISP-1/ISP-2: /ip route print where bgp -> solo 10.10.10.0/24 y 10.10.20.0/24

# ---------- F3: firewall del EDGE (filtro de entrada y plano de gestion) ----------
# input: solo lo que el router necesita (BGP desde los ISP, OSPF y gestion desde adentro, ping).
# forward: las LANs salen; desde los ISP solo entran respuestas. Antispoofing en raw.
# Las reglas de accept de established/related van primero para no cortar las sesiones ya armadas.

/ip firewall address-list
add list=bgp-peers address=192.0.2.1 comment="ISP-1"
add list=bgp-peers address=192.0.2.5 comment="ISP-2"
add list=gestion address=10.0.0.0/24 comment="enlaces internos"
add list=gestion address=10.255.255.0/24 comment="loopbacks"

/ip firewall raw
add chain=prerouting in-interface-list=WAN src-address=10.0.0.0/8 action=drop comment="antispoofing: origen interno desde los ISP"

/ip firewall filter
add chain=input connection-state=established,related,untracked action=accept comment="input: respuestas"
add chain=input connection-state=invalid action=drop comment="input: invalidos"
add chain=input protocol=icmp action=accept comment="input: ping y diagnostico"
add chain=input in-interface-list=WAN src-address-list=bgp-peers protocol=tcp dst-port=179 action=accept comment="input: BGP solo desde los ISP"
add chain=input in-interface-list=LAN protocol=ospf action=accept comment="input: OSPF desde los CORE"
add chain=input in-interface-list=LAN src-address-list=gestion protocol=tcp dst-port=22,8291 action=accept comment="input: ssh y winbox solo desde gestion"
add chain=input in-interface-list=LAN protocol=udp dst-port=5678 action=accept comment="input: descubrimiento de vecinos (solo LAN)"
add chain=input action=drop comment="input: todo lo demas"
add chain=forward connection-state=established,related,untracked action=accept comment="forward: respuestas"
add chain=forward connection-state=invalid action=drop comment="forward: invalidos"
add chain=forward in-interface-list=LAN action=accept comment="forward: salida de las LANs"
add chain=forward in-interface-list=WAN action=drop comment="forward: nada nuevo desde los ISP"

# Verificacion:
#   /ip firewall filter print stats   -> los drop de input y forward suman paquetes, los accept de BGP/OSPF tambien
#   /routing bgp session print        -> las dos sesiones siguen established
#   /routing ospf neighbor print      -> CORE-1 y CORE-2 siguen en Full
