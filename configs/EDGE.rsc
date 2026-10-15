# EDGE - AS 65000 - router-id 10.255.255.3
# Cableado en GNS3:
#   ether1 -> ISP-1   ether2 -> ISP-2   ether3 -> CORE-1   ether4 -> CORE-2
# Si en el proyecto quedaron en otro orden, cambiar los nombres antes de importar.

# ---------- F1: identidad, IPs de enlace y loopback ----------

/system identity set name=EDGE

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
