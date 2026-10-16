# 2026-10-16 01:38:14 by RouterOS 7.24.5
# system id = XKNasuXr9rC
#
/interface bridge
add comment="loopback / router-id" name=loopback protocol-mode=none
/interface ethernet
set [ find default-name=ether1 ] comment="to ISP-1" disable-running-check=no
set [ find default-name=ether2 ] comment="to ISP-2" disable-running-check=no
set [ find default-name=ether3 ] comment="to CORE-1" disable-running-check=no
set [ find default-name=ether4 ] comment="to CORE-2" disable-running-check=no
/interface list
add comment="enlaces a proveedores" name=WAN
add comment="enlaces internos" name=LAN
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=WAN
add interface=ether3 list=LAN
add interface=ether4 list=LAN
add interface=loopback list=LAN
/ip address
add address=192.0.2.2/30 comment=ISP-1 interface=ether1 network=192.0.2.0
add address=192.0.2.6/30 comment=ISP-2 interface=ether2 network=192.0.2.4
add address=10.0.0.1/30 comment=CORE-1 interface=ether3 network=10.0.0.0
add address=10.0.0.5/30 comment=CORE-2 interface=ether4 network=10.0.0.4
add address=10.255.255.3 comment=loopback interface=loopback network=\
    10.255.255.3
/ip service
set ftp disabled=yes
set ssh available-from=10.0.0.0/24,10.255.255.0/24
set telnet disabled=yes
set www disabled=yes
set reverse-proxy disabled=yes
set winbox available-from=10.0.0.0/24,10.255.255.0/24
set api disabled=yes
set api-ssl disabled=yes
/ip ssh
set strong-crypto=yes
/system identity
set name=EDGE
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
