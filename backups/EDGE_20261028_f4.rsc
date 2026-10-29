# 2026-10-28 21:49:14 by RouterOS 7.24.5
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
/routing bgp instance
add as=65000 comment="AS 65000" name=bgp-edge router-id=10.255.255.3
/routing ospf instance
add comment="area 0 del grupo" name=ospf-v2 originate-default=if-installed \
    router-id=10.255.255.3
/routing ospf area
add instance=ospf-v2 name=backbone
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
/ip firewall address-list
add address=192.0.2.1 comment=ISP-1 list=bgp-peers
add address=192.0.2.5 comment=ISP-2 list=bgp-peers
add address=10.0.0.0/24 comment="enlaces internos" list=gestion
add address=10.255.255.0/24 comment=loopbacks list=gestion
/ip firewall filter
add action=accept chain=input comment="input: respuestas" connection-state=\
    established,related,untracked
add action=drop chain=input comment="input: invalidos" connection-state=\
    invalid
add action=accept chain=input comment="input: ping y diagnostico" protocol=\
    icmp
add action=accept chain=input comment="input: BGP solo desde los ISP" \
    dst-port=179 in-interface-list=WAN protocol=tcp src-address-list=\
    bgp-peers
add action=accept chain=input comment="input: OSPF desde los CORE" \
    in-interface-list=LAN protocol=ospf
add action=accept chain=input comment=\
    "input: ssh y winbox solo desde gestion" dst-port=22,8291 \
    in-interface-list=LAN protocol=tcp src-address-list=gestion
add action=accept chain=input comment=\
    "input: descubrimiento de vecinos (solo LAN)" dst-port=5678 \
    in-interface-list=LAN protocol=udp
add action=drop chain=input comment="input: todo lo demas"
add action=accept chain=forward comment="forward: respuestas" \
    connection-state=established,related,untracked
add action=drop chain=forward comment="forward: invalidos" connection-state=\
    invalid
add action=accept chain=forward comment="forward: salida de las LANs" \
    in-interface-list=LAN
add action=drop chain=forward comment="forward: nada nuevo desde los ISP" \
    in-interface-list=WAN
/ip firewall raw
add action=drop chain=prerouting comment=\
    "antispoofing: origen interno desde los ISP" in-interface-list=WAN \
    src-address=10.0.0.0/8
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
/routing bgp connection
add comment="eBGP con ISP-1" disabled=no hold-time=9s input.filter=bgp-in-isp \
    instance=bgp-edge keepalive-time=3s local.address=192.0.2.2 .role=ebgp \
    name=to-ISP-1 output.filter-chain=bgp-out-isp .redistribute=ospf \
    remote.address=192.0.2.1 .as=65001
add comment="eBGP con ISP-2" disabled=no hold-time=9s input.filter=bgp-in-isp \
    instance=bgp-edge keepalive-time=3s local.address=192.0.2.6 .role=ebgp \
    name=to-ISP-2 output.filter-chain=bgp-out-isp .redistribute=ospf \
    remote.address=192.0.2.5 .as=65002
/routing filter rule
add chain=bgp-out-isp comment="solo las LANs del grupo" rule=\
    "if (dst == 10.10.10.0/24 || dst == 10.10.20.0/24) { accept }"
add chain=bgp-out-isp comment="nada mas: no somos transito entre ISPs" rule=\
    reject
add chain=bgp-in-isp comment="default y loopbacks de los ISP" rule=\
    "if (dst == 0.0.0.0/0 || dst in 203.0.113.0/24) { accept }"
add chain=bgp-in-isp rule=reject
/routing ospf interface-template
add area=backbone comment=ospf-loopback interfaces=loopback passive
add area=backbone auth=md5 auth-id=1 comment=ospf-transito disabled=no \
    interfaces=ether3,ether4 type=ptp
/system identity
set name=EDGE
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
