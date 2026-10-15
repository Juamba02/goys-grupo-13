# ISP-1 - AS 65001 - router-id 203.0.113.1
# Cableado en GNS3:
#   ether1 -> EDGE
# Si en el proyecto quedo en otra interfaz, cambiar el nombre antes de importar.

# ---------- F1: identidad, IPs de enlace y loopback ----------

/system identity set name=ISP-1

/interface ethernet
set [ find default-name=ether1 ] comment="to EDGE (cliente AS 65000)"

/interface bridge
add name=loopback protocol-mode=none comment="loopback / router-id"

/interface list
add name=CUSTOMER comment="enlace al cliente"

/interface list member
add list=CUSTOMER interface=ether1

/ip address
add address=192.0.2.1/30 interface=ether1 comment="EDGE"
add address=203.0.113.1/32 interface=loopback comment="loopback"

# Verificacion:
#   /ping 192.0.2.2 count=3
