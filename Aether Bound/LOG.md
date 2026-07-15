# LOG — bitácora append-only del Vault

## [2026-07-14] fix+qa | Geometría nueva ejecutada (pelo/torso/manos/boca) — 49% → 55%
Ejecución de [[PRD-Geometria-Nueva-Pelo-Torso-Manos-Boca]] tras la
ratificación de Boris. QA de regresión completo
(`test_core`/`test_combat`/`autotest_biomech`/`autotest_slice`/
`autotest_ui`) ALL_PASS en cada punto.
**19. Torso:** `abs_plate` (masa elevada) ELIMINADO — el abdomen vuelve a
ser la superficie desnuda del cilindro. `pec` aplanado (escala Z 0.5→0.32,
X 1.4→1.7) para acercarse a "línea de pectoral" en vez de bulto.
**20. Manos:** gap entre dedos recortado (offsets 0.025/0.010→0.0175/
0.0058); cada dedo pasa de 1 caja + esfera-nudillo a 2 falanges
(proximal+distal) encadenadas por un `Node3D` con rotación propia —
quiebre de ángulo real, no bulto. Pulgar con curl mucho más agresivo
(rotation.x −0.25→−0.55) y nacimiento más cerca del centro.
**21. Pelo — reconstrucción completa de `_hair_frontier_crop`
(`hair_library.gd`):** concha recortada agresivamente (scale.y 0.72→0.50,
centro subido) para exponer nuca/orejas reales; remolino de coronilla
nuevo (3 cajas en abanico); reemplazo de las 31 mechones-caja
casi-fundidas por ~25 mechones-CONO (flequillo 5 + laterales 6 + corona
3, más grandes, protrusión real vía `_cone` con la misma técnica de raíz-
hundida/punta-afuera que la nariz). Mejora MUY visible en banco (nuca/
orejas expuestas confirmado, ver capturas) pero el QA de esta ronda
señala que los mechones todavía no leen como hebras individuales — se
funden en 2-3 lóbulos redondos ("birrete/casco de natación"), objetivo
parcialmente logrado.
**22. Boca — Opción A ejecutada:** de 3 piezas (lip_upper/lip_lower/
mouth_seam) a 1 sola cápsula fusionada + línea de comisura tallada
(descentrada hacia arriba para preservar la asimetría "inferior más
carnoso" sin una segunda masa). `lip_mat_lower` eliminado (quedó sin uso).
**QA visual de esta ronda: 49% → 55%** (+6 — salto real pero menor al
esperado de un cambio de geometría). El propio QA confirma 2 de 4 áreas
resueltas en su objetivo (torso, boca-estructura) y 2 a medias (pelo —
concha sí, mechones no; manos — quiebre sí, proporción no). **Hallazgos
nuevos de esta ronda:** (a) parche/costura visible cuello-hombro (posible
gap de geometría no soldada, no investigado); (b) boca lee como "herida"
por el tono rojo-marrón oscuro, no por la forma; (c) **la silueta general
del torso/hombros ("maniquí de tienda", sin cintura ni trapecio real) es
ahora, según el propio QA, el mayor punto de apalancamiento para la
próxima ronda** — más que cualquier detalle de cara/manos, y está fuera
del alcance de este PRD (toca `SHOULDER_X`/proporciones, un punto que
varios PRDs anteriores vienen dejando como decisión explícita de Boris,
no ejecución automática). Warpaint sigue sin coincidir con la lámina de
CARA (siempre existió esa discrepancia entre las dos láminas — Boris ya
resolvió que no le preocupa, ver ratificación arriba).

## [2026-07-14] ratificación | Boris aprueba geometría nueva; boca=Opción A; warpaint personalizable (Fase 4)
Boris ratificó las 3 direcciones de [[PRD-Geometria-Nueva-Pelo-Torso-Manos-Boca]]
(pelo/torso/manos) sin cambios, eligió **Opción A para la boca** (fusionar
en una sola masa) y resolvió la nota fuera de alcance del warpaint: **no le
preocupa la contradicción entre las dos láminas** — la versión bilateral
actual se queda "mientras quede bien". Decisión de producto nueva: **el
warpaint debe ser personalizable por el jugador en la creación de
personaje**, no fijo en el fenotipo humano base. El dato ya existe
(`PhenotypeData.PHENOTYPE_FIELDS["warpaint"]`, pick de `WARPAINTS`) — falta
la UI de creación de personaje, que ya vive en **Fase 4** del
[[Plan-de-Produccion]] ("Vestir y doler"). No es trabajo de la ventana C6;
queda anotado como requisito confirmado para cuando se aborde esa UI.
Arranca ejecución en código de pelo/torso/manos/boca.

## [2026-07-14] plan | Propuesta de geometría nueva para pelo/torso/manos/boca
Boris pidió planear la geometría nueva tras confirmar que los 18 puntos de
ajuste de parámetros llegaron al techo (~50-55%, según el propio QA de la
ronda 3). En vez de delegar a un QA imparcial de nuevo, el orquestador miró
DIRECTO ambas láminas con zoom (`fenotipo-humano-v1.png` cara/pelo frente+
espalda, `fenotipo-humano-torso-v1.png` mano/torso) — mismo principio que
"ante conflicto, auditar contra la lámina" de [[Lecciones]]. Hallazgos que
cambian el enfoque: (1) **pelo** — la lámina tiene nuca/laterales casi
rapados (mucha piel expuesta) y un flequillo de 4-5 mechones INDIVIDUALES
grandes con puntas reales, no una concha continua con 31 mechones chicos
casi fundidos; (2) **torso** — el abdomen es CASI PLANO en la lámina, los
"oblicuos" son literalmente 1-2 líneas de trazo sin volumen — `abs_plate`
como masa elevada está resolviendo el problema equivocado; (3) **manos** —
los dedos de la lámina están CASI JUNTOS (la separación se lee por la línea,
no por el hueco físico) con un quiebre de ÁNGULO real en el nudillo, no una
esfera-bulto; (4) **boca** — sin referencia directa en pose neutra, queda
como decisión de Boris entre 2 direcciones. **Hallazgo colateral fuera de
alcance:** las dos láminas dibujan el warpaint DISTINTO (asimétrico en la
de cara, bilateral en la de torso, la ronda 3 implementó la bilateral) — ni
un QA imparcial ni el orquestador pueden resolver esa contradicción sin que
Boris elija cuál lámina manda. Propuesta completa en
[[PRD-Geometria-Nueva-Pelo-Torso-Manos-Boca]]. **Código sin tocar — este
checkpoint es de planeación, esperando ratificación antes de ejecutar.**

## [2026-07-14] fix+qa | Tercera ronda: boca/warpaint/brazalete — 45% → 49%
Boris pidió seguir con los hallazgos más baratos de la ronda del 45%.
**16. Boca — geometría, no solo color.** El `mouth_seam` (línea de
comisura) se había agrandado en rondas históricas para forzar visibilidad
bajo el toon (cuando competía con la barba) — con la barba ya fuera del
default, esa caja pasó a ser el elemento MÁS prominente de la boca, leída
por el QA como "rectángulo sólido". Achicada (alto 0.010→0.006) y
recedida (z 0.137→0.129, detrás de la cara frontal de los labios en vez de
casi al ras). Labios engrosados (radios 0.007/0.009→0.010/0.013) para que
tengan masa propia en vez de perderse contra la línea de comisura.
**17. Warpaint bilateral y diagonal (corrige el punto 7 original).** El
orquestador leyó DIRECTAMENTE `fenotipo-humano-torso-v1.png` (sin
intermediario) y confirmó que el patrón real es una "V"/"A" simétrica —
dos franjas anchas desde ambas sienes convergiendo en diagonal hacia el
puente de la nariz — no "2 trazos verticales de un solo lado" como había
transcrito el QA original de la ronda del 32%. Reconstruido bilateral
(`for fside in [-1,1]`), diagonal (`rotation.z`), y engrosado
(0.006→0.011) para que se note a distancia media, no solo en close-up.
**18. Brazalete verde retirado.** `_arm_stripe` (banda de pintura en el
bíceps) no existe en ninguna lámina — verificado contra
`fenotipo-humano-torso-v1.png`: lo que hay ahí es un BRAZAL DE CUERO
(vestuario, ya cubierto por `character_outfit.gd`, no modelado en el
banco desnudo), no pintura. Se quita del fenotipo humano base.
**QA visual de esta ronda: 45% → 49%** (+4). El propio QA confirma los 3
fixes en su alcance (bíceps limpio, warpaint bilateral con dirección
correcta, boca ya no domina la lectura) pero señala que el techo de esta
técnica ronda 50-55% mientras 4 bloqueadores estructurales sigan sin
geometría nueva: **torso lee "plancha/prisma" sin anatomía a distancia
media**, **pelo sigue como casco/domo sin mechones reales** (confirmado
tras 2 intentos fallidos de tuning geométrico en la ronda anterior —
necesita rediseño, no parámetros), **manos como "tablas planas"** pese a
la separación de dedos, y **boca sin volumen real de labios** (el fix de
esta ronda la sacó de "elemento más ruidoso" pero no logró que lea como
labios). **Hallazgo re-señalado (no nuevo, ya conocido):** la barba sigue
fuera del default (decisión de Boris de la Fase C) — el QA sin contexto
la marca como ausencia mayor, recordatorio de que sigue como nota abierta
para cuando se aborde junto con el pelo real. QA de regresión
(`test_core`/`test_combat`/`autotest_biomech`/`autotest_slice`/
`autotest_ui`) ALL_PASS. **No tocado a propósito:** los pecs (`pec`
sphere, líneas ~433-438) que el QA de la ronda 42% señaló como "leen como
ojos en el torso" — geometría con historial de debate específico
orquestador↔QA (números ya negociados: r 0.05, escala 1.4/0.9/0.5,
verificados contra el radio real del cilindro) — no se toca sin más
contexto de Boris.

## [2026-07-14] fix+qa | Segunda ronda: pauldron fantasma + contraste de pelo — 42% → 45%
Boris pidió arrancar la segunda ronda de fixes tras el QA del 42%,
empezando por los 2 más baratos.
**14. Pauldron fantasma (RESUELTO, confirmado por el QA de esta ronda,
ausente en los 9 renders).** Causa raíz: `_build()` en `character_rig.gd`
agrega las venas de mana DESPUÉS del pauldron, y una de ellas ("right
upper arm") se parentea directo a `arms[1]` — el mismo nodo del pauldron
— así que el pauldron dejó de ser el "último hijo de arm_r". El hack por
índice (`get_child(count-1)`) que tanto `tmp_anatomy.gd:75` como
`_apply_build()` (línea ~1286, lógica de escalado Vanguard — **bug de
producción real, no solo de banco de pruebas**) usaban para encontrarlo
empezó a agarrar la vena en su lugar. Fix: pauldron ahora tiene
`.name = "pauldron"`; ambos call sites lo buscan por `find_child()` en vez
de por índice.
**15. Pelo — mejora parcial, NO resuelto de raíz.** Se probaron 3
variantes de geometría (subir protrusión/reducir sink globalmente, luego
solo en filas traseras) — ambas reabrieron el defecto histórico "dientes
en la silueta frontal" (blanket) o no produjeron cambio visible perceptible
(por fila) — revertidas. Lo único que quedó: contraste tonal de mechones
subido de 2 tonos (±10%) a 3 tonos (+28%/-18%), técnicamente perceptible
mirando de cerca pero el QA confirma que **no resuelve el problema real**:
la silueta general sigue leyendo "casco/gorro sólido", con un borde
horizontal duro entre pelo y frente. **Diagnóstico para la próxima
sesión:** el problema es de GEOMETRÍA/silueta (la concha elipsoide +
mechones semi-hundidos no rompen el contorno general), no de tono — un
ajuste de color no lo va a cerrar; hace falta una revisión de forma más
profunda (quizás una sesión dedicada, posiblemente con propuesta visual
ANTES de codear, como se hizo con pelo/Fase D en el pasado).
**QA visual de esta ronda: 42% → 45%** (+3). Confirma que ambos fixes
funcionan en su alcance específico pero no mueven los bloqueadores de
fondo. **Hallazgos NUEVOS que aparecieron en este corte (no reportados
antes):** boca como "rectángulo sólido, lee como agujero geométrico"
(más notorio sin barba encima); **dos manchas ovaladas en el pecho que
leen como "ojos" en el torso** (geometría de `pec`, preexistente, nunca
señalada hasta ahora); brazalete/banda verde en el brazo que el QA no
reconoce contra ninguna lámina (es `_arm_stripe`, ya marcado como
"sin confirmar en la lámina" en el PRD original — candidato a quitar).
Resto de hallazgos (nariz faceted, ojos platillo, warpaint casi invisible
a distancia, manos aún angulosas, cuello grueso) se mantienen de la ronda
anterior. QA de regresión (`test_core`/`test_combat`/`autotest_biomech`)
ALL_PASS en ambos fixes.

## [2026-07-14] qa | QA visual imparcial de cierre — 32% → 42% (mismo protocolo, subagente sin contexto)
Corrido el mismo protocolo de la ronda que dio ~32%: subagente sin contexto
de código, renders frescos (`tmp_anatomy.gd` tras los 13 puntos) contra
`fenotipo-humano-v1.png` + `fenotipo-humano-torso-v1.png`. **Veredicto:
42% de fidelidad global** (+10 puntos). Mejoras confirmadas por el QA:
torso sin caja rígida (hombros/pectorales con volumen real), manos con
dedos separados (aunque la forma final — "abanico de cartas" — no
convence), ubicación del warpaint correcta aunque la forma no.
**CRITICAL sin resolver / nuevo:**
1. **Pelo sigue leyendo casco/gorro sólido** — el swap a Frontier Crop
   (punto 2) cambió el ÍNDICE de estilo pero el QA no ve textura de
   mechones ni volumen direccional; sigue siendo el hallazgo #1, igual
   que en la ronda del 32%.
2. **Objeto flotante gris/azul en el hombro derecho** — verificado por el
   orquestador contra `anatomy_close.png`: es el pauldron, que
   `tmp_anatomy.gd:75` intenta ocultar buscando el ÚLTIMO hijo de `arm_r`
   (hack frágil por índice) pero no lo está logrando. **No es parte de
   los 13 puntos de este PRD ni se tocó en esta sesión** — bug
   preexistente, candidato a fix rápido separado.
3. **Costuras duras en abdomen/pelvis** — el ajuste del punto 12
   (abs_plate) no cerró la lectura de "caja" que ve el QA en esa zona.
**HIGH nuevos/reabiertos:** boca abierta con relleno sólido (lee como
grito, no como expresión neutra — geometría, no color; el punto 8 solo
tocó el TONO de `mouth_seam`, no la forma del hueco entre labios); warpaint
con forma rígida (2 barras verticales cortas) en vez de trazo diagonal
fluido continuo hacia la mejilla; piel grisácea confirma el diagnóstico
del punto 11 (LUT del post, no tocado sin Boris). MEDIUM: piernas/botas
muy finas y oscuras vs. el volumen muscular de la lámina; orejas "asa
pegada" sin pliegue interior; nariz aún facetada en perfil.
**Pendiente: decisión de Boris** — ¿segunda ronda de fixes (empezando por
pelo + pauldron fantasma, los 2 CRITICAL más baratos de arreglar) o
aceptar el 42% como checkpoint y avanzar a Fase D con estas notas
abiertas?

## [2026-07-14] fix | PRD Rework Fenotipo Humano Cuerpo Completo — 13 puntos EJECUTADOS EN CÓDIGO
Ejecución completa del plan ratificado en
[[PRD-Rework-Fenotipo-Humano-Cuerpo-Completo]] (13 puntos, orden por
dependencia), con QA visual (`tests/tmp_anatomy.gd`) y regresión
(`test_core`/`autotest_biomech`/`test_combat`/`autotest_slice`/
`autotest_ui`) ALL_PASS tras cada punto. Todo en `character_rig.gd` salvo
donde se indica.
1. **Venas cian:** el bloque que actualiza `accent` por tema de origin
   corría DESPUÉS del cálculo de `vein_mat.albedo_color` — en el primer
   `apply_phenotype()` las venas se pintaban con el cyan default
   `#46e6ff` antes de que `accent` tomara el color del origin. Movido el
   bloque de origin ANTES del cálculo de venas. `phenotype_data.gd`:
   default de `arcaneMod` 0.25→0.0 (no es parte del fenotipo humano base).
2. **Pelo:** `tmp_anatomy.gd` tenía `hair=11` (Prince Curtain, melena de
   cintas) en vez de `10` (Frontier Crop, el propio código lo marca como
   canon del fenotipo humano). Verificado visualmente: silueta corta real,
   no la misma lógica de cintas en versión chica.
3. **Torso:** trapecios eran `BoxMesh` sobre el cilindro del torso (arista
   dura garantizada); reemplazados por esfera escalada semi-hundida, mismo
   patrón que `pec`/`deltoid`.
4. **Hombros:** ángulo del trapecio 0.40→0.28 rad — primer paso de bajo
   riesgo; `SHOULDER_X` queda intacto (decisión de Boris si no basta).
5. **Orejas:** resuelto pasivamente por el swap de pelo (punto 2) — visibles
   en perfil sin tocar `hair_library.gd`.
6. **Manos:** gap entre dedos (`f_off`) de ~0.38mm efectivo a ~1.4mm limpio;
   nudillo (esfera chica semi-hundida) agregado en la base de cada dedo;
   pulgar de caja a cápsula (ya no lee "ranura paralela").
7. **Warpaint:** de 1 franja diagonal a 2 trazos verticales (ceja/sien
   izquierda → pómulo), confirmado por Fable contra la lámina.
   **Corrección sobre el propio PRD:** el punto 7 daba por "índice inválido"
   `warpaint=6` en `tmp_anatomy.gd` (la lista `WARPAINTS` de la UI solo
   llega a 5) y proponía fijarlo a un valor 1-5 — pero el atlas
   (`warpaint_atlas.gd:217-231`) documenta que el patrón 6 ("Scout Marks")
   está VACÍO A PROPÓSITO porque esa marca vive como geometría en
   `_face_mark`. Probado con `warpaint=1`: pintó el patrón legacy "Slash
   Crimson" ENCIMA de los 2 trazos nuevos — revertido a `6`.
8. **Boca:** `mouth_seam` usaba `pupil_mat` (negro plano, leía "hueco");
   nuevo `mouth_seam_mat` en tono de labio oscurecido (`#a85f47` al 55%).
9. **Nariz:** `bot_r` 0.026→0.019 (base más angosta). **Desviación del
   PRD:** no se tocaron `radial_segments` (4→6-8 propuesto) — con N=4 y
   `rotation.y=0` hay una cara plana exacta al frente (el fix de "Ronda 8"
   ya documentado en el código, que cerró 3 rondas de facetado ilegible);
   con N par >4 ningún múltiplo de `rotation.y` deja una cara centrada en
   +Z, así que subir segmentos reabría el problema que Ronda 8 cerró.
10. **Cejas:** `BoxMesh` (0.048,0.011,0.010)→(0.040,0.006,0.010) — primer
    paso de bajo riesgo; Fable ya advirtió que esto no da arco real
    (segunda pasada = cadena de cápsulas, pendiente si Boris lo pide).
11. **Piel:** diagnóstico con post desactivado — confirma que `skin_mat`
    base es cálido/rosado; el LUT del post (dawn) es el responsable del
    "gris apagado" percibido (y del entintado toon completo). Es global —
    **no tocado** sin aprobación explícita de Boris, tal como pedía el PRD.
12. **Abdomen:** `abs_plate.scale` x 1.1→1.25 (ancho), z 0.4→0.30
    (protrusión) — borde más gradual contra el cilindro.
13. **Columna (riesgo alto):** `spine.position.z += 0.01` (estático, sin
    lerp que lo borre). **Desviación del PRD:** `upper_spine.rotation.x =
    -0.09` NO se asignó una sola vez en `_build()` como proponía el plan —
    se descubrió que el "follow del torácico fuera del strike" (línea
    ~2892) hace `lerp` cada frame que no es strike hacia
    `spine.rotation.x * 0.30`, así que una asignación directa se borra sola
    en <150ms de idle (mismo mecanismo que "el settle satura el clamp" de
    [[Lecciones]]). Se sumó como offset constante (`DORSAL_CURVE_X`) al
    TARGET de ese lerp, para que la curva sobreviva al reposo real, no solo
    al primer frame. `autotest_biomech` + `test_combat` corridos
    ANTES y DESPUÉS del cambio, ambos ALL_PASS. **Nota abierta:** la
    métrica "cabezas" del banco bajó 7.49→7.13 tras este cambio — el
    cráneo inclinado infla su propio AABB (medición suelo→coronilla vía
    bounding box, ver [[Lecciones]] sobre inflación de AABB), probablemente
    un artefacto de medición y no una regresión anatómica real, pero sin
    confirmar — a verificar antes del próximo VoBo.
**Pendiente: correr un nuevo QA visual imparcial (mismo protocolo, sin
contexto de código) contra ambas láminas para medir el % de fidelidad
resultante, y VoBo de Boris.**

## [2026-07-14] plan | PRD nuevo: rework de fenotipo humano CUERPO COMPLETO — QA imparcial detecta ~32% de fidelidad
Boris no había ratificado la sesión anterior (cierre de Fase C cara al 75%)
y pidió, antes de seguir, correr un QA visual imparcial (subagente Fable)
comparando el personaje humano completo contra las láminas RAW
(`fenotipo-humano-v1.png` + `fenotipo-humano-torso-v1.png`) — no solo cara.
Veredicto: **~32% de fidelidad global**. El 75% que cerró la Fase C solo
medía cara; con pelo (estilo "Prince Curtain" de 22 cintas en vez del canon
"Frontier Crop"), torso (trapecios como cajas, costuras visibles), manos
(dedos casi fundidos) y un bug real de venas cian (`accent`/`arcaneMod`) el
personaje completo lee como maniquí técnico, no como el aventurero de la
lámina. **Lección de proceso que motivó este PRD (pedido explícito de
Boris):** el feedback de arte no se estaba traduciendo a requerimiento
técnico preciso antes de tocar código, forzando demasiadas rondas de
iteración. Se corrigió con 3 roles separados que se validan entre sí ANTES
de escribir código: QA visual (Fable) → técnico (lee el código real,
traduce a archivo/línea/valor, detecta 2 falsos positivos) → QA de nuevo
(ratifica o corrige la traducción técnica). El plan resultante — 13 puntos
priorizados CRITICAL→LOW con coordenadas/valores concretos y orden de
ejecución por dependencia — queda asentado en
[[PRD-Rework-Fenotipo-Humano-Cuerpo-Completo]]. **Código sin tocar
todavía** — este checkpoint es solo de planeación.

## [2026-07-14] fix | Mentón corregido tras quitar la barba — cierra la ventana de ajuste facial
Con la barba fuera, un QA final enfocado solo en labios+mentón encontró un
problema real que la barba había estado tapando: la cara frontal de
`chin_boss` (z≈0.098) quedaba ~4.7cm detrás de la cara frontal de
`lip_lower` (z≈0.145) — el mentón nunca competía visualmente con el labio,
al revés de la lámina (mentón marcado, el rasgo más anguloso de la cara).
Primer intento de fix (igualar/superar el z del labio, front≈0.148) se
pasó de rosca — leía como mandíbula protuberante/bulldog, detectado en
captura antes de pedir verificación. Calibrado a un punto intermedio
(`character_rig.gd`: profundidad 0.036→0.055, posición z 0.080→0.0975,
front≈0.125) — confirmado: mentón como masa definida y separada, sin
sobremordida, con un pliegue mentolabial que el QA identificó como
anatómicamente correcto (no un artefacto). Labios sin cambios (ya estaban
resueltos). QA de regresión ALL_PASS. **Cierra la ventana de ajuste facial
de la Fase C — listo para pasar a Fase D (orejas + pelo).** **Mapeado para
Fase D: revisar la barba de nuevo** (Boris la sacó del default por
"no me gusta nada" pese al 75% técnico; retomarla junto con el pelo real,
no como tema cerrado para siempre).

## [2026-07-14] fix | Barba quitada del default (veredicto directo de Boris: "no me gusta nada")
Pese a que el [[QA Loop]] cerró la barba en un estado técnicamente sólido
(6+ rondas: esferas dispersas → bloque sólido → conicidad real → pulido de
contorno, confirmado por el agente de desempate como "coherente con el
lenguaje del resto de la cara"), el director la rechazó de plano al verla
en las capturas finales. Se prioriza el veredicto directo del director por
encima del % de QA — el `beardDensity`/`_beard_stubble` no se borran (el
sistema queda intacto y configurable para personalización del jugador),
solo cambia el DEFAULT del fenotipo humano canónico: `beard` vuelve de 1
(Stubble) a 0 (Clean) en `phenotype_data.gd`. QA de regresión completo
ALL_PASS. El fenotipo humano canónico queda lampiño otra vez, como estaba
antes de la Fase C paso 6.

## [2026-07-14] feature | QA Loop cierra Fase C cara en 75% de fidelidad
Boris pidió correr el [[QA Loop]] (código↔QA↔PRD) hasta ~80% de fidelidad
o el techo real de la técnica. Progreso medido: 30-35% → 40-45% → 50-55%
→ 53-56% → 60-63% → 62-65% (el agente QA perdió su historial de
transcript a mitad de camino) → un agente nuevo sin contexto visual
discrepó fuerte con lo que orquestador y Boris veían directamente en las
capturas (dijo "sin esclerótica visible, peor rasgo de la cara" y "barba
retrocedida a collar de cuentas") → se lanzó un TERCER agente de
DESEMPATE que leyó el código real (no solo impresión) y falló: confirmó
la falta de esclerótica (bug real, iris desbordaba el blanco entero) pero
objetó la lectura de "collar" en la barba. Desde ahí, 6+ rondas más de
desempate → 55% → 58% → 61% → 69% → **75% final**.

Se resolvieron con múltiples iteraciones EN VIVO (capturar → ver el
problema → corregir → recapturar, no solo cálculo teórico):
- **Boca**: bloque (r1) → agujero tipo "grito" por sobre-corregir el gap Y
  (r2) → bloque chico de nuevo (r3) → escalón real sobre las CARAS
  FRONTALES (no los centros — con radios distintos ambas caras pueden
  coincidir en el mismo Z pese a que los números "parecen" distintos, fue
  la causa de 4 rondas estancadas) + tono diferenciado por labio
  (`lip_mat` oscuro arriba / `lip_mat_lower` claro abajo) — resuelto.
- **Barba**: reemplazo COMPLETO del vocabulario, de esferas dispersas
  (`_beard_stubble` original de Fase C p6) a bloque sólido CONFIGURABLE
  (`density`, fenotipo `beardDensity`). 5 iteraciones de forma: collar
  gigante (cálculo de profundidad de jaw mal hecho) → aro (más ancho que
  el jaw real a esa altura, la mandíbula se angosta hacia el mentón) →
  bulto negro (esfera cae entera en la banda oscura del toon) → "ladrillo"
  (caja única sin la conicidad del jaw) → 3 cajas escalonadas + esfera de
  remate, midiendo el z_surface real del jaw en 3 alturas distintas.
- **Ojos**: iris/pupila desbordaban la esclerótica entera (margen
  NEGATIVO, no "fino" como decía el comentario de Fase C p3) — confirmado
  contra refs. de Link/Zelda (BotW/TotK) que Boris aportó al Vault
  (`90-Raw/research/quality-benchmarks/`). Luego Boris notó que los ojos
  quedaban muy separados (hueco entre esquinas internas ~2.4x el ancho de
  un ojo vs. la regla estándar ~1x) — recogidos y agrandados, ceja movida
  junto.
- **Pómulos/mentón**: esfera → caja achatada (mismo principio en ambos).
- **Nariz**: causa real no era magnitud sino ORIENTACIÓN — arista al
  frente (dos caras iguales, luz simétrica, sin contraste) → cara plana
  al frente (una cara iluminada + sombra lateral = quiebre real), misma
  lección que resolvió la boca.
- **Warpaint**: color bajado 3 veces hasta un oliva apagado.

**Lección nueva (candidata a [[Lecciones]]):** una esfera NUNCA da un
plano/borde anguloso en este vocabulario de primitivas+Sobel — confirmado
independientemente en mentón, pómulo y barba. Usar cajas para cualquier
rasgo que la lámina muestre como plano definido.

PRD actualizado y cerrado: [[PRD-Fase-C-Ajuste-Facial]]. QA de regresión
completo ALL_PASS en cada ronda, 7.49 cabezas estable. **Pendiente: VoBo
final de Boris sobre el 75% antes de pasar a Fase D pelo** (el techo del
75% es atribuible a pelo/orejas placeholder, fuera de este scope).

## [2026-07-14] ingest | Benchmarks visuales Link/Zelda + Sable/Hinterberg
El director agregó 9 archivos a `90-Raw/research/quality-benchmarks/`:
`link-01/02/03.jpg` + `zelda.jpg` (Breath of the Wild / Tears of the
Kingdom) — propuestos como fenotipo BASE para el modelado del elfo
(Fase C6b/C6c): a diferencia de la lámina de concept (still 2D), esto es
un resultado YA logrado dentro de un videojuego real — ojos almendra con
esclerótica blanca claramente visible, nariz fina, boca seria de línea
simple. Sirvió además de evidencia directa en el desempate de la Fase C:
confirmó que la esclerótica del ojo humano actual (Godot) tenía margen
NEGATIVO (el iris desbordaba la esclerótica entera), comparando contra
estas referencias. `sable-01..05.{webp,jpg}` + `dungeons-of-hinterberg-
01..03.jpg` — capturas reales de los dos pilares del norte artístico
([[Art Bible]] "Melancolía Gráfica"), complementan el texto con
referencia visual directa. Indexado en `00-Index.md`.

## [2026-07-14] design | QA Loop ratificado (nuevo método de trabajo)
Boris pidió formalizar en el Vault el método que surgió durante el ajuste
fino de la Fase C: un subagente QA imparcial (sin contexto de la sesión)
mide fidelidad contra la lámina RAW canónica (rasgo por rasgo, % + lista
priorizada CRITICAL/HIGH/MEDIUM/LOW), un segundo subagente PRD traduce ese
veredicto a un documento ejecutable (mismo formato que PRD-006/007, citando
archivos/variables reales), y el orquestador itera código→QA→PRD hasta un
% objetivo o hasta que el QA declare el techo real de la técnica vigente.
Documentado en `30-Loops/QA Loop.md` (contrato mínimo: Objetivo · Entrada ·
Fases · Validación · Artefactos · Salida, mismo esqueleto que los demás
Loops). Indexado en `00-Index.md`. Reemplaza el patrón viejo de "VoBo del
director → ajuste a ciegas → VoBo de nuevo" cuando existe una lámina de
referencia canónica contra la que medir.

## [2026-07-14] feature | Fase C ajuste fino post-QA (mandíbula, boca, pómulos, ojos, barba, warpaint)
Boris pidió QA imparcial (subagente sin contexto previo) comparando las
capturas de la Fase C contra la lámina `fenotipo-humano-v1.png`. Veredicto:
**≈30-35% de fidelidad, "totalmente alejada"** — silueta craneal demasiado
esférica (sin quiebres), pómulos invisibles, ojos con "arrugas" no
buscadas, boca como bloque sin lectura de labios, barba no perceptible,
warpaint como "curita fosforescente". Objeté parcialmente (yo veía
labios/barba en mis propias capturas) pero Boris, comparando de nuevo
contra la lámina, le dio la razón al QA — la lámina muestra barba COMPLETA
de mandíbula-a-mandíbula, no un mentón aislado. Se le pidió al QA pasar de
diagnóstico a plan ejecutable (geometría concreta, no "mejorar X") y se
ejecutó en su orden sugerido:
1. **Silueta craneal**: masa de "ángulo goníaco" (bulto hundido por
   overlap, altura de oreja) — introduce el quiebre vertical→horizontal
   de la mandíbula que la esfera única de `jaw_mesh` no tenía.
2. **Boca**: labio sup/inf casi tangentes (gap Y 0.013, misma Z) → sin
   escalón de profundidad detectable por el Sobel. Gap Y al doble +
   escalón Z real (sup. protruye, inf. se hunde).
3. **Pómulos**: escala Z 0.46→0.64 (estaban tan aplastados que "no leían
   desde ningún ángulo") + menos hundimiento.
4. **Ojos/arrugas**: diagnóstico correcto del QA — no era piel, era el
   Sobel apilando pómulo+ceja a ~3.4cm del ojo. Más distancia pómulo-ojo +
   brow con menos invasión.
5. **Barba** (prioridad explícita de Boris): de 2 esferas aisladas
   ("perilla") a cadena de 11 masas con overlap real ~2x entre centros,
   de patilla a patilla. 2 rondas de fix en vivo: r6d (subida — colgaba
   sobre el cuello por falta de quiebre jaw/cuello) y r6e (más overlap —
   leía "collar de cuentas" antes de suficiente solape). Oscurecido
   35%→20%.
6. **Warpaint**: proporción 4:1→10:1 + color `PAINT_COLORS[4]` desaturado
   `#4dff9d`→`#6b7f4a` en `palette_data.gd` (array propio, no toca
   `HAIR_COLORS`). Franja subida de nuevo en Z (pómulo más grande volvió a
   enterrarla).
QA: `test_core`+`autotest_biomech`+`test_combat`+`autotest_slice`+
`autotest_ui` ALL_PASS, 7.49 cabezas estable. **Pendiente: VoBo de Boris —
¿re-correr QA vs. lámina o cerrar Fase C y pasar a Fase D pelo?**

## [2026-07-14] feature | Fase C cara COMPLETA — p4 nariz, p5 boca, p6 barba, p7 orejas, p8 warpaint (8/8)
Sesión corrida de un tirón (director: "avancemos y al final vemos ajuste
fino") — los 5 pasos restantes de la Fase C ejecutados y verificados en
`character_rig.gd` / `hair_library.gd` / `phenotype_data.gd`.
**p4 nariz cuña integrada**: el prisma de 4 caras vivía como cap plano
flotando sobre el plano facial (sin overlap) → costura visible. Mismo
truco de fusión que mandíbula/pómulo: raíz (puente) encogida casi a un
punto y HUNDIDA ~1.6 cm dentro del cráneo; punta proyecta ~8-9 mm fuera.
Se agregaron ALAS (bultos chicos semi-hundidos junto a la punta) que el
M9-r3 pedía y nunca se construyeron.
**p5 boca por geometría**: las 3 cajas planas (pupil_mat negro, un trazo
sin volumen) se reemplazan por labio superior + inferior reales (`lip_mat`
nuevo, rosa cálido, cilindros que se hunden en la mandíbula) + comisuras
como bultos; la línea oscura queda solo de sombra interior.
**p6 barba corta**: `HairLibrary._beard_stubble()` usaba un shell
translúcido (pitfall ALPHA del toon `toon_opaque`, que no escribe alpha).
r6a (revertido): una sola masa opaca grande tapaba la boca entera y leía
como bigote-máscara. r6b (final): DOS masas chicas (bigote + mentón/
mandíbula) con gap real donde vive la boca, oscurecidas 35% vs. el pelo.
Default del slider `beard` sube de 0 (Clean) a 1 (Stubble) — la lámina
pedía barba de 3 días como rasgo de identidad, el fenotipo canónico vivía
lampiño. **Nota de ajuste fino: el mentón lee como bola marcada en
perfil, candidato a achicar/aplanar.**
**p7 orejas**: se agregó un lóbulo (bulto chico bajo el pabellón existente,
mismo truco de fusión) — faltaba el quiebre lóbulo/pabellón que el resto
de la cara ya tenía.
**p8 warpaint 1 franja limpia**: de DOS marcas asimétricas ("Scout Marks"
de M9-r2, frente + mejilla) a UNA franja sobre el pómulo izquierdo. **Bug
de regresión encontrado y corregido en el mismo paso:** la franja (z=0.106
desde M9-r2, nunca retocada) quedaba enterrada dentro de la masa `cheek`
nueva de la Fase C p2 — invisible en render; subida a z=0.128.
QA de los 8 pasos: `test_core` + `autotest_biomech` + `test_combat` +
`autotest_slice` + `autotest_ui` ALL_PASS, 7.49 cabezas estable en todos.
**Pendiente: VoBo de cara completa con Boris (ajuste fino: pómulos + barba/
mentón) → Fase D pelo.**

## [2026-07-13] feature | Fase C cara: mandíbula, pómulos y ojos (3/8 masas)
Continuación de la sesión de tarde. **p1 mandíbula fundida** (`c12da0a`):
esfera escalada que penetra el cráneo (overlap real, no tangente — lección
de las uniones del cuerpo), mata el prisma de 4 caras + caja de mentón del
r5 (los dos ofensores de costura). Recalibrado a 7.49 cabezas (colgaba a
6.67 en el primer intento). **Veredicto del director: "me convence
muchísimo".** **p2 pómulos altos** (`eb1ecab`): plano malar elongado
semi-hundido en vez de esferita redonda al ras. Feedback del director:
"los pusiste a un lado de los ojos" — diagnóstico correcto, el pómulo
quedaba casi a la misma altura que el ojo (y=0.016 vs ojo y=0.022); fix
(`23f03d7`) baja la base a y=-0.012 y el rango del slider nunca cruza la
altura del ojo. Segundo veredicto: "no me terminan de convencer". Decisión
conjunta (pregunta del director, respuesta del orquestador): NO seguir
iterando el pómulo a ciegas contra una cara incompleta — es una masa sutil
por diseño y compite mal con una nariz-prisma vieja y sin barba; se revisa
en un **VoBo de cara completa después de la barba** (p6), con más contexto
y sin costo (el pómulo es un parámetro aislado, retocable después). **p3
ojos almendra** (`ea3f5bb`): mata el ojo-platillo del r5 — esclerótica más
chica/aplastada, iris+pupila crecen para llenar casi todo el alto del ojo,
la ceja crece y baja para SOLAPAR de verdad el tope del ojo (párpado real)
→ lee entrecerrado/calmado. QA de los 3 pasos: `test_core` ALL_PASS + banco
`tmp_anatomy.gd` sin errores en cada ronda. **Pendiente: p4 nariz cuña
integrada → p5 boca → p6 barba corta → checkpoint VoBo cara completa → p7
orejas → p8 warpaint.**

## [2026-07-13] feature | Cintura del cuerpo desnudo cerrada + Fase C cara abierta
Sesión de tarde. (1) **VoBo del director** al outfit frontier (r2). (2) Se
retomó el pendiente dejado a propósito: **verificar la continuidad de cintura
del cuerpo DESNUDO**. Delegado a subagente Sonnet; había un hueco REAL de
15.2 cm entre `abs_plate` (mundo y=1.172) y `pelvis` (y=1.02) — se veía el
fondo a través del torso, tapado por accidente por la faja del outfit. Fix
(`de347d3`): malla `waist` (cilindro de piel hijo de `spine`, top_radius=0.11
= radio base del torso, copia `torso.scale` x/z en `_apply_build` → costura
cero en cualquier build; overlap real 5 cm en la pelvis). Banco reusable
`tmp_waist_check.gd`. QA `test_core`+`autotest_biomech` ALL_PASS; verificado
visualmente por el orquestador (`waist_check_*.png`, piel continua). Nota
abierta menor (preexistente, no tocada): sliver de axila brazo-torso. (3)
**Fase C cara ABIERTA con luz verde del director** a la propuesta por masas
fundidas (esquema `propuesta_masas_cara_humano_faseC`, anclado a la lámina
`fenotipo-humano-v1.png`). Diagnóstico r5-rechazado vs lámina: falta barba
corta, ojos anti-platillo, nariz integrada, mandíbula fundida sin costuras,
boca por geometría, warpaint de 1 franja. Orden de masas aprobado (8 pasos,
captura por paso). Hallazgo de infra: `HairLibrary.build_beard()` existe pero
el stubble usa overlay translúcido (pitfall toon ALPHA) → barba como masa
opaca semi-hundida.

## [2026-07-13] feature | Faja: cierra el hueco ombligo-a-cadera (feedback director)
Boris vio en las capturas del outfit una franja de piel entre la faja y
el pantalón. Diagnóstico medido (cotas de nodos, no a ojo): la faja de 3
bandas quedaba en cintura alta (body 1.065-1.235) y dejaba ~4.5 cm de
piel sobre el pantalón (pelvis tope ~1.02) — el jerkin sólido viejo lo
tapaba. Fix (ea985f1): 5 bandas solapadas bajando hasta solapar el belt,
radio creciente para seguir la cadera; el vuelo se acerca al faldón de
la lámina. Gates core+slice ALL_PASS; capturas r2 en
`test_out/rounds/outfit-frontier/`. **PENDIENTE (dejado a propósito por
Boris): verificar la continuidad de cintura del cuerpo DESNUDO**
(constraint sin-playera; el auditor advirtió que el jerkin tapaba un
posible hueco de anatomía torso→pelvis) — zoom preparado, sin revisar.
Nota abierta menor: el belt horizontal quedó parcial bajo la faja
(subirlo si Boris quiere el cinturón sobre el fajín, como la lámina).

## [2026-07-13] design | VAULT-STARTER.md — pase agnóstico (sin dominio de juego)
El director pidió dejar el starter agnóstico a cualquier proyecto: fuera
toda mención a Godot/videojuegos. Cambios: intro sin "videojuego"; árbol
sin `godot/`; op-tags `feature→build` y `playtest→review`; "Feature
Loop"→"Build Loop", "Review/Playtest Loop"→"Review Loop" (fuera
feel/montages); "código" (como entregable) → "entregables/trabajo" en los
principios SSoT/sincronización, Lint, gate y CLAUDE.md; bootstrap pregunta
"dominio (software/investigación/escritura/producto/operaciones…)". Se
conserva la terminología git (repo/branch/commit) por ser parte del
método para cualquier dominio. Verificado: 0 menciones a juego/Godot.

## [2026-07-13] design | VAULT-STARTER.md — el método exportado en un archivo único
Encargo del director: destilar nuestro esquema de trabajo completo en un
.md autocontenido para que cualquier persona arranque un proyecto de
Vault adjuntándolo a su propio Claude Code. Generado en la raíz del repo
(`VAULT-STARTER.md`) desde las fuentes raw (LLM-WIKI de Karpathy + VDD
v1.0), el SCHEMA vigente (incluido el §7 de cierre de sesión) y los 5
loops. Contiene: teoría (compilación vs RAG, Vault como OS/máquina de
estados, separación de roles), estructura completa
(Raw/Schema/Knowledge/State/Loops/Index/LOG), plantilla de página con
ciclo de status, contratos genéricos de los 5 loops, la rutina de cierre
de 6 pasos con la semántica de sobrescritura (Current-State = presente,
LOG = historia, Lecciones = viva y obligatoria pre-código), tiering de
orquestación, instrucciones de bootstrap para el agente (§9), CLAUDE.md
sugerido (§10) y consejos de campo pagados en este proyecto (§11).
Agnóstico de dominio; en español.

## [2026-07-13] feature | Outfit configurable por piezas + cierre de sesión (checkpoint §7)
Feedback de Boris tras ver el outfit frontier: la faja y la bandolera
NO deben quedar hardcodeadas al personaje. Refactor (305eac1):
`character_outfit.gd` pasa de bloque monolítico a catálogo de piezas
(`build(rig, [ids])` + `remove_piece`/`remove_all` + `PRESETS.frontier`);
back-compat vía alias `build_frontier`. La UI de personalización (pestaña
OUTFIT) queda para Fase 4, la API ya la soporta. Andamiaje Beckett
`golden_boot` versionado (c9c6f22). Gates de cierre: core+slice+combat
ALL_PASS sobre HEAD. Working tree limpio; `Los 9 Links` (toque
accidental CRLF de Obsidian) restaurado. **Pendientes de VoBo: torso
desnudo + outfit. Sigue: Fase C cara → Fase D pelo (propuestas por
masas antes de codear) → movimientos.**

## [2026-07-13] feature | Rework integral Fases A→D: shaders VoBo, cuerpo a la lámina, anatomía de torso, outfit frontier (8 commits, 5 gates verdes)
Día completo dirigido en vivo por Boris con QA imparcial Fable como
contrapeso. (1) Dos auditorías imparciales archivadas verbatim
(`90-Raw/reviews/QA-Auditoria-{Codigo,Output-vs-RAW}-2026-07-12.md`):
código sólido cero critical; arte ~55% fidelidad, pipeline de render
cerca del norte, personaje no. (2) Fase A shaders ✅ VoBo colores:
shadow_floor por preset (muere la banda negra) + cristal peligro rojo
unshaded (42d169e). (3) Fase B cuerpo ✅ "mucho mejor": uniones fundidas
(c31bf81), musculatura de brazos aplastada a pedido (c2be29e, 5ac2640),
y el fix raíz del QA dirigido al tronco superior (3550bfe +
`QA-Auditoria-Tronco-Superior-2026-07-13.md`): el esqueleto del hombro
llevaba un fósil de la review v0.1 (+12%) que contradecía la lámina —
SHOULDER_X 0.262→0.21, la silueta cuello→muñeca solo desciende.
LECCIÓN mayor: ante conflicto review↔lámina, auditar contra la lámina.
(4) Debate formal orquestador↔QA (3 temas: jerkin/cuello/musculatura)
→ veredictos ratificados por Boris con comparativos
(`test_out/rounds/debate-tronco/`). (5) Anatomía de torso ✅ (e5d3e51):
pecs elipsoides, placa abdominal sin six-pack, clavícula-cápsula,
cuello +15%, piernas ya cumplían; rúbrica [[Benchmark-Musculatura-Torso]]
(borrador) + lámina NB `fenotipo-humano-torso-v1.png` (autoridad #1
SOLO superficie de torso, alcance acotado por Boris). (6) Outfit
frontier ✅ (1794b1a): jerkin/strap/belt fuera del cuerpo base →
`character_outfit.gd` (faja envuelta de lámina + pouches); juego
vestido, banco desnudo. Gates completos ALL_PASS. DECISIONES de Boris:
VoBos viejos rechazados; peinado príncipe DESECHADO (Fase D = masas de
silueta tipo animé, propuestas antes de codear); Beckett MCP adoptado
como loop de iteración en vivo (instalado 2118c81, protagonista del
día). Pendiente VoBo: torso desnudo + outfit.

## [2026-07-12] feature | Plan de rework EN EJECUCIÓN — Sesiones 0–2: Beckett instalado, cuelgue resuelto, peinado príncipe reconstruido (m10-r5/r6)
Sesión de ejecución del plan "Rework gráfico Humano C6/M10 + spike
Beckett" (Boris dio luz verde; delegación por tiering: Sonnet ejecutó
S0 y las rondas estéticas de S2; el orquestador, diagnóstico y fixes de
fidelidad). **S0:** TERCERA RONDA añadida a
`90-Raw/research/Plugin-Evaluation-2026-07-11.md` — cara sin plugin
minable (Humanizer = blend-shapes sobre malla continua, incompatible);
cross-check ROM contra Humanizer/VRM con huecos anotados
(muñeca/tobillo/clavícula/dedos); orientation warping de PoseWarping
portable a hips/spine/upper_spine → candidato C4 (tercera persona
exclusiva, todo lo first-person descartado). **S1:** Beckett MCP 1.8.0
instalado (`godot/addons/beckett/`, habilitado, `.mcp.json`
gitignoreado, servidor solo-localhost verificado); **cuelgue del banco
RESUELTO: contención confirmada** — matando Epic/EA/Steam, tmp_anatomy
7 s / test_core 0.4 s (lección cerrada + protocolo en [[Lecciones]]).
**S2:** el banco desbloqueado reveló el bug real del M10-r4: contrato
de ejes contradictorio entre `_s_spine` (espina Y negativa) y `_ribbon`
(`mbasis.y` = flow) → mechones creciendo opuestos a su flow (astas).
Fix + lección nueva. r5 (Sonnet, 4 rondas): barrido trasero, enmarque
lateral, +3 mechones nuca. r6 (orquestador): masa occipital + banda de
flequillo (la concha sola era un crop; hairline frontal por fin
visible; v1 de la banda enterrada a 0.82R — margen real aplicado).
Capturas por ronda en `test_out/rounds/m10-r5|r6/`. QA: test_core +
autotest_slice ALL_PASS. **VoBo del director pendiente (m10-r6)**;
observaciones honestas anotadas en Current-State (cercanía tonal
castaño↔piel bajo dawn y sombras gris-frío de mechones → ambas van por
los gradientes/banding de C8 en la Sesión 4 del plan).

## [2026-07-12] design | Propuesta-Recursos-de-Modelado RATIFICADA — Design Loop C8 CERRADO
El director ratificó (mismo día, sin cambios): los 5 recursos con su
orden (triplanar → loft/perfil → gradientes → banding MToon →
iteración), los 3 ajustes al plan de rework C6/M10 de la sesión
paralela, y el loft como mini-loop propio pre-C6b. Página →
`ratificado`; C8 → 🔄 (ejecución pendiente: ajustes 1–3 dentro del plan
de rework, sesiones 2/4/5). Quedan en §0a solo los VoBo que requieren
ojos del director sobre material (turnaround r5 + cowl; §7 del SCHEMA).
Cierre de sesión de la conversación de evaluación de plugins con esta
entrada (protocolo §7).

## [2026-07-12] design | Propuesta-Recursos-de-Modelado (Design Loop abierto) + reconciliación con el plan de rework paralelo
Boris pidió al "director técnico" los recursos para modelar mejor los
avatares → Design Loop abierto: [[Propuesta-Recursos-de-Modelado]]
(status propuesto, C8 en Task-Board). 5 recursos: triplanar (mata los
bugs de UV ya pagados), generador loft/perfil (generalizar
`_ribbon`/`_s_spine` a torso/miembros — mini-loop propio pre-C6b),
gradientes procedurales, banding tipo MToon en `toon_opaque`, e
iteración (vista-esqueleto + Beckett, ya agendados). Anti-objetivos:
Blender/Blockbench/artista externo/hardware. **Reconciliación entre
sesiones vía Vault:** se leyó el transcript de la sesión paralela
(plan "Rework gráfico Humano C6/M10 + spike Beckett", sesiones 0–5,
solo existía en esa conversación) — plan VALIDADO en secuencia; 3
ajustes registrados en la propuesta (Sesión 4 += gradientes+banding;
Sesión 5 → Decal VS triplanar; Sesión 2 nota del piloto de cinta
continua). El Vault es el punto de sincronización: la sesión paralela
hereda esto por Current-State §0a.

## [2026-07-11] lint | Benchmark de calidad godot-vrm reubicado fuera de concept/ canon
Boris había subido 3 PNG del avatar VRM "AliciaSolid" a `90-Raw/concept/`
con el criterio: cualquier output de mayor calidad que el nuestro es
referencia válida para iterar, aunque la técnica no encaje con el Art
Bible. Criterio sano, pero `concept/` es la carpeta de concept art CANON
aprobado — mezclar ahí capturas externas contaminaría compilaciones
futuras. Reubicadas a `90-Raw/research/quality-benchmarks/` (nueva
carpeta, index actualizado). Análisis honesto agregado al doc de
plugins: solo 1 de las 3 imágenes es render limpio comparable (las otras
son UI del editor / debug de física); el personaje es asset autorado a
mano (no algo que el plugin "genere") comparado contra nuestro procedural
en pleno rework — no es 1:1; y el estilo (anime/VTuber) es la
anti-referencia EXPLÍCITA del [[Art Bible]] (junto a Genshin). Se
extrajeron 3 lecciones sí transferibles a nuestro estilo: textura
pintada/degradada vs. color plano, curva de banding más suave
(comparable con MToon `_ShadeShift/_ShadeToony`, ya fichado), degradado
raíz→punta en pelo. Sin cambios de código.

## [2026-07-11] ingest | godot-vrm corregido: v2.5.7 (fork AzPepoze, Godot 4 nativo)
Tras el cierre de sesión, Boris re-bajó el zip correcto de godot-vrm
(`godot-vrm-v2.5.7.zip` — el original era la rama godot3 obsoleta,
descartada horas antes). Verificado: fork AzPepoze de V-Sekai, VRM
Importer 2.5.7 + MToon Shader 3.4.0, ambos declarados "for Godot 4.x";
`.gdshader` nativo + archivos `.uid` + `vrm_physics.gdextension`
(`compatibility_minimum "4.3"`) — compatible con 4.6.3. GDExtension CON
binarios Windows/Linux/**macOS** (mejora sobre el zip viejo, que no tenía
macOS). Soporta VRM 0.x y 1.0. Veredicto actualizado en
`90-Raw/research/Plugin-Evaluation-2026-07-11.md`: MToon (12 shaders,
shading real en `mtoon_common.gdshaderinc`) queda **minable** como
referencia de toon shading contra `toon_opaque` — su técnica de outline
(cull_front + casco invertido) se ignora, ya resuelta por Sobel en C6a. No
se adopta el addon completo (seguimos sin pipeline de avatares importados).
Sin cambios de código.

## [2026-07-11] state | Cierre de sesión: SCHEMA §7 (rutina de cierre consolidada) + higiene
Boris preguntó si la rutina de cierre estaba en el Vault: estaba REPARTIDA
(CLAUDE.md regla 4, regla de oro, SCHEMA §6, memoria persistente de Claude —
el paso commit/push no estaba escrito en el Vault). Consolidada como
**SCHEMA §7 "Cierre de sesión"** (checklist de 6 pasos; pendiente VoBo).
Higiene: op-tags de hoy corregidos a la taxonomía de §4 (research→ingest);
`.gitignore` ahora excluye sub-vaults `.obsidian` anidados (aparecieron en
10-Knowledge y 20-State/Decisiones — abrir subcarpetas como vault en Obsidian
los crea; el vault root es `Aether Bound/`); descartado un cambio EOL-only de
00-Index. Current-State: sección nueva 0a "decisiones que esperan al
director" (VoBo r5 + cowl, spike Beckett, VoBo §7). Lección de entorno
re-pagada en vivo: Get/Set-Content de PS 5.1 corrompió el UTF-8 del LOG
(restaurado de git; ediciones de texto SIEMPRE con herramientas del agente).

## [2026-07-11] ingest | Segunda ronda: 4 zips más + Beckett MCP (cierra la evaluación en 12 zips)
Boris sumó humanizer, skeleleton-2d, godot-vrm, AMSG y beckett-godot-mcp.
Veredicto integrado al mismo doc raw. Hallazgo mayor: **AMSG = referencia de
lógica para C2/C4** (detección de mantle por 3 raycasts + shapecast portable
a nuestra física analítica; PoseWarping = orientation/stride/slope warping y
taxonomía de estados para el pase de poses). Humanizer NO para cuerpos (choca
con C6) pero su tabla ROM (`physical_skeleton.gd`) y sus skeleton_config.json
sirven de cross-check articular en C6b — responde la intención del director
con el zip de esqueleto ("dónde van las articulaciones y sus DOF"), que
derivó en semilla: **vista-esqueleto de debug en el banco de anatomía**
(dibujar articulaciones + ROM que ya viven en rig_biomech.gd). El zip
skeleleton-2d es GPLv3 (solo mirar). godot-vrm resultó ser la RAMA GODOT 3
(inservible en 4.6.3; re-bajar master si se quiere MToon de referencia).
Beckett MCP (Lite 1.8.0, revisado por el orquestador): servidor MCP embebido
en el editor con observación del juego corriendo (screenshot/remote tree/
runtime props) — propuesto spike de 1 sesión cuando el banco corra limpio;
decisión del director. Sin cambios de código.

## [2026-07-11] ingest | Evaluación de 8 plugins + Chickensoft + cabello/facial
Boris entregó 8 zips en Downloads + 2 URLs. Inventario técnico por subagente
Sonnet (tiering de [[Lecciones]]); análisis contra Plan/Art Bible/Lecciones
por el orquestador. Veredicto archivado en
`90-Raw/research/Plugin-Evaluation-2026-07-11.md`: **Dialogue Manager 3.10.1
= único candidato de adopción completa** (entra con PRD-009, Fase 2 — cubre
el hueco real de diálogo/escenas); HTerrain y ProtonScatter = minas de
shaders para Fase 2/4 (low_poly faceteado, wind sway, splatmapping, perlin+
erosión GPU, grass bend, toon water); FancyControls/FACS = patrón de tween UI
para Fase 4 (aclarado: es UI, NO facial — el consejo externo que lo
recomendaba para caras confabuló); MTerrain referencia menor; Beehave
diferido post-slice; LimboAI descartado (fuente C++ sin binarios);
GodotSteam zip vacío (repo en Codeberg); Chickensoft descartado (C#-only).
Research cabello: no hay plugin que aplique; el ribbon del M10-r4 ES la
técnica canónica; SpringBoneSimulator3D no aplica (requiere Skeleton3D).
Semillas para modelado futuro: expresiones faciales por estado (Fase 3–4),
spike nodo `Decal` para rasgos (esquiva la costura UV), reglas de textura
facial (alpha-scissor, margen 8 mm, tinte blanco×albedo). Sin cambios de
código; ventana C6/C4 intacta.

## [2026-07-10] wip+blocked | M10-r3/r4: peinado "príncipe" (PRD ribbon) — banco colgado, cierre de sesión
Boris pidió melena estilo Príncipe de Cuento (ref. Shrek), tono castaño
original, "150 mechones". r3 (150 tablillas rectas al radio exterior, 2
familias: cortina + tejas de domo) completó pero falló en revisión visual:
orejeras tipo casco de frente + borde-repisa recto de nuca — mismo defecto que
`frontier_crop` ya había resuelto. Boris entregó un PRD técnico completo
("Cabello Estilizado Ondulado — Estilo Príncipe de Cuento"): construcción por
capas de mechones-CINTA (ribbon, ancho variable raíz→punta, curva en "S",
normal facetada por segmento — no cilindro ni tablón recto), 20–26 mechones en
4 capas (base craneal / flequillo-coronilla 6–8 / laterales sien-oreja 8–10 /
sueltos que rompen silueta 4–6). Este número (20–26) reemplaza el "150"
original — Boris lo confirmó como refinamiento válido. r4 implementa el PRD:
helpers nuevos `_ribbon`/`_s_spine` en `hair_library.gd` (cadena de cajas
ahusadas siguiendo una curva en S) + `_hair_prince_curtain` reescrito con 22
mechones en 4 capas. **BLOQUEADO al cierre:** `tmp_anatomy.gd` (windowed) y
`test_core.gd` (headless) se cuelgan o quedan extremadamente lentos en 3+
corridas limpias (proceso mata todo rastro previo confirmado, CPU real
consumida — no deadlock clásico de GDScript). Revisión estática de
`_ribbon`/`_s_spine` no encontró loops sin cota ni normalizaciones a NaN.
`hair=11` no es el default (`PhenotypeData.default_phenotype()` usa `hair=0`)
y ningún gate automatizado lo toca — CERO riesgo para test_core/
autotest_biomech/combat/slice existentes. Sospecha sin confirmar: contención
de recursos (Epic Games Launcher/EA Desktop/Xbox App corriendo en paralelo,
~9 GB RAM fuera de Godot) — consistente con la fragilidad térmica ya anotada
de la laptop RTX 2060. Código commiteado como WIP (no como ronda cerrada, no
mostrado a Boris como terminado). Aparte: se evaluó extender la reescritura
"ribbon" al estilo 5 (`_hair_curtain_long`, mismo defecto de tablones planos,
actualmente sin uso en el pipeline canónico) — Boris de acuerdo en NO tocarlo
ahora, queda anotado como deuda técnica sin urgencia.

## [2026-07-10] feature | M10-r2: 31 mechones angulares (pedido del director)
El director pidió ~25–35 mechones para acercar el pelo a la lámina. Sistema
procedural DETERMINISTA sobre la concha: 4 filas de latitud (cresta/corona/
parietales/nuca) × columnas, 31 mechones-cuña hundidos a media profundidad
(el Sobel entinta sus aristas como trazos direccionales de pelo; a distancia
se funden), tamaño en cascada frente→nuca, dos tonos alternados (base /
+10% claro = profundidad cel). Convergencia en 5 sub-rondas contra la
silueta: filas medias solo sector trasero >104° (los laterales asomaban como
rulos/dientes), cresta acotada a la corona, sink progresivo hacia los
costados, mechones delgados (0.11R). El PERFIL es la vista más cercana a la
lámina hasta ahora. Queda: 1 muesquita por sien en la silueta frontal (a
decisión del director: matarla o dejarla como textura). QA
biomech/combat/slice ALL_PASS. Ronda archivada en test_out/rounds/r6.

## [2026-07-10] feature | M9-r6: cráneo desnudo VoBo (a) + mandíbula TRAPECIO
El director pidió el turnaround CALVO para juzgar el cráneo desnudo — VoBo de
la estructura ("todo bien"; banco queda sin pelo mientras se esculpe la cara).
Tuning en vivo: la mandíbula pasa de caja a TRAPECIO (prisma de 4 caras con
taper, ancho en la línea de orejas → estrecha al mentón; el ×0.81 en z del
slider de jaw restaura la relación ancho/profundidad) — las facciones se
afilan. QA biomech/combat ALL_PASS. Nota del cráneo desnudo para el backlog de
cara: la bóveda sigue muy esférica de perfil (occipucio poco protagonista).


## [2026-07-10] ingest+feature | Review v0.5 archivada + M9-r5: quiff redondeado, marcas restauradas, limpieza
Quinta review (v0.5, overall 5.5 — el riesgo señalado: REGRESIONES al aplicar
fixes) → archivada. r5 responde los 4 bloqueantes: (1) quiff sin birrete —
masas redondeadas-angulares de esferas escaladas, curva superior ASIMÉTRICA
más alta al frente, cero caras planas (cae también la cuña M6 y baja el
hairline M7); (2) marcas restauradas al tamaño r3 como franjas rectas
(frente ≈ ceja, mejilla cruzando el PÓMULO — la primera posición leía curita
en la boca); (3) limpieza de rasgos: ojos conformados a la superficie
(esclerótica −4 mm, más plana) y cejas pegadas (flotaban 10 mm — eso era lo
"atravesado" visto desde atrás); (4) orejas a la vertical MEDIA del cráneo
(leían piercing) — asoman flanqueando en la trasera ✓. PROCESO nuevo por
exigencia del reviewer: capturas archivadas POR RONDA en
`godot/test_out/rounds/rN/` para diff visual anti-regresiones. Turnaround
verificado contra r4 en los 4 ángulos. QA biomech/combat/slice ALL_PASS.
Pendiente: ratificación EXPLÍCITA del director del cowl/base-body (3ª
documentación en PR) — con ella y el VoBo, la próxima ronda aspira a
Approved with Minor Changes.

## [2026-07-10] ingest+feature | Review v0.4 archivada + M9-r4: la nuca del jugador
Cuarta review (v0.4, overall 6/10, 5 bloqueantes) → archivada. r4 responde:
(1) PELO reconstruido — el hallazgo técnico de la ronda: las cajas no pueden
abrazar una esfera (tablones r4a, occipucio enterrado r4b); la solución es una
CONCHA elipsoide ajustada que se auto-recorta contra el cráneo (emerge ~7 mm
en parietales/coronilla/occipucio, se hunde a la altura de orejas y nuca baja
→ hairline que SUBE sola en las sienes, fade natural, cero borde-repisa) +
quiff/cresta de cajas hundidas como acentos angulares. La nuca — el ángulo del
jugador — ya lee corte corto con fade, no casco. (2) Orejas visibles en perfil
y espalda ✓. (3) Cuello −30% (0.10, base 0.075; HEAD_Y baja con él) —
bloqueante promovido CERRADO. (4) Cowl: documentado por 3ª vez (base-body
modular; pendiente ratificación del director en su respuesta). (5) El plano
flotante era la cresta/quiff de la construcción anterior — eliminado con la
reconstrucción (quedan 2 esquinitas del quiff en la silueta superior,
anotadas). (M6) Ambas marcas como GEOMETRÍA recta (el _slash del atlas
escalonaba la mejilla en gusano); patrón 6 del atlas intencionalmente vacío.
QA: biomech/combat/slice ALL_PASS. Turnaround completo regenerado.

## [2026-07-10] feature | M9-r3 CERRADO: quiff, marcas bilaterales, cráneo compacto — QA verde
Continuación tras la caída del clasificador: bench corrido y convergido en
varias sub-rondas. (1) Quiff angular contenido (la 1ª pasada leía sombrero de
plato; la visera frontal ocultaba la marca → levantada) sobre el casquete
probado del library (r3b dejaba la coronilla calva en perfil). (2) Marcas
BILATERALES en lados opuestos como el concept: mejilla izquierda por atlas +
frente derecha por GEOMETRÍA (dos bugs de entierro cazados: anillo del bíceps
menor que el radio efectivo escalado ×1.12 de _apply_build; placa de frente al
ras de la elipse = astilla de 1 mm que la tinta Sobel se comía — ambos a
Lecciones). (3) Cráneo compacto + mandíbula dominante (trapecio invertido),
nariz-prisma de 4 lados, orejas semi-elípticas, cuello 0.13 base ancha, boca
+15%. (4) Gate biomech FLAKY arreglado de raíz: el assert adversarial re-fuerza
la violación 6 frames (hitch de boot saturaba el settle y borraba la violación
antes del clamp; 2/3 fallos → 4/4 verde). Turnaround de cabeza en el banco
(frente/¾/perfil/espalda). QA: biomech ×4 + combat/slice/ui + core ALL_PASS.

## [2026-07-10] ingest+feature | Review v0.3 archivada + M9-r3: quiff, trapecio invertido, marcas bilaterales
Tercera review del director (v0.3, overall 5.5/10; cierres verificados: pelo
castaño, ojos on-model "no tocar más", piel, prop) → archivada en
`90-Raw/reviews/`. r3 en código: quiff ANGULAR de cajas (fuera el moño — la
esfera superior leía top knot), cráneo compacto 0.82 x (fuera el ovoide;
mandíbula 0.138 domina el ancho bajo = trapecio invertido), pómulos como
quiebre (no globo lateral), marcas BILATERALES con lateralidad corregida por
la review (frente = lado derecho x-chico; mejilla = izquierdo espejo W-1-x;
franjas 4:1), nariz = prisma sesgado de 4 lados con arista al frente (fuera
el bloque), orejas semi-elípticas verticales con inclinación (fuera el
disco), cuello 0.13 con base 0.068 al trapecio, boca +15%. Vestuario:
base-body modular DOCUMENTADO (2ª vez — la review lo da por cerrado si está
en el PR). Banco: turnaround de cabeza (frente/¾/perfil/espalda) obligatorio
desde ahora. Bench+QA pendientes de correr (clasificador de shell caído
momentáneamente); se verifican antes del cierre.

## [2026-07-10] ingest+feature | Review v0.2 archivada + M9-r2/M10: cabeza del concept
Segunda review estructurada del director (Head/Bust v0.2, fidelidad 4/10) →
archivada en `90-Raw/reviews/`. Respuesta en código: pelo nuevo `frontier_crop`
castaño claro (fuera cuña/rizo; hack del hair_slot revertido — Dagna recupera
sus trenzas), warpaint 6 "Scout Marks" + banda de pintura en el bíceps,
mandíbula ancha/amable + boca con sonrisa franca + ojos entrecerrados (fuera
caricatura) + cejas rectas, cuello 0.15 grueso (convergencia v0.1/v0.2),
orejas a banda ceja-nariz. Hallazgos de pipeline: la cara del atlas vive en la
costura u=0; jaw/cheeks embarraban la pintura (atlas ahora solo en cráneo);
dump `warpaint_atlas.png` en el banco. Vestuario = base-body modular
DOCUMENTADO (sistema signature; ropa Fase 4 por decisión previa del director).
TODO puntual: diagonal de FRENTE oculta bajo hairline (debug UV con retícula).
QA completo ALL_PASS.

## [2026-07-10] feature | M9-r1: la cara gana personalidad (review MEDIUM 9)
Primera ronda de M9 (manos cerradas, "listo, vamos con M9"): mandíbula marcada
+ mentón presente, nariz más fina y larga, MEJILLAS ALTAS (pómulos bajo el ojo;
rango del slider `cheek` subido), SONRISA ligera (boca de 3 segmentos de tinta,
comisuras arriba — el primer intento salió ceño por signo invertido), cejas
finas café cálido (las losas negras leían enojo), iris café legible en el banco
(el accent papel lo dejaba blanco-sobre-blanco) y **orejas por defecto** en el
origin neutro (un humano base tiene orejas; los origins las reemplazan).
Capturas nuevas del banco: anatomy_face.png + anatomy_face_34.png. Pendiente de
la ronda 2 con el ojo del director: peinado real (M10), forma frontal de la
nariz. QA biomech/combat/slice ALL_PASS.

## [2026-07-10] feature | C6a-r5e: dedos 10% más delgados
Tuning del director tras aprobar la tenar ("listo"): los cuatro dedos (no el
pulgar) 10% más delgados en sección (0.0108×0.038) — las ranuras crecen y la
tinta Sobel de las separaciones respira mejor. QA biomech/combat ALL_PASS.

## [2026-07-10] feature | C6a-r5d: el pulgar nace de la tenar (ref. anatómica)
El director pasó referencia anatómica (Cleveland Clinic, vista palmar): el
pulgar nace de la eminencia tenar a media palma, no del borde inferior.
Nacimiento 50% más adentro de la mano; conserva dirección de dedos + 30°.
QA biomech/combat ALL_PASS.

## [2026-07-10] feature | C6a-r5c: dedos +20% + pulgar alineado a 30°
Tuning en vivo del director sobre r5b ("funciona mejor"): los cuatro dedos
+20% de largo (medio 0.076) y el pulgar deja de cruzar horizontal — apunta en
la MISMA dirección que los dedos (cuelga) con 30° de apertura hacia el
interior. QA biomech/combat ALL_PASS.

## [2026-07-10] feature | C6a-r5b: cuatro dedos reales (la garra se tumbó)
Segunda ronda del director sobre las manos: "hay tres masas — pulgar más dos"
(la v1 de dos bloques leía como garra). Ahora: palma + CUATRO dedos delgados
individuales con ranuras de 3 mm entintadas por el Sobel y largos naturales
(medio el más largo) + pulgar. A distancia se funden en una masa. QA
biomech/combat/slice ALL_PASS.

## [2026-07-10] feature | C6a-r5: manos con dedos estilizados
Feedback del director: las manos no tenían dedos. Solución BotW/Palia: palma +
dos masas de dedos con ranura (el Sobel entinta la separación — de cerca se ve,
a distancia muda) + pulgar aparte hacia el cuerpo + curl progresivo. El nodo
`hand` sigue siendo la palma (arma/prótesis intactos). Captura nueva
`anatomy_hands.png`. QA biomech/combat/slice ALL_PASS.

## [2026-07-10] ingest+feature | Review v0.1 del director archivada + C6a-r4
El director entregó la **Character Blockout Review v0.1** (Needs Revision,
~60–65% fidelidad; norte: BotW/Hinterberg/Palia/Torchlight, NO anime) →
archivada verbatim en `90-Raw/reviews/` como fuente raw y checklist de C6.
r4 implementa CRITICAL 1–4 (silueta atlética +12% hombros, cabeza menor — el
culpable visual era el pelo-bloque —, cuello largo, brazos con masa), HIGH 5–8
(gemelo, manos, pies, planos de torso al ras del cel) y LOW 13–15 (A-pose,
codo relajado, deltoide fundido). Pendientes: cara (M9, con el director),
peinados (M10), ropa/accesorios (M11–12, diferidos). QA completo ALL_PASS.

## [2026-07-10] state | Cierre de sesión — ventana C6/C4: C6a+C6c hechos
Sesión cerrada con la ventana C6/C4 a medio camino y checkpoint completo: C6a
(r1 proporciones 7.5 + Sobel-only, r2 volúmenes cónicos, r3 hombros caídos) y
C6c (cabeza sin chibi) en código, QA verde (9 suites + biomech ×5), 3 commits
pusheados en `feat/c6-anatomy-rework` (def9a27, bc22a4d, c58a784). Pendiente al
reabrir: VoBo del director de las capturas r3 → C6b (enano/elfo + ROM + Dagna
re-montada) → C4a/C4b → playtest de la ventana. Detalle en [[Current-State]].

## [2026-07-10] feature | C6a-r3 + C6c: hombros caídos + la cabeza deja el chibi
El director pasó la comparación lado a lado contra `fenotipo-humano-v1`. Respuesta:
trapecios con masa (sloped shoulders, fuera la repisa), silueta más enjuta
(SHOULDER_X/CHEST_X/Z abajo), y C6c adelantado — cráneo con forma, mandíbula
estrecha + mentón, NARIZ (el perfil existe), ojos a escala humana, ceja baja.
7.49 cabezas medidas (canon 7.5). Fix de gate flaky: elbow release −0.085→−0.082
(margen 0.0003 rad → real; lección ampliada). QA completo ALL_PASS (biomech ×5).

## [2026-07-10] feature | C6a-r2: volúmenes de lámina (feedback del director)
Feedback en vivo sobre las capturas de C6a: "que los cuerpos dejen de componerse de
puros círculos". Los volúmenes pasan a masas cónicas (`CylinderMesh` con taper):
tronco pecho→cintura continuo con hombros cuadrados, brazos deltoide→muñeca fina,
manos de mitón (caja), muslo→rodilla y pantorrilla→tobillo, botas con puntera,
cuello desde el trapecio. Esferas solo en articulaciones + cráneo (C6c). Pauldron
re-asentado. Medidas estables (7.58 cabezas); QA visual completo ALL_PASS.

## [2026-07-10] feature | Ventana C6/C4 abierta — C6a: humano 7.5 cabezas bajo Sobel
Ventana C6/C4 arrancada (branch `feat/c6-anatomy-rework`). Decisiones del director:
pies IK diferidos; **el rework se maneja únicamente en estilo Sobel** (la regla de
Línea del [[Art Bible]] pasa a ser LA línea del rig — sin casco invertido). C6a en
código: shader `toon_opaque` nuevo (toon sin ALPHA — post-safe, con textura y
emission), tabla PROPORTIONS canónica en `character_rig.gd` (7.57 cabezas medidas
vs 6.38 del puerto anime; hombros 2.39 cabezas; deltoides sin hueco lego; cuello
real; cabeza = pivote ×0.84), fix del fallthrough ironblooded en
`_build_origin_features`, banco `tests/tmp_anatomy.gd` (medidas + regla de cabezas
+ capturas 3 distancias bajo el post — regla Sobel verificada en escena). QA: 9
suites ALL_PASS (core/combat/locomotion/ads + biomech/combat/slice/ui/springboard).
Pendiente: VoBo del director; Dagna se re-monta en C6b.

## [2026-07-09] playtest | Gate 1 APROBADO — 🏁 FASE 1 CERRADA
Re-verificación del director tras el fix del corte del salto: **"se siente
perfecto"**. El arco del Springboard completa limpio hasta la cornisa. Playtest Loop
del Gate 1 CERRADO. **Fase 1 del [[Plan-de-Produccion]] CERRADA:** en el greybox se
pelea junto a Dagna y se usa el Seismic Springboard T1 sobre su onda para alcanzar
una cornisa imposible, ≥60 FPS. PRD-006 (combate mínimo) + PRD-007 (Dagna aliada +
Springboard T1) completos en código Y validados en playtest. La cláusula de escape
C6 NO se disparó (los cuerpos corruptos no impidieron juzgar el feel). **Siguiente:
la ventana C6 (rework anatómico del cuerpo base) + pase de poses C4, RATIFICADA entre
el Gate 1 y la Fase 2; luego la Fase 2.**

## [2026-07-09] feature | Gate 1 — fix del corte del salto (feedback del director)
Boris probó el Gate 1: **"se siente bien pero al llegar a la altura de la cornisa,
como que se cortó el salto"** (lo dio por posible bug gráfico). Diagnóstico: NO era
gráfico. Como la Y del jugador es analítica, al ENTRAR al footprint de la meseta
**subiendo** (pies por debajo de la tapa 3.5 m), el aterrizaje lo clavaba ahí y
mataba `vel_y` → el impulso restante se perdía. Fix en dos partes:
1. **Aterrizaje descend-only** (`player_controller`): el suelo solo ATRAPA con
   `vel_y ≤ 0`. Así el arco del Springboard completa hasta el ápice y aterriza
   cayendo. En llano no cambia nada (nunca se sube hacia el suelo).
2. **Muro del cliff más firme** (`LEDGE_STEP_MAX` 0.5→0.15): solo entras a la meseta
   con los pies casi a la altura de la tapa (i.e., desde arriba), sin "trepar
   raspando" la cara subiendo.
Gate ampliado con **F2** (regresión permanente): lanzarse pegado al cliff debe
llegar a la altura plena — pico **5.99** (antes del fix ~3.3, el corte). QA:
autotest_springboard + test_core/test_locomotion + autotest_combat/slice/ui +
tmp_springboard/tmp_springboard_directed ALL_PASS. Merge a master estilo PR.
**Pendiente: re-verificación del director → CIERRA la Fase 1.**

## [2026-07-09] feature | PRD-007 alcance 4 — Gate 1 (código): cornisa vía Springboard
Feature Loop. Cierra la construcción de la **Fase 1** (falta solo el playtest del
director). Tres piezas:
1. **La cornisa** — `scenes/combat_arena.gd` crece una meseta elevada (`LEDGE_H`
   3.5 m; footprint x∈[-5,5] z∈[-8,2]) con faro teal = OBJETIVO, delante del
   spawn y separada del arco de enemigos (z=4). Como la Y del jugador es analítica
   (`get_height`), la cornisa es un footprint que devuelve `LEDGE_H`. Solo
   alcanzable vía Springboard: salto normal medido **0.82 m** no llega; lanzamiento
   **6.01 m** sí.
2. **Cliff real (no trepable a pie)** — step-block en `player_controller.update()`:
   una celda elevada a la que NO llegaste desde arriba (subida > `LEDGE_STEP_MAX`
   0.5 m respecto a la Y de inicio de frame) es un MURO → revierte el paso
   horizontal. Aterrizar desde el Springboard (descendiendo) sí entra. Gateado por
   `scene.has_method("is_cliff_wall")` → **cero efecto en The Wilds ni otras
   escenas**. Tuning de feel: el punto de lanzamiento del gate se alejó del borde
   (pista) para que el arco cruce el labio por encima en vez de raspar la cara.
3. **Gate permanente** — `tests/autotest_springboard.gd` ALL_PASS (A–H): boot→ARENA
   con aliada, Bond→pound→onda (código real), no-trepa-a-pie, salto normal <cornisa,
   Springboard-en-ventana → **cornisa alcanzada** (aterriza a y=3.50, pico 6.01, en
   plena meseta z=-2.8), Dagna pelea sin caer (HP 120→111, piso de vida), FPS 578
   (piso catastrófico; el ≥60 se lee frío). Captura `springboard_gate.png`.
QA: test_core + autotest_combat + tmp_springboard + tmp_springboard_directed +
autotest_slice + autotest_ui ALL_PASS. **FPS del greybox ≥60 con margen enorme**
(577–583 en autotest; +3 mallas estáticas sobre el greybox de 177 fps frío del
alcance 5). Merge a master estilo PR. **Pendiente: playtest del director del feel
→ CIERRA la Fase 1** (cláusula de escape C6 si los cuerpos impiden juzgar).

## [2026-07-09] lint | Cierre de sesión — vault consistente tras PRD-007 2b + 3
Lint Loop pedido por el director al cierre. Reporte de las 5 fases:
1. **Contradicciones Knowledge↔código:** ninguna. El cambio de control del 2b
   (RMB→apuntar, guardia→`XBUTTON1`) no aparece en ninguna página Knowledge —
   correcto: los bindings son detalle de implementación, no canon. El "único
   botón de vínculo = R" sigue coherente (RMB es solo contexto de apuntado, ya
   reconciliado en el PRD-007 §Canon).
2. **Wikilinks:** cero colgantes reales. Falsos positivos descartados: links que
   envuelven salto de línea, `[[wikilink]]`/`[[wikilinks]]` (ejemplos del SCHEMA/
   Lint Loop) y `[[PRD-007 …]]` (menciones EN BACKTICKS de un lint histórico +
   caché de UI de Obsidian, no links vivos). 2 "huérfanas" (LLM-WIKI, VDD) son
   fuentes 90-Raw referenciadas por ruta — legítimo.
3. **Status:** cero páginas `propuesto` pendientes de ratificar.
4. **Index vs. realidad:** 27 Knowledge + 8 State + 5 Loops — todas en [[00-Index]]
   y viceversa. Fix menor: la línea del PRD-007 en el Index ahora refleja progreso
   (alcances 0–3+2b ✅), alineada con el estilo de la del PRD-006.
5. **State vs. repo:** [[Current-State]] refleja el branch real (`master`, todo
   pusheado; los alcances 2b y 3 mergeados + playtest aprobado). Árbol limpio salvo
   `.obsidian/graph.json` (estado de UI), commiteado en este cierre.
Vault consistente. Sin reparaciones pendientes.

## [2026-07-09] playtest | PRD-007 alcance 3 — Dagna IA de combate APROBADA
Playtest del director en `Start-Playtest-Greybox.bat`. Veredicto: **"funciona
bien"** — Dagna pelea a tu lado (onda con daño + pound autónomo + muralla-block +
aggro por cercanía) sin robarte tu pelea. **Sin cambios de tuning:** `POUND_DAMAGE`
30, `AI_POUND_CD` 7 s, `POUND_SENSE` 3.8, `GUARD_BLOCK_RANGE` 2.6 quedan como
están. Playtest Loop del alcance 3 CERRADO. **Con esto la mecánica de Dagna aliada
está completa; falta solo el alcance 4 = Gate 1** (cornisa vía Springboard +
`autotest_springboard` + ≥60 FPS frío) para cerrar la Fase 1.

## [2026-07-09] feature | PRD-007 alcance 3 — Dagna IA de combate mínima (código)
Feature Loop. Dagna ya **pelea a tu lado** (mínima pero real, sin companion AI
rica). Tres piezas: (1) **la onda HACE DAÑO** —`_on_springboard_wave` aplica
`POUND_DAMAGE` 30 con falloff a los enemigos, además del knockback; cierra el TODO
"la onda ES un ataque" de los alcances 1–2 y aplica a los 3 disparos (Bond /
dirigido / autónomo); salta enemigos `dying` (Lección). (2) **Pound AUTÓNOMO en
contexto** —`ally_dagna._update_combat_ai()`: con ≥1 enemigo dentro de `POUND_SENSE`
3.8 y cooldown `AI_POUND_CD` 7 s libre, Dagna golpea sola. (3) **Muralla-block +
defensa propia** — sube `rig.set_guard`+`guard.start_block` cuando un enemigo entra
en `GUARD_BLOCK_RANGE` 2.6; `receive_hit()` (guard.receive → flinch/bloqueo +
knockback) pero **NUNCA cae** (piso `HEALTH_FLOOR`; decisión del director: su
pérdida es coda del slice). **Aggro por CERCANÍA** (decisión del director:
nearest, no tanque): `game_director._nearest_target()` + `enemy_humanoid`
`combat_target`/`set_combat_target` → cada enemigo persigue/golpea al más cercano
entre jugador y Dagna (Dagna atrae golpes cuando se mete). Archivos:
`ally_dagna.gd`, `game_director.gd`, `enemy_humanoid.gd`. QA: `tmp_dagna_combat.gd`
nuevo ALL_PASS (nearest ambos sentidos, retarget del enemigo, pound autónomo →
onda + daño 40→24 HP, muralla arriba/abajo, bloqueo reduce daño, martilleo sin
caer) + captura `dagna_combat.png`; regresión tmp_springboard / tmp_springboard_
directed (aislado del pound autónomo) / autotest_combat / test_core / slice / ui
ALL_PASS. **Pendiente: playtest del director.**

## [2026-07-09] playtest | PRD-007 alcance 2b — Springboard DIRIGIDO APROBADO
Playtest del director en `Start-Playtest-Greybox.bat`. Veredicto: **"ambos se
sienten muy bien, nada que ajustar"** — los dos modos (reactivo `R` solo +
dirigido `RMB` apunta / `R` ordena) validados a nivel feel. El esquema de control
nuevo confirmado en vivo (RMB apunta, guardia/parry en el botón lateral trasero
`XBUTTON1`, SPACE salto). **Sin cambios de tuning:** rango 11 m, cooldown 4.5 s,
empuje 3 m/s y altura quedan como están. Playtest Loop del 2b CERRADO. Siguiente:
alcance 3 (IA de combate mínima de Dagna) → alcance 4 = Gate 1.

## [2026-07-09] feature | PRD-007 alcance 2b — Seismic Springboard DIRIGIDO (código)
Feature Loop sobre el spec RATIFICADO (Extensión del [[PRD-007 Dagna aliada +
Seismic Springboard T1]]). Añade **colocación** sobre el springboard reactivo del
alcance 2: `RMB` (mantener) apunta un punto en el suelo (raycast cámara→suelo con
`cam.project_ray_*` + decal teal clampeado a `DESIGNATE_RANGE` 11 m); `R` con el
apuntado activo ordena a Dagna **viajar** al punto (deja su slot de guardia — costo
táctico) y golpear ahí; el lanzamiento desde esa onda comandada suma un **empuje
horizontal** hacia el punto (`SPRINGBOARD_DIRECT_PUSH` 3 m/s) sobre el `_air_vel`
del alcance 2. Cooldown de orden 4.5 s. Los dos modos conviven (`R` solo =
reactivo, intacto). **Decisión de control del director:** RMB pasó a apuntar y la
**guardia/parry se mudó al botón lateral trasero del mouse (`XBUTTON1`)**; SPACE
sigue siendo salto. Archivos: `player_controller.gd` (apuntado + clamp + decal +
empuje del arco), `game_director.gd` (router R + cooldown + marca `directed` de la
onda), `ally_dagna.gd` (estado `traveling` + `travel_and_pound`). QA:
`tmp_springboard_directed.gd` nuevo ALL_PASS (clamp al borde 11.0 m, onda en el
punto err 0.45 m, Dagna viaja 5.9 m, arco dirigido 8.91 m vs 4.67 m plano =
+4.24 m, cooldown activo/decae) + captura `springboard_directed.png`; regresión
`tmp_springboard` (6.00/0.82/4.67 m intactos), `autotest_combat` (FPS 938),
`test_core`, `autotest_slice`, `autotest_ui` ALL_PASS. **Pendiente: playtest del
director** (rango/cooldown/empuje/altura a tunear; verificar el mapeo físico
XBUTTON1 = botón trasero, swappable a XBUTTON2 si sale invertido).

## [2026-07-09] design | Metodología del pase visual — playtests por capa con gate secuencial (RATIFICADA)
Nace de una verificación del director (lámina NotebookLM de las 4 capas vs.
vault). **Hallazgo de la verificación:** el pipeline de 4 capas es canon
([[Art Bible]] §Pipeline técnico) y está IMPLEMENTADO y parametrizado por capa
en `melancolia_post.gdshader` (probado en la golden scene B11) — pero solo lo
usa `golden_scene.gd`; The Wilds jugable sigue en el toon viejo, y su
aplicación (Plan §Fase 4) no tenía metodología ni PRD. **Ratificado por el
director:** playtests por capa ACUMULATIVOS en The Wilds (L1 → L1+2 → L1+2+3 →
full, toggles en vivo — precedente tecla T del A/B de animación) con **gate
secuencial estricto: cada capa se LIBERA con VoBo del director ANTES de apilar
la siguiente**; cada VoBo debe acercar al comicbook look de los keyframes
canónicos (la escena persigue la imagen) + costo de FPS medido por capa
(presupuesto térmico RTX 2060). Costo real identificado para el futuro PRD:
migración de materiales de The Wilds a variantes opacas (toon escribe ALPHA →
invisible al post, [[Lecciones]]). Registrado en [[Plan-de-Produccion]] §Fase 4.
**Solo nota metodológica — sin construcción** (el PRD del pase visual nace en
Fase 4 con estos gates como su QA).

## [2026-07-09] lint | Salud del vault — consistente (fix de wikilink histórico)
Lint Loop de cierre de sesión (tras alcance 2 construido + playtest aprobado +
2b ratificado). **Reporte, 5 fases:** (1) **Contradicciones:** ninguna — el
alcance 2/2b es coherente con [[Dagna]] / [[Los 9 Links del Pivote]] / [[Game
Feel Bible]]; el punto de canon RMB+R vs. "único botón de vínculo"
([[Bond y el Bond Vacío]]) quedó pre-resuelto en el PRD §Extensión (RMB =
contexto de apuntado, R sigue siendo el botón del Bond). (2) **Wikilinks:** 3
flags, todos benignos — `[[wikilink]]`/`[[wikilinks]]` son ejemplos del SCHEMA
(no links reales); **`[[PRD-007 …]]` de un lint previo (línea 76) sí apuntaba al
archivo intruso borrado esta sesión → de-linkificado** (fix menor, historia
intacta). Sin huérfanas (solo LLM-WIKI/VDD raw, por archivo). (3) **Status:**
cero páginas `propuesto`/pendientes — `Briefs de Concept Art` ya `ratificada`;
PRD-007 `ratificado` + §Extensión 2b `RATIFICADO`. (4) **Index vs realidad:** 43
páginas, todas catalogadas (27 Knowledge + 8 State + 5 Loops + SCHEMA/LOG); sin
fantasmas. (5) **State vs repo:** `Current-State` actualizado — alcance 2
aprobado en playtest, 2b como siguiente a construir; branch line al día, se pushea
en este cierre. **Vault consistente.**

## [2026-07-09] design | PRD-007 extensión alcance 2b — Springboard DIRIGIDO (RATIFICADA)
Nace del playtest del alcance 2: el director aprobó el feel base y propuso
**colocar** la onda (hoy nace pegada al slot de Dagna a tu hombro — no se puede
poner adelante para arcar hacia una cornisa). Design Loop cerrado; el director
ratificó las **3 decisiones**: (1) **dos modos** — *reactivo* (`R`, el alcance 2
actual, intacto) + *dirigido* (`RMB` apunta con decal teal clampeado a rango → `R`
ordena → Dagna **viaja** al punto → pound ahí → esprintas y arcas); (2) **arco
emergente** del momentum (`_air_vel`) **+ pequeño empuje hacia el punto** (cero
física nueva); (3) **extensión del PRD-007** (alcance 2b), no tuning. Reglas de
arranque a tunear en playtest: rango de orden ~10–12 m, viaje a `MOVE_SPEED_MAX`
(~2 s, **Dagna deja su slot de guardia** = costo táctico → alcance 3), cooldown
~4–5 s, ventana de onda 0.6 s, estados `follow→traveling→pounding→cooldown`.
Canon resuelto: **RMB+R preserva "R = el botón del vínculo"** (RMB = contexto de
apuntado, gramática del ADS — no un segundo botón de Bond). Anti-objetivos: sin
pathfinding rico (línea + ground-snap), sin ondas múltiples, el modo reactivo no
cambia. Único código nuevo: apuntado (raycast + decal) + máquina de estados de la
orden; todo lo demás reusa el alcance 2 + la locomoción de `ally_dagna.gd`. Spec
en [[PRD-007 Dagna aliada + Seismic Springboard T1]] §Extensión. **Registrado,
NO construido** (pedido del director). Siguiente al construir: los 5 sub-pasos del
orden de construcción 2b.

## [2026-07-09] feature | PRD-007 alcance 2 — Seismic Springboard T1 (Bond=`R` + salto-en-onda → lanzamiento)
Cierra la mecánica central del PRD-007. **Input Bond = `R`** (`game_director`:
`_check_key_r()` + `request_bond_pound()`) pide el ground-pound a Dagna en el
estado ARENA; la onda ya se registra sola (alcance 1). El controlador comparte
`springboard_waves` por referencia (mismo patrón que `enemies`). **Lanzamiento**
(`player_controller._wave_at()` en el bloque de salto vertical): un salto DENTRO
de una onda activa no usa el `jump_force` normal (8.4 → ~0.8 m con el warrior
ironblooded pesado) sino `SPRINGBOARD_LAUNCH_VEL 17.0` → **~6.0 m** (7.3× el
salto normal, altura "imposible" para cornisas). **Air control por la ley de leap
del PRD-005:** el lanzamiento SIEMBRA `_air_vel` con el momentum horizontal actual
y activa `_leaping`, de modo que el path aéreo del leap conserva y DIRIGE la
inercia (llegas corriendo → cargas y diriges; saltas parado → subes recto). **Feel
(GFB):** fachada nueva `Feel.springboard_launch()` = freeze pesado (pop de la
curva de subida) + trauma; VFX de estela teal ascendente; **tell de HUD**
(`hud.set_springboard_ready()` = cue "SALTA" teal que pulsa mientras pisas la onda
con ventana abierta, refuerza los anillos diegéticos). Sonda
`tests/tmp_springboard.gd` ALL_PASS: Bond→pound→onda, altura con onda 6.00 m vs.
sin onda 0.82 m (7.3×), air control 4.67 m de desplazamiento dirigible, captura
`springboard_launch.png` (jugador en el aire, suelo curvado abajo). QA regresión:
test_core + autotest_combat ALL_PASS. **Pendiente: playtest del director (feel) —
"afinamos con playtest"** (números de altura/tecla/ventana a tunear en vivo).
Siguiente: alcance 3 (IA de combate mínima de Dagna) y alcance 4 (Gate 1: cornisa
solo alcanzable vía Springboard + `autotest_springboard` + ≥60 FPS frío).

## [2026-07-08] feature | PRD-007 alcance 1 — ground-pound de Dagna → zona de onda + VFX teal
Donde nace la mecánica del Springboard. `ally_dagna.gd`: `ground_pound()` =
secuencia plant→slam→recover; en el impacto (tras windup ~0.35 s) spawnea el
VFX (burst teal + 2 anillos de choque expandiéndose por el suelo, per la
lámina `Seismic Springboard.png`) y emite `springboard:wave`. El director
registra la zona de onda en `springboard_waves` ({pos, radio 4.2, ventana
0.6 s} — la consume el jugador en el alcance 2) y **empuja a los enemigos
cercanos** (la onda ES un ataque; knockback por `push_pull`, sin daño aún —
eso llega con la IA del alcance 3). Los triggers del pound (Bond alcance 2,
IA alcance 3) se enchufan después; aquí lo dispara la sonda. `tests/
tmp_pound.gd`: onda registrada + knockback (heavy 1.6 m) + expiración +
captura `pound_wave.png` (los anillos teal leen igual que la lámina). QA:
test_core/combat/slice/ui + tmp_ally (regresión follow) ALL_PASS. Siguiente:
alcance 2 (Springboard T1: Bond=`R` + salto-en-onda → lanzamiento vertical).

## [2026-07-08] design | [[Briefs de Concept Art]] RATIFICADA
El director ratifica la biblioteca de prompts: sus outputs (fenotipos,
keyframes dawn/dusk, trilogía Speck, foliage_clump, Dagna v1) ya son canon
en `90-Raw/concept/`, y sus fuentes ([[Fenotipos y Creación de Personaje]],
[[Art Bible]]) están ratificadas. Era el único `propuesto` que quedaba en el
vault. Página VIVA: los briefs de los 8 pivotes restantes se añaden sin
desratificar lo probado (mismo patrón que [[Benchmark Biomecánico]]). Index
actualizado. Vault ahora 100% sin status pendientes.

## [2026-07-08] lint | Salud del vault — consistente (fix de branch line)
Lint Loop tras PRD-007 (ratificación + alcance 0) y el depósito de concept
art. **Reporte:** (1) sin contradicciones — PRD-007 coherente con Dagna /
Los 9 Links / Slice of Bond. (2) Wikilinks: sin rotos reales (solo los
`[[wikilink]]` de ejemplo del SCHEMA); el intruso `PRD-007 …` resuelve; sin huérfanas
(solo LLM-WIKI/VDD, fuentes raw por archivo). (3) Status: `Briefs de Concept
Art` sigue `propuesto` (único abierto, decisión del director); PRD-007
`ratificado` ✅. (4) Index: 45 páginas, PRD-007 catalogado. (5) State vs
repo: **fix** — la línea "Branch actual" seguía en "Capas 1–3" (después
vinieron concept art + PRD-007 + alcance 0) y le faltaba la sonda `ally`;
actualizada. Vault consistente.

## [2026-07-08] feature | PRD-007 alcance 0 — Dagna aliada spawnea y sigue
Primer alcance del PRD-007. `gameplay/ally_dagna.gd`: Dagna montada por el
pipeline de personajes (`apply_to_rig("dagna")`) sobre los 4 componentes
canónicos (kit Vanguard neutro por ahora), SIGUE un slot al hombro izquierdo
del jugador (la cámara vive en el derecho — lección nueva), con ground-snap
y gait procedural. Boot flag `--ally=dagna`: spawn en ARENA, array `allies`
separado de `enemies`, update en `_gameplay_update`. Sonda `tests/tmp_ally.gd`
(spawn + follow: 22 m recorridos, dist acotada ~2.6 m + captura
`ally_dagna_follow.png` — Dagna legible). QA: test_core/combat/slice/ui
ALL_PASS (el código de aliada solo se activa con el flag). Sin combate aún.
Siguiente: alcance 1 (ground-pound → zona de onda PushPull + VFX teal).

## [2026-07-08] design | PRD-007 RATIFICADO — Dagna aliada + Seismic Springboard T1
Design Loop del siguiente hito (rumbo al Gate 1). Nuevo spec
[[PRD-007 Dagna aliada + Seismic Springboard T1]] (`20-State/PRDs/`).
**2 ejes decididos por el director:** (1) Springboard T1 = onda + salto en
ventana (co-op de timing; input único Bond; reusa PushPullComponent +
supersalto/leap del PRD-005) — el golpe de suelo de Dagna spawnea una zona
de onda temporal, y saltar dentro de la ventana amplifica el salto a un
lanzamiento vertical; (2) Dagna aliada = mínima pero real (sigue + ground-
pound + muralla + defensa básica, sobre los 4 componentes vía config
`dagna`, sin companion AI rica). **4 detalles ratificados:** Bond=`R`; tell
de ventana = anillos de la onda + pulso de HUD; spawn = flag `--ally=dagna`
+ presente en el gate; pounds de IA se suman en el alcance 3 (T1 arranca
solo-Bond). Alcance en 5 pasos (0 aliada→1 onda→2 T1→3 IA→4 Gate 1 con
cornisa + `autotest_springboard` + ≥60 FPS). Anti-obj: solo T1; sin
Tether/T2/T3, sin camp scene; C6 no se adelanta salvo cláusula de escape.
Task-Board: C7 🔄. Siguiente: Feature Loop alcance 0.

## [2026-07-08] lint | Salud del vault — consistente (fixes menores aplicados)
Lint Loop tras cerrar el paquete de feedback del kit. **Reporte:**
1. Contradicciones: ninguna (Knowledge↔código coherentes).
2. Wikilinks: sin rotos (los `[[wikilink]]`/`[[wikilinks]]` son ejemplos
   del SCHEMA, no links reales); sin páginas huérfanas — las 27 Knowledge
   + State + Loops tienen link entrante; 90-Raw se referencia por archivo.
3. Status: solo `Briefs de Concept Art` sigue `propuesto` (coincide con el
   Index) — pendiente de confirmar con el director si se ratifica o queda.
4. Index vs realidad: 44 páginas, todas catalogadas (incl. Estructura
   Dramática); sin entradas fantasma.
5. State vs repo: **drift corregido** — la línea "Branch actual" seguía en
   "Capa 1" (ya íbamos por la validación) y el "arranque próxima sesión"
   marcaba el playtest como pendiente (ya validado). Fechas `updated:` de
   Current-State/Task-Board/Lecciones puestas al día (2026-07-08).
Vault consistente. Único ítem abierto: status de Briefs (decisión del director).

## [2026-07-08] playtest | Paquete de feedback del kit VALIDADO por el director
El director probó en vivo (`Start-Playtest-Greybox.bat`) y validó las 3
capas del feedback del kit Duelist: Capa 1 (guardia con cuerpo + bloqueo
acero, "mejoró mucho"), Capa 2 (tell del parry: batazo de cuerpo + flash
cian-oro) y Capa 3 (estela del swing). El kit queda cerrado a nivel feel.
Pendiente de arte aparte: el status gráfico de las reacciones del enemigo
(sesión propia). Siguiente hito: PRD-007 (Dagna + Seismic Springboard T1)
rumbo al Gate 1.

## [2026-07-08] feature | Feedback del kit — Capa 3: legibilidad del swing (LMB) + paquete cerrado
Última capa del feedback del kit. El swing se leía poco del lado del
jugador; SIN tocar la biomecánica ratificada del strike, `_spawn_swing_arc()`
dibuja una estela de filo (crescent emisivo additivo con TAPER por
vertex-color: borde de ataque brilla, cola se apaga) al ENTRAR la fase
active — 1×/golpe detectando la transición de fase en el update del
controller — que se desvanece en ~0.16 s (tween albedo→transparente).
Iteración de tuning por sonda: la v1 salió gigante/reventada; se bajó a
crescent fino translúcido (r 0.5–0.95, alpha 0.55) tilteado en diagonal.
Sonda `tmp_guard.gd` amplió la captura (swing_arc.png). QA: test_core/
combat/slice/ui ALL_PASS. Con esto el paquete de feedback del kit
(guardia+bloqueo, parry, swing) queda CERRADO en código; pendiente solo el
visto bueno del director en vivo. El status gráfico del enemigo corre
aparte (sesión propia).

## [2026-07-08] feature | Feedback del kit defensivo — Capa 2: el parry se ve del lado del jugador
El director aprobó la Capa 1 ("mejoró mucho") y dio luz verde a la Capa 2.
El parry Roba solo se leía por el stun del enemigo. Ahora: (a) rig
`play_parry()` = deflexión seca de TODO el cuerpo (el arma batea arriba-
afuera + off-arm en contrapeso + giro de torso lumbar/torácico + cabeza al
acero robado), riposte ~0.3 s sobre la guardia, ROM limpio; (b) VFX
`_spawn_parry_flash()` = pop emisivo cian + burst de chispas cian→oro al
frente del arma, más brillante que el destello de bloqueo. Wiring en
`receive_hit` (reacción parried). Sonda `tmp_guard.gd` amplió la captura
(guard_parry.png). QA: test_core/combat/slice/ui ALL_PASS. Fix de test
descubierto en el camino: el kill loop de autotest_combat estaba acotado
por FRAMES → dependiente del FPS (a ~900 fps mataba tarde y fallaba); se
acotó por TIEMPO REAL. Lecciones nuevas: loops de autotest por tiempo real,
y capturas de pose en 2s tras un tick. Pendiente: Capa 3 (legibilidad del
swing LMB) + visto bueno del parry en vivo.

## [2026-07-08] feature | Feedback del kit defensivo — Capa 1: la guardia gana cuerpo + bloqueo diferenciado
Playtest del director (clip 2026-07-08) del kit Duelist: la GUARDIA (RMB
mantener) no comunicaba nada — sin pose y el vignette rojo salía igual al
bloquear; el parry (RMB tap) poco evidente del lado del jugador; el status
gráfico del enemigo no le encanta (→ tarea de arte aparte, chip creado).
Plan en 3 capas; el director eligió arrancar por la Capa 1 con sonda visual
para su visto bueno antes de seguir. **Capa 1 ✅ código:** (a) rig
`set_guard(bool)` = pose de bloqueo sostenida (antebrazos cruzados + arma
arriba + brace) que compone sobre el gait, bajo el strike, y aguanta bajo
el flinch — dentro de ROM (constraint_report vacío); (b) golpe BLOQUEADO
deja de pintar rojo → destello ACERO (COL_BLOCK en hud.gd) + chispa de
deflexión en el arma (_spawn_guard_spark), el rojo queda solo para daño
limpio; wiring `stats.take_damage(...,blocked)` + `_set_guard`→`rig.set_guard`.
Sonda `tests/tmp_guard.gd` (neutral/guardia/3-4/flinch). QA: test_core/
combat/slice/ui ALL_PASS. Lanzador `Start-Playtest-Greybox.bat` para el
playtest en el greybox. Pendiente: visto bueno del director → Capa 2 (tell
del parry) + Capa 3 (legibilidad del swing).

## [2026-07-07] feature | PRD-006 alcance 5: greybox + spawns parametrizables + autotest_combat — PRD-006 CERRADO
Cierra PRD-006 y abre el Gate 1. Tres piezas nuevas: (1) `scenes/
combat_arena.gd` — greybox blockout barato (suelo plano + anillo + postes)
que implementa el contrato de escena completo; (2) `gameplay/spawn_spec.gd`
— parser tolerante de la spec de spawns (`light,heavy`, `2light+1heavy`,
`duelpair` alias, vacío→default); (3) `tests/autotest_combat.gd` — gate
windowed permanente. Integración en `game_director.gd`: estado FSM `ARENA`
+ `--skip=arena` + helper `_spawn_humanoids` COMPARTIDO con WILDS (el
`--spawn=duelpair` viejo se generalizó; back-compat verificado por
`tmp_spawnflag`). El autotest verifica: spawn parametrizado (2 kinds),
parry Roba→stun, kill loop del kit Duelist real (ambos muertos, 940
frames) y FPS. **Greybox a 177 FPS → gate ≥60 holgado.** QA: test_core/
slice/ui ALL_PASS. Lección dura nueva: golpear a un enemigo `dying`
reinicia su timer de muerte (receive_strike vuelve a health<=0 y pone
state_t=0) → en kill loops/AoE, dejar de pegar al entrar en dying. Falta
solo el playtest del director del feel acumulado (alcances 4 + tuning).

## [2026-07-07] design | Ventana de C6 RATIFICADA: entre el Gate 1 y la Fase 2
El director ratifica la ventana del rework anatómico (C6): tras cerrar
PRD-006/007 y el Gate 1, junto al pase de poses C4 — una sola cirugía
anatómica antes del contenido de Fase 2. Cláusula de escape acordada: si
en el playtest del Gate 1 los cuerpos impiden juzgar el feel, C6 se
adelanta a dentro de PRD-007. Secuencia vigente: alcance 5 → PRD-007 →
Gate 1 → C6+C4 poses → Fase 2. Fase 4 conserva solo el vestido final.

## [2026-07-07] design | Veredicto del director sobre Dagna in-engine → C6 rework anatómico
Tras ver la comparación lado a lado (lámina · greybox · golden scene):
la demo en golden scene confirma que el REGISTRO del Art Bible aterriza
sobre el rig (sonda nueva `tests/tmp_dagna_golden.gd`: materiales toon →
toon_golden opaco para sobrevivir al post, conservando el outline), pero
**la anatomía está lejos de la lámina**. Causa raíz señalada por el
director: el cuerpo base reutiliza los gráficos del prototipo PRE-RESET,
que ya estaban corruptos — debió hacerse un rework completo en vez de
heredarlos. Decisión: **C6 — rework anatómico del cuerpo base** (Task-
Board): reconstruir proporciones/volúmenes/cabeza desde las láminas de
fenotipo, conservando la biomecánica ganada (hip-first, columna 2 seg,
constraints, canon 2s). Ventana recomendada: junto al pase de poses C4
(B15c/B15d), tras el Gate 1 y antes del contenido de Fase 2; el vestido
final (materiales/cara/atlas) permanece en Fase 4.

## [2026-07-07] feature | Dagna gráfica en Godot — pipeline lámina → config → rig
Entregable extra pedido por el director: meter a Dagna GRÁFICAMENTE en el
motor para **liberar su diseño** y probar el pipeline replicable. Sistema
nuevo: `godot/data/characters.gd` (configs de personajes nombrados =
origin+clase+fenotipo+piezas firma; `apply_to_rig()`) +
`godot/character/character_signature.gd` (extras de lámina colgados
ADITIVOS sobre el rig: túnica de guardiana, hombreras/espinilleras de
compuerta, cuña de trenza, tatuajes de gremio arco+cuña, martillo de
cabezal plano a la espalda, cinturón, faldón — cero cambios al rig base).
Dagna (`ironblooded` + warrior + fenotipo enano robusto, mismo par
weight/height que el heavy) se lee inconfundible vs. `dagna-v1.png`; la
**cuña de la trenza quedó garantizada y legible en perfil** (la ficha lo
exigía). Sonda `tests/tmp_dagna.gd` (frente/espalda/perfil/detalle con
cámara nivelada tomada por la sonda — el idle fuerza head.rotation.x=0, así
que el "mira arriba" era encuadre). Solo capa de LOOK: ROM/IK enano +
animación diferidos (C4 + PRD-007). QA: test_core/autotest_slice ALL_PASS,
tmp_dagna limpio. **Ejecución creativa por subagente Fable, orquestación +
fixes de fidelidad (mirada, cuña) por Opus.** La sesión de Fable se cortó
por límite de gasto mensual de la cuenta. Pendiente: visto bueno estético
del director (miss: cuña sutil de frente, hombreras altas, tatuajes
tenues). El pipeline queda como MOLDE para los otros 8 pivotes.

## [2026-07-07] feature | PRD-006 tuning de presión enemiga (B15g)
El par humanoide ya no se congela entre golpes — el otro asesino del
feel medido en B15g ("YDIF plano / se lee pasivo"). En
`enemy_humanoid.gd`, los 3 candidatos del benchmark: recover del light
0.55→0.42 s; `chain_prob` data-driven (light 0.72 encadena, heavy 0.0
respira — antes hardcodeado a `kind=="light"`); y **circle-strafe
durante recover** (componente tangente + corrección radial al anillo
de ataque; el sentido alterna al re-entrar para no leerse robótico).
El heavy sigue lento (su identidad) pero ACECHA en vez de plantarse.
Verificado por sonda `tmp_pressure` en juego real (jugador inmortal +
pineado, 8 s): `recover_path` del light ≈0 → 3.55 m (≈1.7 m/s, calza
con strafe_speed), heavy 3.56 m; loop de golpes vivo (light 6 / heavy
5 strikes). QA: test_combat/test_core/autotest_slice ALL_PASS.
Pendiente: playtest del director. Nota: la regresión de datos vive en
la sonda windowed, no en test_combat headless — preload de un script
que referencia el autoload EventBus rompe la compilación en `--script`
(autoloads no registrados headless).

## [2026-07-07] feature | PRD-006 alcance 4: canales 1–3 de la Game Feel Bible como sistema
La mitad temporal que faltaba contra Sifu (B15e #1). Autoload `Feel` +
lógica pura `combat/time_feel.gd` (canal 1) y `combat/trauma_shake.gd`
(canal 2), reutilizables por PRD-007. Hit-stop 2f/3f GLOBAL por masa
de arma (números medidos B15; ×1.5 golpe de muerte, 50% al recibir,
cap 1 por 100 ms); parry Roba = clang 3f (B15b) + dilation 0.2×0.35 s
+ sting de dos notas sintetizado (E5→B5, placeholder hasta B8); shake
trauma² Perlin con caps GFB (0.25 m / 2° / 0.6); canal 3 = combat
framing (FOV +4°, lift 0.12 m, histéresis 2 s) + soft-aim cono 30°
total. `HitPayload.weapon_mass` nuevo (el stop escala por ARMA, no por
cuerpo; el lunge de la bestia usa masa corporal). QA: test_combat +22
asserts, sonda en juego real `tmp_timefeel` (clang 3 f exactos,
dilation 0.354 s, trauma, heat), test_core/autotest_slice/autotest_ui
ALL_PASS, FPS 491/336. Lección dura: relojes reales del autoload en
usec — sin vsync (~300–500 fps) el frame mide <1 ms y con msec el dt
daba 0 (la dilation se quedaba pegada). Pendiente: playtest del
director (feel) + tuning de presión enemiga (B15g).

## [2026-07-06] design | [[Benchmark Biomecánico]] RATIFICADO por el director
Cierre de la decisión que dejó abierta el Lint Loop: el director
ratifica el benchmark (v1 Sable/Hinterberg + v2 AAA + v3 mediciones
B15–B15g). La condición original ("ver el alcance 2 con poses
extremas") quedó superada: el canon se validó midiendo nuestra propia
build (B15d) y el playtest verificado del alcance 3 (B15f–B15g). Con
esto las 27 páginas de Knowledge quedan `ratificado` salvo [[Briefs de
Concept Art]] (propuesto legítimo — pipeline NB2 en exploración).

## [2026-07-06] lint | Lint Loop: vault sano — 7 fixes menores aplicados, 1 decisión para el director
Barrido completo (44 páginas). **Sano:** cero wikilinks a páginas
inexistentes, cero huérfanas (los Raw quedan enlazados vía 00-Index/
SCHEMA/ADR-001), Index↔realidad 1:1 en ambas direcciones, State=repo.
**Fixes aplicados:** 2 wikilinks partidos por salto de línea en LOG
(B15f y alcance 1 — Obsidian no los resolvía); Current-State
desactualizado en 3 líneas ("último PR: alcance 1"→alcance 3, sondas
tmp ampliadas y atadas a PRD-006 completo, "después del alcance 2"→
alcance 3 ✅); 00-Index marcaba `(propuesto)` a [[Fenotipos y Creación
de Personaje]] y [[Dagna]] que ya son `ratificado`. **Decisión para el
director:** [[Benchmark Biomecánico]] sigue `propuesto` y su condición
de ratificación ("ver el alcance 2 con poses extremas") ya se cumplió —
B15d–B15g validaron el canon contra nuestra propia build; ratificarlo
es cosa de una palabra. [[Briefs de Concept Art]] sigue `propuesto`
legítimamente (pipeline NB2 aún en uso exploratorio).

## [2026-07-06] state | Cierre de sesión: B15e→B15g + tinte + alcance 3 completo y VERIFICADO en juego
Sesión nocturna completa sobre el veredicto del director ("fundamentals
sí, Sifu no"). Recorrido: **B15e** (playtest medido: 8 tintes/11.4 s +
cero reacción corporal = trade-fest) → **fix del tinte** (wash →
vignette de bordes, centro siempre limpio) → **PRD-006 alcance 3 ✅**
(reacciones corporales por Equilibrio en bestia y jugador + par
light/heavy sobre el mismo rig, mergeado a master) → **fix del bat**
(Start-Godot.bat no reenviaba flags; nuevo Start-Playtest-Duelist.bat)
→ **B15f–B15g** (verificación en juego real: los 2 asesinos de B15e
resueltos, par legible por silueta, Playtest Loop CERRADO 5/7).
Hallazgo abierto: presión enemiga baja (≈1 golpe/2–3 s). Arranque de la
próxima sesión fijado en [[Current-State]]: alcance 4 (hit-stop 2f/3f +
TimeFeel + sting + shake) + tuning de presión + medir parry/síncopa.
Sondas tmp_* siguen en tests/ (limpiar al cerrar PRD-006).

## [2026-07-06] playtest | B15g ✅: par light/heavy verificado — Playtest Loop del alcance 3 CERRADO
Clip de 23.6 s con el bat nuevo. 5/7 verificados: spawn por flag,
siluetas por rol distinguibles sin color, ataques de ambos legibles (el
swing del maul del heavy se lee en arco completo), reacciones y muertes
corporales, vignette con centro limpio en pelea real. Pendientes de
MEDICIÓN (no de implementación): parry vs humanoides y síncopa del
combo. **Hallazgo de feel:** presión enemiga baja — cadencia ≈1 golpe/
2–3 s se lee como pasividad; candidatos de tuning anotados en
[[Benchmark Biomecánico]] §B15g. Lo que falta contra Sifu ahora es
temporal: alcance 4 (hit-stop 2f/3f + TimeFeel + sting) + presión.

## [2026-07-06] playtest | B15f: alcance 3 verificado en gameplay (parcial) — los 2 asesinos de B15e resueltos
Dos clips del director post-fix (el 2º usable solo 60 s). Pipeline B15
sobre la pelea (52–60 s): **cero washes de pantalla** (vs 8/11.4 s en
B15e) — el daño ahora es banda de borde con centro limpio, visible
pulsando en pleno combate; y la bestia acusa CON EL CUERPO (roll
lateral, postura baja, patas abiertas — stagger distinguible de flinch
en silueta a distancia de juego). Sin verificar (no salió en cámara):
flinch del jugador (escala/ángulo), par light/heavy (boot sin
`--spawn=duelpair`) y síncopa (sin combos limpios). Ver
[[Benchmark Biomecánico]] §B15f. Decisión pendiente: cerrar verificación con clip
dirigido o avanzar a alcance 4 con lo validado.

## [2026-07-06] feature | Flag --spawn=duelpair para el playtest del alcance 3
El par light/heavy ya spawnea en Wilds sin sonda: boot
`--origin=ironblooded --cls=warrior --skip=wilds --spawn=duelpair` los
mete a 8 m frente al jugador (además de las bestias). QA: sonda
`tmp_spawnflag.gd` PASS (par presente + screenshot) y `autotest_slice`
ALL_PASS (sin flag no cambia nada). Decisión: se valida el alcance 3 en
playtest ANTES de construir el alcance 4 — el hit-stop congela poses, y
las poses tienen que decir lo cierto antes de dramatizarlas con tiempo.

## [2026-07-06] feature | PRD-006 alcance 3 ✅ código: reacciones corporales + light/heavy
Dos pasos en branch `feat/prd006-alcance3`. **Paso 1 (absorbe B15e):**
la bestia resuelve el combate nuevo por `receive_strike()` → el
GuardComponent decide (flinch/stagger/posture break) y el CUERPO lo
anima (head snap inmediato, roll lateral, derrumbe con patas abiertas);
FSM suspendida durante stagger/broken; ventana de castigo = daño ×1.5;
`hit()` viejo intacto para los autotests históricos. El jugador acusa
con `rig.play_flinch()`: head snap a 60 (nunca stepped, canon B15) +
recoil de columna en el reloj de pose. **Paso 2:** `enemy_humanoid.gd` —
el par del PRD sobre el MISMO CharacterRig y strike hip-first: light
(raider_saber nuevo, masa 0.7, encadena, postura frágil) y heavy
(heavy_maul, masa 1.8, torre, carga 0.8–1.0 s legible). Parry Roba →
stun 2 s. QA: test_core + test_combat + autotest_slice + autotest_ui
ALL_PASS; sondas `tmp_reactions.gd` y `tmp_duel_pair.gd` con capturas al
midpoint. Pendiente: playtest del feel (Playtest Loop) y greybox de
spawns (alcance 5).

## [2026-07-06] feature | Fix del tinte de daño ✅ (adelantado por B15e)
El wash plano de daño (ColorRect full-rect alpha 0.55, decay único
~0.45 s en hud.gd) es ahora un vignette real de bordes: shader
canvas_item radial (sin screen texture — compatible con la lección del
toon/ALPHA), centro SIEMPRE a alpha 0, decay en dos fases fuerte ≤0.2 s
+ cola ≤0.3 s (spec de [[Benchmark Biomecánico]] §B15e consecuencia 1).
QA: `autotest_ui` + `autotest_slice` ALL_PASS; sonda visual
`tests/tmp_vignette.gd` captura t=0/0.1/0.25/0.5 s — centro limpio con
el golpe recién recibido, tinte extinto a 0.5 s. Desbloquea la medición
de la síncopa en el próximo clip del director.

## [2026-07-06] ingest | B15e ✅: playtest dirigido del kit Duelist — "fundamentals sí, Sifu no"
El director jugó el kit Duelist y grabó 48 s (pelea 1v1 vs bestia,
23.0–34.5 s). Veredicto: "los fundamentals existen, pero no es ni de
cerca la experiencia de Sifu". El pipeline B15 (hojas 60 fps + YDIF) le
da la razón con números: 0 hit-stops; **8 tintes rojos a pantalla
completa en 11.4 s de pelea** (el tinte es el evento visual más grande
del clip, YDIF 37–41 vs ~10 de un swing; wash ~50 % del combate);
jugador golpeado SIN cambio de pose; bestia solo flash blanco (kit
activo — re-confirma B15d #2); patrón resultante = trade-fest (tanquear
es óptimo, no se observa guardia/parry). Salvedad B15d cerrada a medias:
kit confirmado activo, síncopa aún no medible con ese encuadre + wash.
**Ajuste de prioridades:** adelantar el fix del tinte (wash → vignette
≤0.2 s fuerte) ANTES del alcance 4; alcance 3 (reacción corporal por
Equilibrio) ataca directo el trade-fest. [[Benchmark Biomecánico]] §B15e.

## [2026-07-06] state | Cierre de sesión: benchmark completo (B15–B15d) + kit Duelist listo para playtest
Sesión cerrada con el ciclo de benchmark observacional completo: B15
(3 clips base) → B15b (28 clips de Sifu) → B15c (gaits de Sable) → B15d
(nuestra build, AS IS vs TO BE). El alcance 2 de PRD-006 quedó ✅ en
código a la espera del playtest del director. Arranque de la próxima
sesión fijado en [[Current-State]]: (1) playtest del kit Duelist con
boot melee — ideal grabando 3–4 combos con cámara quieta; (2) alcance 3
absorbiendo la reacción corporal de la bestia; (3) alcance 4 con
hit-stop + revisión del tinte de daño; (4) backlog C4: poses por gait +
canal airborne. Task-Board sincronizado (B15c/B15d visibles, herencias
en C3 y C4).

## [2026-07-06] ingest | B15d ampliado: running jump medido (video↔código)
A pedido del director se midió el W+espacio del clip AS IS: aire 42 f
(0.70 s), coincide exacto con JUMP_V 8.4 / GRAVITY 24 del código —
validación cruzada. Landing stutter plano ~3 f (no bloqueante ✅, mejor
que el presupuesto Fortnite de 6 f). **Hallazgo:** el salto es invisible
en la silueta — `rig.set_motion()` no tiene canal airborne, así que
despegue/aire/aterrizaje no tienen pose (solo la raíz arquea y la cámara
hace thump). El aire es un gait sin pose: extiende la lección B15c.
[[Benchmark Biomecánico]] §B15d punto 6.

## [2026-07-06] ingest | B15d: nuestra build medida contra el benchmark (AS IS vs TO BE)
El director grabó nuestra propia build (63 s: Wilds → bestia → núcleo →
menú) y se analizó con el pipeline idéntico de B15 (hojas 60 fps + YDIF).
Medido-contra-medido: 0 hit-stops en combate (esperado — alcance 4);
locomoción YA alineada con Sable (raíz continua + holds ~4–5 f); columna
sin postura por gait (B15c ya pendiente). **Hallazgos nuevos:** (1) la
bestia reacciona solo con flash blanco ~7–8 f y pose IDÉNTICA — cero
reacción corporal (refuerza la consecuencia 3 con evidencia propia);
(2) el daño al jugador es un tinte salmón de pantalla completa >1 s que
tapa la lectura — mover el feedback al cuerpo y acortar el tinte.
Salvedad: no está claro si el kit Duelist estaba activo en el clip; el
clip ideal para medirlo es `--cls=warrior`, cámara quieta, 3–4 combos.
[[Benchmark Biomecánico]] §B15d.

## [2026-07-06] ingest | B15c: crouch walk y sprint de Sable (2 clips más)
Paréntesis del director tras el alcance 2. Mismo sistema confirmado
(holds ~4 f solo extremidades + raíz continua) y una lección nueva de
gaits para [[Locomoción]]/C4: **cada gait es una POSE de silueta propia**
— crouch = torso plegado ~90° con mano rozando el suelo; sprint =
encorvada adelante con cabeza baja (cita de Holland verificada frame a
frame). Nuestra columna de 2 segmentos ya permite posturas de columna
distintas por estado de la FSM. [[Benchmark Biomecánico]] §B15c.

## [2026-07-06] feature | PRD-006 alcance 2: kit Humano Duelist jugable
El input real deja el prototipo 0 atrás: LMB/F arranca el combo ×4 del
CombatComponent (buffer generoso; durs sincopadas con los números B15:
0.40/0.32/0.46/0.62), RMB contextual en melee = guardia (hold bloquea,
press abre la ventana ESTRICTA de parry Roba — B15b), momentum→daño se
captura al arrancar el swing (el slide alimenta el golpe aunque la ley
sprint↔arma frene el cuerpo el mismo tick), y el lunge de la bestia viaja
como HitPayload por la guardia del jugador (parry → stun ~2 s medido en
Sifu). **Anti-objetivo resuelto por enrutamiento de input:** try_attack()
intacto, solo autotests históricos lo llaman. QA: test_combat/core/
locomotion/ads ALL_PASS · autotest_slice ALL_PASS · autotest_biomech
ALL_PASS · wilds 280 fps. Decisiones en [[PRD-006 Combate mínimo]].
Pendiente: playtest del director (feel) antes del alcance 3.

## [2026-07-06] ingest | B15b: tutorial completo de Sifu (28 clips) — parry y guard break medidos
El director grabó las lecciones completas del tutorial de Sifu (Structure
& Block / Deflect / Parry / Avoid / Special / Command Attacks) + 2 peleas
reales. Identificación por frame del nombre de lección en pantalla +
detección de congelados YDIF en los 28 clips. **Cerrados los 3 faltantes
de la v3:** parry exitoso = clang con hit-stop 3 f (un frame MÁS que el
golpe normal: el premio está en el freeze) + riposte ~0.3 s + stun ≥0.85 s;
guard break al jugador = burst + golpe gratis + ~1.0 s de stagger sin
control; bloqueo bajo special = cede terreno deslizando (→
PushPullComponent). Bonus: los fallos grabados muestran el feedback
"Too Early" — ventana de parry estricta que castiga el spam. Trampas de
método documentadas: pausas pedagógicas de ~18 f del tutorial y freezes
de idle en escenas oscuras NO son hit-stops. [[Benchmark Biomecánico]]
§B15b + consecuencias 6–8; Task-Board y Current-State al día.

## [2026-07-06] ingest | B15 ✅: benchmark observacional medido (3 clips del director)
Clips 60 fps de Sifu/Fortnite/Sable analizados frame a frame (hojas de
contacto ffmpeg + perfil YDIF por frame para detectar hit-stops e
impactos). Resultado en [[Benchmark Biomecánico]] §v3 — números medidos,
no estimados: **Sifu** hit-stop 2f normal / 3f pesado (congelado GLOBAL),
combo sincopado (16f/8f/29f entre impactos), viaje a contacto 2–3f,
contacto ≈60% del ciclo (**valida la frontera 0.58 de weapons.json**),
Double Palm 32f windup + 24f follow. **Fortnite** movilidad no
bloqueante: aterrizaje ~6f sin cortar sprint, slide entra/sale en ~6f,
salto 34f de aire. **Sable (LA pregunta clave): raíz CONTINUA cada
frame + holds de ~4f solo en extremidades + tela suave encima —
validación 1:1 de nuestro canon A/B; el body pop descartado coincide
con la referencia.** Faltantes del clip: parry/guard break, mantle
(pedir clip extra solo si el alcance 2 los pide). Task-Board y
Current-State actualizados; consecuencias listadas para el alcance 2
(hit-stop budget, síncopa de dur, reacción al frame siguiente).

## [2026-07-06] state | Cierre de sesión: B14 + A/B + alcance 1 + articulación
Sesión completa en un día. Recorrido: **B14 ✅** (benchmark v2 AAA — motion
matching descartado, camino Sifu/HZD validado; la v1 quedó ratificada de
facto por 4 rondas de A/B en vivo) → **A/B del stepping CERRADO** (canon:
2s solo extremidades, cuerpo suave; body pop probado en 3 variantes y
descartado, queda tras toggle) → **PRD-006 alcance 1 ✅** (4 componentes +
HitPayload + weapons.json + curvas trifásicas; test_combat 41/41; PR por
merge local) → fix melee vivo (play_strike no estaba conectado al juego)
→ **ronda de articulación ✅ aprobada** (follow-through + lag abierto +
columna 2 segmentos) tras feedback "legos/playmobil" del director.
Lecciones nuevas: follow-through vs tope de bisagra; A/B de percepción
siempre con zoom. **Próxima sesión: alcance 2 (kit Duelist jugable)** —
primera decisión: cómo convive el reemplazo del combate con el
autotest_slice histórico. Master limpio, todo pusheado.

## [2026-07-06] playtest | Ronda de articulación APROBADA por el director
Veredicto en vivo tras #1+#2+#3: "se ve bien". La ronda completa contra
el feedback "legos/playmobil": #2 mató el frenar-en-seco (follow-through
amortiguado), #1 el todo-llega-junto (lag abierto con overlap real), #3
el torso-monobloque (columna lumbar+torácica). Lo que queda de lectura
de juguete es etapa: mesh de bloques (pase visual en producción del
slice) y pies sin IK (C4). Cerrada la ronda; el rig queda como base de
animación del alcance 2.

## [2026-07-06] playtest | Articulación #1+#3: lag abierto + columna en 2 segmentos
Director tras la #2: "vamos en dirección correcta" → aplicadas las otras
dos. **#1:** CHAIN_LAG abierto (0/0.08/0.16/0.22 + `chest` 0.12) — más
overlap entre segmentos, con el pico del codo aún pegado al cierre de la
ventana activa (k≈0.67) para que la mano no conecte tarde. **#3:** la
columna deja de ser monobloque — `upper_spine` (torácico, ROM propio ~60%
del lumbar) carga torso/strap/brazos/cuello/cabeza; en el strike el twist
se reparte 45% lumbar + 62% torácico con lag de pecho (el torso se
ENROSCA); fuera del strike, capa de follow (38% twist / 30% lean, lagged).
Fix en el camino: release del codo -0.10→-0.085 — el follow-through
oscilaba +0.036 y el tope de extensión es +0.03 (lección nueva en
[[Lecciones]]). QA: core, combat, biomech, rig, scenes, slice — todo
ALL_PASS. Pendiente: veredicto del director de la ronda completa (1+2+3).

## [2026-07-06] playtest | Articulación #2: follow-through por segmento en el settle
Feedback del director: el melee lee "como legos/playmobil". Diagnóstico
compartido: parte etapa (mesh de bloques, sin secundario), parte deuda
(segmentos que frenan en seco, poca superposición, columna monobloque).
El director ordenó la ronda #2 (follow-through): el settle del strike es
ahora un coseno amortiguado por segmento — undershoot pico ~−10% del
release, lo distal ondula más y decae más lento (whip/decay/freq escalan
con el lag de cadena). Pendientes de su orden: #1 (abrir CHAIN_LAG) y
#3 (columna 2–3 segmentos, adelanto de C4). QA: test_combat, biomech y
slice ALL_PASS.

## [2026-07-06] playtest | Fix: el melee vivo no mostraba el strike biomecánico
Feedback del director ("no lo siento tan melee") destapó dos cosas: (1)
`play_strike` (hip-first + curvas del alcance 1) solo lo llamaban los
autotests — el juego vivo animaba el envelope legacy de 0.38 s; puenteado:
el path melee de `try_attack` ahora anima con `play_strike(0.55)`, daño
legacy intacto (anti-objetivo). (2) El boot `--skip=wilds` sin `--cls`
hereda la clase de la pantalla de creación — para probar melee hay que
bootear warrior (`--origin=ironblooded --cls=warrior --skip=wilds`).
QA: test_core y slice ALL_PASS. Commit 59ec800.

## [2026-07-06] feature | PRD-006 alcance 1: arquitectura de combate + curvas trifásicas
Branch `feat/prd-006-a1`. (1) `godot/combat/`: HitPayload (4 campos canon
+ MarkMultiplier fijo 1.0), CombatComponent (combos con ventanas ancladas
a las fases biomecánicas — buffer generoso acepta desde active, encadena
al cerrar recovery, windup cancelable; momentum = masa × velocidad al
conectar), GuardComponent (Equilibrio nace de la masa §B.3; flinch →
stagger → posture break; parry Roba §B.4: roba Equilibrio + desarma),
EnergyComponent (Aether placeholder), PushPullComponent (§B.2: un solo
sistema físico — impulsos con decay, techo de sanidad; PRD-007 lo
reutiliza). Datos: `data/weapons.json` (duelist_blade ×4, unarmed,
gloom_claws, heavy_maul). Instanciados en jugador Y bestia, NEUTROS
(anti-objetivo: el combate viejo intacto, autotest_slice verde). (2)
Curvas v2 del strike en `rig_biomech.segment_offset` (acción #2 de
[[Benchmark Biomecánico]]): coil con moving hold, release back-out con
overshoot, settle con rebote; fracciones de fase (= ventanas) intactas.
QA: test_combat NUEVO 41/41 ALL_PASS; test_core, biomech, scenes, slice
todos verdes. Next: alcance 2 (kit Duelist jugable sobre los componentes).

## [2026-07-06] playtest | A/B CERRADO: canon = 2s solo extremidades, cuerpo suave
Veredicto del director tras 3 rondas de body pop (completo → moving hold
→ 24 Hz jerárquico): ninguna variante paga su costo; "pop en extremidades
es mucho mejor". CANON: stepping en 2s (12 Hz) SOLO en extremidades;
cuerpo/raíz suaves a 60. `body_pop_on_twos` queda default OFF con el
mecanismo completo implementado (3 variantes probadas y commiteadas) por
si el alcance 1 con poses extremas reabre la pregunta. Tecla T conserva
el ciclo de 3 modos. Lección de método: el A/B de percepción necesita
zoom de cámara — a distancia default el chop de extremidades no se lee.

## [2026-07-06] playtest | Body pop ronda 3: timing jerárquico — cuerpo a 24 Hz
Feedback del director sobre la ronda 2: "solo extremidades es mucho mejor;
¿y si el cuerpo va a 24 Hz?". Implementado: reloj propio del body pop a
24 Hz (BODY_POP_STEP 1/24) — el cuerpo re-ancla el doble de rápido que la
pose (12 Hz); caps de la ronda 2 quedan como red anti-lag. Es timing
JERÁRQUICO à la Spider-Verse/Xrd (mezcla de 1s y 2s): la masa corre fina,
el ritmo cómic vive en las extremidades. Toast actualizado. QA: test_core,
biomech y slice ALL_PASS. Pendiente: veredicto de la ronda 3 (si 24 Hz
converge visualmente a "solo extremidades", ese es el veredicto gratis).

## [2026-07-06] playtest | Body pop ronda 2: moving hold (feedback: "se siente con lag")
El pop puro trailing-completo (hasta ~0.5 m en sprint) se percibía como
input lag. Corregido con MOVING HOLD: el offset del hold se capea a 0.15 m
(≈25 ms percibidos en sprint) y el yaw a ~11°; el anchor se arrastra con
el cuerpo para no acumular excedente entre ticks. El pop queda como chop
constante de textura, no como retraso. Era el plan B ya documentado en
[[Benchmark Biomecánico]] (moving holds, técnica stop-motion/Xrd). QA:
test_core, biomech y slice ALL_PASS. Pendiente: veredicto del director
sobre la ronda 2.

## [2026-07-06] playtest | A/B resuelto: 12 Hz CANON + body pop implementado
El director vio la diferencia (con zoom de cámara; las sondas confirmaron
antes que el stepping funcionaba end-to-end — el enmascarador era la raíz
continua). Decisiones: (1) **EN 2s / 12 Hz queda como canon** del rig;
(2) **body pop implementado YA**: el mesh visible holdea X/Z + yaw entre
ticks (estilo Sable, `body_pop_on_twos`, snap-guard 1.5 m; el eje Y del
body queda para crouch/slide; raíz/gameplay siempre continua); (3) la
página [[Benchmark Biomecánico]] sigue `propuesto` hasta ver el alcance 1
(poses extremas). Tecla T ahora cicla 3 modos: 2s+pop → solo extremidades
→ suave. QA: test_core, biomech, rig y slice ALL_PASS; tira A/B regenerada
muestra el pop (~0.5 m de hold en sprint). Sondas tmp_* quedan hasta el
cierre del alcance 1.

## [2026-07-06] playtest | A/B en vivo del stepping en 2s: tecla T in-game
Preparado el A/B que pedía [[Benchmark Biomecánico]] v1: tecla **T** en el
juego alterna `animation_on_twos` en caliente (toast en HUD: "EN 2s
(12 Hz)" vs "suave (60 fps)"); boot directo a WILDS con `--skip=wilds`.
QA: test_core ALL_PASS, autotest_scenes ok, autotest_slice ALL_PASS.
Sesión en vivo lanzada para el director. Pendiente: veredicto del director
(ratifica la página v1+v2 o pide ajustes — moving holds es el plan B si el
stepping puro se siente muerto).

## [2026-07-06] design | B14 cerrada: benchmark v2 AAA — el AAA valida el camino, no lo cambia
Research de los 5 títulos encargados, volcado en [[Benchmark Biomecánico]]
§v2 (sigue propuesto; se ratifica junto con la v1). Hallazgo estructural:
el AAA se divide en dos familias. (A) Data-driven / motion matching (AC,
For Honor, 007 First Light con Glacier Next): descartada sin ambigüedad —
el combustible es una base masiva de mocap que no tenemos ni queremos;
rescatables solo los conceptos (dial responsividad↔fidelidad, motion
warping — que nuestro hip drive ya hace procedural). (B) Autorada + capas:
NUESTRO camino, validado. Sifu es el benchmark real: combate ~100% handkey,
estructura trifásica build-up/impacto/release (= nuestras curvas del
alcance 1), legibilidad por silueta + timing manipulado + ralentización
deliberada; su costo es iteración (docenas de rondas por ataque, 2→15
animadores) — para 1+LLM: presupuestar MUCHO feedback del director, las
curvas iteran barato. HZD aporta foot IK con anotación de contacto (→ C4,
Godot lo trae) y el checklist de estados de locomoción. Jedi FO (physical
animation) queda como versión procedural barata en Fase 4, respetando la
regla del stepping. Conclusión: la pila de 4 capas de la v1 queda
ratificada como arquitectura; PRD-006 alcance 1 es el paso correcto.
Task-Board B14 ✅. Pendiente para ratificar la página: A/B en vivo del
stepping (v1) + visto bueno del director a la v2.

## [2026-07-06] state | Cierre de sesión: PRD-006 parte 1 mergeada; B14 fijada como primera tarea
Sesión 2026-07-05/06 cerrada. Recorrido: A2b ratificada (alcance del
slice) → A1 ratificada (plan de producción, frente A COMPLETO) → Fase 0
cerrada (C1+C5) → B10 ratificada (Game Feel Bible) → PRD-006 ratificado e
iniciado: alcance 0 completo (rig restringido + strike hip-first) con 2
rondas de feedback de movilidad del director aplicadas + deep dive
[[Benchmark Biomecánico]] (hallazgo: el gap es timing/pose, no realismo;
pose stepping en 2s implementado tras toggle). QA todo verde al merge
(biomech, core, rig, scenes, slice). **Mandato del director al cierre:
B14 (benchmark v2 AAA — AC, 007 First Light, HZD, Jedi, y Sifu para
biomecánica/movilidad/combate) es LA PRIMERA TAREA de la próxima sesión,
antes de seguir el dev.** Branch `feat/prd-006-combate` mergeado a master
(el loop de PRD-006 sigue abierto: alcances 1–5).

## [2026-07-06] design | Deep dive biomecánico: el benchmark es TIMING, no más realismo
Pedido del director: benchmark contra Sable y Hinterberg. Hallazgo central
(página nueva [[Benchmark Biomecánico]], propuesto): Sable anima EN 2s
(12 poses/s sostenidas, frame a frame, técnica Xrd/Spider-Verse) con poses
empujadas al extremo — legibilidad > realismo (Micah Holland, Shedworks).
Hinterberg no publica data de animación (su deep dive público es de
rendering); su lección es eficiencia. Diagnóstico: nuestro rig era suave/
gomoso — ni realista ni expresivo. Síntesis con el canon §4.3: esqueleto
REALISTA (intacto) + pose EXTREMA + timing EN 2s; el gameplay nunca se
escalona. Implementado ya en el rig (commit en branch): pose stepping a
12 Hz detrás de toggle `animation_on_twos`, relojes de combate continuos
a 60 fps, constraints corriendo TODOS los frames (red de seguridad no
escalonada — el autotest adversarial lo forzó). QA: biomech ALL_PASS,
test_core ALL_PASS, rig 11 casos, slice ALL_PASS. Pendiente: A/B en vivo
con el director + ratificar la página.

## [2026-07-06] playtest | Ronda 2 de movilidad: cadera como motor (feedback del director)
Director: "buena movilidad en general; el crouch walk no convence y la
cadera sigue conservadora". Corregido (commit 0b45ab8): (1) ROM del pelvis
en Y ampliado a ±0.7 con justificación biomecánica (pelvis + pivote de pie
como unidad hasta que C4 traiga pies IK); (2) strike con cadera −0.60/+0.55
+ drive de traslación (el peso viaja al objetivo, no solo rota); (3) crouch
walk v2: rotación pélvica por zancada, peso lateral sobre el pie plantado,
contra-rotación de tronco y brazos en contra-balanceo — la silueta baja
aceptada se preserva. QA ALL_PASS, cero violaciones. Strips nuevos:
biomech_crouchwalk_{a,b}.png + strike re-capturado.

## [2026-07-06] playtest | Review de strips del strike: coil amplificado (feedback del director)
Dos observaciones del director sobre los strips de biomech: (1) el look de
las capturas está fuera de la Art Bible — CONFIRMADO COMO PLANEADO (stage
pelado de QA + rig del prototipo cuyo cel genérico es anti-referencia
explícita; el look canónico se aplica en Fase 4 del [[Plan-de-Produccion]];
las fases 1–3 se revisan en crudo: el cuerpo, no el pixel). (2) "No veo
mucha amplitud en el coil" → CORREGIDO (commit 47a483e): amplitudes
llevadas al borde del ROM (cadera −0.42, columna −0.75, hombro −1.90,
codo −1.45), contra-giro de cabeza (los ojos quedan en el objetivo — lo
que hace legible un windup real), captura del windup movida al pico del
coil (k 0.28). autotest_biomech ALL_PASS se mantiene (cero violaciones:
el ROM absorbe las amplitudes nuevas).

## [2026-07-06] feature | PRD-006 alcance 0 COMPLETO: rig humano restringido (en branch)
En `feat/prd-006-combate` (commit 5d9d93b). Entregado: `rig_biomech.gd`
(tabla ROM humana de referencia — hombro 3-DOF, codo/rodilla bisagra sin
hiperextensión, columna, cadera; clamp con reporte de violaciones
intentadas; curvas de cadena cinética con lags cadera→torso→hombro→brazo
y fases windup 0–0.32 / active 0.32–0.58 / recovery = las ventanas de
combate) + `play_strike()` hip-first en el rig (el snap legacy queda solo
para el slice histórico) + pase de constraints SIEMPRE al final del pose.
QA: `autotest_biomech` ALL_PASS (locomoción/strike cero violaciones ROM,
orden de fases correcto, clamp adversarial verificado, capturas de fases a
midpoint); regresión verde (test_core, rig 11 casos, slice). Siguiente
tarea del loop: alcance 1 (4 componentes + HitPayload).

## [2026-07-06] design | PRD-006 RATIFICADO — arranca el Feature Loop de combate
El director ratifica la spec iterada (movilidad realista como columna
vertebral). Feature Loop abierto en `feat/prd-006-combate`; orden de
construcción: alcance 0 (rig humano restringido: constraints + cadena de
transferencia hip-first) → componentes → kit Duelist → enemigos → feel →
greybox/QA. Doble criterio de aceptación en Playtest Loop.

## [2026-07-06] design | PRD-006 iterado: Movilidad Realista como columna vertebral
Mandato del director en sesión: construir el combate con mucho foco en
[[Movilidad Realista]]. El PRD se reestructura: (1) nueva sección columna
vertebral §4.3 — el moveset deriva del esqueleto, ventanas de combo =
fases biomecánicas del golpe (carga de cadera / transferencia / re-
equilibrio), momentum→daño como física corporal (masa × velocidad),
telegraphs = biomecánica legible (se lee la cadera del rival, no un
flash); (2) alcance 0 nuevo: rig humano restringido (C4 parcial: joint
constraints + cadena de transferencia hip-first) ANTES de animar ataque
alguno — Task-Board C4 → 🔄; (3) QA con assert de constraints por joint y
revisión biomecánica en montage; (4) doble criterio de aceptación: "no se
siente como el prototipo 0" + "el cuerpo importa más que el pixel".
Sigue `propuesto`, pendiente ratificación.

## [2026-07-05] design | PRD-006 (combate mínimo) PROPUESTO — con anti-objetivo del director
Spec nueva [[PRD-006 Combate mínimo]] en `20-State/PRDs/`. Mandato del
director incorporado como anti-objetivo: **el combate no debe sentirse
como el prototipo 0** — diagnóstico del viejo (`try_attack()`: botón +
cooldown, daño plano, flash+nudge) y reemplazo estructural (combos
AnimNotify + buffer, HitPayload 4 campos, reacciones por Equilibrio,
GuardComponent con parry Roba, canales de la Bible, soft-aim). El código
viejo queda intacto solo para autotest_slice histórico. Criterio de
aceptación literal del Playtest Loop: "no se siente como el prototipo 0".
Pendiente ratificación.

## [2026-07-05] design | B10 RATIFICADA: Game Feel Bible sellada
El director ratifica sin cambios, incluida la decisión mayor de cámara:
LIBRE + soft-assist, sin lock-on duro (revisable en Gate 1 si el greybox
la desmiente). [[Game Feel Bible]] → `ratificado`; Task-Board B10 ✅.
La Fase 1 queda desbloqueada para implementación: siguiente, PRD-006
(combate §4.2 mínimo contra la Bible) y PRD-007 (Dagna companion +
Springboard T1).

## [2026-07-05] design | B10: Game Feel Bible PROPUESTA (abre Fase 1)
Página nueva [[Game Feel Bible]] (`propuesto`), anclada en los valores
vivos del prototipo (FOV-kick 8°, stutter 0.03 s/m, cam-thump 0.18 s).
4 canales: tiempo (hit-stop 40/70/110 ms por masa de arma; parry =
dilation 0.2×0.35 s, no se apilan), screen-shake (modelo trauma², cap 0.6,
Perlin; el shake comunica masa ajena, el impacto propio habla por
thump/stutter), cámara de combate (DECISIÓN MAYOR propuesta: libre +
soft-assist, sin lock-on duro — el momentum del Duelist manda; revisable
en Gate 1), y feel del Springboard (windup 0.4 s, apex float g×0.5 0.2 s,
sting T2/T3; degradado post-traición sin float/sting). Pendiente
ratificación del director.

## [2026-07-05] feature | Fase 0 CERRADA: C1 rename + C5 fix --skip (merge a master)
Feature Loop en `feat/fase-0-higiene` → merge --no-ff a master. **C1:**
AETHER BOUND en config/name (título de ventana), prints de boot y README
(roadmap V&V marcado histórico); identificadores internos retenidos adrede
(save path, sentinel de test_hello, `window.__BORISAWA` del build web
congelado, fallback defaultName). **C5:** `start()` invoca
`_apply_skip_arg()` cuando el fast-path llega a OFFICE; el helper quedó
idempotente respecto de OFFICE. QA: test_core ALL_PASS, autotest_scenes
10/10, autotest_slice ALL_PASS (errors=0), wilds_fps 372 en frío;
aceptación live de --skip=wilds por log FSM. Además se preserva un ajuste
manual del director en [[Lecciones]] (tiering: Opus/Fable si disponible).
**Fase actual del [[Plan-de-Produccion]]: 1 (fundaciones — el link vivo).**

## [2026-07-05] design | A1 RATIFICADA: Plan de Producción sellado — arranca Fase 0
El director ratifica el plan sin cambios (companion AI en F1, diseño B
just-in-time, regla de re-apertura por gate fallido x2). [[Plan-de-Produccion]]
→ `ratificado`; Task-Board A1 ✅. **El frente A queda cerrado completo.**
Fase actual: 0 (higiene) — C1 rename V&V → AETHER BOUND + C5 fix
`--skip=wilds` + gates QA verdes.

## [2026-07-05] design | A1: Plan de Producción macro PROPUESTO
Página nueva [[Plan-de-Produccion]] (20-State, `propuesto`). Norte único:
shippear el [[Slice of Bond]]. 5 fases con gates de Playtest Loop: F0
higiene (C1+C5) → F1 fundaciones/link vivo (B10 + PRD-006 combate mínimo +
PRD-007 Dagna companion/Springboard T1 + C4 parcial; el mayor riesgo
—companion AI— primero) → F2 espina Cinder Ascent + tiers (PRD-008/009 +
T3) → F3 arco completo 4 escenas (PRD-010/011/012) → F4 arte/audio/tuning
(gate final: playtester externo siente la pérdida dos veces). Diseño B
just-in-time (solo B10 entra); B1-B8 restantes diferidos post-slice.
Pendiente ratificación del director.

## [2026-07-05] design | A2b RATIFICADA: alcance del Slice of Bond sellado
El director ratifica la propuesta sin cambios (incluidas las 3 decisiones
señaladas: Cinder Ascent como espina, T1→T3 comprimido en una sesión sin
tope por acto, Standing fuera como sistema). [[Slice of Bond]] →
`ratificado` completo; Task-Board A2b ✅. El frente A queda: solo A1 (plan
de producción macro) abierto. Siguiente: desglose del slice en PRDs
(Feature Loops) + B10 (Game Feel Bible).

## [2026-07-05] design | A2b: alcance del Slice of Bond PROPUESTO
Propuesta completa escrita en [[Slice of Bond]] (pendiente de ratificación).
Estructura: la Estructura Dramática en miniatura, 4 escenas — cold open El
Nido (prófugo + reclutamiento + T1), espina Cinder Ascent corto (Springboard
como progresión + camp scene del ritual + T2), mini-dungeon eco del Sunken
Archive (T3 + traición con la Primera Cuña), coda Bond vacío desandando el
Ascent (ratio 80/20). Sistemas in: locomoción PRD-005, combate §4.2 mínimo
(Humano Duelist + Dagna Enano Vanguard reducido + 2 enemigos), Tether solo-
Bond sin Standing, 1 camp scene. Out: Quinteto, marcas, economía Standing,
momentos de Persona sistémicos. Duración 45–60 min. Criterio de éxito: el
playtester siente la pérdida dos veces (mecánica y emocional). Task-Board
A2b → 🔄.

## [2026-07-04] lint | Vault preparado para orquestación por Opus
El director pierde acceso a Fable a partir de 2026-07-05; revisión de
agnosticismo de modelo. Resultado: el Vault ya era agnóstico por diseño (VDD);
cambios: tiering de [[Lecciones]] actualizado (Opus = orquestador único),
7 lecciones operativas de la sesión golden-scene consolidadas en Lecciones
(trampa ALPHA del toon, quad de post, absf, Image.load_from_file en CLI, gh
sin auth → merge --no-ff, patrón PowerShell de autotests, comandos de
Start-GoldenScene/process_clump), Index desfasado de ADR-002 corregido, plan
de sesiones de arte en Current-State actualizado a "todas cerradas".

## [2026-07-04] state | Creación del Vault
Adopción del modelo de trabajo VDD × LLM-WIKI (ver [[SCHEMA]] y ADR-001).
Scaffolding: capas 10-Knowledge / 20-State / 30-Loops / 90-Raw, Index y este Log.
Frameworks fuente archivados en `90-Raw/`.

## [2026-07-04] ingest | GDD v2.2 → 21 páginas Knowledge
Ingest #1: `docs/GDD.md` (congelado con banner) compilado en 21 páginas
interlinkeadas en `10-Knowledge/`. Todas `ratificado` (el GDD venía bendecido).

## [2026-07-04] state | Migración de State + Loops v1
`20-State/`: Current-State, Task-Board (frentes A/B/C desde GDD §8),
Lecciones (desde BACKLOG.md), ADR-001, ADR-002. `BACKLOG.md` raíz archivado
como histórico. `30-Loops/`: Ingest, Design, Feature, Playtest, Lint.

## [2026-07-04] design | Fenotipos y Creación de Personaje (Sesión 1 de arte)
Nueva página [[Fenotipos y Creación de Personaje]] (status `propuesto`).
3 decisiones ratificadas por el director: Mistbound 100% humanos (se retira lo
beast-folk); enanas con trenzas/patillas ornamentadas (sin barba plena);
slider peso = solo visual (masa la fija la celda). Plan de sesiones de arte
acordado: 1 fenotipos → 3 golden scene (B11) → 2 Game Feel Bible (B10).
Repo renombrado a Aether-Bound-RPG (remote actualizado).

## [2026-07-04] design | Briefs de concept art para fenotipos
Estudio de silueta de las 3 razas mostrado y validado en sesión. Nueva página
[[Briefs de Concept Art]]: 3 prompts autocontenidos para Nano Banana 2
(fenotipos) + notas de pipeline (aprobados → 90-Raw/, evaluar contra los 5
ejes de la Art Bible). El mismo pipeline alimentará B11 (keyframes) y B9
(Speck).

## [2026-07-04] ingest | Concept art de fenotipos → 90-Raw/concept/
5 láminas Nano Banana 2 archivadas (humano, elfo lavanda+porcelana, enano
varón, enana v2 definitiva) tras 2 rondas de re-roll (1b piel, 2b→2c
proporción blindada). Todas evaluadas contra los 5 ejes; referencias cruzadas
en [[Fenotipos y Creación de Personaje]]. B13 ✅. Lección de prompt: el sesgo
"woman→alta/esbelta" se corrige poniendo la proporción como primera regla +
negativos anti-deriva (documentado en [[Briefs de Concept Art]] 2c).

## [2026-07-04] design | Fenotipos RATIFICADOS — Sesión 1 de arte cerrada
El director ratifica [[Fenotipos y Creación de Personaje]] (B12 ✅). La
Sesión 1 queda cerrada: página canónica + 5 láminas de referencia. Siguiente:
golden scene (B11).

## [2026-07-04] design | Golden scene: estrategia + brief del keyframe
Decisión de método (el director señaló que the_wilds arrastra la dirección de
arte vieja): la golden scene NO retrofitea the_wilds.gd — se construye un
diorama nuevo diminuto que persigue un keyframe ratificado; se hereda solo
tech agnóstica de look (FSM, sistema MultiMesh, mecanismo de presets, harness
A/B), nunca paletas/materiales/post viejos. Briefs 4 ("Wilds at dawn") y 4b
(variante atardecer) escritos en [[Briefs de Concept Art]]. B11 → en curso.

## [2026-07-04] ingest | Keyframes Wilds dawn/dusk → 90-Raw/concept/
`keyframe-wilds-dawn-v1.png` + `keyframe-wilds-dusk-v1.png` archivados.
Evaluación 5 ejes: línea-que-muere-con-la-distancia y rojo-único-saturado
demostrados de libro; composición idéntica entre horas (gate A/B viable).
Pendiente de ratificación del director: (a) el par como criterio de
aceptación de la golden scene; (b) decisión nueva que trajo el dusk — filos
neón teal en crestas de noche (herencia Sable nocturna, no estaba en brief).

## [2026-07-04] design | Speck: forma base ratificada + brief de 3 estadios
RATIFICADO: Speck = salamandra/axolotl luminosa (branquias-antena, cresta
erizable; rima con la Muda). Brief 5 escrito en [[Briefs de Concept Art]] —
regla nueva: los cristales del estadio 3 usan la misma geometría del God-Core
del keyframe (revelación retroactiva cosida en el arte). Avanza B9.

## [2026-07-04] ingest | Speck 3 estadios v1 → 90-Raw/concept/
`speck-estadio{1-cria,2-vinculo,3-espejo}-v1.png` archivadas. Evaluación:
identidad ✓✓ (misma criatura en las 3), beats canónicos en viñetas ✓
(estornudo/puente/imitación del Pivote), cristales E3 riman con el core del
keyframe ✓. FALLO: el crecimiento no se lee — las 3 comparten cuerpo de cría
(la edición preservó de más; inverso del caso enana 2b). Re-roll propuesto
para E2/E3 con silueta humana gris de escala + anti-chibi (prompts en sesión;
pendiente decisión del director: re-roll vs resolver escala en 3D).

## [2026-07-04] design | Keyframes RATIFICADOS + regla nocturna
El director ratifica: (a) el par dawn/dusk como criterio de aceptación de la
golden scene; (b) filos neón teal nocturnos como regla canónica de la
[[Art Bible]] (sección nueva "regla nocturna" + keyframes canónicos). La capa
3 del pipeline debe soportar glowing edges con color por hora del día.

## [2026-07-04] design | ADR-002 CERRADA: Godot confirmado + ficha de Dagna (B1)
**"A3: Godot confirmado"** — el director sella el motor con la evidencia de
la golden scene (ADR-002 actualizada; Task-Board A3 ✅). Decisión de
secuencia: B1-Dagna ANTES de A2b (la ficha del Pivote dimensiona el slice,
no al revés). Página nueva [[Dagna]] (propuesto): bio Guardiana de la Puerta,
beat de reclutamiento ("You kept the wrong promise"), tiers del Springboard
(T2 Fault Line / T3 Mountain's Answer), quiebre por ley del clan, objeto
firma "la Primera Cuña" (+ martillo si T3), brief visual sobre la enana v2.

## [2026-07-04] design | Dagna RATIFICADA + brief 7 (concept art)
El director ratifica la ficha completa de [[Dagna]] ("me gusta todo"; solo
faltaba el visual). Brief 7 escrito en [[Briefs de Concept Art]]: prompt
autocontenido NB2 con la enana v2 como ancla de anatomía; plants visuales —
cuña miniatura en la trenza (plant del objeto firma), hombreras-compuerta,
martillo-ariete. Pendiente: generar/aprobar `dagna-v1.png` → ingest.
Siguiente sesión: A2b (alcance del slice), dimensionado alrededor de Dagna.

## [2026-07-04] ingest | dagna-v1.png aprobada → 90-Raw/concept/
Lámina generada por el director y aprobada por ambos: trapecio intacto (el
ancla de la enana v2 previno la deriva esbelta), martillo-ariete ✓,
hombreras-compuerta ✓, tatuajes de gremio ✓, sin barba ✓. Nota a modelado:
la cuña miniatura de la trenza quedó tímida — garantizarla en el modelo 3D.
**Dagna COMPLETA** (ficha ratificada + lámina canónica). B1: 1/9.

## [2026-07-04] feature+ingest | Follaje por tarjetas con sprite real + 2 especies nuevas
Técnica de follaje ratificada e implementada: tarjetas alpha-cutout en cruz
sobre cascarón con normales radiales (`toon_foliage.gdshader` +
`_card_shell`). Sprite sheet del brief 6 generada por el director →
`90-Raw/concept/foliage-clumps-v1.png`; procesada a asset tintable con
`tools/process_clump.gd` (blanco→alpha, tonos casi-blancos, tinta preservada)
→ `godot/rendering/foliage_clump.png`. Especies nuevas en la golden scene:
**pino** (tiers cónicos de tarjetas) y **jacaranda** (tronco bifurcado +
paraguas lavanda; claves de preset pine/bloom/bloom_dark por hora). El look
Moebius de copas festoneadas quedó funcionando en las dos horas.

## [2026-07-04] feature | Golden scene RONDA 2 CERRADA — look capturado como sistema
Director aprueba ("buen punto; después fine-tuning"). Entregado sobre la v0:
color alineado a keyframes (valor de acuarela: sombras luminosas, ambient_lift
0.24, shadow_opacity por hora) · terreno con relieve (vaguada+montículos) ·
árboles con anatomía Moebius (esqueleto recursivo de ramas, grumos del sprite
del director SOLO en puntas, 3 especies: caducifolio/pino/jacaranda) ·
God-Core facetado (columnas prismáticas + facetas con banda propia) · god
rays · regla nocturna teal. **El look es ahora un sistema replicable:**
melancolia_post + toon_golden + toon_foliage + foliage_clump.png + tabla
PRESETS. Gates: test_core ALL_PASS, FPS 432-530 (≥60). Merge a master.
Fine-tuning pendiente anotado en B11: corteza/curvatura de ramas héroe en
close-up, facetado del cristal de cerca, cel banding del terreno lejano.
Los re-rolls v2 de E2/E3 derivaron a humanoide/bípedo (E2 uncanny, E3 raptor
elegante pero otra criatura) → DESCARTADOS, no se ingestan. Decisión del
director: **cuadrúpeda en los 3 estadios** (la alternativa "se yergue en E3"
se evaluó y descartó). Prompts v3 emitidos: parten de las v1 (anatomía buena)
con candado anti-bípedo triple + silueta de escala. Lección de prompt: pedir
proporciones nuevas sin fijar la postura invita al modelo a re-anatomizar.

## [2026-07-04] ingest | Speck E2/E3 v2 (briefs v4) → 90-Raw/concept/
`speck-estadio2-vinculo-v2.png` + `speck-estadio3-espejo-v2.png` archivadas.
Los briefs v4 (generación desde cero, encuadre field-guide, spine parallel to
the ground, v1 solo como referencia de cara) resolvieron el crecimiento:
cuadrúpedas ✓, escala con silueta humana ✓ (cintura/pecho), identidad ✓,
cristales E3 riman con el core ✓, "expresión intacta" ✓. La trilogía
cría→adolescente→espejo lee el crecimiento completo. Set visual de Speck
COMPLETO — pendiente ratificación del director.

## [2026-07-04] design | Set visual de Speck RATIFICADO — sesión de arte cerrada
El director ratifica la trilogía (cría v1 / adolescente v2 / espejo v2).
B9: parte de arte ✅ (queda re-naming VFX). Balance de la sesión de arte:
fenotipos 3 razas ✅ (5 láminas) · keyframes dawn/dusk ✅ (gate golden scene)
· regla nocturna nueva en Art Bible · trilogía Speck ✅ · 3 lecciones de
prompt-craft documentadas. Siguiente: Feature Loop de la golden scene (B11).

## [2026-07-04] design | Pareja del Slice of Bond RATIFICADA (A2)
**Humano Duelist × Dagna (Seismic Springboard).** Razón principal: el
supersalto/momentum del PRD-005 ya es la base técnica del link; orfandad
mecánica máximamente legible (pierdes la verticalidad); quiebre de Dagna de
los más fuertes. Página nueva [[Slice of Bond]]. Abierto: alcance (A2b).
(En paralelo corre el Feature Loop de la golden scene en feat/golden-scene.)

## [2026-07-04] feature | Golden scene v0 APROBADA en vivo — loop cerrado (PR→master)
Diorama nuevo (claro + árboles héroe + core + 3 planos + presets dawn/dusk) +
`melancolia_post.gdshader` (4 capas screen-space) + `toon_golden.gdshader`
opaco + `autotest_golden` (A/B + modo --hold / Start-GoldenScene.bat).
Director revisó en vivo: "mucho mejor" → cierre v0. Gates: test_core ALL_PASS,
FPS 510/625 (≥60). **Evidencia ADR-002: las 4 capas corren en Godot a 8–10×
el presupuesto.** Lecciones nuevas: el toon del prototipo escribe ALPHA (pase
transparente → invisible a screen_texture); quads de post van en pase
transparente; absf/abs en inferencias GDScript.
**Ronda 2 abierta (gaps):** calidez+rayos del dawn · core como racimo de
cristal · árboles nudosos sin costuras · bandas cel visibles.
