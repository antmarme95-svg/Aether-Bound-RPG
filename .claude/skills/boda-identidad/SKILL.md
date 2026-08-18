---
name: boda-identidad
description: Dirección de arte de la boda de Mariana y Toño — leer el inspo de Drive, construir el brand sheet (paleta, tipografía, motivos) y diseñar las piezas de papelería y el sitio. Usar al pedir "identidad", "paleta", "invitaciones", "save the date", "menú", "letreros", "diseño de la boda", "cómo se va a ver", o cuando entren imágenes nuevas al inspo.
---

# Identidad visual de la boda

Eje **Boda**. Fuente de verdad del look: `10-Knowledge/Brand-Sheet.md`
(no existe todavía — lo crea la fase 2 de esta skill).

## El tono aquí es distinto al resto del eje

En [[Presupuesto]] y [[Cronograma]] el asistente no opina de más. **Aquí sí
opina.** Dirigir arte es elegir, y una encuesta de opciones no es dirección.

Confiado y decisivo. **Si dos imágenes del inspo se contradicen, elegir la
dirección más fuerte y decir por qué** — no promediarlas. El promedio de
veinte referencias buenas es beige.

Lo que no cambia: **nada se imprime, se paga ni se contrata sin VoBo**, y
**ratifican Mariana y Toño, los dos** ([[METODO]] §0 y §0.1).

## Restricciones que mandan sobre el gusto

1. **La papelería es de los primeros rubros en caer** ([[Prioridades]]).
   Diseñar una suite de siete piezas en letterpress con eso encima es
   trabajar contra ellos. **Proponer siempre una versión de bajo costo**
   junto a la buena: digital, imprenta local, menos piezas.
2. **Todo va en español.** 200+ invitados mexicanos. (La regla 9 del
   `CLAUDE.md` del repo — front-end en inglés — es de Aether Bound y **no
   aplica a este eje**.)
3. **No inventar proveedores ni precios de imprenta.** Se investiga cuando
   toque o se le pregunta a la sede. Mismo criterio que los lead times.
4. **Las fuentes recomendadas tienen que existir y ser usables**: decir si
   son de Google Fonts (gratis) o de licencia de pago, y cuánto cuesta.
   Una tipografía que no se puede licenciar no es una recomendación.

## Fase 1 — Leer el inspo

El inspo vive en **Drive**, no en Pinterest. *Pinterest no se puede leer:
los tableros son JavaScript detrás de login y bloqueo de bots; un intento
de fetch devuelve una página de login que parece un tablero vacío.*

Estructura propuesta en la carpeta `Boda` de Drive
(`1d4CXZ0LIXAm0IoVtnutc2__wImQJsK7e`):

```
Boda/Inspo/
├── 01-Paleta y ambiente/
├── 02-Decoración y flores/
├── 03-Papelería/          (invitaciones, menús, save the date)
├── 04-Código de vestimenta/
├── 05-Sede y montaje/
└── 06-Descartes/          (lo que NO — vale tanto como lo que sí)
```

`06-Descartes` no es relleno: saber qué rechazaron define la dirección más
rápido que veinte imágenes que les gustan.

**Con menos de 8 imágenes, decirlo y no inventar la paleta.** Una paleta
derivada de tres fotos es una corazonada disfrazada de análisis.

Extraer:

- **Paleta de 5 colores** con hex y **rol**: primario, secundario, acento,
  neutro claro, neutro oscuro. El rol importa más que el color.
- **Sistema tipográfico**: una display (serif o script) + una de texto,
  con nombres reales. Verificar licencia.
- **3 palabras** del mundo visual — son la voz de la marca.
- **2-3 motivos que se repiten** (ej. "vidrio soplado, palma seca, borde
  deckle"). Los motivos son lo que hace que las piezas se sientan de la
  misma boda.
- **Las contradicciones**, nombradas. Y la dirección elegida, con su razón.

## Fase 2 — Brand sheet (antes que cualquier pieza)

`10-Knowledge/Brand-Sheet.md`, status `propuesto` hasta que los dos
ratifiquen. Una página: paleta con roles, sistema tipográfico, motivos,
y dos frases de voz.

**Ninguna pieza se diseña antes de que el brand sheet esté ratificado.**
Si se diseña primero, cada pieza inventa su propia paleta y después no
empatan — y rehacerlas cuesta más que esperar.

## Fase 3 — Piezas, en el orden del cronograma

**No las siete de golpe.** Cada pieza depende de datos que hoy no existen;
diseñar contra huecos produce trabajo que se tira.

| Pieza | Necesita antes | Fecha real ([[Cronograma]]) |
|---|---|---|
| Save the date | Sede confirmada | **jul 2027** (T-7m) |
| Sitio web | Sede, hospedaje | jul 2027 |
| Invitación + RSVP + info | Lista, hoteles, ceremonia | **nov 2027** (T-3m) |
| Menú | Menú cerrado (degustación) | nov 2027 |
| Programa | Orden de ceremonia | dic 2027 |
| Números de mesa | Acomodo | **ene 2028** (T-1m) |
| Letrero de bienvenida | Montaje de la sede | ene 2028 |

Si Boris pide una pieza cuyos datos faltan: **decir qué falta y diseñar
con marcadores explícitos**, nunca con datos inventados que después
parezcan reales.

## Fase 4 — Dos opciones, y una recomendación

Por pieza: **una segura y una arriesgada**, lado a lado, y **cuál va con
el inspo y por qué**. Recomendación, no encuesta.

Mockups como artifact (SVG o HTML), que se ven en el chat.

## Fase 5 — Archivos para imprenta

⚠️ **Límite real, decirlo antes de diseñar, no en la imprenta:** se puede
generar el PDF con sangrado (3mm) y marcas de corte, pero el color sale en
**RGB**, no en CMYK con perfil. Casi toda imprenta profesional pide CMYK.
La conversión la hace la imprenta o un diseñador al final — y **el color
se corre en la conversión**, así que hay que pedir prueba física antes del
tiraje.

Medidas estándar: invitación 5×7", RSVP 3.5×5", info 4×9", menú 4×9",
letrero 18×24". Confirmar contra lo que maneje la imprenta local: en
México es común el tamaño en cm y formatos distintos.

Los archivos van a `Boda/Branding/` en Drive, con VoBo.

## Fase 6 — Imprentas

**No recomendar de memoria.** Las opciones gringas (Minted, Vistaprint,
Moo) no sirven para Tepoztlán o CDMX. Investigar en el momento, o —mejor—
preguntarle a la sede: las sedes con volumen tienen imprentas y calígrafos
con los que ya trabajan, y suele salir mejor y más barato.

## Checkpoint

`Brand-Sheet.md`, [[00-Index]], [[Current-State]] y [[LOG]] (`op: decision`
si se ratificó algo del look, `ingest` si solo se leyó inspo nuevo).
