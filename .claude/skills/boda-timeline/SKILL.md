---
name: boda-timeline
description: Recalcular el cronograma de la boda de Mariana y Toño y sincronizarlo con el calendario "Wedding HQ" de Google. Usar cuando Boris pida revisar el timeline, cuando cambie un dato base (sede, fecha, número de invitados), cuando un proveedor dé su anticipación real, o al pedir "cronograma", "qué sigue", "hitos", "calendario de la boda", "vamos tarde".
---

# Timeline de la boda — recálculo y sincronización

Eje **Boda** ([[METODO]]). Mantiene [[Cronograma]] y su espejo en el
calendario de Google **"Wedding HQ"**.

## Por qué existe esta skill

Nació de criticar un prompt de internet que hacía esto mismo de un tiro.
Sus cuatro fallas son las cuatro reglas de esta skill:

1. **Anclaba en "12 meses"** en vez de en la fecha real. Con boda el
   2028-02-05, un timeline de 12 meses arranca en feb-2027 y le habría
   dicho a Boris "aparta la sede en 6 meses" cuando ya iba tarde. **Aquí el
   ancla es siempre la fecha real, y lo vencido se reporta primero.**
2. **Inventaba lead times de memoria.** Aquí los calcula `cronograma.py`, y
   cada hito trae `origen`: `plantilla` ⚠️ (genérico, no verificado) o
   `proveedor` ✅ (lo dijo el proveedor, gana siempre — [[METODO]] §1).
3. **Empujaba ~30 eventos sin preguntar.** Aquí hay gate de VoBo.
4. **No era re-ejecutable**: re-correrlo duplicaba todo. Aquí cada hito
   guarda su `event_id` en `hitos.json`, así que re-correr **actualiza**.

## Fase 0 — Aritmética primero, siempre

```bash
python "Boda/scripts/cronograma.py" --json
```

Sale con código 1 si hay hitos vencidos. **El LLM no calcula fechas**: las
lee de aquí. Si una fecha del reporte se siente rara, se arregla
`hitos.json` o el script, nunca la fecha "a mano" en la conversación.

## Fase 1 — Leer el estado

[[Current-State]] y [[Datos-Base]]. Si los datos base siguen en
`propuesto`, **decirlo** — el cronograma hereda esa incertidumbre.

## Fase 2 — Lo vencido y lo que está en riesgo

Antes que nada: qué está vencido, cuántos días, y qué desbloquea. Un hito
vencido **es trabajo, no información**. No enterrarlo en una lista de 17.

## Fase 3 — Personalizar (la parte que sí vale del prompt original)

Nombrar **los 3 hitos que hay que mover más temprano que el estándar**,
con su razón. Los factores vigentes de esta boda:

- **5-feb-2028 cae en puente** (Constitución, lunes 7). Sube asistencia,
  sube precio, adelanta la competencia por sede y hospedaje.
- **Tepoztlán es pueblo chico**: hospedaje para 200+ es cuello de botella.
- **Febrero arrastra San Valentín**: la flor sube y escasea esa semana.
- **200–215 invitados** con $800k: el conteo es la palanca del presupuesto.
- **Ceremonia sin definir**: si sale católica, el expediente parroquial y
  las pláticas se piden con meses y **no se aceleran con dinero**.

Y cerrar con **los 3 hitos que Boris y Mariana van a subestimar**, una
línea cada uno. Es un pre-mortem, no relleno.

## Fase 4 — Proponer el diff (NO tocar el calendario todavía)

Tabla de tres columnas: **hito | qué hay en el calendario | qué propongo**,
marcando `NUEVO` / `MUEVE` / `IGUAL` / `SOBRA`. Solo eso. Nada se crea.

## Fase 5 — Gate de VoBo 🔴

**Ningún evento se crea, mueve ni borra sin un "sí" explícito de Boris en
el chat, en esta sesión.** Ver [[METODO]] §0 y [[Lecciones]].

Recordar que **"Wedding HQ" se comparte con Mariana**: cada evento fantasma
le llega a ella también.

## Fase 6 — Sincronizar

Solo lo aprobado, en un lote:

- Calendario **"Wedding HQ"**, aparte del personal, zona `America/Mexico_City`.
  Si `hitos.json → calendario.id` está vacío, crearlo y guardar el id.
- Por evento: **título de una línea** ("Apartar sede", "Enviar save the
  date"); **descripción de 2 frases** — la acción, y **qué decisión hay que
  traer ya tomada** a esa fecha; **recordatorio a 7 días**, más uno a
  **1 día** si el hito cae en las últimas 8 semanas (`cronograma.py` ya lo
  resuelve en el campo `recordatorios`).
- Marcar en la descripción si el lead time es ⚠️ de plantilla.
- **Guardar el `event_id` de vuelta en `hitos.json`.** Sin esto la skill
  deja de ser idempotente y la próxima corrida duplica.

## Fase 7 — Checkpoint

Regenerar la tabla de [[Cronograma]] desde el script, y actualizar
[[Current-State]], [[Task-Board]] y [[LOG]] (`op: seguimiento`).

## Cuando un proveedor contradice la plantilla

**Gana el proveedor.** Editar ese hito en `hitos.json`: `meses_antes` o
`fecha_fija`, y `origen: "proveedor"`. Eso es aprendizaje permanente — la
razón de que esto sea una skill y no un prompt.
