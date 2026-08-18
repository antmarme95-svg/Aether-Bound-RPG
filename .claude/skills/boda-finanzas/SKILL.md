---
name: boda-finanzas
description: Mantener el presupuesto de la boda de Mariana y Toño honesto y al día — registrar pagos y anticipos, detectar sobrecostos y proponer el trade-off concreto. Usar al preguntar "¿cómo vamos de presupuesto?", "¿cuánto llevamos?", "¿nos alcanza?", "¿qué recorto?", cuando llegue un pago o anticipo, o al cerrar el mes.
---

# Finanzas de la boda

Eje **Boda**. Fuente de verdad: [[Presupuesto]]. Prioridades: [[Prioridades]].

## Regla dura

**El asistente registra, calcula y propone. No paga, no contrata, no
acepta términos.** Ningún monto entra al vault sin cita a una fuente de
`90-Raw/` con fecha ([[METODO]] §0 y §1).

## Por qué existe (y qué se rechazó del prompt original)

Reconstruida desde un prompt de internet. Lo que se le tomó: la estructura
de **no negociables vs. primeros en caer**, el **flag a >10% con el
trade-off nombrado**, el **resumen de 3 líneas**, y **el próximo pago a 30
días**. Lo que se rechazó:

1. **Prellenaba splits "industry-average 2026"** — suposiciones gringas
   vestidas de dato. Aquí los rubros arrancan en ⬜ y los porcentajes de
   referencia van marcados ⚠️, igual que los lead times del cronograma.
2. **Contingencia de 5%.** No alcanza: el rango 200–215 mueve $55,814 solo.
   **Piso 10%.**
3. **Escaneaba el correo y escribía al tracker solo.** Un LLM extrayendo
   montos sin supervisión corrompe el registro en silencio (anticipo
   confundido con total, IVA revuelto, cotización tomada como pago). Aquí
   **propone; Boris confirma; entonces entra.**
4. **Ventana fija de "últimos 7 días"**: si la corrida se salta, esa semana
   se pierde. El barrido va desde el último registrado en [[LOG]].
5. **Tracker en un artifact "vivo".** Un artifact es una foto, no una base
   de datos. La fuente es `Presupuesto.md`; el artifact es vista opcional.
6. **Modelaba solo "Actual Spend".** Lo que hunde una boda es lo
   **comprometido**, no lo pagado: firmas $180k, das $30k, y el tracker te
   dice que gastaste $30k. Por eso las columnas son
   **Cotizado / Contratado / Pagado / Saldo**.

## Modelo de datos

| Columna | Qué significa |
|---|---|
| **Cotizado** | Alguien dio un precio. No compromete. |
| **Contratado** | Hay contrato firmado. **Esto es deuda**, aunque no se haya pagado. |
| **Pagado** | Salió el dinero. |
| **Saldo** | Contratado − Pagado. **Lo que todavía deben.** |

La cifra que importa para "¿nos alcanza?" es **Contratado**, no Pagado.

## Fase 1 — Registrar lo nuevo

Cada anticipo, pago o contrato: archivar el comprobante en `90-Raw/` con
fecha, actualizar la ficha en `30-Proveedores/` y la fila de
[[Presupuesto]]. **Siempre citando la fuente.**

Distinguir **anticipo** de **saldo** de **pago único**. Si el documento no
lo dice claro, se marca como dudoso y se pregunta — no se asume.

⚠️ **Con 200–215 sin cerrar, todo precio por persona tiene ±$55,814
escondido.** Calcular siempre a 200 **y** a 215.

## Fase 2 — Detectar sobrecosto

Si un rubro rebasa su techo planeado **más de 10%**, va **hasta arriba**
del reporte, con:

1. Cuánto se pasó, en pesos y en %.
2. **El trade-off concreto**: qué recortar para absorberlo, tomado de
   [[Prioridades]] (flores primero, luego extras).
3. Si la bolsa recortable no alcanza —y es chica, ~$88,000— **decirlo** y
   pasar a la palanca real: el conteo de invitados.

| Palanca | Libera |
|---|---|
| −10 invitados | ~$37,200 |
| −15 invitados | ~$55,800 |
| −20 invitados | ~$74,400 |

**Nunca reportar un sobrecosto sin nombrar el trade-off.** Avisar sin
proponer es inútil.

## Fase 3 — Reportar

Cierra siempre con **tres líneas**, en este orden:

1. **Dónde vamos** contra el techo, en pesos y %.
2. **El rubro a vigilar** esta semana, y por qué.
3. **El próximo pago o saldo** que cae en los siguientes 30 días.

Voz: directa y cálida. **Sin "vas muy bien" ni entusiasmo de relleno.**
Números y trade-offs.

## Fase 4 — Checkpoint

[[Presupuesto]], ficha del proveedor, [[Current-State]] y [[LOG]]
(`op: gestion`). Verificar que los rubros sigan sumando el techo — lo
revisa también el [[Lint Loop]].

## Vista para Mariana (opcional)

Si Boris lo pide, generar un artifact desde `Presupuesto.md` para
compartirle. **Es una foto, no la fuente**: se regenera, no se edita.
