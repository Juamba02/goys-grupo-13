# 2026-10-23 19:57:34 by RouterOS 7.24.5
# system id = Ie65IEJuTcO
#
/interface bridge
add comment="loopback / router-id" name=loopback protocol-mode=none
/interface ethernet
set [ find default-name=ether1 ] comment="to EDGE (cliente AS 65000)" \
    disable-running-check=no
set [ find default-name=ether2 ] comment="sin uso" disable-running-check=no \
    disabled=yes
set [ find default-name=ether3 ] comment="sin uso" disable-running-check=no \
    disabled=yes
set [ find default-name=ether4 ] comment="sin uso" disable-running-check=no \
    disabled=yes
/interface list
add comment="enlace al cliente" name=CUSTOMER
/routing bgp instance
add as=65001 comment="AS 65001" name=bgp-isp1 router-id=203.0.113.1
/ip neighbor discovery-settings
set discover-interface-list=none
/interface list member
add interface=ether1 list=CUSTOMER
/ip address
add address=192.0.2.1/30 comment=EDGE interface=ether1 network=192.0.2.0
add address=203.0.113.1 comment=loopback interface=loopback network=\
    203.0.113.1
/ip firewall address-list
add address=203.0.113.1 comment="loopback de ISP-1 anunciada por BGP" list=\
    bgp-anuncios
/ip firewall filter
add action=accept chain=input comment="input: respuestas" connection-state=\
    established,related,untracked
add action=drop chain=input comment="input: invalidos" connection-state=\
    invalid
add action=accept chain=input comment="input: ping y diagnostico" protocol=\
    icmp
add action=accept chain=input comment="input: BGP solo desde EDGE" dst-port=\
    179 protocol=tcp src-address=192.0.2.2
add action=drop chain=input comment="input: todo lo demas"
/ip service
set ftp disabled=yes
set ssh available-from=203.0.113.1/32
set telnet disabled=yes
set www disabled=yes
set reverse-proxy disabled=yes
set winbox available-from=203.0.113.1/32
set api disabled=yes
set api-ssl disabled=yes
/ip ssh
set strong-crypto=yes
/routing bgp connection
add comment="eBGP con EDGE (cliente AS 65000)" disabled=no instance=bgp-isp1 \
    local.address=192.0.2.1 .role=ebgp name=to-EDGE output.default-originate=\
    always .network=bgp-anuncios remote.address=192.0.2.2 .as=65000
/system identity
set name=ISP-1
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=none
/tool mac-server mac-winbox
set allowed-interface-list=none
