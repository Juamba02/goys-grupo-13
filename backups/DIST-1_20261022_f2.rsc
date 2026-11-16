# 2026-10-23 00:31:33 by RouterOS 7.24.5
# system id = jVYLzupMeIC
#
/interface bridge
add comment="loopback / router-id" name=loopback protocol-mode=none
/interface ethernet
set [ find default-name=ether1 ] comment="to CORE-1" disable-running-check=no
set [ find default-name=ether2 ] comment="to CORE-2" disable-running-check=no
set [ find default-name=ether3 ] comment="to LAN USERS (SW-USERS)" disable-running-check=no
set [ find default-name=ether4 ] comment="to LAN SERVERS (SW-SERVERS)" disable-running-check=no
/interface vrrp
add authentication=simple comment="gateway LAN USERS" interface=ether3 name=vrrp10 priority=150 version=2 vrid=10
add authentication=simple comment="gateway LAN SERVERS" interface=ether4 name=vrrp20 version=2 vrid=20
/interface list
add comment="enlaces internos" name=LAN
add comment="LANs de usuarios y servidores" name=ACCESS
/routing ospf instance
add comment="area 0 del grupo" name=ospf-v2 router-id=10.255.255.4
/routing ospf area
add instance=ospf-v2 name=backbone
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add interface=ether1 list=LAN
add interface=ether2 list=LAN
add interface=ether3 list=ACCESS
add interface=ether4 list=ACCESS
add interface=loopback list=LAN
/ip address
add address=10.0.0.14/30 comment=CORE-1 interface=ether1 network=10.0.0.12
add address=10.0.0.22/30 comment=CORE-2 interface=ether2 network=10.0.0.20
add address=10.10.10.2/24 comment="LAN USERS (IP fisica; la VIP de VRRP va en F2)" interface=ether3 network=10.10.10.0
add address=10.10.20.2/24 comment="LAN SERVERS (IP fisica; la VIP de VRRP va en F2)" interface=ether4 network=10.10.20.0
add address=10.255.255.4 comment=loopback interface=loopback network=10.255.255.4
add address=10.10.10.1 comment="VIP LAN USERS (vrid 10)" interface=vrrp10 network=10.10.10.1
add address=10.10.20.1 comment="VIP LAN SERVERS (vrid 20)" interface=vrrp20 network=10.10.20.1
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
add area=backbone auth=md5 auth-id=1 comment=ospf-transito disabled=no interfaces=ether1,ether2 type=ptp
add area=backbone comment=ospf-loopback interfaces=loopback passive
add area=backbone comment=ospf-lans interfaces=ether3,ether4 passive
/system identity
set name=DIST-1
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
