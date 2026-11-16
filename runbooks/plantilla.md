# Runbook — Drill N: <nombre>

Plantilla de R5 para los 5 drills de failover. Cada runbook es el **procedimiento** para repetir el drill; el **resultado** (tiempos, análisis y capturas) queda en la memoria §4.2. Copiar este archivo como `drill-<N>-<tema>.md` y completar todas las secciones.

## Objetivo

Qué falla se simula, qué mecanismo de failover se prueba y qué tiene que pasar para que el drill se dé por bueno.

## Roles

| Rol | Quién | Qué hace |
| :-- | :-- | :-- |
| Operador | | Provoca la falla y la revierte |
| Observador | | Mide desde el host o el router de medición y saca las capturas |

Se rota quién opera (backlog F4): anotar en el historial quién operó cada corrida.

## Antes de empezar

- [ ] **Backup "antes"** (política 1.4): el último backup de `backups/` de cada router involucrado refleja el estado actual. Si hubo cambios desde ese backup, tomar `/export file=<ROUTER>_<AAAAMMDD>_pre-drill<N>` y versionarlo.
- [ ] **Estado normal verificado:** los comandos de esta sección dan el resultado esperado. Si no, no se hace el drill.
- [ ] **Medición lista:** el ping de medición está corriendo y responde.

| Dónde | Comando | Resultado esperado |
| :-- | :-- | :-- |
| | | |

## Falla

| Paso | Dónde | Comando | Cuándo |
| :-- | :-- | :-- | :-- |
| 1 | | | En el ping N de la medición |

## Detección

Cómo se entera la red de la falla (qué timer vence o qué evento la dispara) y dónde se ve.

| Dónde | Comando | Qué se ve |
| :-- | :-- | :-- |
| | | |

## Respuesta

Qué hace la red sola (o qué hace el operador si la respuesta es manual) y cómo se comprueba.

| Dónde | Comando | Qué se ve |
| :-- | :-- | :-- |
| | | |

## Recuperación

| Paso | Dónde | Comando | Qué se ve |
| :-- | :-- | :-- | :-- |
| 1 | | | |

Al terminar se vuelve a correr la tabla de "Estado normal verificado": todo tiene que dar igual que antes de la falla.

## Medición

- **Qué se mide:** tiempo sin salida = pings perdidos × intervalo, desde la falla hasta el primer ping que vuelve a responder. También se mide la vuelta (pings perdidos al recuperar).
- **Desde dónde:** host o router y comando exacto.
- **Capturas:** `capturas/f4/<router>-drill<N>-<qué>.png` (una del ping con los perdidos y una del evento en el router). Antes de capturar, `/system clear-screen`: ninguna captura tiene que mostrar comandos con claves.

## Limpieza

Qué se agregó solo para el drill y cómo se borra. El drill no deja cambios: si quedara alguno, va a `configs/` por PR y al change log.

## Historial de corridas

| Fecha | Operador | Corte | Vuelta | Capturas | Notas |
| :-- | :-- | :-- | :-- | :-- | :-- |
| | | | | | |

## Post-mortem

Resumen en 2 o 3 líneas (por qué funcionó, qué limita el tiempo, qué se cambiaría) y enlace a la memoria §4.2, donde está el análisis completo.
