# ISP-2 - AS 65002 - router-id 203.0.113.2
# Cableado en GNS3:
#   ether1 -> EDGE
# Si en el proyecto quedo en otra interfaz, cambiar el nombre antes de importar.

# ---------- F1: identidad, IPs de enlace y loopback ----------

/system identity set name=ISP-2

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
add name=monitor group=read disabled=yes comment="solo lectura / consultas y SNMP"

/ip service
set [ find name=telnet ] disabled=yes
set [ find name=ftp ] disabled=yes
set [ find name=www ] disabled=yes
set [ find name=www-ssl ] disabled=yes
set [ find name=api ] disabled=yes
set [ find name=api-ssl ] disabled=yes
set [ find name=reverse-proxy ] disabled=yes
set [ find name=ssh ] address=203.0.113.0/24
set [ find name=winbox ] address=203.0.113.0/24

/ip ssh set strong-crypto=yes

/ip socks set enabled=no
/ip upnp set enabled=no
/ip proxy set enabled=no
/ip cloud set update-time=no
/ip dns set allow-remote-requests=no
/tool bandwidth-server set enabled=no

# el unico enlace es hacia el cliente: sin descubrimiento ni acceso por MAC
/ip neighbor discovery-settings set discover-interface-list=none
/tool mac-server set allowed-interface-list=none
/tool mac-server mac-winbox set allowed-interface-list=none
