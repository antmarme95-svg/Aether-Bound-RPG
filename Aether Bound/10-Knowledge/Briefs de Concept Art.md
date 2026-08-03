---
status: ratificado
source: "[[Fenotipos y Creación de Personaje]] + [[Art Bible]] (destilados a prompt); RATIFICADO por el director 2026-07-08 (sus outputs — fenotipos/keyframes/Speck/foliage/Dagna — ya son canon en 90-Raw/concept/). Página viva: los briefs de los 8 pivotes restantes se AÑADEN sin desratificar lo probado."
updated: 2026-07-27
---

# Briefs de Concept Art — Fenotipos

> Prompts autocontenidos para generadores de imagen (calibrados para Nano
> Banana 2; sirven igual de brief para un concept artist humano). Regla del
> pipeline: lo generado que se apruebe entra a `90-Raw/` como referencia
> inmutable y se evalúa contra los 5 ejes de la [[Art Bible]].

**Bloque de estilo compartido (embebido en cada brief):** hand-painted
graphic novel watercolor · crisp black ink linework · flat cel 3–4 bandas con
bordes dry-brush · paleta lavada de baja saturación · grano de papel · Sable
ligne claire × BotW impresionista. **Negativos:** Genshin candy saturation ·
photorealism/PBR · generic anime cel · neon glow.

**Regla estándar (2026-07-24, desde el batch §10):** agregar siempre *"no
text, no labels, no captions, no annotations, no diagram-style callouts"*
al negativo. NB2 a veces agrega hojas de spec anotadas (nombres de piezas,
lista de negativos escrita en la imagen) — no es el mismo bug que el texto
corrompido/filtrado (ver Kadrun v1, Ilyara), es una elección de formato del
modelo, pero conviene evitarlo por default: las láminas se usan para medir
proporción y comparar estilo entre personajes (mismo método de
[[Lecciones]]), y el texto superpuesto estorba esa lectura.

## 1 — Elfo (Aether-Born)

```
Full-body character concept sheet, front view and side view, of a fantasy elf on a plain warm paper background. Silhouette reads as one continuous vertical line: very tall and slender, roughly 8 heads tall, narrow sloped shoulders, long neck, long limbs and long fingers, flexible dancer's posture with weight held high. Long ears sweeping backward continuing the line of the skull. Large almond eyes with a high tilt, high cheekbones, fine narrow jaw. Sleek straight hair worn in a high elven topknot, long loose strands falling behind the swept-back ears and down the spine, reinforcing the single vertical line of the silhouette; hair color ranging from bone white to void black, with a faint aether-teal sheen where light catches it. Skin in cold pale tones with a faint lavender undertone. Glowing pale-teal aether engravings traced across the collarbone and forearms, like luminous filigree under the skin — subtle, not neon. Simple fitted travel clothing in muted greens and greys, medieval aetherpunk: organic shapes, a few brass pipe-fittings. Art style: hand-painted graphic novel watercolor — crisp black ink linework on the figure, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, melancholic and serene mood, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Negative: no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no neon glow, no heavy armor.
```

### 1b — Re-roll: variante piel porcelana (edición sobre imagen)

Adjuntar la lámina v1 del elfo y usar:

```
Keep this exact character sheet — same pose, three views, outfit, hair, ears, proportions, linework and watercolor style — but change only the skin: replace the lavender skin with a porcelain warm-pale skin tone, cold and fair, keeping just a faint lavender undertone in the shadows. The pale-teal aether engravings on collarbone and forearms stay visible against the lighter skin.
```

Fallback standalone: mismo brief 1 con la frase de piel → *"Skin in porcelain
warm-pale tones, cold and fair, with only a faint lavender undertone in the
shadows"* y añadir al negativo *"no purple or lavender skin"*. Motivo: la v1
convirtió el subtono lavanda en piel completa; se canonizan ambos extremos de
la paleta para que "elfo = piel lila" no sea la lectura por defecto.

## 2 — Enano (Iron-Blooded)

```
Full-body character concept sheet, front view and side view, of a fantasy dwarf woman on a plain warm paper background. Silhouette reads as a trapezoid, nearly as wide as tall: about 4.5 heads tall, massive trapezius and shoulders swallowing the neck, short thick limbs, enormous hands, low center of gravity, deep natural squat stance, planted and immovable. Heavy brow, broad jaw, a nose with history. No beard: long ornamented side-braids at the temples, threaded with small forge-iron rings and metal inlays. Skin in warm bronze tones with soot shading, one variant in ashen forge-touched grey. Guild tattoos in dark amber geometry on the forearms. Practical smith-soldier clothing, leather and dark iron with faint warm ember accents at the seams, medieval aetherpunk. Art style: hand-painted graphic novel watercolor — crisp black ink linework, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, dignified and stubborn mood, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Negative: no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no comedic caricature dwarf, no full beard on the woman, no neon glow.
```

### 2b — Re-roll: enana sin barba, ropa ligera (edición sobre imagen)

La v1 entregó varón con barba plena y full plate (desviación de las decisiones
ratificadas). Adjuntar la lámina v1 y usar:

```
Keep this exact character sheet style, proportions and watercolor rendering — same trapezoid silhouette, 4.5 heads tall, massive shoulders, huge hands, low center of gravity — but change the character to a dwarf woman with no beard: strong heavy-browed feminine face, broad jaw, hair pulled back with long ornamented side-braids at the temples threaded with small forge-iron rings. Replace the full plate armor with practical smith-soldier clothing: fitted leather and cloth in earth tones with a few dark iron pieces and faint warm ember accents at the seams, so the body silhouette stays readable. Keep the amber geometric guild tattoos on the forearms. Negative: no full beard, no heavy plate armor, no comedic caricature.
```

La v1 masculina se archiva igualmente (referencia válida del varón; silueta,
tatuajes y ember accents ✓).

### 2c — Standalone: enana con proporción blindada

La 2b validó cara/trenzas/ropa pero derivó alta-esbelta (sesgo del modelo con
"woman"). Prompt desde cero con la proporción al frente, refuerzo en positivo
y negativos anti-deriva; anillas de forja integradas:

```
Full-body character concept sheet, front view, back view and side view, of a fantasy dwarf woman on a plain warm paper background. The proportions are the single most important rule: she is exactly 4.5 heads tall, a trapezoid silhouette nearly as wide as she is tall, with massive trapezius and shoulders that swallow the neck, a wide barrel torso, enormous hands, very short thick arms and legs, and a low planted center of gravity — immovable, built like a load-bearing wall. She is NOT tall, NOT slender, NOT athletic; every limb is short and thick. Strong feminine face with a heavy brow, broad jaw and a nose with history; no beard. Hair pulled back tight, with long ornamented side-braids at the temples threaded with small forge-iron rings and metal inlays. Skin in warm bronze tones with soot shading. Amber geometric guild tattoos on both forearms. Practical smith-soldier clothing that keeps the body silhouette readable: fitted leather and cloth in earth tones, a few dark iron pieces at shoulders and boots, faint warm ember accents at the seams, heavy belt with tools, medieval aetherpunk. Art style: hand-painted graphic novel watercolor — crisp black ink linework, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, dignified and stubborn mood, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Negative: no tall or slender body, no long legs, no human proportions, no hourglass figure, no full beard, no heavy plate armor, no comedic caricature, no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no neon glow.
```

## 3 — Humano (the Restless / Mistbound)

```
Full-body character concept sheet, front view and side view, of a human mercenary on a plain warm paper background. Silhouette is the athletic reference the other races deviate from: about 7.5 heads tall, balanced athletic proportions, versatile ready stance mid-weight-shift, adaptable and restless energy. Face is individual and imperfect — humans are the most physically diverse race, this one with river-town features and a weathered grin. Skin any tone of the full human range; a rare frontier variant has a faint mist-mint pallor. Frontier Mistbound culture marks: a single diagonal warpaint stroke in muted green across the chest or cheekbone, fog-cured leathers, a scarf and small smuggler charms; the city variant instead wears layered river-market fabrics in wood and ochre tones, medieval aetherpunk with rough brass gadget straps. Art style: hand-painted graphic novel watercolor — crisp black ink linework, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, melancholic-adventurous mood, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Negative: no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no beast-folk features, no animal ears or tail, no neon glow.
```

## 4 — Keyframe "The Wilds at dawn" (golden scene, B11)

El keyframe ratificado será el **criterio de aceptación** de la golden scene
Godot (la escena persigue la imagen — nunca al revés; así no se heredan los
errores del look viejo, que es anti-referencia). Registro Sable×BotW (cubo de
[[La Rueda]]).

```
Wide cinematic landscape keyframe, 16:9, of an immense melancholic fantasy forest at dawn. Composition rules: empty space is the protagonist — a vast sky and rolling terrain dwarf a single tiny traveler figure walking a faint trail, seen from far away. Foreground: a grassy clearing and two enormous ancient trees with sprawling roots, drawn with crisp black ink linework and flat watercolor color. Middle ground: the forest rolls over hills, the ink lines turning grey and fading as if the brush is running out; half-buried among the trees, one crystalline God-Core formation glows a deep saturated red — the only intense color in the frame, reading as quiet danger. Far distance: mountain ridges and treetops dissolve into flat pale-blue pastel silhouettes with no interior detail, pure aerial perspective; faint floating islands barely visible in the haze. Dawn light: washed ochres and soft pinks low on the horizon, long soft shadows, air with physical weight — light rays scattering through morning mist, subtle glowing edges where backlight meets the ink lines. Overall palette: low saturation, hand-painted watercolor wash on grainy paper, melancholic and epic, serene loneliness. Art style: a hand-painted graphic novel — the game Sable's ligne claire linework and flat graphic shapes blended with Breath of the Wild's soft impressionist color and atmospheric perspective; flat cel shading in 3–4 fixed light bands with dry-brush jittered edges; visible watercolor paper grain across the whole image. Negative: no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime style, no neon glow except the single red core, no busy detail in the distance, no characters in close-up.
```

### 4b — Variante atardecer (edición sobre el keyframe aprobado)

El gate de la golden scene compara dos horas del día (eje de paleta drástica):

```
Keep this exact composition, linework, framing and style — but change the time of day to dusk: the washed ochres and pinks become deep blues and violets with cool neon-tinged accents on the horizon (Sable's night palette), the sky darkens, the mist turns cold, the glowing edges intensify slightly against the backlight — and the red God-Core now burns as the brightest thing in the frame. Same paper grain, same low saturation elsewhere, same melancholic mood.
```

Qué obliga a testear: capa 1 (línea muere con la distancia), capa 2 (bandas
jitter), capa 3 (aire con peso + glowing edges), capa 4 (grano) + espacio
vacío protagonista y rojo = máxima saturación del frame ([[Art Bible]]).

## 5 — Speck: los 3 estadios + Forma shapeshifteada (B9)

**Redireccionamiento 2026-07-23:** Speck es la última Warden, no criatura natural.
Forma base = **Warden cristalino + runas Warden + translúcido**, no salamandra.
Los 3 estadios son **manifestación del despertar**, no crecimiento animal. 

Regla clave: E1 es crisálida (dormida, shapeshifteada); E2 es despertar (forma
real emerge lentamente); E3 es verdad completa (cristales rojos = God-Core,
idéntica geometría). La revelación de [[El Mundo y la Muda]] cosida en arte.
Los 3 estadios comparten ADN de silueta, ojos facetados tipo gema, y runas.

**Forma shapeshifteada (E1→E2 coexisten):** Zorro endémico de The Wilds,
1.5× tamaño normal, pelaje **rojo/naranja** (visual-locked en [[Speck]] — el valor beige/gris es de una versión anterior y genera el asset equivocado) con patrones geométricos sutiles (runas
Warden interpretadas como "coloración rara"). Seams teal presentes. Pata
delantera izquierda con cristal visible (glitch del shapeshifting). Ojos
facetados. Comportamiento demasiado inteligente.

### 5a — Speck E1, Crisálida/Forma Warden (GENERADO 2026-07-23, NB Pro) ✅

**Especificación final RATIFICADA 2026-07-23:** Speck en forma Warden real
(no shapeshifteada), cuerpo de bio-constructo crystallino. Superviviente de
civilización Warden — tecnología biológica diseñada, no evolucionada. Paleta
jade pálido casi-blanco translúcido (no obsidiana). Orejas pétalos translúcidos
(Opción 3, elegancia divina). Runas oro brillante visible + activas. Patas
esmeralda pálido casi-blanco (conexión tierra). Seams aether flujo uniforme
(teals + ambers). Translucidez variable (orejas + extremidades más translúcidas).
Atmósfera: arqueología vivida, luminosa, antigua, triste, poderosa.

**Brief ejecutado:**

```
Creature concept sheet, front view and side view, of "Speck" — stage one, the 
ancient Warden form (not an axolotl, not a natural creature). A small bio-construct, 
living relic of a lost divine civilization, small enough to carry in two hands. Form 
reads as sculptural, semi-geological, deliberate design. Body is pale translucent 
jade-green flesh with visible crystalline structures veined beneath like mineral 
growth — the crystal patterns are angular, geometric, evidence of conscious design 
not evolution. Ears are thin translucent petal-like structures, faceted like quartz, 
sweeping back elegantly and catching light. Eyes are dark amber, deeply faceted and 
gem-like, reflecting an ancient consciousness with sad weight. Forearms and paws are 
a slightly deeper esmeralda-pale green, almost-white, suggesting earth-connection and 
divine aspect. Golden geometric runes are etched across the chest, flanks and upper 
legs — active and brilliant, god-script glowing faintly (evidence the Warden is 
awakening). Seams of aether glow in uniform flow: teals and ambers brilliantly 
visible as cracks where power flows through the crystalline body. The translucidez 
is variable: ears nearly ghostly, extremities clearly transparent, core slightly 
more opaque. Posture suggests something ancient coiled and waiting, wise, tired. 
Stubby thick-proportioned limbs. Small vignette: she rests in a palm, luminous and 
small, a relic from ages before. Mood: mysterious, precious, luminous, unsettling 
— ancient technology that should not exist. Atmosphere: lived-in archaeology, 
luminous, ancient, sad, powerful. Art style: hand-painted graphic novel watercolor, 
ligne claire with mineral/crystalline detail, flat cel shading 3–4 bands, low 
saturation palette with golden runes and teal+amber aether seams brilliant against 
the pale jade. Visible paper grain. Blend of Sable ligne claire × Breath of the 
Wild impressionist color. Negative: no Genshin mascot look, no opaque dark obsidian, 
no muted runes, no photorealism, no anime cel shading, no neon glow except golden 
runes and aether seams.
```

**Archivos:** `speck-estadio1-warden-crisalis-v1.png` (RATIFICADO 2026-07-23 POR BORIS)

### 5b — Speck E2, Despertar (BRIEF RATIFICADO 2026-07-23) — DESCARTADO

**Nota 2026-07-23:** Decisión de Boris — saltear E2. Los 4 Finales muestran E3 (God-Core) 
en variaciones narrativas. Zorro → E1 (descubrimiento silencioso) → E3 (clímax: Fragmento 
activa, Speck reacciona involuntariamente). No hay E2 intermediario.

### 5c — Speck E3, Verdad Completa (BRIEF BASE — Variaciones por Final)

**Especificación:** Clímax en The First Wound. Fragmento activa → Speck reacciona 
involuntariamente (hive mind forzado). Jade pálido se revela como rojo God-Core.

**Narrativa transversal — los 4 grados de agencia, y hay que poder VERLOS.** La
transformación es involuntaria en todos los casos ([[Speck]] §Capa 4). Lo que cambia
por final es **cuánta agencia tiene Speck sobre lo que viene**, y son cuatro grados
distintos, no dos. Fuente: [[Speck]] §Capa 4.

| Grado | Finales | Verbo | Qué debe leerse en la imagen |
|---|---|---|---|
| **Le preguntan** | **F4** | *responder* | Es la única donde Speck **contesta**. Mirada hacia el jugador, no hacia el core. Reciprocidad. Es lo único que distingue F4 |
| **Deciden por ella y acepta** | **F1** | *aceptar* | Dignidad frente a una decisión **ajena**. NO reciprocidad, NO igualdad — nadie le preguntó. Se sostiene sola |
| **Es cedida, no arrebatada** | **F2a, F3** | — | Agencia ausente, pero **vive** — cedida y catalogada en F2a, encadenada bajo el jugador en F3. La fuerza nunca entra en su cuerpo |
| **Es arrebatada** | **F2b** | — | La única donde "arrebatada" es literal: el forcejeo la mata |

> ⚠️ **Dos errores que este brief tenía y que el arte generado hereda:**
> 1. **Colapsaba F1 y F4** en un solo bucket de "aceptación con gracia divina". Está
>    prohibido: *"El verbo de F1 es aceptar; el de F4 es responder. Colapsarlos borra lo
>    único que distingue a F4"* ([[Speck]] §Capa 4). **F1 y F4 no pueden verse igual** —
>    si el jugador no distingue las dos láminas, "costos incomparables" no existe para él.
> 2. Decía *"finales donde vive (F1, F4)"*. **Falso: en F2a Speck también vive**, cedida
>    viva al Council. Vivir no es el eje; la agencia sí.
>
> **Consecuencia de producción (histórico — resuelto 2026-07-29/30):** los briefs
> §5c.1 (F1) y §5c.4 (F4) habían sido generados bajo la lectura colapsada — F1 pedía
> *"beside the player as equal"* y *"no passivity"*, que es agencia, y su mood
> (renewal, warmth) era indistinguible del de F4. Los dos quedaron corregidos y
> ratificados. Y §5c.2 estaba escrito antes del split F2a/F2b: mostraba un cadáver
> calcificado en el cráter, que es **F2b**, no F2a. Reorganizado: **§5c.2a** es el
> brief nuevo de F2a (Speck viva, administrada, sola); **§5c.2b** es la lámina vieja,
> re-etiquetada correctamente como lo que siempre fue — el brief de F2b.

**Base visual común a todos los finales:**
Cristales rojos saturados (misma geometría que God-Cores del mundo). Seams aether 
rojo-ámbar brillantes. Ojos amber facetados con peso/consciencia antigua. Patas 
rojo-esmeralda. Runas oro activas. Orejas pétalos rojo translúcido. **Lo crítico:** 
retiene humanidad en los ojos/postura. Sigue siendo Speck — pero ahora sin velo, 
sin defensa.

> ⚠️ **Nota de generación (2026-07-30), aplica a los 5 briefs:** E3 es
> **desvelamiento, no crecimiento** ([[Speck]] §la forma no crece — "cuando lo ves
> sin velo, ves quién siempre fue"). El cuerpo debe leerse reconociblemente
> **zorro** — no un esqueleto/robot genérico de cristal — y las orejas deben
> mantener la forma de **pétalos** establecida (no orejas de zorro simples). La
> primera pasada de `5c.4` cumplió las 3 correcciones narrativas (sin pedestal,
> mirada recíproca al jugador, sin halo triunfal) pero derivó a un costillar
> expuesto y orejas simplificadas — anotado, sin bloquear, pendiente de una
> pasada de refinamiento visual si hay margen.

**Briefs específicos por final a continuación.**

#### **5c.1 — Final 1: The Guided Molt — E3 Viva, Aceptación y Propósito**

> ⚠️ **Re-hecho 2026-07-29.** La versión anterior generó un **ciervo con astas** —
> rompió la regla de que los 3 estadios comparten ADN de silueta con la forma zorro
> ([[Briefs de Concept Art]] §Redireccionamiento — *"Los 3 estadios comparten ADN de
> silueta, ojos facetados tipo gema, y runas"*). La causa probable: *"crest branches...
> tendrils of light extending outward"* se leyó como cornamenta al no anclar la
> anatomía base. El prompt de abajo fija **vulpino, cuadrúpedo, sin cornamenta**
> explícitamente, y corrige además el problema de agencia (ver tabla arriba: F1 es
> *aceptar*, no *reciprocidad* — "stands beside the player as equal" era el error).
>
> **✅ Regenerado 2026-07-29 con el ancla vulpina — PASS aproximado.** Boris confirmó
> resultado zorro/cuadrúpedo, sin astas, comparado contra `speck-trueform-translucent.png`
> y el viejo `Final 1 The Guided Molt.png`. El ancla anatómica funcionó. **Falta VoBo
> formal y archivo final ratificado** — queda pendiente para la próxima sesión.

```
Creature concept sheet, front view and side view, of "Speck" at the end of Final 1, 
The Guided Molt: the moment where involuntary transformation becomes accepted purpose. 
ANATOMY LOCK: she is built on a FOX skeleton — vulpine skull and muzzle, quadruped 
fox-proportioned body, four fox legs and paws, a fox tail — the SAME silhouette DNA 
as her E1 crystalline form and her shapeshifted fox disguise, just fully revealed and 
larger in scale. She is NOT a deer, NOT a stag, NOT a cervid — she has no antlers and 
no branching crown structure of any kind. She stands as a living Warden creature in 
her true red God-Core form — jade pálido revealed as vivid translucent red crystalline 
body over vulpine anatomy. Deep saturated red crystals gleam along the fox-shaped spine, 
flanks and legs with the exact geometry of the God-Core formations, alive with energy. 
Aether seams glow in warm ámbar and teal, flowing like living blood through the lattice. 
Ears are fox-shaped but translucent red and petal-thin, elegant, catching light like 
stained glass — vulpine ear shape, not floral, not antler-like. Eyes remain dark amber, 
faceted, now warm with acceptance and ancient purpose — not happiness, but grave dignity, 
looking forward into the middle distance, NOT at the player — no reciprocity, no 
dialogue, nobody asked her anything, she is enacting a decision made for her. The golden 
runes blaze across her body, active and glorious, god-script awakened. Posture is calm, 
steady, solitary — she stands alone, apart from the group, accepting her role on her 
own, not beside anyone as an equal. The light around her is warm amber and soft red, 
healing light, not danger. She reads as: *"Nobody asked. I choose to carry it anyway."* 
Small vignette: warm light radiates outward from her crystalline spine and flanks — no 
antler-like or branch-like light structures — as if mending something broken in the 
world. Mood: luminous, purposeful, solemn dignity, quiet acceptance of a decision that 
was not hers to make — grave, not triumphant. Atmosphere: renewal, warmth, ancient power 
channeled for good. Art style: hand-painted graphic novel watercolor, ligne claire, flat 
cel shading 3–4 bands, saturated red and warm amber dominant, low saturation elsewhere, 
visible paper grain. Blend of Sable × Breath of the Wild with luminosity. Negative: NO 
DEER, NO STAG, NO ELK, NO CERVID, NO ANTLERS, no branching crown or horn structures, no 
equal-footing pose beside a human figure, no eye contact with viewer/player, no 
darkness, no victim expression, no passivity, no cold light, no photorealism, no text, 
no captions, no neon glow beyond natural aether brilliance.
```

#### **5c.2a — Final 2a: The Long Winter, Handed Over — E3 Viva, Administrada ✅**

**Archivo:** `Final 2a The Long Winter Handed Over.png` (GENERADO 2026-07-30, RATIFICADO por Boris).

**Evaluación:** ✅ Los 3 ejes que distinguen F2a se cumplen — sola en cuadro (sin grupo ni jugador), contención clínica con vendaje/collar en vez de cadenas oscuras, paleta fría administrativa con su cuerpo como única nota cálida. Cuerpo de placas de cristal sólidas (mejor que la deriva a esqueleto expuesto de 5c.4). **Misma nota abierta que 5c.4, no bloqueante:** orejas de zorro simples en vez de la forma de pétalos establecida — ver ⚠️ en §Base visual común.

> Brief nuevo (2026-07-30). Nunca se había escrito: la lámina que existía para
> "Final 2" era, en rigor, el brief de F2b (ver 5c.2b abajo). F2a es distinto en
> los tres ejes que importan — **vive** (no muere como F2b), **está sola** (no
> hay grupo como en F4, y el Bond Echo canónico es *"responde débilmente, desde
> muy lejos... como quien está siendo consultada contra su voluntad"*), y el
> sabor es **decepción fría, no tragedia ni imprisonment dramático** — es un
> recurso administrado, no una prisionera de un villano (eso es F3). Sin
> cadenas oscuras (vocabulario ya usado en F3); en su lugar, contención clínica.

```
Interior keyframe of Speck's fate at the conclusion of Final 2a, The Long Winter: 
Handed Over — she lives, but she has become an administered resource. ANATOMY LOCK: 
she is built on a FOX skeleton — vulpine skull and muzzle, quadruped fox-proportioned 
body, four fox legs and paws, a fox tail, the SAME silhouette DNA as her E1 
crystalline form and her shapeshifted fox disguise — she must read clearly and 
immediately as fox-derived, NOT a generic crystal skeleton or robot. She is NOT a 
deer, NOT a stag, NOT a cervid — no antlers, no branching crown structure. Her body 
is deep saturated red translucent crystal with the exact geometry of the God-Core 
formations, gold runes still faintly active across her flanks, aether seams glowing 
low and steady in warm ámbar and teal — dimmed, not extinguished. Her ears keep 
their established petal-like shape: thin, translucent, faceted like quartz petals, 
NOT simple pointed fox ears. Her eyes are dark amber, faceted — not hollow or broken 
like a prisoner's, not warm and reciprocal like an answered question — subdued, 
distant, quietly resigned, the look of someone being consulted against her will. 
She is alone in frame — no Bound Five, no player character, no companions: this is 
the loneliness of the ending, two years later. She is contained, not chained — no 
heavy dark chains like a conqueror's prisoner. Instead: a soft woven lattice of 
pale aether-dampening crystal forms a collar and cuffs around her neck and forelegs, 
clinical rather than punitive, with a small stylized band on one foreleg — a 
diegetic institutional marker, not legible text. She rests in a sparse, cold 
institutional chamber — worked stone and dark metal, Triune Council or Great 
Forging Clan architecture, clean and administrative rather than dungeon-like. Cold 
pale blue-white aether lamps light the room evenly, no warm sunlight. A single 
narrow window or opening in the background shows a sliver of the outside world, 
distant and out of reach, going on without her. Her posture: lying or sitting 
quietly, contained but not brutalized, patient in a way that reads as resignation 
rather than peace. Mood: quiet disappointment, not tragedy — cold, administrative, 
a resource being managed, not a monster being punished. Atmosphere: sterile, still, 
muted, faintly sad. Art style: hand-painted graphic novel watercolor, ligne claire, 
flat cel shading 3–4 bands, desaturated cool palette (pale blues, greys, worked 
stone) with her red crystal body as the only warm color note in the frame, muted 
rather than saturated. Visible paper grain. Blend of Sable × Breath of the Wild, 
colder and quieter than the other finals. Negative: NO DEER, NO STAG, NO ELK, NO 
CERVID, NO ANTLERS, no branching crown or horn structures, no skeletal exposed- 
ribcage look, no simple pointed ears — ears must be petal-shaped and translucent, 
no heavy dark punitive chains, no torture or brutality, no visible player character 
or companions, no crater or wild outdoor landscape, no warm golden light, no 
triumphant or majestic framing, no hollow broken prisoner-eyes, no readable text or 
captions, no photorealism.
```

#### **5c.2b — Final 2b: The Long Winter, Fallen — E3 como God-Core Muerto, Monumento Frío ✅**

**Archivo:** `Final 2 The Long Winter.png` (GENERADO 2026-07-23, imagen pasada — el nombre de archivo interno era `Speck - Imprisoned Warden Form Final 3`, corregido acá al nombre real en disco)

**Evaluación:** ✅ 95%+ PASS — Landscape keyframe The First Wound cementerio (desolado, monumento muerto, luz fría gris-azul, Speck reconocible pero cristalizada, ojos congelados, runas dormidas, seams atenuados). Composición épica: Speck miniaturizada por vastedad, humano pequeño en distancia mirando. Paleta desaturada excepto rojo muted. Atmósfera: solemnidad, pérdida absoluta, funeral. **Capstone visual de desolación.**

#### **5c.3 — Final 3: The Conqueror's Clause — E3 Viva, Encadenada y Prisionera**

```
Creature concept sheet, front view and side view, of "Speck" in Final 3, The Conqueror's 
Clause: the moment of imprisonment and betrayal. She stands as a living Warden creature, 
transformed by the Fragmento's forced reaction, but now bound in heavy crystalline chains — 
thick geometric lattices of dark amber-tinted crystal wrapping around her limbs, torso, 
and neck, anchoring her in place. Her body is deep saturated red God-Core crystal, same 
geometry as the cores, but the translucent red is visibly cracked and fractured — trauma 
visible in the structure. The aether seams glow dimly, faintly, the red-ámbar light 
suppressed by the chains' magical weight. Her petal-like ears are drooped, translucent 
red but folded, exhausted. Eyes are still dark amber and faceted, but hollow — ancient 
consciousness imprisoned, looking at the viewer with infinite sad betrayal. The golden 
runes are barely visible, dimmed, as if the chains suppress the god-script. Posture is 
sitting or standing in submission, weight dragging, no resistance left — she has stopped 
trying. The chains glow faintly with cold blue-amber light, magical binding. Small 
vignette: she sits alone, chains casting long geometric shadows, the light cold and 
isolating. Mood: imprisoned, traumatized, betrayed, hollow — the beloved friend turned 
possession. Atmosphere: cold, isolating, cruel, the weight of ownership. Art style: 
hand-painted graphic novel watercolor, ligne claire, flat cel shading 3–4 bands, 
desaturated red with emphasis on grey chains and cold blue accents, visible paper grain. 
Blend of Sable × Breath of the Wild with darker, colder palette. Negative: no warmth, 
no freedom, no gentle posture, no active runes, no flowing seams, no hope — must read 
as defeat and ownership, not majesty.
```

#### **5c.4 — Final 4: The Warden's Choice — E3 Viva, Respondiendo ✅**

**Archivo:** `Final 4 The Warden's Choice v2.png` (GENERADO 2026-07-30, RATIFICADO por Boris — reemplaza al v1 pre-canon de 2026-07-23, que queda en `90-Raw/concept/` como referencia histórica del problema corregido).

**Evaluación:** ✅ Las 3 correcciones narrativas se cumplen — sin pedestal/monumento, mirada recíproca directa al jugador (el único beat que distingue F4), sin halo ni composición triunfal. **Nota abierta, no bloqueante:** el cuerpo derivó a costillar expuesto tipo esqueleto y las orejas perdieron la forma de pétalos — ver ⚠️ en §Base visual común. Aceptado tal cual; refinamiento visual queda para una pasada futura si hay margen.

> ⚠️ **Re-hecho 2026-07-30.** El archivo viejo (`Final 4 The Warden's Choice.png`,
> GENERADO 2026-07-23, evaluado "100% PASS" en su momento) es **pre-canon**: se
> aprobó antes del split de 5 finales, antes de la tabla de grados de agencia (hoy
> 4, ver arriba), y antes de que `Los 5 Finales §F4` fijara *"agridulce, no triunfal"* como sabor
> obligatorio. Comparado contra el canon actual, tiene 3 problemas:
> 1. **Composición de monumento** — pedestal, nombre grabado en runas, grupo
>    mirando hacia arriba a distancia reverente. Es apoteosis/deificación, no una
>    despedida. Ella *"se queda en el cráter para siempre"* tal cual quedó, no
>    como estatua erigida después.
> 2. **Sin reciprocidad.** Lo único que distingue F4 es que ella **responde** —
>    mirada hacia el jugador, no al horizonte ni al sol. El viejo la muestra
>    mirando de frente en pose de ídolo, sin ningún personaje específico como
>    destinatario de esa mirada.
> 3. **Triunfal en vez de agridulce** — halo dorado detrás de la cabeza, luz de
>    amanecer como gloria. El sabor declarado prohíbe exactamente esto.
>
> El brief de abajo mantiene el formato de landscape keyframe (coherente con
> `5c.2b`) y la luz cálida de amanecer (contraste correcto con el frío de F2b),
> pero reconstruye la escena como un momento **íntimo y recíproco**, no público.

```
Landscape keyframe of The First Wound at the conclusion of Final 4, The Warden's 
Choice — the one ending where the player asked and Speck answered. ANATOMY LOCK: 
she is built on a FOX skeleton — vulpine skull and muzzle, quadruped fox-proportioned 
body, four fox legs and paws, a fox tail — the SAME silhouette DNA as her E1 
crystalline form and her shapeshifted fox disguise. She is NOT a deer, NOT a stag, 
NOT a cervid — no antlers, no branching crown structure of any kind. She stands as 
a living Warden creature in her true red God-Core form, deep saturated red 
translucent crystal with the exact geometry of the God-Core formations around her, 
aether seams glowing warm ámbar and teal, golden runes active across her body. She 
has calcified in place at the edge of the central core — this is where she will 
stand forever, permanent, rooted directly into the crater floor. NO PEDESTAL, NO 
PLINTH, NO CARVED INSCRIPTION, NO STATUE BASE of any kind — she stands on bare 
crater ground among the God-Core formations, not elevated, not enshrined. Dawn 
light, warm gold-amber, soft — the intended contrast is with Final 2's cold 
blue-grey, not with grandeur. THE CENTRAL BEAT, the only thing that must read 
clearly: she is looking down and directly AT THE PLAYER CHARACTER, who stands close 
to her at an intimate, human distance — not at the horizon, not at the sky, not out 
at the viewer generically. Her eyes are dark amber, faceted, warm — and for the 
first and only time across all five endings there is reciprocity in that gaze: she 
was asked a question, and this is her answering it. The player character stands 
near enough to almost touch her, head tilted up, in a quiet private exchange — not 
a public unveiling. The rest of the Bound Five (Roen, Valen, Darro, the active 
Pivote) stand a short distance back, small in frame, each visibly processing their 
own private grief in their own posture — NOT posed as reverent worshippers looking 
up in awe, NOT arranged symmetrically below her like an audience at a monument. No 
golden halo or sunburst directly behind her head. Mood: bittersweet, not triumphant 
— quiet acceptance, warmth undercut by the knowledge that this is a goodbye. The 
world got its slow cure; a friend was lost anyway, only this time with her consent. 
Atmosphere: intimate, solemn, tender, grave — a farewell, not a coronation. Art 
style: hand-painted graphic novel watercolor, ligne claire, flat cel shading 3–4 
bands, warm gold-amber and saturated red dominant, visible paper grain. Blend of 
Sable × Breath of the Wild with luminosity. Negative: NO DEER, NO STAG, NO ELK, NO 
CERVID, NO ANTLERS, no branching crown or horn structures, no pedestal, no plinth, 
no carved name or runic inscription base, no statue-like presentation, no halo or 
sunburst directly behind her head, no group posed as worshippers looking up from a 
reverent distance, no looking at the horizon or sky, no looking at the viewer 
generically — she must be looking at the player character specifically, no 
triumphant or glorious framing, no photorealism, no text, no captions.
```

### Forma Shapeshifteada — Zorro (E1→E2, coexiste con Estadios Warden) — BRIEF RATIFICADO 2026-07-23

**Especificación:** La forma que ve el mundo (menos el jugador con su poder innato).
Zorro endémico de The Wilds, 1.5× tamaño normal, imperfectamente shapeshifteado por
Speck mientras despierta lentamente. El shapeshifting falla inconsistentemente: seams
teal visibles como "manchas", pata delantera izquierda translúcida (glitch), patrones
geométricos sutiles (runas dormidas), ojos facetados demasiado inteligentes. Propósito:
el mundo ve "zorro extraño"; el jugador con poder innato ve la verdad bajo el velo.

**Brief:**

```
Full-body character concept sheet, front view and side view, of "Speck" in fox form 
— the imperfect shapeshifted disguise of an ancient Warden. An endemic fox of The Wilds, 
scaled 1.5× normal size, with an unusual demeanor and physical glitches that mark the 
disguise as slowly failing. Fur is reddish-orange natural fox coloring, but with subtle 
geometric patterns traced faintly across the body — runic shapes, too regular to be 
natural, suggesting divine design beneath the illusion. The fur texture should read as 
natural but slightly *off*, as if light sometimes catches it wrong. Seams glow faintly 
in muted teal-grey in places the fur should be uniform — visible as "strange patches" to 
the casual observer, but readable as aether seams to those with power. Left foreleg 
deviates: the structure is noticeably more translucent and crystalline, catching light 
like quartz — a glitch in the shapeshifting that can't quite hide. Eyes are large, 
faceted like gems, too intelligent and ancient for a simple fox — the eyes betray the 
truth even as the form lies. Posture is relaxed but deliberate, slightly uncanny in its 
awareness and grace. Vignette: the fox sits calmly, observing — a sense of witness and 
waiting. Mood: strange, slightly unsettling, alien intelligence behind fox eyes, 
beautiful in an eerie way. Art style: hand-painted graphic novel watercolor, ligne 
claire with natural fox anatomy detail, flat cel shading 3–4 bands, low saturation warm 
palette with subtle teal-grey seams and geometric rune patterns visible, natural fox 
coloring. Visible paper grain. Blend of Sable × Breath of the Wild. Negative: no 
cartoony mascot cuteness, no Genshin aesthetic, no loss of fox anatomy, no anime style, 
no bright neon seams or runes (keep them subtle/muted), no humanoid features, no animal 
ears that read as magical — they must look like natural fox ears.
```

Referencia narrativa: ver [[Speck]] sección "Encuentro & Shapeshifting".


## 6 — Sprite sheet de grumos de follaje (golden scene / assets de árbol)

Técnica ratificada en sesión (2026-07-04): follaje por **tarjetas alpha-cutout
en cruz sobre cascarón elipsoidal con normales radiales** (TotK/Sable/
Hinterberg; meta-referencia Moebius). Implementada en
`godot/rendering/toon_foliage.gdshader` + `golden_scene._card_shell()` con
textura procedural provisional. La sprite canónica reemplaza el placeholder
guardándola como `godot/rendering/foliage_clump.png` (el código la carga solo).

```
Sprite sheet, 3x3 grid, of nine hand-drawn leaf clumps for a stylized tree canopy, on a pure white background, each clump isolated with clear white space around it. Style: Moebius ligne claire — crisp black ink outline with a scalloped, bumpy leaf-mass contour; interior filled with flat pale watercolor green in 2 tones and sparse small ink strokes suggesting individual leaves (short curved ticks, Moebius foliage texture); no gradients, no realistic rendering, visible paper grain acceptable. Each clump is a rounded cauliflower-like mass seen from the side, varied silhouettes: some wide, some tall, some small. Flat lighting, no cast shadows, no background elements. Negative: no photorealism, no 3D render look, no gradients, no Genshin saturation, no single big smooth blob — every clump edge must be scalloped and bumpy.
```

Destino: `foliage-clumps-v1.png` → recortar un grumo (o varios) → PNG con
alpha en `godot/rendering/foliage_clump.png`. El sprite debe pintarse en tonos
claros casi-blancos con verdor sutil: el color final lo pone `albedo_color`
del preset (dawn/dusk lo tiñen distinto).

## 6b — Rivermeet Keyframe (Golden Scene variante ciudad, B11)

**Archivo:** `Rivermeet keyframe` (GENERADO 2026-07-23, imagen pasada)

**Especificación:** Capital humana Aethelgard/Rivermeet, vista cinematic golden hour (tarde/atardecer). Río como protagonista (ancho, slow, glinting, refleja luz). Terraced riverside bluffs, arquitectura timber-frame, cloth awnings ochre/rust. Mercados flotantes, docks, puentes colgantes de cuerda. Foreground: marketplace con silhouettes humanas (escala). Middle: ciudad proper, ink+watercolor Sable×BotW. Background: bluffs lejanos en silhoueta pálida, aerial perspective. Luz: ambar bajo horizonte, long warm shadows. Mood: commerce + community BUT melancholic (the Restless spirit). Paleta: washed, low-saturation excepto golden light. 

**Evaluación:** ✅ 95%+ PASS — Contraste perfecto a The Wilds (vastedad solitaria). Comunica civilización, humanidad, commerce pero con tono melancólico idéntico al juego. Río es realmente protagonista. Puentes cuerda = ingenio humano. Escala íntima (dock) pero épica (cityscape). **Second golden scene landscape, establece coherencia visual de ubicaciones.**

## 6c — God-Core Night Keyframe (Golden Scene variante cementerio nocturno, B11)

**Archivo:** `God-Core Night` (GENERADO 2026-07-23, imagen pasada)

**Especificación:** Vast underground/highland cemetery de God-Cores, night. Deep blue-violet sky starlit, no moon. Massive crystalline God-Core formations (prismáticas, geométricas) justing from stone como tombstones/sleeping giants. Red crystal structures con internal glow DEEP SATURATED RED (pulsing faintly). Long geometric shadows crisp + sharp (cast by red light). Composition: empty space protagonista, perspective elevada (looking DOWN at sleeping gods). Foreground: 2-3 cores massive silhouetted contra own glow (backlighting). Middle: cores fade to ruby con distance. Far: absolute darkness, infinito. Cracked stone ground (batalla/catástrofe visible). Ink linework gris/negro, flat cel 3-4 bands. Paleta: greys + deep blues + RED saturado único color intenso. Watercolor grain. Sable night palette. Mood: solemnity, dread, awe — "cemetery of gods, waiting."

**Evaluación:** ✅ 100% PASS — Third golden scene landscape PERFECTO. Composición elevada comunica "gazing upon sleeping gods". Cracked ground = trauma visible. Red glow único color = maximum saturation rule. Contrasta F2 (muerte fría daylight) vs. Night (vigilia dormida starlight). Infinidad + silhouettes = escala cósmica. **Capstone de los 4 landscapes monumentales.**

## 6d — Keyframes de capital (QA retroactivo, agente Haiku, 2026-07-24)

Material generado en sesión previa, sin brief formal escrito, evaluado
retroactivamente contra Geografía y Ciudades.md por un agente de QA. 4/5
aprobados.

**`rivermeet-keyframe-daylight-v2.png`** — 🟡 aprobada, toma diurna
complementaria al keyframe golden-hour ya ratificado en §6b (misma ciudad,
distinta hora del día — no redundante).

**`emberdeep-keyframe-forges-v1.png`** — ✅ excelente. Capital enana:
excavación vertical, múltiples niveles, forjas + Aether azul, atmósfera
"metal caliente", arquitectura industrial enana.

**`stillspire-keyframe-canopies-v1.png`** — ✅ muy buena. Capital élfica:
ciudad suspendida en copas gigantes, arquitectura orgánica integrada a
árboles y cascadas, luces Aether verde/teal, referencia Rivendell/Imladris
cubierta.

**`mistbound-frontier-sentinel-post-v1.png`** — ✅ buena. Franja fronteriza
(no ciudad), postas defensivas simples, clima árido, cultura mercenaria
pragmática.

**`Driftmarket (mercado flotante).png`** — 🔴 sin renombrar, lore/estilo
correctos PERO tiene un caption de texto quemado en la imagen
("DRIFTMARKET – FLOATING MARKET..."), incumple la regla estándar
anti-texto (ver §10). Candidata a re-corrida con esa regla aplicada; no se
re-corrió todavía.

## 7 — Dagna (Pivote del slice, B1)

Referencia adjunta: `fenotipo-enana-v2.png` (ancla de anatomía/proporción).
Plants visuales: cuña miniatura en la trenza izquierda (el objeto firma de
[[Pivotes/Dagna-Ficha-Expandida-v1]] a la vista todo el slice), hombreras-compuerta (gremio legible a
3m), martillo-ariete (abre puertas, no mata). Destino: `dagna-v1.png`.

```
Use the attached dwarf woman character sheet as the exact anatomy, proportion and art style reference — same trapezoid silhouette exactly 4.5 heads tall, massive trapezius and shoulders swallowing the neck, wide barrel torso, enormous hands, very short thick arms and legs, low planted center of gravity — but design a specific named character: "Dagna", a veteran dwarven gatekeeper in her prime. Full-body character concept sheet, front view, back view and side view, on a plain warm paper background. Face: strong feminine face with a heavy brow, broad jaw, a nose with history, and the calm, patient gaze of someone who has stood guard at a door for decades — dignified, unhurried, quietly warm; no beard. Hair: dark copper, pulled back tight, with long ornamented side-braids at the temples threaded with small forge-iron rings, and a tiny iron wedge charm hanging from the left braid. Skin: warm bronze with soot shading. Amber geometric guild tattoos on both forearms with a gate-and-wedge motif (an arch crossed by a wedge). Clothing: practical gatekeeper armor over fitted leather and cloth in earth tones — engraved gate-plate pauldrons and shin guards that look like miniature fortress doors, a short frontier felt cape, heavy belt with tools and iron wedges, faint warm ember accents at the seams, medieval aetherpunk. Weapon: a flat-headed gate maul (the head reads as a door ram, not a war hammer) slung across her back. Art style: hand-painted graphic novel watercolor — crisp black ink linework, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Mood: the mountain that learned to love what it guarded. Negative: no tall or slender body, no long legs, no human proportions, no hourglass figure, no full beard, no full plate armor, no comedic caricature, no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no neon glow.
```

## 8 — Cabeza/rostro close-up (Humano) — lámina de medición para Fase 5

**Por qué existe:** [[Fase5-Cara-Propuesta-DRAFT]] (rework de mandíbula/
ojos/nariz/mentón/orejas) necesita medir proporción en píxeles con el mismo
método que ya destrabó `SHOULDER_X` ([[Lecciones]]) — pero no existe lámina
de cabeza en close-up, solo `fenotipo-humano-v1.png` (cuerpo completo, cara
chica) y las reviews `Character-Head-Review-v0.2-v0.5` (capturas del propio
rig, no concept art de referencia externa). **Decisión de Boris
(2026-07-16): generar una nueva.** Referencia de fenotipo: brief 3 —
humano the Restless/Mistbound, silueta atlética neutral de la que las otras
2 razas se desvían. A diferencia del brief 3 (cuerpo completo, expresión de
personalidad), esta lámina pide **expresión neutra y encuadre grande**
específicamente para que las 5 partes sean medibles pixel a pixel en las 4
vistas — no es una lámina de personalidad, es una lámina de regla.

```
Head and neck close-up character reference sheet, four views side by side at the exact same scale (front view, three-quarter view, profile view, back view), of a human mercenary — the same phenotype as the athletic reference human (the Restless / Mistbound): balanced proportions, individual and imperfect features typical of the most physically diverse race, weathered river-town features, adult male, on a plain warm paper background. Neutral relaxed expression with mouth closed in all four views — this is a measurement reference, not an expression study. Bald or short cropped hair pulled back so the ears, jaw line, cheekbones and hairline are fully visible and unobstructed in every view — no hair covering the ears or forehead. Skin in a mid-range human tone. Clearly readable individual features: defined jaw, natural nose, visible ear shape and placement, natural eye shape and spacing — every part at consistent scale across all four views so proportions can be compared directly view to view. Art style: hand-painted graphic novel watercolor — crisp black ink linework on the figure, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Negative: no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no neon glow, no hair covering the ears or jaw, no smiling or exaggerated expression, no different head size between the four views, no accessories or headwear, no beast-folk features, no animal ears or tail.
```

**Uso previsto:** una vez generada y aprobada contra los 5 ejes del [[Art
Bible]] (mismo protocolo que el resto de este documento), guardar como
`fenotipo-humano-rostro-v1.png` en `90-Raw/concept/` y medir sobre ella
(método de [[Lecciones]]: medir en píxeles, convertir a proporción
relativa, nunca inventar el número) mandíbula, separación de ojos,
proyección de nariz, mentón y posición/tamaño de oreja en las 4 vistas.

## 9 — Gobernantes y Triune Council (Estructura Política, B12)

**Contexto:** [[Estructura Política]] define 3 reinos + un cuerpo
supra-racial de 3 asientos. Generados con **Nano Banana 2** (no Pro —
prompts ajustados a un solo turno, sin depender de re-roll iterativo
multi-imagen). Cada brief usa el fenotipo racial ya ratificado (briefs 1/2c/3)
como ancla de anatomía/proporción y agrega regalía + edad + personalidad
específica del cargo. Destino: `90-Raw/concept/` — `reina-ithessa-v1.png`,
`rey-borran-v1.png`, `regente-edrick-ashcombe-v1.png`,
`embajador-cyrion-v1.png`, `embajador-kadrun-v1.png`,
`consejera-merrit-vance-v1.png`.

**Nota de diseño transversal:** Reina y Rey deben leer como **gobernantes
legítimos** (regalía plena, autoridad tranquila); Regent Edrick debe leer
**deliberadamente menos regio** — cargo precario, no sangre real ([[Estructura
Política]]: "Voice of the Council", no "Rey"). Los 3 embajadores del Council
deben leer como **diplomáticos/burócratas de alto nivel**, no guerreros ni
realeza — ropa formal de embajada, no armadura ni corona.

**⚠️ Adjuntar el fenotipo racial correspondiente (hallazgo QA 2026-07-24):**
todo brief que abre con *"Use the [race] phenotype as the exact anatomy and
proportion reference"* asume una imagen adjunta — sin ella, NB2 no tiene
ancla visual real y el texto solo no basta (causa probable de la falla de
proporción en Ithessa/Borran v1, ver [[LOG]]). Archivos existentes en
`90-Raw/concept/`:

| Brief | Personaje | Adjuntar |
|---|---|---|
| 9a / 9a-v2 | Queen Ithessa | `fenotipo-elfa-V2.png` |
| 9b / 9b-v2 | King Borran | `fenotipo-enano-varon-v1.png` |
| 9c | Regent Edrick | `fenotipo-humano-v1.png` |
| 9d | Embajador Cyrion | `fenotipo-elfo-V2.png` |
| 9e | Embajador Kadrun | `fenotipo-enano-varon-v1.png` |
| 9f | Consejera Merrit Vance | `fenotipo-humana-V1.png` |

Los prompts v2 (9a-v2, 9b-v2) ya no dependen del adjunto — la proporción
está reescrita directo en el texto como regla #1 — pero adjuntar igual
refuerza, no contradice.

### 9a — Queen Ithessa (Stillwood)

555 años — mayor que Valen/Sereth (180-250) pero más joven que el Círculo de
los Vivos (570-700+, vivieron el cataclismo como adultos). Debe leer como
elfa madura y digna, no como anciana frágil ni como joven ingenua — gobierna
hace siglos pero carga el peso de no ser la máxima autoridad moral de su
propio reino.

```
Use the elf phenotype as the exact anatomy and proportion reference — silhouette reads as one continuous vertical line, roughly 8 heads tall, narrow sloped shoulders, long neck, long limbs, flexible posture held high, long ears sweeping backward — but design a specific named character: "Queen Ithessa", ruler of an ancient elven forest kingdom, mature and dignified, centuries old but not frail — regal composure earned over a long, steady reign, not youthful innocence. Full-body character concept sheet, front view and side view, on a plain warm paper background. Face: high cheekbones, large almond eyes with a calm, measuring gaze — the expression of someone who has ruled long enough to be patient, but who carries a quiet awareness that she is not the oldest wisdom in her own court. Hair: very long, silver-white with the faintest residual warmth of youth at the roots, styled in an elaborate braided coronet that becomes her crown — no separate metal crown, the hair itself is the regalia. Skin: cold pale tones with a faint lavender undertone. Glowing pale-teal aether engravings traced across the collarbone, forearms and temples, denser and more ornamental than a common elf's — a queen's mark. Clothing: a long flowing formal gown in deep forest green and silver, structured shoulders that echo tree-bark texture, medieval aetherpunk with organic brass filigree at the hems, a small ceremonial staff of pale wood inlaid with teal aether veins held loosely at her side. Art style: hand-painted graphic novel watercolor — crisp black ink linework, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Mood: quiet, steady authority — a ruler who governs the present without claiming ownership of the past. Negative: no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no neon glow, no heavy armor, no separate metal crown, no frail elderly appearance, no youthful/childlike appearance.
```

### 9a-v2 — Queen Ithessa (REVISADO — corrige corona/silueta/estilo, QA 2026-07-24)

**Hallazgos de la v1 (NB2):** corona metálica presente pese al negativo
explícito; silueta no leyó como el ancla élfica (hombreras anchas, proporción
de fantasía estándar en vez de línea vertical de 8 cabezas); marcas teal
extendidas por mejillas como pintura facial; estilo general más ilustración
pulida/semi-anime que acuarela Sable×BotW. Prompt reforzado: proporción al
frente como "regla más importante" (mismo truco que blindó a la enana en el
brief 2c), regalía sin metal reforzada en positivo Y negativo, marcas
relocalizadas, negativos de estilo mucho más agresivos.

```
Full-body character concept sheet, front view and side view, of "Queen Ithessa", ruler of an ancient elven forest kingdom, on a plain warm paper background. The silhouette is the single most important rule: she reads as one continuous unbroken vertical line, exactly 8 heads tall, narrow sloped shoulders with NO pauldrons or shoulder armor breaking the line, a long slender neck, long thin limbs, willowy and elongated — NOT a standard fantasy body, NOT broad-shouldered, every part of her reads tall and narrow. Long pointed ears sweep backward continuing the line of the skull. Face: high cheekbones, large almond eyes with a calm measuring gaze, fine narrow jaw — mature and dignified, centuries old but not frail. Hair: very long, silver-white, elaborately braided and coiled directly on top of her own head into a crown shape — the braided hair itself IS the crown, there is no metal, no gemstones, no separate headpiece of any kind sitting on top of or woven into the hair. Skin: cold pale tones with a faint lavender undertone, smooth and unmarked on the cheeks and forehead — the face has NO glowing patterns, NO teal markings, NO face paint of any kind. Faint glowing pale-teal aether engravings appear ONLY on the collarbone and forearms, thin delicate filigree lines, not a dense pattern. Clothing: a long flowing formal gown in deep forest green and silver with soft draped fabric shoulders (fabric only, no rigid armor plates), medieval aetherpunk organic brass filigree at the hem, a slender pale wood ceremonial staff inlaid with teal aether veins held loosely at her side. Art style: this must look like a traditional hand-painted watercolor illustration on textured paper — visible rough watercolor paper grain across the entire image, crisp black ink linework with slightly uneven hand-drawn line weight, flat cel shading in only 3-4 distinct light bands with soft dry-brush jittered edges between them, NOT a smooth gradient. Washed, low-saturation, slightly muted watercolor palette. Style blend of the game Sable's ligne claire flat graphic shapes and Breath of the Wild's soft impressionist color. Negative: no metal crown, no tiara, no gemstone headpiece, no jewelry on the head besides braided hair, no face paint, no facial markings on cheeks or forehead, no shoulder armor or pauldrons, no broad shoulders, no standard/average fantasy body proportions, no short or stocky body, no smooth airbrushed digital gradient shading, no clean vector-style linework, no glossy modern video-game splash art finish, no anime illustration style, no Genshin Impact candy saturation, no photorealism or PBR rendering, no neon glow, no heavy armor, no frail elderly appearance, no youthful/childlike appearance.
```

### 9b — King Borran (Ignis Reach)

Tataranieto directo del Rey del cataclismo — sucesión ritual, sin disputa. Debe
leer como enano de mediana edad ya asentado en el trono (no joven heredero
inseguro), con regalía que fusiona corona y forja — el Great Forging Clan
**es** el trono, no un cuerpo separado.

```
Use the dwarf phenotype as the exact anatomy and proportion reference — a trapezoid silhouette nearly as wide as tall, exactly 4.5 heads tall, massive trapezius and shoulders swallowing the neck, wide barrel torso, enormous hands, very short thick limbs, low planted center of gravity, immovable stance — but design a specific named character: "King Borran", ruler of a dwarven mountain kingdom, mature and settled in his reign, great-grandson of the king who lived through the ancient cataclysm — carries inherited ceremonial memory with total confidence, not insecurity. Full-body character concept sheet, front view and side view, on a plain warm paper background. Face: heavy brow, broad jaw, a thick braided beard woven with small forge-iron rings and rune-stamped clasps — the beard itself reads as a chronicle of his lineage. Hair: dark iron-grey, pulled back beneath a low crown that is forged, not gemmed — a simple heavy band of dark iron and gold inlay shaped like overlapping hammer-strikes, fused seamlessly with the aesthetic of the Great Forging Clan rather than looking like a separate royal ornament. Skin: warm bronze tones with soot shading. Amber geometric guild-and-crown tattoos on both forearms, denser than a common smith's. Clothing: ceremonial forge-plate over practical smith-king garb — dark iron pauldrons chased with gold, a heavy fur-lined mantle in deep ember red and black, medieval aetherpunk with faint warm ember accents glowing at the seams. Holds a ceremonial war-hammer/scepter hybrid, more symbol than weapon, resting head-down on the ground. Art style: hand-painted graphic novel watercolor — crisp black ink linework, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Mood: immovable, generational certainty — a mountain that has always had a king. Negative: no tall or slender body, no human proportions, no comedic caricature dwarf, no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no neon glow, no gemstone-heavy crown, no young/insecure posture.
```

### 9b-v2 — King Borran (REVISADO — corrige proporción/estilo, QA 2026-07-24)

**🟡 ESTADO: PROVISIONAL.** Hay dos re-rolls de este prompt archivados en
`90-Raw/concept/`: uno intermedio (con la nota menor de más abajo, ahora en
`_legacy/king-borran-v2-superseded.png`) y uno posterior, corrido después de
esa nota — **`king-borran-v2.png` es el vigente**, por ser el último que
Boris generó (2026-07-24). No tiene QA formal registrado todavía; sigue sin
bloquear el frente. Si se retoma: aplicar el mismo formato de prosa corta que
resolvió Kadrun en 9e-v2 (ver [[LOG]]), no solo reforzar la proporción en una
oración densa.

**Hallazgos de la v1 (NB2):** proporción enana ROTA — leyó como vikingo
humano grande (~5-6 cabezas), no como el trapezoide de 4.5 cabezas blindado
en el canon (Dagna/Torgan/Vekka lo respetan); corona genérica sin motivo de
martillo; mismo problema de estilo pulido/semi-anime que Ithessa. Prompt
reforzado: proporción como "regla más importante" (idéntico framing al que
salvó a la enana en el brief 2c), corona con motivo explícito reforzado,
negativos de estilo agresivos.

```
Full-body character concept sheet, front view and side view, of "King Borran", ruler of a dwarven mountain kingdom, on a plain warm paper background. The proportions are the single most important rule: he is exactly 4.5 heads tall, a trapezoid silhouette nearly as wide as he is tall, with a massive trapezius and shoulders so wide they swallow the neck entirely, a wide barrel torso, enormous hands, very short thick arms and legs, and a low planted center of gravity — immovable, built like a load-bearing wall, NOT a tall human viking build. He is NOT tall, NOT athletic, NOT broad-in-a-human-way — every limb is short and thick, the total height barely clears a human's waist. Face: heavy brow, broad jaw, a thick braided grey beard woven with small forge-iron rings and rune-stamped clasps — the beard itself reads as a chronicle of his lineage. Hair: dark iron-grey, pulled back beneath a crown that is clearly forged metal, not gemmed — a heavy band of dark iron with raised gold inlay in a repeating overlapping hammer-strike chevron pattern, visibly fused in style with forge-craft rather than looking like a jeweled royal ornament. Skin: warm bronze tones with soot shading. Amber geometric guild-and-crown tattoos on both forearms. Clothing: ceremonial forge-plate over practical smith-king garb sized to his short thick frame — dark iron pauldrons chased with gold sitting on his massive shoulders, a heavy fur-lined mantle in deep ember red and black, medieval aetherpunk with faint warm ember accents glowing at the seams. Holds a ceremonial war-hammer/scepter hybrid at rest, head resting on the ground, in a relaxed formal stance rather than a battle-ready one. Art style: this must look like a traditional hand-painted watercolor illustration on textured paper — visible rough watercolor paper grain across the entire image, crisp black ink linework with slightly uneven hand-drawn line weight, flat cel shading in only 3-4 distinct light bands with soft dry-brush jittered edges between them, NOT a smooth gradient. Washed, low-saturation, slightly muted watercolor palette. Style blend of the game Sable's ligne claire flat graphic shapes and Breath of the Wild's soft impressionist color. Negative: no tall body, no human proportions, no viking-human build, no long or average-length arms and legs, no slender build, no comedic caricature dwarf, no gemstone-heavy crown, no plain unadorned crown, no battle-ready aggressive stance, no smooth airbrushed digital gradient shading, no clean vector-style linework, no glossy modern video-game splash art finish, no anime illustration style, no Genshin Impact candy saturation, no photorealism or PBR rendering, no neon glow.
```

### 9c — Regent Edrick Ashcombe (Aethelgard)

**Diferencia deliberada de los dos anteriores:** sin sangre real, cargo
precario ("Voice of the Council" — [[Estructura Política]]). Debe leer
administrativo/burocrático, no monárquico — nervioso bajo la compostura,
consciente de que su Casa podría caer como las anteriores.

```
Use the human phenotype as the exact anatomy and proportion reference — balanced athletic proportions, roughly 7.5 heads tall, individual and imperfect features typical of the most physically diverse race — but design a specific named character: "Regent Edrick Ashcombe", the current civil administrator of a human river-trade city, NOT a hereditary king — his authority is political and precarious, not born. Full-body character concept sheet, front view and side view, on a plain warm paper background. Face: middle-aged, sharp intelligent features, a carefully neutral courtroom expression that doesn't fully hide an undercurrent of calculation and mild anxiety — the face of a man who knows his position could collapse like the ones before him. Hair: dark brown streaked with early grey, cropped short and precisely groomed. Skin: mid-range human tone, city-pale rather than weathered. Clothing: formal administrative robes of office in deep river-blue and muted gold, layered and structured like a magistrate's or high clerk's dress rather than a king's — NO crown; instead a heavy chain-of-office pendant bearing the seal of the Council, worn over the chest as his only symbol of authority. Carries a sealed scroll-case and a single ornate signet ring, medieval aetherpunk river-city tailoring with brass clasp details. Art style: hand-painted graphic novel watercolor — crisp black ink linework, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Mood: composed but precarious — power borrowed, not owned. Negative: no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no neon glow, no crown, no royal regalia, no heavy armor, no beast-folk features.
```

### 9d — Embajador Cyrion (asiento élfico del Triune Council)

Nombramiento de larga permanencia — décadas en Rivermeet representando a la
Queen Ithessa. Diplomático veterano, distinto en tono de Sereth (más joven,
cortesano) y de Valen (académico contemplativo) — este es poder político
puro, ejercido con paciencia élfica.

```
Use the elf phenotype as the exact anatomy and proportion reference — silhouette reads as one continuous vertical line, roughly 8 heads tall, narrow sloped shoulders, long neck, long limbs, flexible posture, long ears sweeping backward — but design a specific named character: "Ambassador Cyrion", a veteran elven diplomat who has represented his queen's court in a foreign human capital for decades. Full-body character concept sheet, front view and side view, on a plain warm paper background. Face: high cheekbones, narrow jaw, an almost unreadable diplomat's calm — eyes that assess everything and reveal nothing, the patience of someone who has outlasted several human governments already. Hair: pale silver-blond, sleek and precisely tied back in a low formal knot, no loose strands — nothing left to chance. Skin: cold pale tones with a faint lavender undertone. Faint pale-teal aether engravings at the collarbone, understated and formal rather than ornamental. Clothing: severe formal diplomatic robes in muted slate-grey and deep teal, structured and minimal, cut for a foreign court rather than his own — no weapons visible, a small formal seal-ring is his only ornament. Art style: hand-painted graphic novel watercolor — crisp black ink linework, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Mood: patient, permanent, watchful — a fixture of the court he serves in, not a visitor. Negative: no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no neon glow, no weapons, no heavy armor, no royal crown.
```

### 9e — Embajador Kadrun (asiento enano del Triune Council)

Cargo casi hereditario dentro del Great Forging Clan — formal, no de trabajo.
Distinto en tono de Vekka (maestra técnica en su taller) — este es the Great Forging Clan
en su registro diplomático, no artesanal.

```
Use the dwarf phenotype as the exact anatomy and proportion reference — a trapezoid silhouette nearly as wide as tall, exactly 4.5 heads tall, massive trapezius and shoulders swallowing the neck, wide barrel torso, enormous hands, very short thick limbs, low planted center of gravity — but design a specific named character: "Ambassador Kadrun", a senior dwarf of the Great Forging Clan posted for life as his king's formal representative in a foreign human capital — dignified diplomat, not a working smith. Full-body character concept sheet, front view and side view, on a plain warm paper background. Face: heavy brow, broad jaw, a neatly groomed formal beard (shorter and more precisely trimmed than a working smith's, threaded with fewer but finer forge-iron rings) — composed, formally polite, immovable patience. Hair: iron-grey, pulled back tight and formal. Skin: warm bronze tones with soot shading, less soot-stained than a working forger's — this is a court dwarf, not a shop-floor one. Amber geometric guild tattoos on both forearms, the Great Forging Clan's mark rendered in a fine formal style. Clothing: formal ambassadorial dress rather than smith's gear — a structured dark-iron-grey coat with gold clan-crest clasps, no apron or work tools, medieval aetherpunk with restrained ember-colored trim at the cuffs. Carries no weapon, only a small ceremonial clan seal on a chain. Art style: hand-painted graphic novel watercolor — crisp black ink linework, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Mood: formal, immovable, quietly proud — clan authority wearing a diplomat's coat. Negative: no tall or slender body, no human proportions, no comedic caricature dwarf, no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no neon glow, no work apron or smith tools, no weapon.
```

### 9e-v2 — Embajador Kadrun (REVISADO — corrige texto filtrado en imagen, QA 2026-07-24)

**Hallazgo de la v1 (NB2):** el prompt se filtró como texto renderizado
dentro de la propia imagen (bloque de instrucciones visible, con palabras
corrompidas: "waterco-shading", "ceshading", "jitterd jittered", "Noo work
tools") — glitch de generación, probablemente por densidad/longitud del
prompt original. Reescrito en prosa más corta y natural, negativos como
oraciones simples en vez de una lista larga tras "Negative:" — mismo
contenido, menos denso.

```
Full-body character concept sheet, front view and side view, of a dwarf ambassador named Kadrun, on a plain warm paper background. He has a wide trapezoid body, exactly four and a half heads tall, with massive shoulders that swallow his neck, a broad barrel chest, enormous hands, and very short thick arms and legs — squat, wide, and low to the ground, nothing like a tall human build. His face has a heavy brow and broad jaw, framed by a neatly trimmed grey beard threaded with a few fine forge-iron rings — calm, formally polite, patient. His grey hair is pulled back tight. His skin is warm bronze with light soot shading. Fine amber geometric guild tattoos mark both forearms. He wears a structured dark iron-grey formal coat with gold clan-crest clasps and warm ember-colored trim at the cuffs — no apron, no tools, no weapon, just a small ceremonial clan seal on a chain around his neck. Painted in a hand-painted watercolor graphic-novel style: crisp black ink outlines, flat shading in a few soft bands with dry-brush edges, a muted low-saturation palette, visible watercolor paper grain — style blend of the games Sable and Breath of the Wild. No tall or slender body. No human proportions. No comedic caricature dwarf. No candy-bright saturation. No photorealism or PBR rendering. No anime cel shading. No neon glow. No apron or smith tools. No weapon.
```

### 9f — Consejera Merrit Vance (asiento humano del Triune Council)

El asiento más volátil de los 3 — se gana por consenso de Casas + Consorcio
de Mercado, no por sangre. Debe leer más afilada y políticamente agresiva que
Regent Edrick — alguien que escaló para llegar aquí y sabe que puede
perderlo.

```
Use the human phenotype as the exact anatomy and proportion reference — balanced athletic proportions, roughly 7.5 heads tall, individual and imperfect features typical of the most physically diverse race — but design a specific named character: "Councilor Merrit Vance", the current human seat-holder of a supra-racial diplomatic council, a political operator who won her seat through negotiation and consensus rather than birthright — sharper and more visibly ambitious than a hereditary noble, aware her position can be lost as easily as it was gained. Full-body character concept sheet, front view and side view, on a plain warm paper background. Face: sharp intelligent features, a composed public smile that doesn't quite reach watchful eyes, the look of someone always reading the room for the next shift in power. Hair: dark, pulled back in a severe practical style with a few precise loose strands, no softness wasted on vanity. Skin: mid-range human tone, city-pale. Clothing: sharply tailored formal court dress in deep wine-red and charcoal, structured shoulders that read as armor without being armor, layered river-city formal wear, medieval aetherpunk with fine brass clasp details — more overtly powerful and less bureaucratic-grey than a court clerk's robes. Carries a slim ceremonial letter-opener/dagger hybrid at her belt, symbolic more than practical. Art style: hand-painted graphic novel watercolor — crisp black ink linework, flat cel shading in 3–4 fixed light bands with dry-brush jittered edges, washed low-saturation watercolor palette, visible paper grain, style blend of the game Sable's ligne claire and Breath of the Wild's soft impressionist color. Mood: sharp, hungry, precarious — power she fought for and knows how to lose. Negative: no Genshin Impact candy saturation, no photorealism or PBR rendering, no generic anime cel shading, no neon glow, no crown or royal regalia, no heavy armor, no beast-folk features.
```

## 10 — Elenco político nuevo (Isolde Marrow, Tobin Hale, The Elder Circle)

**Formato:** prosa corta y natural, no oraciones densas con "Use the X
phenotype as the exact anatomy and proportion reference" — ese formato
causó texto filtrado dentro de la imagen y peor fidelidad de proporción en
la ronda de QA anterior (ver [[LOG]], Kadrun v1→v2). Este formato replica
lo que sí funcionó: prosa breve, proporción como primera frase, negativos
como oraciones cortas al final. **Recomendado adjuntar** el fenotipo
correspondiente igual (tabla en §9) — refuerza, no contradice.

**Destino en `90-Raw/concept/`:** `isolde-marrow-v1.png` ·
`tobin-hale-v1.png` · `threnn-v1.png` · `ilyara-v1.png` · `maelys-v1.png` ·
`corwyn-v1.png`. Adjuntar `fenotipo-humana-V1.png` (10a, mujer),
`fenotipo-humano-v1.png` (10b, varón), `fenotipo-elfo-V2.png` (Threnn/
Corwyn, varones), `fenotipo-elfa-V2.png` (Ilyara/Maelys, mujeres).

### 10a — Lady Isolde Marrow (House Marrow, rival de Regent Edrick)

Contraste directo con Edrick: carismática, confiada, populista — sin
corona (no la tiene, todavía), pero con presencia que sugiere que la
merece. [[Estructura Política]].

```
Full-body character concept sheet, front view and side view, of a human noblewoman named Isolde Marrow, on a plain warm paper background. She has balanced athletic proportions, roughly seven and a half heads tall, standing with confident open posture and a direct, magnetic gaze — nothing like a cautious bureaucrat, everything like someone who expects to be followed. Her face is sharp and warm at once, mid-thirties, a winning half-smile that reads as genuine charisma rather than practiced diplomacy. Her hair is dark auburn, styled elegantly but practically, loose enough to move. Her skin is a warm mid-range human tone. She wears a fitted traveling-court hybrid outfit — rich burgundy and deep bronze fabric cut for movement, not court stillness, medieval aetherpunk with brass clasp details. No crown, no formal chain of office — instead a single heirloom ring with worn, ancient engraving, and a small House Marrow crest brooch, both clearly older than anything she could have commissioned herself, hinting at a lineage she claims predates the current throne. Painted in a hand-painted watercolor graphic-novel style: crisp black ink outlines, flat shading in a few soft bands with dry-brush edges, a muted low-saturation palette, visible watercolor paper grain — style blend of the games Sable and Breath of the Wild. No crown or royal regalia. No heavy armor. No photorealism or PBR rendering. No anime cel shading. No candy-bright saturation. No neon glow. No beast-folk features. No text, no labels, no captions, no annotations, no diagram-style callouts.
```

### 10b — Harbormaster Tobin Hale ("Old Tobin", Driftmarket)

Sin sangre de House, sin corrupción — poder ganado por reputación durante
décadas. Debe leer humilde y cálido pese a controlar el comercio del
Driftmarket. [[Geografía y Ciudades]].

```
Full-body character concept sheet, front view and side view, of a human harbormaster named Tobin Hale, on a plain warm paper background. He has balanced but weathered proportions, roughly seven and a half heads tall, in his sixties, with a warm, welcoming stance rather than an imposing one — despite his real economic power, nothing about him reads wealthy or noble. His face is deeply lined and sun-weathered, kind eyes with decades of patience in them, a easy half-smile, thick grey-white beard and hair, practical and unstyled. His skin is a warm tan, roughened by years of sea air. He wears a heavy, well-worn wool coat over practical dockworker's clothing, sleeves rolled, faint ember-brown and sea-blue tones, medieval aetherpunk with small brass fittings — the coat's lapels covered in a scattering of small tokens and charms, gifts from decades of traders and refugees he helped, each different, none matching, a quiet record of a life of small honest kindnesses. Carries a battered leather logbook under one arm. Painted in a hand-painted watercolor graphic-novel style: crisp black ink outlines, flat shading in a few soft bands with dry-brush edges, a muted low-saturation palette, visible watercolor paper grain — style blend of the games Sable and Breath of the Wild. No wealthy or noble clothing. No crown or regalia. No heavy armor. No photorealism or PBR rendering. No anime cel shading. No candy-bright saturation. No neon glow. No text, no labels, no captions, no annotations, no diagram-style callouts.
```

### 10c — The Elder Circle (4 briefs, mismo tratamiento de edad extrema)

**Nota transversal:** los 4 deben leer visiblemente más viejos que
cualquier otro elfo ya generado (Valen/Sereth/Lyris/Nyael/Cyrion, todos
180-250 años) — se acercan al techo de vida élfico (650-700). Canas
totales (raro en elfos), quietud pesada en la postura, piel aún más
translúcida por la edad. [[Estructura Política]].

#### Threnn — el guerrero que proteger el statu quo a cualquier costo

```
Full-body character concept sheet, front view and side view, of an ancient elf named Threnn, on a plain warm paper background. His silhouette still reads as one continuous vertical line, roughly eight heads tall, narrow sloped shoulders, long limbs — but carried with the stillness and weight of extreme age, centuries beyond a typical elf. His hair is fully silver-white, unusually so even for an elf, pulled back severely. His face is stern, weathered by time rather than sun, deep quiet lines around eyes that have seen war — heavy, unmoving expression, a soldier who never stopped being one. His skin is pale with a cold undertone, visibly more translucent and aged than a young elf's. Faint pale-teal aether engravings trace his collarbone, dimmer than a young elf's, as if faded with time. He wears simple, age-worn robes in muted iron-grey and deep green, no ornamentation except a single old scar across one forearm and a plain sword-belt worn empty — a warrior's habit outliving the need for a weapon. Painted in a hand-painted watercolor graphic-novel style: crisp black ink outlines, flat shading in a few soft bands with dry-brush edges, a muted low-saturation palette, visible watercolor paper grain — style blend of the games Sable and Breath of the Wild. No youthful appearance. No bright or dark hair color, silver-white only. No heavy armor. No photorealism or PBR rendering. No anime cel shading. No neon glow. No text, no labels, no captions, no annotations, no diagram-style callouts.
```

#### Ilyara — la sanadora que cree que la Muda debe completarse

```
Full-body character concept sheet, front view and side view, of an ancient elf healer named Ilyara, on a plain warm paper background. Her silhouette reads as one continuous vertical line, roughly eight heads tall, narrow sloped shoulders, long limbs, but held with the gentle stillness of extreme age. Her hair is fully silver-white, loose and simple. Her face is calm and deeply compassionate, soft lines of age around eyes that carry old grief without bitterness — a healer who has seen the worst of what bodies and hearts can survive. Her skin is pale, cold-toned, visibly translucent with age, fine pale-teal aether engravings faded along her forearms and hands. She wears simple flowing healer's robes in soft sage-green and bone-white, unadorned, sleeves pushed back, a small pouch of dried herbs at her belt. Painted in a hand-painted watercolor graphic-novel style: crisp black ink outlines, flat shading in a few soft bands with dry-brush edges, a muted low-saturation palette, visible watercolor paper grain — style blend of the games Sable and Breath of the Wild. No youthful appearance. No bright hair color, silver-white only. No heavy armor or weapons. No photorealism or PBR rendering. No anime cel shading. No neon glow. No text, no labels, no captions, no annotations, no diagram-style callouts.
```

#### Maelys — la testigo rota, casi no habla

```
Full-body character concept sheet, front view and side view, of an ancient elf named Maelys, on a plain warm paper background. Her silhouette reads as one continuous vertical line, roughly eight heads tall, narrow sloped shoulders, long limbs, but drawn inward, distant, as if partly elsewhere. Her hair is fully silver-white, unkempt, falling loosely over part of her face. Her expression is unreadable and haunted, eyes slightly unfocused, looking through the viewer rather than at them — the stillness of someone who witnessed something she has never named. Her skin is very pale, almost ghostly translucent, faint pale-teal aether markings barely visible, as if fading away. She wears simple, undyed grey-white robes, plain and unadorned, a thin shawl pulled loosely around her shoulders as if for comfort rather than warmth. Painted in a hand-painted watercolor graphic-novel style: crisp black ink outlines, flat shading in a few soft bands with dry-brush edges, a muted low-saturation palette, visible watercolor paper grain — style blend of the games Sable and Breath of the Wild. No youthful appearance. No bright hair color, silver-white only. No confident or alert posture. No heavy armor or weapons. No photorealism or PBR rendering. No anime cel shading. No neon glow. No text, no labels, no captions, no annotations, no diagram-style callouts.
```

#### Corwyn — el más político de los cuatro

```
Full-body character concept sheet, front view and side view, of an ancient elf named Corwyn, on a plain warm paper background. His silhouette reads as one continuous vertical line, roughly eight heads tall, narrow sloped shoulders, long limbs, held with poised, composed confidence despite his great age. His hair is fully silver-white, sleek and precisely groomed, tied back in a formal knot. His face is sharp and composed, faint knowing smile, calculating eyes that miss nothing — a courtier's face that never fully retired from the court. His skin is pale, cold-toned, visibly aged but well-kept. Faint pale-teal aether engravings trace his collarbone, understated. He wears well-tailored formal robes in muted slate-blue and silver, more refined and court-adjacent than the other Elder Circle members, a single understated silver ring his only ornament. Painted in a hand-painted watercolor graphic-novel style: crisp black ink outlines, flat shading in a few soft bands with dry-brush edges, a muted low-saturation palette, visible watercolor paper grain — style blend of the games Sable and Breath of the Wild. No youthful appearance. No bright hair color, silver-white only. No heavy armor or weapons. No photorealism or PBR rendering. No anime cel shading. No neon glow. No text, no labels, no captions, no annotations, no diagram-style callouts.
```

## 11 — Briefs pendientes 2026-07-27 (item Wanderer's Goggles + 13 keyframes de lugar)

Batch escrito por Haiku 4.5 siguiendo las plantillas de §6d/§10 (formato prosa corta, regla anti-texto obligatoria). Boris decide el orden de corrida en NB2 — este batch documenta los 14 prompts listos para ejecutar.

**Nota:** el §11.7 (torres de guardia) se separa en 11.7a/b/c porque cada raza es visualmente muy distinta.

**Nueva convención de archivos:** el §11.2 (Wanderer's Goggles) inaugura una carpeta `90-Raw/concept/props/` para items diegéticos futuros (Fragmento, God-Cores individualizados, etc.).

**✅ CERRADO (2026-07-27) — 14/14 corridas y QA'd, 13/14 ratificadas al primer o segundo intento:**
- **13 ratificadas directo:** Driftmarket v2, Wanderer's Goggles, First Wound, Grove of Cycles, Oficina de Tobin, las 3 Torres de Guardia, Rivermeet Council Chamber, Emberdeep vertical, Ascending Falls, Iven's Settlement, Mistbound interior.
- **1 con iteración:** Sunken Archive — v1 rechazada (leyó como catacumba egipcia con momias), v2 ratificada.
- **Lección de proceso:** un rechazo inicial de la oficina de Tobin fue revertido — el texto en un mapa colgado en la pared es contenido diegético de un objeto in-world, no un caption/label inyectado por NB2. La regla anti-texto aplica a artefactos de generación (spec-sheets, captions flotantes), no a texto narrativamente justificado dentro de la escena (mapas, cartas, libros que un personaje tendría).
- Detalle de QA por brief en cada sub-sección abajo.

### 11.1 — Driftmarket re-corrida — RATIFICADO ✅

**Archivo destino:** `driftmarket-keyframe-v2.png`

**Especificación:** Ciudad flotante suspendida sobre The Wilds, plataformas de madera rústica conectadas por puentes de cadena y cuerda. Velas de tela ochre-rust llenan el cielo, batidas por viento constante. Mercado caótico en el nivel bajo: silhouettes de mercaderes, nómadas, mesas de comercio, canastas, bolsas colgantes. Luces teal-azulada de Aether despierto (no corrupto) filtrándose entre los mástiles. Atmósfera crepuscular cálida, como una tarde que nunca termina del todo. Agua visible muy abajo — oscura, en movimiento. Composición: vista elevada desde un ángulo de 45°, Driftmarket al centro-izquierda, río/The Wilds extendiéndose abajo. Mood: comercio honesto, refugio flotante, ajetreo controlado.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No smooth airbrushed digital gradient shading. No clean vector-style linework. No glossy modern video-game splash art finish. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada.** Resuelve el problema que hundió v1 (caption quemado) — cero texto en la imagen. Plataformas flotantes con puentes de cadena, velas ochre-rust, luces Aether teal filtrando entre mástiles, mercado con mercaderes visibles, atmósfera crepuscular. Coincide con el brief punto por punto.

### 11.2 — The Wanderer's Goggles (item — prop narrativo) — RATIFICADO ✅

**Archivo destino:** `props/wanderer-goggles-v1.png`

**Especificación:** Props reference sheet de unos goggles/lentes viejos de latón, guardados 40+ años en el cajón de Tobin Hale. Lentes ambar-doradas ligeramente empañadas de edad. Correa de cuero desgastada, con marcas de pliegue. Instrumento sin adornos — se ven exactamente como lo que son, herramienta útil, no artefacto ceremonial. Composición: vista frontal, vista lateral, detalle cerrado de la correa y el mecanismo de ajuste en los flancos. Sin brillo dramático. Sin aura mágica visible. Latón oxidado visible en los bordes. Textura de cuero deteriorado pero íntegro. Background blanco/papel cálido. Mood: humildad, funcionamiento, 40 años de espera en silencio.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No glossy magical aura. No dramatic lighting or shadow. No ornamental jewelry styling. No smooth polished metal look. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada. Es el primer item con brief propio y salió excelente en el primer intento.** Latón viejo con pátina verde de oxidación, lentes ambar-doradas, correa de cuero desgastada y agrietada — exactamente el instrumento humilde y funcional que pedía el brief. Reference sheet con 4 vistas, sin brillo mágico, sin ornamentos. Inaugura la carpeta `90-Raw/concept/props/` con buen precedente de calidad.

### 11.3 — Sunken Archive (interior) — v1, SUPERADO

**Archivo destino:** `sunken-archive-interior-v1.png`

**Especificación:** Bóveda subterránea Warden — geometría imposible, ángulos que desafían perspectiva. Cristal dormido embebido en las paredes emitiendo luz azul pálido. Corredor central que desciende suavemente hacia un pedestal al fondo. El Fragmento reposando en el pedestal como objeto de reverencia silenciosa. Flanqueando todo el corredor: cadáveres calcificados dispuestos en formación ritual — cuerpos apilados con precisión ceremonial en los nichos de las paredes, no mezclados, no hecatombe. Mismos símbolos geométricos de la piel de Speck tallados sutilmente en los cuerpos (marcas Warden). Escala interior masiva pero íntima — el Bound Five cabría holgadamente, pero se sentirían pequeños. Iluminación: cristal azul dormido únicamente, sin fuente cálida. Silencio implícito, reverberación pesada. Composición: perspectiva desde la entrada mirando hacia el pedestal y el Fragmento, cadáveres calcificados en profundidad suave, sin gore, no aterradora — ceremoniosa. Mood: reverencia con peso, descubrimiento silencioso, tumba antigua ratificada.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No bright saturation. No neon glow. No zombie/necromancy aesthetic. No gore or visceral detail. No ominous shadow play. No glossy polish. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA v1 (2026-07-27):** 🔴 rechazada. Se leyó como catacumba egipcia con momias vendadas en repisas apiladas — rompe la identidad Warden de los cuerpos (deberían ser reconocibles como los mismos God-Cores que despiertan en el cráter, no una necrópolis genérica). Geometría gótica regular sin la sensación de "ángulos que no cierran". Fragmento perdido al fondo, sin ser foco dominante.

### 11.3-v2 — Sunken Archive (interior) — REVISADO, RATIFICADO ✅

**Archivo destino:** `sunken-archive-interior-v2.png`

**Especificación:** Bóveda subterránea Warden. Corredor central largo con perspectiva profunda hacia un pedestal al fondo que sostiene **el Fragmento — foco emisivo dominante, luz azul-jade fría que jala el ojo por todo el recorrido**. Geometría de la bóveda deliberadamente imposible: arcos angulares que no cierran perfecto, ángulos ligeramente desalineados, sensación de arquitectura hecha por una civilización que no razonaba con nuestra geometría.

Los flancos del corredor NO son repisas apiladas. Son **cuerpos calcificados fundidos a la piedra viva de las paredes**, en formación ritual vertical (como si hubieran sido enterrados de pie, brazos cruzados, integrados a la roca). De cada cuerpo emerge **cristal prismático azul-jade** — piel-vuelta-mineral, mismo patrón geométrico que se ve en el pelaje de Speck (canon Speck §Capa 2). Esto los identifica visualmente como God-Cores en estado dormido: los mismos cadáveres que despiertan en el cráter del Acto 3 sub-beat 5.

Las paredes tienen inscripciones marginales apenas visibles al ojo desnudo — patrones sutiles que se pierden en la textura de la piedra, pistas de una capa oculta que los Wanderer's Goggles revelarán (canon: proyecciones Warden residuales solo visibles con Goggles).

Iluminación: cristales embebidos en la bóveda (azul pálido dormido) + resplandor jade emisivo del Fragmento al fondo. No hay fuente cálida. Composición: vista desde la entrada del corredor mirando hacia el pedestal, cuerpos-cristal verticales alineados a los flancos, silencio con reverberación implícita.

**Negativos:** No mummies. No wrapped bodies. No egyptian catacomb aesthetic. No shelved rows of corpses. No gothic cathedral arches with perfect symmetry. No administrative/library layout. No warm lighting. No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA v2 (2026-07-27):** ✅ **Ratificada.** Resuelve el problema dramático central — los cuerpos-cristal con brazos cruzados fundidos a la piedra se leen inequívocamente como Wardens/God-Cores dormidos, no como momias. Fragmento como foco emisivo dominante funciona perfecto, jala el ojo por todo el corredor. Sin momias, sin catacumba egipcia, sin repisas administrativas — todo resuelto.

🟡 **Nota menor no bloqueante:** la geometría "imposible" no se cumplió del todo — la bóveda salió como nave gótica catedralicia perfectamente simétrica (crucería, arcos apuntados regulares, columnas idénticas), en vez de "ángulos que no cierran". Es hermoso pero se lee como arquitectura humana medieval, no alienígena. No traiciona el canon dramático (la identidad Warden de los cuerpos, que era el hallazgo crítico, sí quedó resuelta), así que no bloquea la ratificación — mismo nivel de nota que Threnn en el elenco político. **Si se re-corre en el futuro:** forzar más asimetría (arcos desalineados, apoyos irregulares) para reforzar la sensación de geometría alienígena.

### 11.4 — The First Wound (clímax jugable, diferente del keyframe §6c nocturno) — RATIFICADO ✅

**Archivo destino:** `first-wound-climax-v1.png`

**Especificación:** Cráter masivo al extremo **sur** de The Wilds. **Sol poniéndose** — contraste deliberado con §6c nocturno (God-Core Night es vigilia dormida, esto es vigilia despierta). Cielo naranja-rosado en gradiente teal. Dos anillos de God-Cores calcificados en formación circular alrededor del cráter — el anillo interior más compacto, el exterior más disperso. El core central en el fondo (piso del cráter) — **el más grande, pulsando en frecuencia jade vivo**, respondiendo a Speck que está por llegar. Otros cores despertando alrededor en baja intensidad, cada uno con pulso propio, frecuencias ligeramente distintas (visualizar como variantes de verde-jade). Cracked stone ground radiando desde el centro en grietas nuevas. Borde del cráter visible como línea literal en foreground (moral boundary). Foreground: small silhouette del Bound Five en el borde opuesto del cráter para escala — apenas visibles. Composición: vista elevada ligeramente desde el borde, mirando hacia abajo y adentro del cráter, core central pequeño pero claro en la profundidad. Mood: umbral, decisión inminente, escala cósmica desperta.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No neon glow. No excessive brightness. No chaotic energy visual. No humanoid figures at scale. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada.** Cráter con core central pulsando jade rodeado de cores menores despertando, grietas irradiando del centro, cielo naranja-rosado en ocaso, 5 siluetas del grupo en el borde para escala. Composición fuerte, mood de umbral y decisión logrado. 🟡 Nota menor no bloqueante: a esta distancia los cores se leen más como cristales/orbes que como cuerpos reconocibles — coherente con la vista aérea amplia pedida, no traiciona el canon.

### 11.5 — Grove of Cycles (interior del templo) — RATIFICADO ✅

**Archivo destino:** `grove-of-cycles-interior-v1.png`

**Especificación:** Interior del templo élfico donde The Elder Circle se reúne en debate. Árboles vivos creciendo en formación arquitectónica — troncos que se alzan como columnas, ramas que se entrelazan formando bóveda natural. Hojas visiblemente en movimiento suave, escritura sutil en la textura de las hojas (Warden script antigua, escribiéndose y borrándose en tiempo real — demasiado pequeño para leer, pero claro que *algo* está escribiendo). Silencio profundo, sin aves, sin viento: composición espaciosa. Aether verde-teal suave fluyendo entre el follaje sin corrupción — contraste absoluto con clima político del Acto 2. Cuatro figuras élficas ancianas apenas sugeridas en la profundidad (Elder Circle) — siluetas tranquilas, no dinámicas. Piso de raíces entrelazadas, musgo tenue, naturaleza cultivada no silvestre. Iluminación: luz filtrando verde-dorada a través del dosel superior, sin sombras duras. Composición: vista desde el borde sur (entrada) mirando hacia la profundidad de la bóveda natural, Elder Circle en la lejanía suave. Mood: pausado, ceremonial, fuera del tiempo.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No harsh shadows. No bustling activity. No visible readable text on leaves. No glossy modern forest. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada, sin re-corrida.** Resultado mejor que lo esperado: túnel-catedral de árboles vivos entrelazados que se sostiene solo, sin arquitectura construida visible — más fiel al espíritu canónico ("sigue siendo el templo que fue durante milenios") que una lectura literal de "salón con columnas". Silencio, raíces entrelazadas y mood ceremonial-atemporal logrados con precisión. Las 4 figuras del Elder Circle confirmadas presentes en la profundidad (conteo inicial erróneo corregido tras revisión).

🟡 **Notas menores no bloqueantes:** (1) el Aether verde-teal se lee como un wisp/cinta localizado y protagónico en vez de fluir difuso por el follaje — desviación de tono, no de canon. (2) La luz salió más oliva/crema desaturada que "dorada" — dentro del rango de la paleta watercolor ya establecida. (3) Hay marcas pequeñas en las ramas superiores que podrían ser el "Warden script escribiéndose" pedido en el brief, o un residuo del glitch de texto de NB2 — ambiguo a esta resolución. Boris decidió no re-correr; si en producción se necesita mirar de cerca, resolver puntualmente entonces.

### 11.6 — Interior de la oficina de Tobin (The Driftmarket) — RATIFICADO ✅

**Archivo destino:** `tobin-office-interior-v1.png`

**Especificación:** Oficina trasera del muelle en The Driftmarket. Rústica, honesta, sin ostentación — espacio de trabajo, no de lujo. Escritorio de madera trabajada (no pulida, con historia visible) con papeles, manifiestos de carga, tintero de cerámica, pluma desgastada. Cajón entreabierto en el escritorio (donde vivieron 40+ años los Wanderer's Goggles — apenas sugerido, no explícito). Puerta cerrada al fondo del escritorio (foreground o middle-ground). Ventana pequeña en la pared izquierda dando al muelle exterior, luz cálida oro-ambar entrando (atardecer). Pared con mapas viejos del Driftmarket clavados sin ornamentación. Sillón simple de madera para visitas (deben caber 2 personas cómodamente — Tobin y el jugador). Sin elementos aetherpunk visibles — Tobin no negocia con Aether. Cesto de papeles usado. Vaso de metal con residuo. Composición: vista desde detrás del escritorio hacia la puerta cerrada, ventana iluminando suavemente. Mood: refugio honesto, lugar de decisión privada, 40+ años de custodio callado.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No magical Aether ornamentation. No ostentatious wealth. No pristine modern office. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada.** Escritorio rústico con papeles, pluma, mapas del Driftmarket clavados en la pared, ventana con luz cálida de atardecer, banca de visitas, puerta cerrada, cajón entreabierto con las siluetas de los Goggles. Nota de proceso: el mapa en la pared tiene texto legible ("Driftmarket"), pero es contenido diegético de un objeto in-world (un mapa colgado), no un caption/label inyectado por NB2 sobre la imagen — distinto del glitch que rompió Ilyara/Kadrun/Driftmarket v1. La regla anti-texto aplica a artefactos de generación, no a texto narrativamente justificado dentro de la escena.

### 11.7a — Aethelgard Watch (torre de guardia humana) — RATIFICADO ✅

**Archivo destino:** `aethelgard-watch-v1.png`

**Especificación:** Torre de guardia humana en la frontera oeste de The Wilds, junto a River Road (entrada desde Rivermeet). Arquitectura humana medieval: piedra local cortada sin pulido, marcos de madera trabajada, techos inclinados de tejas. Banderas del Triune Council colgando desteñidas (material degradado por viento). Silueta funcional, no ornamental — 2-3 pisos de altura, compacta. Braseros encendidos en la cima, humo visible contra el cielo. Guardias humanos visibles patrullando (2-3 siluetas a escala), normales en proporción humana 7.5 cabezas. Puertas de madera reforzada, rastrillo de hierro. Ambientes cálido-atardecer, tonos ochre, marrón, herrumbre. Contraste suave con la naturaleza salvaje de The Wilds. Composición: vista externa desde la senda que llega desde Rivermeet, torre al centro-derecha medio-plano, río visible borroso al fondo. Mood: vigilancia funcional, guardia cansada, deber mecánico.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No fantastical architecture. No elaborate heraldry. No unrealistic proportions. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada.** Piedra y madera, banderas desteñidas, braseros con humo visible, guardias humanos en la cima, río visible hacia Rivermeet al fondo, tono ochre-atardecer. Sin texto, sin problemas de estilo.

### 11.7b — Ignis Reach Watch (torre de guardia enana) — RATIFICADO ✅

**Archivo destino:** `ignis-reach-watch-v1.png`

**Especificación:** Torre de guardia enana en la frontera este de The Wilds, junto a Cinder Ascent (entrada desde Emberdeep). Arquitectura enana: excavada parcialmente *en* la piedra volcánica roja-negra, muros de roca integrada. Geometría angular dominante — no curvas. Símbolos rúnicos del Great Forging Clan tallados profundamente en la fachada (3-4 rúnicos destacados, claramente legibles). Chimeneas y respiraderos activos mostrando humo caliente ascendente. Escala compacta y densa — más ancha que alta, construida para durar siglos. Braseros de forja permanentemente encendidos (visible el brillo naranja débil en las ventanas). Guardias enanos (2-3 siluetas, proporción canónica 4.5 cabezas, pequeños pero robustos). Ambiente rojizo-cálido, vapor sutil, olor implícito de metal y fuego. Composición: vista externa desde el paso montañoso, torre semi-integrada al muro rocoso, geometría angular de la roca continuando la geometría de la torre. Mood: forja permanente, vigilancia técnica, solidez enana ratificada.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No tall or slender proportions. No fantasy-standard tower. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada.** Excavada en roca volcánica, geometría angular, chimeneas con humo caliente, guardias enanos de proporción correcta (silueta ancha y compacta). Los símbolos rúnicos en la fachada son runas decorativas del Great Forging Clan, no texto legible en alfabeto latino — no violan la regla anti-texto.

### 11.7c — Stillwood Watch (torre de guardia élfica) — RATIFICADO ✅

**Archivo destino:** `stillwood-watch-v1.png`

**Especificación:** Torre de guardia élfica en la frontera norte de The Wilds, junto a The Ascending Falls (entrada desde Gloomvault). Arquitectura élfica: integrada orgánicamente a árboles colosales, plataformas de madera curvada que crecen de los troncos (no carpintería apilada, sino crecimiento cultivado). Luces Aether teal en balcones y barandillas. Silueta esbelta y vertical exagerada — mucho más alta que las otras dos torres, ascendiendo entre el dosel. Madera teñida naturalmente, sin pintura. Guardias élficos (2-3 siluetas, proporción canónica 8 cabezas, uno posiblemente en vuelo controlado o ascenso por cuerda). Ambiente crepuscular verde-teal, neblina de cascada permanente en background. Agua cayendo visible en profundidad. Vegetación densa en flancos, helechos gigantes, musgo. Silencio implícito. Composición: vista externa desde abajo mirando hacia arriba, torre ascendiendo entre árboles, cascadas de The Ascending Falls visibles de fondo borroso. Mood: observación silenciosa, vigilancia éterea, discreción élfica.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No human proportions. No stone castle tower aesthetic. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada.** La más fuerte de las 3 torres — integrada orgánicamente al árbol, plataformas curvadas verticales, luces Aether teal en balcones, silueta esbelta y mucho más alta que las otras dos (como pedía el brief), cascadas al fondo, guardia élfico en descenso controlado con cuerda.

### 11.8 — Rivermeet Triune Council Seat (interior de sala de sesión) — RATIFICADO ✅

**Archivo destino:** `rivermeet-council-chamber-v1.png`

**Especificación:** Interior de la sala donde el Triune Council sesiona formalmente en Rivermeet. Tres asientos en semicírculo (abierto hacia la sala) — cada asiento reflejando sutilmente la arquitectura de su raza sin dominancia de ninguno. Asiento humano: madera río-teñida con cojines. Asiento enano: piedra angular con plata incrustada. Asiento élfico: madera curvada con teal Aether grabado sutilmente. Techo alto con vitrales austeros (no pictóricos, geométricos — símbolos de las 3 razas sin jerarquía). Columnas de piedra clara pulida. Piso de mármol blanco-gris en patrón de 3 sectores. Sin público — sesión privada. Luz entra de arriba (vitrales), suave, monumental. Contraste absoluto con el resto de Rivermeet (comercial, cálido, ribereño) — esta sala es institucional, ceremonial, más fría. Sin elementos aetherpunk exagerados — el poder aquí es administrativo y política, no arcano. Frisos discretos en las paredes (historiografía de los 3 reinos, demasiado pequeño para leer). Composición: vista desde la entrada central mirando hacia los 3 asientos vacíos en semicírculo, iluminación desde arriba. Mood: institucionalidad, peso histórico, ausencia de presencia.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No ornate gold decoration. No throne-room grandeur. No crowded gathering. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada.** 3 asientos con diseño distinto por raza (madera rústica humana, metal geométrico enano, curva orgánica élfica) en semicírculo, mármol claro, vitrales austeros, frisos de piedra con las 3 razas al fondo. Fría e institucional, contrasta bien con el resto de Rivermeet. Sin texto.

### 11.9 — Interior Emberdeep detallado (complemento a §6d) — RATIFICADO ✅

**Archivo destino:** `emberdeep-interior-vertical-v1.png`

**Especificación:** Interior de Emberdeep visto en corte vertical, complementando el keyframe de forjas ya aprobado. Múltiples niveles conectados por escaleras talladas en piedra y ascensores de piedra (plataformas que descienden). Forjas activas visibles en al menos 2-3 niveles (luz naranja-cálido radiando). Luz de forja (naranja intenso) mezclada con luz Aether azul-fría en los niveles superiores. Geometría angular enana dominando toda la arquitectura — columnas talladas angularmente, arcos que no son suaves. Símbolos del Great Forging Clan tallados profundamente en columnas (repetidos, claros). Caverna se pierde en profundidad descendente y arriba. Escala interior masiva — el ojo pierde la geometría a cierta profundidad. Guardias y artesanos enanos apenas visibles en varios niveles (proporción canónica 4.5 cabezas). Vapor de forja ascendiendo desde niveles inferiores. Composición: vista desde un balcón superior mirando hacia abajo hacia la profundidad de la caverna, múltiples niveles visible en perspectiva, infinidad abajo. Mood: industria perpetua, solidez monumental, corazón de civilización enana ratificada.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No unrealistic scale. No overly mystical Aether overload. No clean modern industrial look. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada.** Múltiples niveles conectados por puentes de piedra, forjas activas en al menos 2 niveles, mezcla de luz cálida de forja con Aether azul filtrando desde arriba, símbolos de yunque/engranaje del Great Forging Clan tallados en columnas (decorativos, no texto), escala masiva con figuras enanas diminutas para dar profundidad. Complementa muy bien al keyframe de forjas ya ratificado en §6d.

### 11.10 — The Ascending Falls (Gloomvault → Stillspire) — RATIFICADO ✅

**Archivo destino:** `ascending-falls-v1.png`

**Especificación:** Cadena de cascadas escalonadas que sube desde Gloomvault hasta la base de The Stillspire. Terrazas naturales de piedra cubiertas de musgo suave verde. Agua clara descendiendo en múltiples niveles (al menos 3-4 cascadas escalonadas hacia arriba). Puentes de raíz/madera curvada cruzando cada caída, gris-café desteñidos por agua perpetua. Luz Aether teal reflejada en el agua, suave no dramática. Vegetación densa en flancos — árboles élficos colosales, helechos gigantes, flores silvestres teal-pálidas. Referencia visual: Rivendell/Imladris — arquitectura élfica tallada en y alrededor del agua, integrada orgánica. Neblina permanente de cascada (fino spray, no opaco). Ambiente crepuscular con dosel arriba filtrando luz verde-dorada. The Stillspire apenas sugerido en la lejanía superior (escala épica). Sonido implícito: agua constante, viento suave. Composición: vista desde la base (lado de Gloomvault) mirando hacia arriba a lo largo de la cadena, cascadas ascendiendo, Stillspire perdido en la lejanía brumosa superior. Mood: ascenso de peregrinaje, belleza élfica, transición líquida.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No mystical crystal formations. No artificial carved stone visible. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada.** Tríptico narrativo mostrando el ascenso completo: panel 1 Gloomvault (luz cálida), panel 3 base de The Stillspire visible en la lejanía brumosa. Terrazas de piedra musgosa, puentes cruzando cada caída, luz teal reflejada en el agua. 🟡 Nota menor no bloqueante: los puentes se ven más de piedra/madera tallada que "de raíz" como pedía el brief — no afecta la lectura general.

### 11.11 — Iven's Settlement (asentamiento moribundo) — RATIFICADO ✅

**Archivo destino:** `ivens-settlement-v1.png`

**Especificación:** Asentamiento fronterizo humano muriendo lentamente por corrupción de Aether. Casas rústicas de granja (piedra y madera, techos de paja parcialmente restaurados), algunas ya abandonadas, puertas cerradas. Campos que ya no producen (tierra grisácea, cultivos marchitos en estado liminal — ni vivos ni completamente muertos). Pastura en declive. Silueta triste al atardecer. Chimenea de la casa principal (donde vive Iven) apenas humeando (fuego bajo, sin vitalidad). Población invisible — nadie caminando. Un par de figuras sentadas en umbrales (agotamiento visual, no acción). Monumento o piedra de memoria cerca de la aldea. Tono agrícola/humano rústico, cálido pero extinguiéndose. Contraste visual con Rivermeet (próspera): Iven's Settlement se ve ~5-10 años atrás en el tiempo por deterioro lento. Aether corrupto *muy* sutil en el aire como bruma malva-grisácea fina, apenas perceptible. Composición: vista panorámica desde una colina cercana, asentamiento en el valle, sol poniéndose atrás. Mood: silencio, pérdida gradual, dignidad en declive, amor a lo que se desmorona.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No post-apocalyptic ruin. No dramatic decay. No corpses or gore. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada.** Panorámica desde la colina exactamente como pedía el brief: casas de granja en distintos grados de deterioro, campos grisáceos sin producir, figura sentada en un umbral (agotamiento), única chimenea humeando (la casa de Iven), sol poniéndose. Mood de pérdida gradual y dignidad en el declive logrado con precisión.

### 11.12 — Mistbound Frontier complemento (interior de posta defensiva) — RATIFICADO ✅

**Archivo destino:** `mistbound-post-interior-v1.png`

**Especificación:** Interior de una posta defensiva de Mistbound Frontier (tierra interior remota, árida). Complemento al keyframe aprobado de vista externa. Cuarto simple, funcional, austero — sin ostentación. Mesa larga con mapas de patrulla (tinta desteñida, rutas marcadas a mano). Armas colgadas en rack de hierro (espadas, lanzas, escudos — equipo bien mantenido pero usado). Catre simple con manta gris-marrón. Brasero central con hierro de cocina, humo saliendo limpio por chimenea rústica. Ventana pequeña con contraventana de madera (no vidrio). Aire seco, olor de metal y humo contenido. 2-3 guardias humanos en descanso o revisando mapas (proporción 7.5 cabezas, uno de ellos posiblemente Roen joven — nota de color, no obligatorio, apenas sugerido). Arquitectura de piedra local sin pulir, vigas de madera. Luz de brasero (naranja débil). Composición: interior desde la puerta, mesa central con mapas prominentes, brasero al fondo, guardias en pose de descanso o trabajo. Mood: puesto de vigilancia funcional, 15 años de Roen en este tipo de espacios, sin gloria, servicio mecánico.

**Negativos:** No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No romantic soldier aesthetic. No ostentatious tapestry. No unrealistic medieval militaria. No text, no labels, no captions, no annotations, no diagram-style callouts.

**QA (2026-07-27):** ✅ **Ratificada.** Mesa con mapa de patrulla, armas colgadas en rack, catre con manta gris, ventana con contraventana, chimenea con humo, 4 guardias humanos (uno leído como posible Roen joven, nota de color válida). Austero y funcional, coherente con el interior aprobado del brief.

## 12 — Key art y mockups de UI (2026-07-28)

Primer batch de material de **marca y producto**, no de mundo. Cuatro briefs: 1 poster + 3 pantallas de UI.

### Regla nueva de texto para mockups de UI

Los mockups de UI necesitan texto, lo que choca con la regla anti-texto estándar (§10). Resolución canónica:

- **El título `AETHER BOUND` va como texto real** — 2 palabras, alto valor de marca, NB2 lo acierta con fiabilidad razonable.
- **Todo lo demás va como placeholder visual**: barras, bloques o líneas donde iría el copy. El mockup comunica **composición, jerarquía y tono**, no el copy final. Esto evita que NB2 invente texto corrupto en 6 opciones de menú y arruine una imagen que por lo demás sirve.
- **Excepción diegética** (canon §11.6, oficina de Tobin): si el texto es contenido de un objeto del mundo dentro de la escena, se permite.

### Filosofía de UI del proyecto (restricción de diseño, no opcional)

Dos reglas ya ratificadas condicionan estos mockups:
- [[Art Bible]]: *"transición diegética al viajar arteria→ciudad, **sin UI**"*
- [[The Bound Five]]: *"autónomos + un botón, **cero menús**"*

**La UI de Aether Bound es mínima, diegética y pintada** — nunca cajas de vidrio, nunca paneles flotantes con bordes duros, nunca iconografía de MMO. Si un elemento puede vivir en el mundo en vez de encima de él, vive en el mundo.

---

### 12.1 — Poster / Key Art (V1)

**Archivo destino:** `marketing/key-art-poster-v1.png` (inaugura `90-Raw/concept/marketing/`)

**Especificación:** Poster vertical del juego. **The Bound Five de espaldas**, en el borde de un promontorio, mirando hacia The Wilds con The First Wound apenas visible en la lejanía como una herida de luz jade en el horizonte. Escala épica de silueta — las cinco figuras son pequeñas contra el paisaje, ocupando el tercio inferior; el mundo ocupa el resto.

**Composición del grupo** (configuración canónica de referencia, [[The Bound Five]] — arco Humano Duelist): el jugador humano al centro, ligeramente adelantado; **Roen** a su izquierda (humano Vanguard, escudo a la espalda, proporción 7.5 cabezas); **Valen** a la derecha (elfo Strategist, esbelto, 8 cabezas); **Dagna** al extremo izquierdo (enana Vanguard, trapezoide compacto, 4.5 cabezas, escudo pesado); **Darro** al extremo derecho (enano Duelist, más ligero que Dagna, 4.5 cabezas). **Speck** — forma zorro beige — sentada junto al jugador, la única figura que no mira al horizonte: mira hacia el espectador.

Cielo de atardecer en gradiente naranja-rosado hacia teal en lo alto. Perspectiva aérea marcada: el fondo se lava en azul pastel plano (regla de Art Bible). Grano de papel visible en toda la composición. Tinta negra nítida en las siluetas del grupo, agrisándose con la distancia hasta desaparecer en el horizonte.

**Espacio compositivo reservado** para el logo en el tercio superior — zona de cielo limpio, sin elementos que compitan. El logo NO se genera aquí (se compone después).

Mood: melancolía gráfica, umbral, cinco personas antes de la decisión que las va a separar. Silencio.

**Negativos:** No text, no title, no logo, no labels, no captions. No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No heroic action poses. No characters facing the camera. No weapons drawn. No dramatic lens flare. No modern movie-poster collage layout.

---

### 12.2 — Poster / Key Art (V2)

**Archivo destino:** `marketing_key-art-poster-v2.png`

**Especificación:** Poster vertical. **The Bound Five de pie en la cima de The Monolith** — la piedra vertical masiva de 100+ metros en el centro exacto de The Wilds, el punto más alto del mapa. Vista panorámica de 300° abriéndose ante ellos: el peak del Monolith como plataforma rocosa natural, con el mundo entero extendiéndose abajo y alrededor.

**Zona cercana (Centro/Centro-Sur, apenas visible en la base del encuadre, aún dentro de la niebla):** siluetas apenas sugeridas de The Aether Well (un geiser tenue de luz), ruinas Warden dispersas en el terreno inmediato bajo el Monolith, tratadas como manchas de tinta lejanas, no detalladas, casi perdidas en la bruma.

**Horizonte, tres franjas separadas por la curvatura del panorama:**

- **Izquierda (oeste y suroeste (extremo del poster)):** River Road serpenteando rodeada de árboles y flora (primordialmente boscoso) como una cinta plateada hacia una silueta lejana de **Rivermeet/Aethelgard** — perfil de puentes y tejados apenas legible contra el cielo.
- **Izquierda (noroeste):** espacio negativo, elevación que empieza a subir, totalmente boscoso.
- **Centro-fondo (norte):** el dosel oscuro de **Gloomvault** cerrándose hacia arriba (cerro/montaña), y sobre él, en la bruma más alta, la silueta vertical de **The Stillspire** asomando entre los árboles.
- **Derecha (este y suroeste (extremo del poster)):** el paso de **Cinder Ascent**, primero totalmente boscoso y mientras más se acerca al este, convirtiéndose en árido, totalmente subiendo hacia terreno volcánico rojizo, con el resplandor tenue de **Ignis Reach/Emberdeep** como una luz cálida bajo la montaña.

**Sur — deliberadamente ausente.** The First Wound no se muestra: el grupo está de espaldas a esa dirección, o el propio cuerpo del Monolith bloquea la vista hacia el sur. Ningún indicio de cráter ni luz jade en el horizonte — se guarda para más adelante.

**El grupo:** los 5 en el borde de la cima rocosa, de espaldas al espectador, mirando hacia el panorama de los tres reinos: dos elfos (8 cabezas de alto, Una línea continua: vertical, sin interrupciones), dos humanos (7.5 cabezas de alto, apariencia neutral, atléticos) y un enano (4.5 cabezas de alto, trapecio, sin cuello). **El espacio donde antes estaba Speck queda vacío** — un hueco de composición entre las figuras que un ojo atento nota, sin que se explique.

Cielo amplio ocupando más de la mitad del encuadre — gradiente de teal en lo alto a naranja-rosado en el horizonte, con las tres franjas de reino bajo la línea de niebla que se difumina a partir del naranja-rosado. Perspectiva aérea marcada (Art Bible): cada franja de horizonte más pálida y azulada que la anterior. Grano de papel visible. Tinta negra nítida en el grupo y la roca del Monolith, agrisándose con la distancia.

**Espacio compositivo reservado para el logo** en el tercio superior del cielo — zona limpia sin elementos que compitan.

Mood: cinco personas en el techo del mundo, viendo todo lo que está en juego a la vez — y todavía sin saber hacia dónde va a terminar la historia.

**Negativos:** No Speck, no fox silhouette. No text, no title, no logo, no labels, no captions. No visible crater or jade light on the horizon (no First Wound). No readable city detail — silhouettes only. No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No heroic action poses. No characters facing the camera. No weapons drawn. No dramatic lens flare. No modern movie-poster collage layout.

---

---

### 12.3 — Menú principal (title screen)

**Archivo destino:** `ui_main-menu-mockup-v1.png` (inaugura `90-Raw/concept/ui/`)

**Especificación:** Mockup de pantalla de título, formato 16:9 horizontal. Fondo: keyframe pictórico a pantalla completa — una vista de The Wilds al amanecer con niebla baja, tratada como pintura de acuarela, ligeramente desaturada para no competir con la UI. Composición del fondo pensada para dejar el tercio izquierdo relativamente vacío.

**Título `AETHER BOUND`** en el tercio superior izquierdo: tipografía serif con carácter de tinta dibujada a mano — no pulida, con irregularidad de trazo visible. Color tinta oscura, no dorado ni metálico. Escala grande pero contenida.

**Opciones de menú** debajo del título, en columna vertical alineada a la izquierda: **cinco líneas horizontales de placeholder** (barras suaves de tinta, sin letras), la primera ligeramente más marcada para indicar selección activa. Sin cajas, sin botones, sin bordes, sin fondos translúcidos — el texto flota directamente sobre la pintura, como anotación en un cuaderno.

Elemento diegético opcional: una pequeña silueta de Speck (forma zorro) sentada en el borde inferior del encuadre, mirando hacia el título. Casi imperceptible.

Mood: quietud antes del viaje. Una pintura que espera.

**Negativos:** No UI panels. No glass or translucent boxes. No borders or frames around menu items. No modern game UI iconography. No drop shadows on text. No gradient buttons. No hover glow effects. No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow. No readable menu option text — placeholder bars only.

---

### 12.4 — Creación de personaje (Matriz Raza × Rol)

**Archivo destino:** `ui_character-creation-mockup-v1.png`

**Especificación:** Mockup de la pantalla de creación, formato 16:9. Estructura: **grilla de 3×3** — tres razas en filas, tres roles en columnas ([[Matriz Raza x Rol]]).

**Eje de razas** (filas, ilustradas con siluetas de cuerpo entero a la izquierda de cada fila): **the Aether-Born** (elfo, 8 cabezas, esbelto, marcas de aether tenues), **the Iron-Blooded** (enano, 4.5 cabezas, trapezoide, ancho), **the Restless** (humano, 7.5 cabezas, atlético). Las tres siluetas en la misma pose neutra para que la comparación de proporción sea legible — es una lámina de elección, no de acción.

**Eje de roles** (columnas, indicadas con iconos pintados a mano, no vectoriales): Vanguard (una forma de escudo), Duelist (una hoja curva), Strategist (una forma geométrica angular). Iconos de tinta sobre papel, con irregularidad de trazo.

**Celda seleccionada:** una de las nueve intersecciones marcada con un resaltado suave de acuarela (mancha de color lavada, no un borde ni un glow). Sin cajas alrededor de las celdas — la grilla se sugiere con líneas de tinta finas e imperfectas, como cuadrícula dibujada a mano.

**Zona derecha:** espacio reservado para el retrato del personaje resultante, ocupado en el mockup por una silueta de cuerpo entero en la raza/rol seleccionada, sobre fondo de papel limpio.

**Placeholders de texto:** barras de tinta donde irían los nombres de raza, rol y descripción. Sin letras legibles salvo el título de pantalla, que también va como barra.

Mood: elección con peso. La pantalla no debe sentirse como un configurador — debe sentirse como abrir un libro y elegir de quién va a ser esta historia.

**Negativos:** No text labels on races or roles — placeholder bars only. No UI panels or cards. No glass or translucent boxes. No vector-style icons. No modern character-creator sliders. No stat bars or numeric displays. No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow.

---

### 12.5 — Pantalla de Tether (vínculos)

**Archivo destino:** `ui_tether-screen-mockup-v1.png`

**Especificación:** Mockup de la pantalla de vínculos ([[The Tether]]), formato 16:9. **Es la UI más narrativa del juego** — muestra la profundidad de relación con cada compañero, y esa profundidad *es* el árbol de habilidades.

Estructura: **cinco retratos en semicírculo** — los 4 compañeros (Roen, Valen, el Pivote, Darro) más Speck en el centro, ligeramente adelantada y más pequeña. Retratos pintados en acuarela, busto, con el fondo de cada uno desvaneciéndose en papel.

**Indicador de tier** bajo cada retrato: tres marcas de tinta horizontales (T1/T2/T3), llenas o vacías según el nivel del vínculo. Marcas dibujadas a mano, no barras de progreso rectangulares. Un compañero con dos marcas llenas, otro con tres, otro con una — para que la lectura de estados distintos sea evidente.

**Líneas de conexión** desde el centro (donde está Speck en forma de zorro rojo/naranja) hacia cada retrato: trazos de tinta suaves, de grosor variable según la fuerza del vínculo. Algunas líneas más marcadas, otra apenas visible. **Una de las líneas está rota o interrumpida a la mitad** — sugiere el Bond vacío sin explicarlo.

**Zona inferior:** franja horizontal con **siete pequeños espacios de marca** para los Momentos de Persona de Speck, la mayoría vacíos, dos o tres llenos con un símbolo de tinta simple. Sin explicación, sin números.

Fondo: papel cálido con grano visible, sin ilustración compitiendo.

**Placeholders de texto:** barras de tinta donde irían los nombres de compañeros. Sin letras legibles.

Mood: íntimo, como una página de diario donde alguien lleva cuenta de a quién ha dejado entrar. No es una pantalla de estadísticas.

**Negativos:** No text names — placeholder bars only. No rectangular progress bars. No percentage or numeric displays. No UI panels, cards or glass boxes. No skill-tree node graphics. No RPG stat sheet layout. No photorealism or PBR rendering. No anime cel shading. No Genshin Impact candy saturation. No neon glow.

---

## Notas de uso

- Pedir siempre "concept sheet, front view and side view" — la silueta debe
  ser comparable entre razas.
- 3–4 variantes por brief; evaluar contra los 5 ejes de la [[Art Bible]].
- El negativo *no beast-folk features* del humano es crítico (el modelo
  tiende a bestializar "Mistbound") — decisión ratificada en
  [[Fenotipos y Creación de Personaje]].
- Mismo pipeline servirá para los 3 keyframes de B11 (Wilds amanecer /
  Rivermeet / God-Core de noche) y para [[Speck]] (B9).
