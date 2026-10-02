# Topología corregida — Failover Routing

Diagrama de las 5 capas con las correcciones aplicadas (ver `docs/memoria.md` sección 1): enlace core-core agregado, VRRP movido a distribución, core como tránsito puro, eBGP sin Route Reflector.

```mermaid
flowchart TB
    subgraph INTERNET["INTERNET"]
        ISP1["ISP-1 (AS 65001)"]
        ISP2["ISP-2 (AS 65002)"]
    end

    subgraph EDGE_L["EDGE"]
        EDGE["EDGE (AS 65000)<br/>eBGP x2 + firewall"]
    end

    subgraph CORE_L["CORE (tránsito puro)"]
        CORE1["CORE-1"]
        CORE2["CORE-2"]
    end

    subgraph DIST_L["DISTRIBUTION (VRRP + OSPF)"]
        DIST1["DIST-1 (master vrid 10)"]
        DIST2["DIST-2 (master vrid 20)"]
    end

    subgraph ACCESS_L["ACCESS"]
        SWU["SW-USERS"]
        SWS["SW-SERVERS"]
        HU["Host(s) USERS"]
        HS["Host(s) SERVERS"]
    end

    ISP1 -- eBGP --- EDGE
    ISP2 -- eBGP --- EDGE

    EDGE --- CORE1
    EDGE --- CORE2
    CORE1 == core-core ==> CORE2

    CORE1 --- DIST1
    CORE1 --- DIST2
    CORE2 --- DIST1
    CORE2 --- DIST2

    DIST1 --- SWU
    DIST2 --- SWU
    DIST1 --- SWS
    DIST2 --- SWS

    SWU --- HU
    SWS --- HS
```

**11 nodos · 15 enlaces · 7 routers CHR**, igual a lo especificado en la consigna (sección 4). El detalle de IPs de cada enlace está en `docs/memoria.md` sección 2.
