# CORE-2 - core (transito puro) - router-id 10.255.255.2
# Cableado en GNS3:
#   ether1 -> EDGE   ether2 -> CORE-1   ether3 -> DIST-1   ether4 -> DIST-2
# Si en el proyecto quedaron en otro orden, cambiar los nombres antes de importar.
# Importar solo sobre un CHR limpio (/system reset-configuration no-defaults=yes):
# los add fallan con "already exists" si se vuelve a importar y /import corta en el primer error.
# F2 (OSPF) y F3 (plano de gestion) van despues del hardening; el usuario monitor sigue al final.

# ---------- F1: identidad, IPs de enlace y loopback ----------

/system identity set name=CORE-2

# CHR trae un dhcp-client en ether1 por defecto: no va en este diseno
/ip dhcp-client remove [ find ]

/interface ethernet
set [ find default-name=ether1 ] comment="to EDGE"
set [ find default-name=ether2 ] comment="to CORE-1 (core-core)"
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
add address=10.0.0.6/30 interface=ether1 comment="EDGE"
add address=10.0.0.10/30 interface=ether2 comment="CORE-1"
add address=10.0.0.21/30 interface=ether3 comment="DIST-1"
add address=10.0.0.25/30 interface=ether4 comment="DIST-2"
add address=10.255.255.2/32 interface=loopback comment="loopback"

# Verificacion (vecinos directos):
#   /ping 10.0.0.5 count=3      (EDGE)
#   /ping 10.0.0.9 count=3      (CORE-1)
#   /ping 10.0.0.22 count=3      (DIST-1)
#   /ping 10.0.0.26 count=3      (DIST-2)

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

# descubrimiento de vecinos y acceso por MAC solo en enlaces internos
/ip neighbor discovery-settings set discover-interface-list=LAN
/tool mac-server set allowed-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN

# ---------- F2: OSPF area 0 (memoria 1.3: MD5, una clave por area) ----------
# Misma convencion que EDGE (#13): instancia ospf-v2, router-id = loopback, area backbone;
# enlaces de transito /30 type=ptp con MD5 auth-id=1; loopback passive.
# Si el router ya tiene F1, pegar solo este bloque.
# La clave MD5 NO va en este archivo y RouterOS 7.24 no acepta auth=md5 sin auth-key, asi que
# la plantilla de transito se crea deshabilitada y se activa por consola, ya con MD5:
#   /routing ospf interface-template set [ find comment="ospf-transito" ] auth=md5 auth-id=1 auth-key=<clave del gestor> disabled=no

/routing ospf instance
add name=ospf-v2 version=2 router-id=10.255.255.2 comment="area 0 del grupo"

/routing ospf area
add name=backbone area-id=0.0.0.0 instance=ospf-v2

/routing ospf interface-template
add area=backbone interfaces=ether1,ether2,ether3,ether4 type=ptp disabled=yes comment="ospf-transito"
add area=backbone interfaces=loopback passive comment="ospf-loopback"

# Verificacion (con EDGE, el otro CORE y los DIST configurados):
#   /routing ospf neighbor print     -> 10.255.255.3 (EDGE), .1 (CORE-1), .4 (DIST-1) y .5 (DIST-2) en state=Full
#   /ip route print where ospf       -> loopbacks, enlaces internos y LANs aprendidos por OSPF

# ---------- F3: plano de gestion (firewall de input) ----------
# Misma convencion que EDGE (f3-bgp-edge-isp): el router solo atiende lo que necesita.
# input: OSPF y gestion (ssh/winbox) solo por los enlaces internos (lista LAN), ping, y nada mas.
# CORE es transito puro: no se filtra forward.
# La sesion de consola de GNS3 no pasa por el firewall: se puede aplicar sin perder acceso.

/ip firewall address-list
add list=gestion address=10.0.0.0/24 comment="enlaces internos"
add list=gestion address=10.255.255.0/24 comment="loopbacks"

/ip firewall filter
add chain=input connection-state=established,related,untracked action=accept comment="input: respuestas"
add chain=input connection-state=invalid action=drop comment="input: invalidos"
add chain=input protocol=icmp action=accept comment="input: ping y diagnostico"
add chain=input in-interface-list=LAN protocol=ospf action=accept comment="input: OSPF desde EDGE, el otro CORE y los DIST"
add chain=input in-interface-list=LAN src-address-list=gestion protocol=tcp dst-port=22,8291 action=accept comment="input: ssh y winbox solo desde gestion"
add chain=input in-interface-list=LAN protocol=udp dst-port=5678 action=accept comment="input: descubrimiento de vecinos (solo LAN)"
add chain=input action=drop comment="input: todo lo demas"

# Verificacion:
#   /ip firewall filter print stats   -> el accept de OSPF suma paquetes; el drop final, lo no esperado
#   /routing ospf neighbor print      -> EDGE, CORE-1, DIST-1 y DIST-2 siguen en Full

# Usuario de solo lectura. Va al final a proposito: si el script se pega en la consola,
# RouterOS 7.24 pide la clave del usuario en este paso y, si hubiera mas lineas despues,
# se comeria la siguiente como clave. Escribir la clave de monitor cuando la pida y despues:
#   /user set monitor disabled=no
/user add name=monitor group=read disabled=yes comment="solo lectura / consultas"
