# 2026-10-23 00:31:01 by RouterOS 7.24.5
# system id = E8Y+sPnbLMO
#
/interface bridge
add comment="loopback / router-id" name=loopback protocol-mode=none
/interface ethernet
set [ find default-name=ether1 ] comment="to EDGE" disable-running-check=no
set [ find default-name=ether2 ] comment="to CORE-1 (core-core)" disable-running-check=no
set [ find default-name=ether3 ] comment="to DIST-1" disable-running-check=no
set [ find default-name=ether4 ] comment="to DIST-2" disable-running-check=no
/interface list
add comment="enlaces internos" name=LAN
/routing ospf instance
add comment="area 0 del grupo" name=ospf-v2 router-id=10.255.255.2
/routing ospf area
add instance=ospf-v2 name=backbone
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add interface=ether1 list=LAN
add interface=ether2 list=LAN
add interface=ether3 list=LAN
add interface=ether4 list=LAN
add interface=loopback list=LAN
/ip address
add address=10.0.0.6/30 comment=EDGE interface=ether1 network=10.0.0.4
add address=10.0.0.10/30 comment=CORE-1 interface=ether2 network=10.0.0.8
add address=10.0.0.21/30 comment=DIST-1 interface=ether3 network=10.0.0.20
add address=10.0.0.25/30 comment=DIST-2 interface=ether4 network=10.0.0.24
add address=10.255.255.2 comment=loopback interface=loopback network=10.255.255.2
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
/routing ospf interface-template
add area=backbone auth=md5 auth-id=1 comment=ospf-transito disabled=no interfaces=ether1,ether2,ether3,ether4 type=ptp
add area=backbone comment=ospf-loopback interfaces=loopback passive
/system identity
set name=CORE-2
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
