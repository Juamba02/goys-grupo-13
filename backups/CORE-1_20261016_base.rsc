# 2026-10-16 16:06:28 by RouterOS 7.24.5
# system id = Y8SqBiKLccH
#
/interface bridge
add comment="loopback / router-id" name=loopback protocol-mode=none
/interface ethernet
set [ find default-name=ether1 ] comment="to EDGE" disable-running-check=no
set [ find default-name=ether2 ] comment="to CORE-2 (core-core)" disable-running-check=no
set [ find default-name=ether3 ] comment="to DIST-1" disable-running-check=no
set [ find default-name=ether4 ] comment="to DIST-2" disable-running-check=no
/interface list
add comment="enlaces internos" name=LAN
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add interface=ether1 list=LAN
add interface=ether2 list=LAN
add interface=ether3 list=LAN
add interface=ether4 list=LAN
add interface=loopback list=LAN
/ip address
add address=10.0.0.2/30 comment=EDGE interface=ether1 network=10.0.0.0
add address=10.0.0.9/30 comment=CORE-2 interface=ether2 network=10.0.0.8
add address=10.0.0.13/30 comment=DIST-1 interface=ether3 network=10.0.0.12
add address=10.0.0.17/30 comment=DIST-2 interface=ether4 network=10.0.0.16
add address=10.255.255.1 comment=loopback interface=loopback network=10.255.255.1
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
set name=CORE-1
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
