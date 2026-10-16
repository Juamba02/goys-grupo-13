# 2026-10-16 16:08:00 by RouterOS 7.24.5
# system id = rmIqCjnNQmP
#
/interface bridge
add comment="loopback / router-id" name=loopback protocol-mode=none
/interface ethernet
set [ find default-name=ether1 ] comment="to CORE-1" disable-running-check=no
set [ find default-name=ether2 ] comment="to CORE-2" disable-running-check=no
set [ find default-name=ether3 ] comment="to LAN USERS (SW-USERS)" disable-running-check=no
set [ find default-name=ether4 ] comment="to LAN SERVERS (SW-SERVERS)" disable-running-check=no
/interface list
add comment="enlaces internos" name=LAN
add comment="LANs de usuarios y servidores" name=ACCESS
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add interface=ether1 list=LAN
add interface=ether2 list=LAN
add interface=ether3 list=ACCESS
add interface=ether4 list=ACCESS
add interface=loopback list=LAN
/ip address
add address=10.0.0.18/30 comment=CORE-1 interface=ether1 network=10.0.0.16
add address=10.0.0.26/30 comment=CORE-2 interface=ether2 network=10.0.0.24
add address=10.10.10.3/24 comment="LAN USERS (IP fisica; la VIP de VRRP va en F2)" interface=ether3 network=10.10.10.0
add address=10.10.20.3/24 comment="LAN SERVERS (IP fisica; la VIP de VRRP va en F2)" interface=ether4 network=\
    10.10.20.0
add address=10.255.255.5 comment=loopback interface=loopback network=10.255.255.5
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
set name=DIST-2
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
