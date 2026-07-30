# AUDITORÍA DIRIGIDA — TRONCO SUPERIOR (hombros) · estado r2d · 2026-07-13

> **Fuente RAW, depositada verbatim (2026-07-13).** Auditor: subagente Fable
> imparcial (el mismo perfil de la auditoría general
> [[QA-Auditoria-Output-vs-RAW-2026-07-12]]), solo lectura. Encargo del
> director tras dos rondas de fixes de hombro que "no terminaban de
> convencer". No se edita.

**Fuentes:** lámina `Aether Bound/90-Raw/concept/fenotipo-humano-v1.png`
(frente/espalda/perfil, crops ampliados ×3) vs capturas
`godot/test_out/anatomy_close.png`, `anatomy_full_front.png`,
`anatomy_full_side.png`, `anatomy_face_back.png` (crops ×2–×6 con retícula de
medición) · código `godot/character/character_rig.gd` (PROPORTIONS L25-36,
torso/trapecios L369-405, brazos L422-493).

---

## 1. Diagnóstico principal: por qué los hombros no convencen

Las dos rondas de fixes atacaron la **forma del deltoide** (globo→gota→
aplastado). El deltoide ya no es el problema. El problema es **dónde está
montado el conjunto entero**: el pivote del brazo está demasiado AFUERA y
demasiado ARRIBA, y ninguna escultura del deltoide puede arreglar eso.
Desglose:

### (a) Anchura total — **CRITICAL** · el defecto dominante
El código pone el pivote del brazo en `SHOULDER_X = 0.262` y el deltoide se
sesga afuera (+0.010) con radio efectivo ~0.063 → borde exterior a ±0.335,
**span total ≈ 0.67 m** en un personaje de 1.92 m (medido en captura:
0.67–0.69 m, coincide). La lámina mide **~2.05 alturas de cabeza de
biacromial ≈ 0.52 m**. El render está **~30% más ancho que el concept**. El
comentario del código dice "review +12%" sobre SHOULDER_X — esa corrección de
la review v0.1 se pasó de largo y quedó fosilizada. Con esta anchura, aunque
el deltoide sea una gota perfecta, el personaje lee "hombreras de futbol
americano".

### (b) Altura y pendiente — **HIGH**
- **Altura:** en la lámina el tope del deltoide está **~0.8 cabezas debajo de
  la barbilla**. En el render está a **~0.3 cabezas** (código: barbilla 1.67,
  tope del deltoide ≈ 1.60 → 7 cm). El personaje lee *encogido de hombros
  permanente* — la cabeza asienta directo sobre la repisa.
- **Pendiente:** el trapecio existe (bien) pero su caída es **0.27 rad ≈ 15°**
  y corta (caja 0.19 centrada en x=0.10, muere en x≈0.19). La lámina cae
  **~22–25° en línea continua** desde el cuello hasta el brazo.
- **Lo letal:** la silueta del render **baja y vuelve a SUBIR**. El tope del
  deltoide (y≈0.36 local: 0.29−0.006+0.066×1.15) queda a la MISMA altura que
  el arranque del trapecio junto al cuello. Perfil resultante: cuello →
  bajadita → **bump que remonta** = charretera/hombrera. En la lámina la
  línea cuello→trapecio→deltoide→brazo es **monótonamente descendente**: el
  punto más alto del hombro es el trapecio pegado al cuello, y el deltoide
  está SIEMPRE por debajo de esa línea, continuando la caída.

### (c) Forma del deltoide — MEDIUM (ya casi resuelto)
La gota r2/r2d en sí está bien. Lo que queda: sigue leyendo como pieza
*aparte* porque (1) su tope sube sobre la línea del trapecio (ver b), (2) hay
costura de tinta visible contra el pecho porque apenas se tocan — el deltoide
vive entero FUERA del cilindro del pecho (borde interior x≈0.209 vs borde del
pecho x≈0.19: solape de 2 cm en un músculo de 12 cm).

### (d) Transición pecho-hombro-brazo — **HIGH**
Dos cosas:
1. **Luz entre brazo y torso**: con pivote en 0.262 y el cilindro del pecho
   terminando en x≈0.19 (arriba) y estrechando hacia abajo, hay un **hueco de
   axila visible que corre por todo el flanco** — en `anatomy_close.png` se
   ve cielo/fondo entre el brazo y el torso casi hasta la cadera, y los
   brazos además cuelgan abiertos en A con codos afuera (lectura gorila). En
   la lámina el brazo interior ROZA el torso todo el trayecto; el codo cae a
   la altura del cinturón pegado al costado.
2. **El pecho lee como peto, no como anatomía**: en el close-up se ven los
   rectángulos de tinta del `pec_plate` (caja 0.20×0.09) y la `clavicle`
   (caja 0.19×0.028) — escalones rectos con esquinas de 90° que el Sobel
   entinta como costuras de armadura. La lámina funde pectoral→deltoide con
   curvas, cero rectángulos.

### (e) Relación con el cuello — MEDIUM
El cuello v0.4 (−30%) + hombros altos = la cabeza flota a ras de la repisa.
La lámina, aun con el cowl tapando, muestra un trecho barbilla→hombro largo.
**Ojo**: no se puede recuperar la caída de 0.8 cabezas de la lámina solo
bajando hombros sin revisitar el largo del cuello — hay un tope estructural
aquí que conviene decirle a Boris explícitamente.

**Extra (espalda) — MEDIUM:** en `anatomy_face_back.png` el conjunto
trapecios (profundidad 0.115, casi la del pecho) + tapa plana del cilindro
lee como **techo a dos aguas / gancho de ropa gigante**: dos planos rectos
con arista de tinta cruzando toda la espalda alta. En la lámina de espalda
los trapecios son masas redondas PEGADAS al cuello y la espalda alta es
estrecha.

---

## 2. Comparación medible

| Métrica | Lámina (fenotipo-humano-v1) | Render r2d | Delta |
|---|---|---|---|
| Biacromial (borde a borde de deltoides) | ~2.05 alturas de cabeza ≈ **0.52 m** | **0.67–0.69 m** (código: (0.262+0.073)×2) | **+30%** |
| Hombros / anchura de cabeza | ~2.4 | ~3.4–3.6 | +45% |
| Hombros / cintura | ~1.55 | ~2.4 | el "V" está triplicado |
| Caída barbilla → tope de deltoide | ~0.8 cabezas (~0.20 m) | ~0.3 cabezas (~0.07 m) | hombros ~13 cm "encogidos" |
| Pendiente del trapecio | ~22–25°, continua hasta el brazo | 15° (0.27 rad), corta, y la silueta REMONTA en el deltoide | forma invertida |
| Punto más ancho del cuerpo | deltoides, apenas más anchos que la caja torácica | deltoides, mucho más anchos que todo | — |

---

## 3. Veredicto: "ancho atlético" vs "enjuto caído"

**La lámina dice ENJUTO CAÍDO, sin ambigüedad.** Viéndola de verdad: hombros
estrechos (2.05 cabezas — un humano real promedio, ni siquiera
atlético-heroico), pendiente marcada, brazos delgados pegados al cuerpo, y el
"atletismo" está en la **fibra** (antebrazos venosos, cintura estrecha, cero
grasa), no en la masa ni en la anchura. El propio texto de la lámina dice
"narrow sloped shoulder". La review v0.1 que pidió "+10-15% más ancho"
**contradecía la lámina** y es la raíz fósil del problema actual: se aplicó
(+12% está comentado en el código), nunca se revirtió, y las dos rondas
siguientes esculpieron el deltoide encima de un esqueleto mal ancho. La
lámina es el canon: **revertir la anchura gana**.

---

## 4. Recomendación concreta (ronda siguiente)

En orden de impacto — el fix 1 es EL fix:

1. **`SHOULDER_X: 0.262 → 0.20–0.21`** (span exterior ≈ 0.55–0.57 m). Bonus
   automático: el borde interior del deltoide (~x 0.15) queda DENTRO del
   cilindro del pecho (half-width tope ~0.186) → solape real, muere la
   costura de (c); y el brazo interior (r 0.056, borde en ~0.15) cierra el
   hueco de axila de (d). Verificar que el deltoide no se ahogue en el pecho;
   si pasa, bajar el radio superior del torso 0.16→~0.145.
2. **`SHOULDER_Y: 0.29 → ~0.25-0.26`** y garantizar que el **tope del
   deltoide quede DEBAJO de la línea del trapecio**: o bajar el centro del
   deltoide (y −0.006 → ~−0.02) o quitarle estiramiento vertical (escala
   1.15 → ~1.0). Regla de oro verificable en captura: la silueta
   cuello→muñeca no debe subir NUNCA.
3. **Trapecio:** `rotation.z 0.27 → ~0.40 rad` (23°), reposicionado para que
   su punta exterior-inferior ATERRICE sobre el tope del deltoide (una sola
   línea). Profundidad `0.115 → ~0.08` (o cambiar caja por elipsoide
   aplastada) para matar el "techo" de la vista trasera.
4. **`pec_plate` y `clavicle`:** hundirlas ~0.01 más o convertirlas en
   elipsoides aplastadas — que el volumen lo dé el escalón del cel, no el
   rectángulo del Sobel.
5. **Cuelgue del brazo:** con el pivote adentro, revisar la pose neutral para
   que el brazo caiga vertical (hoy abre en A con codo afuera).

## 5. Lo que SÍ está bien — no tocar

- **Fusión de uniones (Fase B):** cero anillos de tinta, cero huecos lego en
  hombro/codo. Sostenido.
- **Muñeca afilada + mano mitón** (r2): coincide con la lámina.
- **Bíceps/tríceps/antebrazo r2d:** el aplastado quedó en el punto — modulan
  la superficie sin globo. Ubicaciones correctas, dejarlas quietas.
- **El taper único del torso + cintura:** la cintura (~0.28 m) está en
  proporción enjuta correcta; el concepto de un solo cono continuo es el
  correcto.
- **La existencia del trapecio y la dirección de la idea** (matar la repisa
  cuadrada): correcta — solo está corto, tendido y ancho de más.
- **7.5 cabezas de proporción global:** verificado contra las marcas de
  altura de la escena, sostiene.

**Resumen de una línea para Boris:** los hombros no convencen porque el
ESQUELETO del hombro está 30% más ancho y ~13 cm más alto que la lámina —
llevamos dos rondas esculpiendo el músculo correcto sobre el pivote
equivocado; mete el pivote (0.262→0.21), bájalo (0.29→0.26), y haz que la
línea cuello→brazo solo descienda.
