# ISP-2 - AS 65002 - router-id 203.0.113.2
# Cableado en GNS3:
#   ether1 -> EDGE
# Si en el proyecto quedo en otra interfaz, cambiar el nombre antes de importar.
# Importar solo sobre un CHR limpio (/system reset-configuration no-defaults=yes):
# los add fallan con "already exists" si se vuelve a importar y /import corta en el primer error.

# ---------- F1: identidad, IPs de enlace y loopback ----------

/system identity set name=ISP-2

# CHR trae un dhcp-client en ether1 por defecto: no va en este diseno
/ip dhcp-client remove [ find ]

/interface ethernet
set [ find default-name=ether1 ] comment="to EDGE (cliente AS 65000)"

/interface bridge
add name=loopback protocol-mode=none comment="loopback / router-id"

/interface list
add name=CUSTOMER comment="enlace al cliente"

/interface list member
add list=CUSTOMER interface=ether1

/ip address
add address=192.0.2.5/30 interface=ether1 comment="EDGE"
add address=203.0.113.2/32 interface=loopback comment="loopback"

# Verificacion:
#   /ping 192.0.2.6 count=3

# ---------- F1: hardening (politica de seguridad, memoria 1.3) ----------
# Las claves NO van en este archivo. Despues de importar, desde la consola:
#   /password                                   (clave de admin, del gestor del grupo)
#   /user set monitor password=<clave> disabled=no

/user
add name=monitor group=read disabled=yes comment="solo lectura / consultas"

# gestion solo por consola de GNS3: ni el cliente ni el otro ISP tienen acceso
/ip service
set [ find name=telnet ] disabled=yes
set [ find name=ftp ] disabled=yes
set [ find name=www ] disabled=yes
set [ find name=www-ssl ] disabled=yes
set [ find name=api ] disabled=yes
set [ find name=api-ssl ] disabled=yes
set [ find name=reverse-proxy ] disabled=yes
set [ find name=ssh ] available-from=203.0.113.2/32
set [ find name=winbox ] available-from=203.0.113.2/32

/ip ssh set strong-crypto=yes

/ip socks set enabled=no
/ip upnp set enabled=no
/ip proxy set enabled=no
# 7.24: ddns-enabled=no ya no es valido y cloud no esta soportado en CHR free
/ip cloud set update-time=no
/ip dns set allow-remote-requests=no
/tool bandwidth-server set enabled=no

# el unico enlace es hacia el cliente: sin descubrimiento ni acceso por MAC
/ip neighbor discovery-settings set discover-interface-list=none
/tool mac-server set allowed-interface-list=none
/tool mac-server mac-winbox set allowed-interface-list=none

# puertos sin cableado: se apagan (review de R5)
/interface ethernet
set [ find default-name=ether2 ] disabled=yes comment="sin uso"
set [ find default-name=ether3 ] disabled=yes comment="sin uso"
set [ find default-name=ether4 ] disabled=yes comment="sin uso"

# ---------- F3: eBGP con EDGE (memoria 1.3: TCP-MD5, una clave distinta por sesion) ----------
# ISP-2 (AS 65002) anuncia su loopback y le manda la ruta por defecto al cliente (EDGE, AS 65000).
# La clave TCP-MD5 NO va en este archivo: la sesion se crea deshabilitada y se activa por consola:
#   /routing bgp connection set [ find name=to-EDGE ] tcp-md5-key=<clave de la sesion EDGE-ISP-2> disabled=no

/ip firewall address-list
add list=bgp-anuncios address=203.0.113.2/32 comment="loopback de ISP-2 anunciada por BGP"

# en 7.24 el AS y el router-id van en /routing bgp instance; la conexion apunta a la instancia
/routing bgp instance
add name=bgp-isp2 as=65002 router-id=203.0.113.2 comment="AS 65002"

/routing bgp connection
add name=to-EDGE instance=bgp-isp2 local.address=192.0.2.5 local.role=ebgp remote.address=192.0.2.6 remote.as=65000 output.network=bgp-anuncios output.default-originate=always disabled=yes comment="eBGP con EDGE (cliente AS 65000)"

# Verificacion:
#   /routing bgp session print       -> to-EDGE en established
#   /ip route print where bgp        -> 10.10.10.0/24 y 10.10.20.0/24 aprendidas de EDGE

# ---------- F3: plano de gestion del ISP ----------
# El ISP solo atiende BGP del cliente y ping; la gestion es por consola de GNS3.
/ip firewall filter
add chain=input connection-state=established,related,untracked action=accept comment="input: respuestas"
add chain=input connection-state=invalid action=drop comment="input: invalidos"
add chain=input protocol=icmp action=accept comment="input: ping y diagnostico"
add chain=input src-address=192.0.2.6 protocol=tcp dst-port=179 action=accept comment="input: BGP solo desde EDGE"
add chain=input action=drop comment="input: todo lo demas"
