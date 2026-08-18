---
name: boda-cotizacion
description: Procesar una cotización o contrato de proveedor de la boda (PDF, correo, foto) hacia el vault, y comparar opciones de un mismo rubro. Usar cuando llegue una cotización, cuando Boris pregunte "¿cuál conviene?", "compara estas dos", "cuánto llevamos gastado", o al archivar un contrato.
---

# Cotizaciones y proveedores

Eje **Boda**. Implementa el [[Ingest Loop]] para el caso más frecuente:
llega un número de un proveedor y hay que meterlo al vault sin deformarlo.

## Regla dura

**Todo monto en el vault se cita a una fuente de `90-Raw/` con fecha.**
Un precio sin fecha ni vigencia no sirve en tres meses ([[Lecciones]]).
Si un número no se puede citar, no entra: se anota como "dicho de palabra,
sin documento" y se pide el documento.

## Fase 1 — Archivar en crudo

A `90-Raw/` con fecha en el nombre:
`2027-03-14-cotizacion-banquete-<proveedor>.pdf`

**Nunca se edita la fuente.** Si el PDF tiene un error de suma, se anota en
la ficha del proveedor — no se "corrige" el PDF ([[METODO]] §1).

Si llegó por correo, guardar también el `thread_id` de Gmail. Si vive en
Drive, guardar el enlace.

## Fase 2 — Extraer, y verificar la aritmética

Leer la fuente completa y sacar:

- Proveedor, contacto, fecha de la cotización y **vigencia del precio**.
- Concepto por concepto, con precio unitario y cantidad.
- **Qué está incluido y qué NO** (IVA, servicio, propinas, montaje,
  desmontaje, horas extra, hospedaje del proveedor, viáticos a Tepoztlán).
- Anticipo, calendario de pagos, política de cancelación.

**Verificar que la suma cuadre.** Las cotizaciones traen errores de suma
más seguido de lo que parece. Si no cuadra, se reporta — no se corrige en
silencio.

⚠️ **Trampa de esta boda:** casi todo se cotiza por persona. Con 200–215
sin cerrar, cada cotización tiene un rango de ±$15k escondido. Siempre
calcular el total a 200 **y** a 215.

## Fase 3 — Ficha del proveedor

**Copiar `30-Proveedores/_PLANTILLA.md`** a `<rubro>-<proveedor>.md` y
llenar. Respetar los nombres del frontmatter: los lee `dashboard.py` y una
ficha con campos mal escritos **no aparece en el tablero**.

Los tres campos que se olvidan y son los que más valen:

- **`turno`** — quién debe la siguiente respuesta. Se actualiza en **cada**
  contacto, sin excepción.
- **`yo_escribi`** — la última vez que Mariana o Toño escribieron. De ahí se
  cuenta el silencio de 14 días, no del último mensaje del hilo.
- **`cotizado_200` y `cotizado_215`** — los dos siempre.

Si se descarta, escribir **por qué** — evita volver a sondearlo en seis
meses.

## Fase 4 — Propagar

- [[Presupuesto]]: columna `Cotizado` del rubro. Si ya hay contrato,
  `Contratado`. Verificar que los rubros sigan sumando el techo.
- [[Cronograma]]: si el proveedor dio su **anticipación real**, actualizar
  `hitos.json` con `origen: "proveedor"` y correr `boda-timeline`. Esto es
  lo más valioso de todo el proceso: convierte un ⚠️ en un ✅.

## Comparar opciones de un rubro

Tabla con: **total a 200 y a 215**, qué incluye cada uno, qué le falta a
cada uno respecto del otro, anticipo, y política de cancelación.

**Aquí sí se recomienda.** Comparar proveedores no es asesoría financiera
— es el trabajo. Dar una recomendación con su razón, no una encuesta.
Pero la elección la ratifican **Mariana y Toño, los dos** ([[METODO]] §0.1).

## Lo que esta skill NO hace

- **No paga.** Registra lo pagado; nunca ejecuta un pago ni un depósito.
- **No contrata ni acepta términos.**
- **No manda el correo.** Si hay que responderle al proveedor, se deja
  **borrador** y se avisa ([[Gestión Loop]]).
