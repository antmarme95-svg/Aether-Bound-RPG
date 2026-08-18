---
name: boda-seguimiento
description: Barrido periódico del eje Boda — correo, Drive y calendario — para detectar qué llegó, qué hito entra en riesgo y qué proveedor no ha contestado. Usar al arrancar sesión de boda, cuando Boris pregunte "¿qué hay de nuevo?", "¿cómo vamos?", "¿algo pendiente?", o al disparar la rutina semanal.
---

# Seguimiento — barrido periódico

Eje **Boda**. Implementa el [[Seguimiento Loop]]. Su propósito es que
**nada se caiga**, no producir un reporte bonito.

## Fase 0 — Aritmética

```bash
python "Boda/scripts/cronograma.py"
python "Boda/scripts/dashboard.py"
```

El primero da lo vencido y lo que entra en ventana de 45 días. El segundo
da el semáforo de proveedores. **Ambos salen con código 1 si hay algo en
rojo.** Son el esqueleto del reporte; el LLM interpreta, no recalcula.

## Fase 1 — Verificar los conectores

Los tres deben ser **`antmarme95@gmail.com`**. Si el correo aparece con
otra cuenta, **parar y avisar** — ya pasó una vez, y un barrido sobre la
bandeja equivocada sale vacío y parece concluyente ([[Lecciones]]).

## Fase 2 — Barrer

Desde la fecha del último barrido registrado en [[LOG]]:

- **Gmail** — etiqueta `Boda` si ya existe; si no, buscar por nombre de
  proveedor de `30-Proveedores/` y por términos del rubro.
- **Drive** — archivos nuevos en la carpeta `Boda`.
- **Calendar** — calendario "Wedding HQ": próximas citas, y choques contra
  el calendario personal.

## Fase 3 — Clasificar

Cada cosa nueva es **una** de estas:

| Qué es | A dónde va |
|---|---|
| Cotización o contrato | skill `boda-cotizacion` |
| **Anticipo, recibo o confirmación de pago** | skill `boda-finanzas` — **se propone, NO se escribe solo** |
| Proveedor pide una decisión | [[Task-Board]] + se le nombra a Boris |
| Confirmación de invitado | lista de invitados |
| Cambio de fecha o de precio | `hitos.json` / [[Presupuesto]], y se **marca como contradicción** |
| Publicidad | se ignora, no se reporta |

## Fase 4 — Lo que NO llegó, y de quién es el turno

La parte que más valor tiene y la que se olvida.

**El silencio se cuenta desde que NOSOTROS escribimos** (`yo_escribi` en la
ficha), no desde el último mensaje del hilo. Un acuse automático de
"recibimos tu mensaje" mueve `ultimo_mensaje` pero el silencio real sigue
corriendo. Umbral: **14 días** — lo aplica `dashboard.py`, no el criterio
del día.

Un proveedor callado 14 días en temporada de puente normalmente ya se
comprometió con alguien más.

**Y al revés, que es lo que de verdad se cae:** revisar qué fichas tienen
`turno: nosotros`. Es muy fácil creer que uno está esperando al proveedor
cuando el proveedor lleva tres semanas esperándonos. Esos van en amarillo y
se nombran uno por uno.

Después de cada contacto hay que actualizar `turno` y `yo_escribi` en la
ficha. Si no, el tablero miente.

## Fase 4.5 — Lente financiero

Además de los correos de proveedores, buscar comprobantes: *anticipo,
depósito, recibo, factura, pago, transferencia, saldo*. Por cada uno
extraer proveedor, rubro, monto, fecha y **si es anticipo o saldo**.

🔴 **Proponer, nunca escribir solo.** Un LLM que mete montos al presupuesto
sin supervisión corrompe el registro en silencio: confunde anticipo con
total, revuelve precios con y sin IVA, toma una cotización por un pago. Se
presenta la lista, Boris confirma, y **entonces** entra por `boda-finanzas`.

Si algún rubro va >10% sobre su techo, **va hasta arriba del reporte** con
el trade-off nombrado (ver [[Prioridades]]: flores, luego extras).

## Fase 5 — Reportar

Corto y accionable, en este orden:

1. **Vencido o en riesgo** (de los dos scripts: hitos y proveedores en rojo).
2. **A quién le debemos respuesta** (fichas con `turno: nosotros`).
3. **Necesita decisión de Mariana y Toño.**
3. **Llegó esto** (una línea cada cosa).
4. **Sin respuesta desde hace X días.**
5. **Las tres líneas de finanzas** (`boda-finanzas` fase 3): dónde vamos
   contra el techo · el rubro a vigilar · el próximo pago a 30 días.
6. **Nada más pendiente**, si es el caso — decirlo, no rellenar.

Si no pasó nada, la respuesta correcta es "no hay nada nuevo". Un reporte
inflado entrena a ignorarlo.

## Fase 6 — Checkpoint

[[Current-State]], [[Task-Board]] y [[LOG]] (`op: seguimiento`), con la
fecha del barrido para que el siguiente sepa desde dónde leer.

## Gate

**Nada de lo detectado se responde, agenda ni paga automáticamente.**
Se reporta y se propone. Ver [[METODO]] §0.
