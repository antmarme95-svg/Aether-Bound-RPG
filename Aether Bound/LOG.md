# LOG — bitácora append-only del Vault

## [2026-08-21] código | Dagna vive en el motor — el rig no había que construirlo, había que rescatarlo

Boris preguntó si valía la pena avanzar un render de personaje con los assets
que salieron de Unity, y luego pidió crear a Dagna usando `_apply_build`. La
respuesta corta: **`_apply_build` existe, pero no estaba en el proyecto vivo —
y Dagna ya estaba construida.**

**Hallazgo que cambia el plan.** El hard reset de [[ADR-003 Reset de desarrollo
y motor]] dejó `godot/` con solo el spike gris del playtest. Pero el tag
`archive/prototipo` (2026-08-10, ya con `feat/c6-anatomy-rework` mergeado)
tiene a Dagna **entera**: `data/characters.gd` la describe como
`origin: ironblooded` + `class: warrior` + fenotipo + **8 piezas firma**
(túnica de guardiana, hombreras-compuerta, espinilleras, cuña en la trenza
izquierda, tatuajes de gremio en antebrazos, martillo-ariete a la espalda,
cinturón de herramientas, faldón), y `character_signature.gd` las construye.
No hubo que diseñar nada: hubo que **trasplantar**.

**Ojo con la fuente.** Hay dos `character_rig.gd` en el repo y el obvio es el
equivocado: el worktree `.claude/worktrees/quirky-wiles-afa8a0` tiene uno de
2115 líneas de **julio** (pre-rework anatómico). El bueno es el del tag:
**3609 líneas, 2026-08-10**, con toda la escultura por masas. Regla: para
cualquier rescate del prototipo, la fuente es `archive/prototipo`, no un
worktree suelto.

**Trasplante (commit `6d167a1`, rama `feat/dagna-rig`).** Cerradura mínima de
dependencias, verificada archivo por archivo: `character/` (rig, firma,
outfit, pelo, warpaint, biomech), 4 de `data/` (characters, origins, palette,
phenotype) y `rendering/` (toon, toon_opaque, toon_golden, chrono_field,
toon_ramp, materiales, pipeline_config). **Cero autoloads** — se comprobó que
ninguno depende de `EventBus`/`Debug`/`Config`/`Feel`, así que
`project.godot` del spike no se toca y **el build congelado del playtest
queda intacto**. Corre en Godot 4.7.1 sin un solo cambio de API.

**Lámina de contraste** (`scenes/dagna_sheet.tscn` + `tests/dagna_sheet.gd`):
sonda autocontenida — no usa `GameDirector` como la vieja `tmp_dagna.gd` —
que monta a Dagna desde su config y la captura en frente / perfil / espalda /
detalle 3-4, sobre el mismo fondo de papel cálido que
`90-Raw/concept/dagna-v2.png`, en retrato 900×1200. La cámara **deriva** su
distancia del fov y del AABB real del rig, en vez de un múltiplo fijo del
alto: con el múltiplo fijo, cada ajuste de proporción cambiaba el llenado del
cuadro y las láminas dejaban de ser comparables entre rondas.

**Medición del rig: 1.534 m de alto, 0.879 m de ancho (ratio 0.57).** La
lámina pide *"nearly as wide as tall"* a 4.5 cabezas — el ratio es la primera
desviación dura y es medible, no de gusto.

**Lo que SÍ lee contra la lámina:** trenzas cobrizas con anillas, hombreras de
compuerta en ambos hombros, martillo de cabezal plano a la espalda (lee como
ariete, no como martillo de guerra ✓), túnica olivo con correa y botonadura,
cinturón, faldón, espinilleras, tatuajes ámbar en antebrazos, piel bronce,
sin barba. **La identidad de Dagna es reconocible.**

**Lo que NO, en orden de daño a la silueta:**
1. **El torso es una bola**, más ancha que los hombros; la lámina tiene pecho
   ancho con V-taper al cinturón. Las hombreras quedan *fuera* de los brazos,
   desconectadas.
2. **Rim naranja de forja demasiado fuerte** — toda la silueta brilla. La
   [[Art Bible]] dice explícitamente *no neon glow*.
3. **No hay cuello**: la cabeza se apoya en un bloque, y en el detalle se ve
   una masa de mandíbula que lee como cubo suelto.
4. Ojos como barras negras planas — la ficha pide *"la mirada calma y paciente
   de quien lleva décadas de guardia"*.
5. Pelo como casco duro de una pieza; faldón casi negro, sin lectura.

Esto **confirma el baseline ya registrado** (rostro 35%, torso ~40%) y por
tanto confirma que [[PRDs/PRD-Reescritura-Escultura-Rig-v1]] sigue siendo el
trabajo correcto: el problema es de escultura, no de configuración de Dagna.

**Sobre los assets de Unity:** `unity/Assets/` es biblioteca de tienda —
entorno y armas, y solo tres humanoides usables. Sirven de maniquí de
playtest (el puente Unity→Godot ya está resuelto en `godot/assets/dagna/` con
su bonemap), **no** para dar identidad a un Pivote. Los Pivotes salen del rig
procedural. Queda decidido cuál es cuál.

---

## [2026-08-19] código | Pasada de feel de la escena gris — gravedad a 22, y dos bugs graves

Boris jugó dos corridas del test gris. **Veredicto de tacto: bien.**
Movimiento y cámara *"se sienten muy bien"*, el botón se siente bien, y
**desde el suelo se entiende perfecto que arriba hay adónde subir** — que
era exactamente el riesgo de legibilidad que §0.4 pone en juego.

**Único ajuste: la gravedad pasa de 9.8 a 22.** Boris reportó que "se sentía
rara" y tenía razón: 9.8 es la de la Tierra y da **1.53 s de vuelo por
salto**, que en un juego se lee como flotado. Con 22 baja a 1.02 s. **El
alcance no cambió**: el impulso se recalculó a 11.24 para conservar los
mismos 2.87 m de ápice, así que ninguna altura del nivel se tocó.
Queda `--gravedad=` como argumento para comparar variantes sin romper la
geometría, y un chequeo que **falla la construcción** si `project.godot` y
el script del nivel se desincronizan.

### Los dos bugs, que salieron de mirar los CSV y no de un test

**1. El minuto 5 no era el minuto 5.** El driver acumulaba `delta`
redondeado a milisegundos por frame; con la escena vacía y sin tope de FPS
cada frame dura ~0.7 ms y redondea a 1, así que el contador corría **45%
rápido**. Medido: la fase CON duró 208.8 s y 224.1 s contra 300 de diseño —
el botón murió a los tres minutos y medio. Lo peor no es el error sino que
**dependía del FPS de la máquina**: cada tester habría recibido un test
distinto. Arreglado con reloj monotónico, que además es la misma base de
tiempo que estampa la telemetría.

**2. Cerrar la ventana descartaba la sesión entera.** Las dos corridas
quedaron sin `session_end` y el derivador las tiró teniendo todos los datos
adentro. Cerrar la ventana es la forma más natural de terminar; que eso
invalide una sesión irrepetible es un bug del hook, no del facilitador.

**Y un error mío de etiquetado:** la corrida del 18 quedó grabada como
`diego` porque el ejemplo del comando que le pasé llevaba ese nombre. Diego
sigue limpio como tester ciego. El lanzador ahora **pide confirmación** si
el nombre es uno de los tres registrados, y los ejemplos usan `prueba`.

### Lección de método que se repitió dos veces hoy

Los dos bugs los encontré **leyendo los CSV**, no corriendo tests. Los tres
tests que existían daban ALL_PASS con el reloj roto. Y al escribir el test
nuevo produje un **verde falso**: medía un salto que nunca ocurrió, porque
pulsaba antes de que la cápsula tocara el suelo, y la altura máxima salía
*por debajo* del punto de partida. Ahora el helper espera el suelo y
verifica que el salto **existió** antes de afirmar que no llegó alto.
Es la quinta vez en la semana que un instrumento reporta verde sin medir.

**Pendiente que abre esto, y lo decide el director:** en las dos corridas
hubo **2 pulsaciones muertas dentro de la zona contra 34 y 63 fuera**. No es
que no insistiera — insistió mucho, en otro lado. La zona cubre una sola
cara de una mesa que tiene cuatro. Propuesta: que rodee la mesa entera.

## [2026-08-17] canon | Ronda 3 de fixes — 6 tandas, y la clase "fijo anticipa" por fin a la fuente

Tercera vez que el mismo bug vuelve disfrazado. Las rondas 1 y 2 grepearon el patrón
**para Valen**; esta ronda lo grepeó **para la clase entera (Roen, Valen, Darro)** en todo
`10-Knowledge/`, y apareció donde nadie había mirado. Linter en 0 críticos / 0 medios
después de cada tanda, commit por tanda.

**Tanda 1 — la clase "fijo anticipa/calla la traición", los tres fijos.** Los 3 casos
conocidos (`Valen:410` Dagna, `Torgan:539` Roen, `Vekka:447,449` Roen) **eran menos de la
mitad.** El grep inicial encontró **seis instancias más que ningún QA había reportado**,
todas con Roen de sujeto salvo una: `Iven:436` (*"Roen **ya sabía** y giró el hombro
igual"*), `Iven:694` (*"Sabía que pasaría"*), `Maren:425` (*"menos sorprendido… Sabía que
podrías hacerlo. Esperaba que no lo hicieras"*), `Maren:108` (línea de Roen duplicada y
con forma de prescience), `Lyris:306` (*"ya sabía, y sabía también que no llegaría"*),
`Dagna:109` (*"Roen no se sorprende"*), y `Sereth:462` con **Darro** (*"Sabía que eras
conductor"*, que además contradecía su propio 2b de incomprensión total). Se sumaron dos
más al leer las fuentes: `Dagna:262` y `Dagna:469-473`, que glosaban a Valen como *"vio el
patrón y lo dejó pasar"*.
**Fix a la fuente, no a las líneas:** la regla dejó de vivir solo en la ficha de Valen y
ahora es **fuente única en [[El Cráter — Matriz de Rutas]] §Regla de uso para las 13
fichas → *Regla de prescience***, declarada para los tres fijos, con la **salvedad de
tiempo** que faltaba: después de 2b el grupo entero sabe, pero hay que *declarar de dónde
viene el saber* (*"lo sabe desde la sala del Fragmento"*) en vez de dejar un "ya sabía"
suelto — que es exactamente lo que producía los falsos residuos en 3, 4 y 5.
**Decisión de criterio — Dagna NO es excepción a la regla de Valen.** Se mantiene el matiz
canónico (*"la única del set donde la falla no es de modelo sino de carácter"*) pero
reformulado: Valen **archivó mal igual que en las otras ocho**, solo que la carpeta
equivocada se llamaba *cortesía* — el respeto élfico le prohibió mirar de cerca, no lo hizo
mirar y callar. `Valen:258` queda intacto ("el mismo en las nueve rutas") y las dos fuentes
concuerdan.

**Tanda 2 — causalidad de la activación de Torgan (ruta Bram).** `Torgan:405` y
`Los 9 Pivotes:56-58` seguían con la versión vieja (el Council activa a Torgan *como
reacción* al rechazo de Bram). Reescritos a la correcta: activación **por precaución y en
paralelo**, ya corriendo la noche del Reckoning en Driftmarket, cuando Bram todavía no ha
rechazado nada; y **por la cadena propia de Torgan** (Kadrun → Great Forging Clan → clan
menor), no por el contrato de Bram. El re-grep encontró un **tercer** lugar:
`Los 5 Finales:75` (*"segundo agente activado por el Council"*), también corregido. Se
reforzó además `Bram:281`. `El Cráter §2 fila Bram` y `Geografía:1230` ya estaban bien.

**Tanda 3 — el Reckoning de Bram.** `Geografía:1140` y `Bram:205,207` decían que Bram *ya
había rechazado* o *ya intuía* en Driftmarket. Corregidos contra su propia línea canónica
(*"Iba a hacerlo hasta hace cinco minutos"*, dicha al día siguiente en la sala del
Fragmento): en Driftmarket Bram **todavía piensa cumplir**, y su pregunta al jugador pesa
algo que todavía cree que va a hacer, no confiesa una decisión tomada.

**Tanda 4 — encabezados de aritmética de Nyael.** `:51` 0-100 → **0-90**, `:62` 100-180 →
**90-190**, `:64` "80 años" → **cien años exactos**. El resto de la ficha (edad 190, 40
ejecuciones a los 50, 200 en el siglo, línea canónica de 422) ya cuadraba.

**Tanda 5 — medios.** (a) Los dos superlativos físicos de Iven se separaron por **eje**:
`:295` Driftmarket = *la única vez que se le nota **en la cara*** (falla de máscara, el
cuerpo le responde intacto) · `:335` Archive = *la única vez que **pierde el equilibrio***
(falla de control motor, la cara no dice nada). Cada uno declara al otro. (b) Las líneas de
Valen triplicadas: `Torgan:351` y `:549` dejaron de tener redacción propia y ahora citan la
de 2b; ídem `Dagna:473`. (c) `Roen:224` declara la **excepción de la ruta Bram** al "único
que hace algo en el ascenso" (ahí Speck la carga el jugador desde 2b), y `Roen:226` dejó de
apuntar a una sección que no resolvía nada. **Se verificó que Nyael NO es excepción**: ella
está ausente, Speck no, y Roen la carga como en las otras siete.

**Tanda 6 — menores.** La excepción de Nyael al beat *"el Pivote está ahí, a tres metros"*
se escribió **en la fuente única** ([[Bond y el Bond Vacío]] §El Bond vacío, punto 2: son 7
celdas, no 8) · `Roen:321` deja de llamar "su asentamiento" al asentamiento purgado
(`Roen:81` aclara que se crió en un puesto de vigilancia) · `Vekka:90` cita el superlativo
del mutismo de Darro en vez de re-enunciarlo.

**Verificación de cierre.** Doble grep final de los patrones para los tres fijos en todo
`10-Knowledge/`: **0 residuos.** Lo único que queda son los enunciados de la regla misma y
casos donde el sujeto es un Pivote o el Council (Dagna:225, Iven:186, Sereth:144/222,
Bram:78) — legítimos y fuera de la clase.

> ⛔ **El sprint sigue sin cerrar. Hace falta OTRA re-corrida en frío**, y no la puede
> correr quien aplicó estos fixes (skill `canon-qa` §Anti-objetivos). Tres rondas seguidas
> encontraron algo que la anterior no vio; el cambio de esta ronda es que la regla quedó a
> la fuente y grepeable para los tres fijos, no solo para Valen.

---

## [2026-08-17] canon | Ronda 2 de fixes de la re-corrida — 5 tandas, el sprint sigue abierto

Los 2 subagentes en frío que faltaban de la ronda 1 se corrieron y validaron el
bloque. **Congruencia semántica: 0 críticos / 1 medio / 5 menores. Dramaturgia:
3 críticos / 4 medios / 3 menores.** Esta entrada cierra los tres críticos y el
resto. Linter en 0/0 después de cada tanda.

**Tanda 1 — "Valen ya lo sabía" seguía vivo fuera de los sub-beats 2b.** La regla
de `Valen-Ficha-Expandida-v1.md` §Regla de escritura prohíbe cualquier línea con
forma de *"I know"*, y la ronda 1 la aplicó solo a los 2b. Quedaron seis líneas
señaladas (Valen §Dinámicas con Maren/Torgan/Iven/Nyael, y las fichas de Nyael y
Lyris) **más cuatro que aparecieron al barrer la clase completa** y que ningún QA
había reportado: `Maren:435`, `Sereth:86-90`, `Vekka:459` (los tres con
*"Calculé esta trayectoria entonces / Esperaba estar equivocado"*) y `Nyael:387`
(*"Valen es el único que sabe para quién trabaja Nyael"*). Las diez ahora citan la
línea 2b de su propia ruta, con forma variada — el patrón es **archivó mal la
señal**, nunca vio-y-calló.

**Tanda 2 — la escena Valen↔Nyael era físicamente imposible.** `Nyael:108-112`
tenía un diálogo cara a cara (*"Dejaste nota." / "Siempre dejo nota." / "Sé."*) en
un Acto 3 donde Nyael **no está presente en ningún momento**: su ruptura es la
ausencia en la sala del Fragmento, su captura no se ve, y su única línea es la nota
del nicho. Reescrito como reacción de Valen **a la nota**, leída de pie y devuelta
al nicho. Sobrevivió cinco rondas de QA.

**Tanda 3 — F2a-Bram no se había propagado a [[Los 5 Finales]].** La ronda 1 corrigió
la Matriz y la ficha de Bram pero dejó `Los 5 Finales:75` y `:161` diciendo
*"no aplica a Bram"*. Corregido con el matiz correcto: Bram **no traiciona** —eso sigue
en pie— pero el gate se cumple igual porque el holder es Torgan (holder = agente, sin
tercero), espejo exacto de la ruta Nyael.

**Tanda 4 — cinco medios.** (a) Causalidad invertida en el Reckoning de Bram
(`Geografía:1081`): el Council activa a Torgan **como respaldo**, no *"porque Bram ya
rechazó"* — Bram rechaza al día siguiente, en la sala del Fragmento. (b) §La Rueda de
Roen atribuía a su infancia lo que solo pudo ver en el Triune Council (Mistbound es
puesto interior). (c) Las 3 fichas de fijos describían el corredor sin las excepciones
Bram/Nyael — `Roen:257` ya tenía la versión correcta veintitantas líneas después, o sea
autocontradicción interna. (d) El epílogo F2a de Bram duplicaba la culpa que
[[Los 5 Finales]] asigna en exclusiva a F2b; se le escribió motor propio —
**intrascendencia**, no culpa: hizo lo correcto y no cambió nada, y la pulsera **se
afloja** en vez de tensarse. F2b conserva la culpa y ahora lo dice explícitamente.
(e) Aethelgard Watch ya no dice que Roen *"fue este puesto, en otra vida"*.

**Tanda 5 — seis menores.** Beat de "releer la nota de Nyael" duplicado entre Roen y
Darro → **se queda Darro**; Roen la lee una sola vez y no la vuelve a tocar. Fauna de
Mistbound en `Bram:48` aclarada como animales, no criaturas de Aether. Cadena de Torgan
en la fila Bram de la Matriz: se activa por **su propia** cadena enana, no por el
contrato del Council. Segunda mitad del beat obligatorio de F3 (*"el jugador la recoge
del otro lado del borde"*) agregada en Dagna, Iven, Maren, Sereth y Vekka. Excepción del
Bond invertido anotada en la fila Mobile Foundry de [[Los 9 Links del Pivote]] — la
ficha de Bram ya la tenía, el pendiente estaba mal descrito y quedó cerrado.

**⛔ El sprint sigue sin cerrar.** Esta re-corrida encontró 3 críticos que la anterior
no vio, uno de ellos una escena imposible con cinco rondas de antigüedad. Hace falta
otra pasada de 2 subagentes en frío, y no la puede correr quien aplicó estos fixes.

**Ambigüedad sin resolver, para el director:** `Torgan:311` tiene a Roen diciendo
*"Nunca soltó el brazo derecho en tres meses. Debí leerlo"* y `Torgan:539` tiene al mismo
Roen diciendo *"Sabía que cuando llegara el momento cumplirías. Esperaba estar
equivocado"*. Roen no está sujeto a la regla de Valen, pero las dos líneas son sobre la
misma traición y se contradicen. Requiere decisión de diseño, no se tocó.


## [2026-08-13] código | Escena gris del Protocolo A — construida y verificada

Era lo último que bloqueaba el test gris del Bond. `godot/scenes/gray_test.tscn`,
generada por `tools/build_gray_scene.gd`, con `tools/test_gray_scene.gd`
(**18 verificaciones, ALL_PASS**).

**Lo que hay:** arena de 44×44 con muros de contención, una mesa central de
12×12 a **2.4 m**, y sobre la mesa una torre de dos peldaños a **4.6 m** y
**7.0 m**. El jugador es una cápsula que solo camina — **no tiene salto
propio**, porque el encuadre que se le lee al tester dice "moverte y un botón
que te impulsa hacia arriba", y de eso depende que la cornisa sea alcanzable
solo con el botón. El botón da **7.5 m/s**, o sea un ápice de **2.87 m**, y
solo responde con los pies en el suelo.

**El test que importa no verifica que el código corra, verifica que la
afirmación de diseño sea cierta:** camina contra la mesa **desde 8
direcciones** con física real y mide la altura máxima. Da **0.00 m**. Si
hubiera cualquier otra vía de subida, al minuto 5 el tester subiría por ahí,
P daría 0 y el 🔴 sería mentira.

**Dos problemas de diseño que solo aparecieron al mirar las capturas:**

1. **El nivel no se leía.** Suelo, mesa y cielo estaban a menos de 0.25 de
   distancia en valor y todo era una mancha plana. Con ambiente alto, además,
   la cara superior de la mesa y su cara frontal quedaban del mismo tono y el
   borde desaparecía. Corregido: tres grises bien separados y ambiente bajo
   con direccional fuerte, que es lo que hace que un borde sea un borde.
2. **Desde el suelo la mesa se leía como un MURO.** Vista a la altura de la
   cámara del juego, una mesa de 2.4 m tiene la cara superior casi de canto y
   nada dice que arriba se pueda estar. Eso rompía el test por un motivo
   ajeno al pilar. **La torre se movió de al lado de la mesa a ENCIMA de la
   mesa:** dos bloques parados sobre una superficie son la forma más barata
   que existe de decir "esto es una superficie", sin cartel ni flecha ni
   objetivo escrito. Beneficio extra: ahora **toda** la verticalidad del
   nivel está del otro lado del botón, así que al minuto 5 no se pierde una
   cornisa — se pierde el piso de arriba entero, que es exactamente la forma
   de la pérdida de Dagna.

**Lección de método, otra vez la misma:** un `str.replace` de Python falló en
silencio al editar el test y dejó un bloque viejo apuntando a coordenadas que
ya no existían. Ya está en [[Lecciones]] desde el 2026-08-12 y volvió a pasar.
**Para editar archivos del repo, la herramienta que falla ruidosamente.**

**Pendiente que abre esto:** una pasada de *feel* con Boris en la máquina.
Velocidad, sensibilidad de cámara y altura del salto están puestas por número
y nadie las jugó. Si el control se siente mal, un 🔴 sería de ejecución y el
test habría costado tres sesiones para decir eso.

## [2026-08-13] canon | Re-corrida de QA del bloque "dos tiempos" — 7 tandas de fixes

Dos subagentes en frío (dramaturgia + congruencia semántica), en paralelo y sin
verse, sobre el bloque de propagación cerrado el 08-12. Todos los hallazgos se
arreglaron **a la fuente** con re-grep de la clase completa (regla 8 del
`CLAUDE.md`). Linter en **0 críticos / 0 medios** tras cada tanda; un commit por
tanda.

**Tanda 1 — la ruptura de Bram, en la fuente única.** `[[El Cráter — Matriz de
Rutas]]` §1 seguía diciendo que Bram rehúsa "en el corredor"; corregido a la
**sala del Fragmento (sub-beat 2b)**, con el corredor pasando sin toma. Mismo fix
en `[[Los 9 Pivotes]]` §segundo agente y en `[[Geografía y Ciudades]]` §THE
RECKONING variante Bram — esta última reescrita con cuidado de que **la profecía
de Tobin no anticipe lugar ni momento**, solo que hay "un segundo". Salió de paso
un residuo de la misma clase en la última cena ("al amanecer, en el corredor…").

**Tanda 2 — F2a en la ruta Bram (decisión de Boris).** F2a **sí existe** ahí, por
el mismo mecanismo de holder=agente que Nyael. La nota de la Matriz §2 pasó de
"solo ruta Nyael — Bram no llega a F2a" a cubrir las dos rutas, dejando explícito
que **"Bram no traiciona" sigue siendo cierto** y que el gate mide la acción del
jugador frente al holder, no si el Pivote traicionó. El epílogo F2a de Bram ya no
dice que *"Torgan completa la entrega"* (pisaba el paso 5): ahora Torgan
**sostiene y espera**, mudo, y la quietud del jugador es la entrega.

**Tanda 3 — origen de Roen.** Su biografía lo hacía nacer en un puesto entre The
Wilds y las ciudades humanas, con nidos acercándose cada generación —
contradecía `[[Geografía y Ciudades]]` §Mistbound Frontier (**tierra interior
remota, no la trinchera**). Reescrito como **puesto de vigilancia interior**:
libro de novedades que dice *sin novedad*, guarnición que existe por inercia
administrativa. El padre ya no muere defendiendo el puesto — lo mandan con una
columna a una purgación en otro distrito. Se ajustaron además §Años de Guardia y
§Quiebre para que el tono sea **burocracia y aislamiento**, no veteranía de
guerra, y para que la acusación de "albergaba corrupción" se lea como lo que es:
papeleo.

**Tanda 4 — Darro y Vekka.** La ficha tenía dos versiones en la misma sección
("al tercer año" vs. "el rechazo llegó al primer año, se quedó los 2 restantes").
Se eliminó la segunda y se agregó un bloque de **aritmética canónica fija**: dos
años de aprendizaje real (30-32), rechazo al tercero (33). Concuerda con
`Vekka` §Darro y `Torgan` §"Lo que Torgan sabe de Darro". El resto de la
cronología (salida a los 33, 5 años a la deriva, 38-63) cierra sin tocarse.

**Tanda 5 — Valen y Darro migran al sub-beat 2b.** Era el más grande. Las dos
fichas tenían todavía una escena de clímax única en el cráter, escrita para la
revelación vieja de un solo tiempo:

- **Valen** decía *"I know"* (saber y callar), lo cual contradice las nueve
  celdas, donde su beat es **haber archivado mal la señal** ("I filed it as
  homesickness", "I logged both… I did not connect them"). Se escribió §Escena 1
  con el patrón general + **las nueve líneas citadas por wikilink, no
  reescritas**, y una regla de escritura que prohíbe toda formulación de
  saber-y-callar.
- **Darro** "explotaba por primera vez en la campaña" en el cráter, lo cual
  rompía las ocho líneas de grito ya escritas en 2b y las dos excepciones de ruta
  (mudo con Vekka, sentado en silencio con Dagna). Mismo tratamiento.

Las escenas del cráter se **recortaron, no se borraron**: quedan como reacción
contenida de quien ya lo sabía. **Corolario resuelto:** la frase genérica de
"se sienta lejos del grupo en silencio absoluto" ya no aplica a las nueve rutas —
está condicionada explícitamente a las siete que no son Vekka ni Dagna, así que
el superlativo *"la única vez que Darro se queda mudo"* vuelve a ser verdadero.

**Tanda 6 — siete medios.** Cadena de Dagna en `[[Estructura Política]]` (dos →
**tres eslabones**) · Reckoning de Dagna sin vocabulario de "unmaking", que es
dogma exclusivo de Vekka · Reckoning de Torgan con **mensajero del clan menor
confirmando un juramento de 55 años**, no del Great Forging Clan ni nuevo ·
activación del Fragmento **al llegar al borde** en Torgan e Iven, no como remate
post-diálogo · cadena de Lyris unificada a **Triune Council → Frontier High
Command → Lyris**, con la escolta aérea como aposición y no como eslabón · beat
de duelo F4-vivo de Iven, que era vergüenza y no duelo · Maren F1, que repetía el
dispositivo de F4.

> **Criterio para el duelo de Iven:** la vergüenza (excluirse de la historia que
> cuenta) **no es duelo** y se dejó como beat aparte. El duelo nuevo es un
> hábito: **aparta una ración en cada cena y nunca la come** — el turno de darle
> de comer, sin la criatura. No colisiona con ningún otro de los 12 ejes, y se
> ancla en su propia línea de 2b (*"Le daba de comer, carajo"*).
>
> **Criterio para Maren F1:** se cambió el vehículo, no el contenido. F4 conserva
> la nota sin firma (es su eje asignado); **F1 ya no tiene nota** — lo que llega
> al jugador es **un tercero**, años después, contando de segunda mano una frase
> que Maren dijo en voz alta para nadie en una reunión de raciones.

**Tanda 7 — cuatro menores.** "las otras ocho celdas" → **siete** (Bram no pierde
su link) · Lyris F1, donde el sujeto de "neutralizada" era ella y debía ser el
mensajero · Lyris F3, "lado seguro del borde" → **el lado del core central**,
según la Matriz · **bloque de aritmética canónica fija de Nyael**, que no tenía:
edad **190**, formación hasta los 90, **siglo de servicio pleno 90→190**, y
**240 ejecuciones totales** (40 en formación + las 200 del siglo que nombra su
línea canónica).

> ⛔ **El sprint no está cerrado.** Falta la re-corrida final con 2 subagentes en
> frío, **todavía no ejecutada** — no la puede correr quien aplicó los fixes.

**Ambigüedad detectada y no resuelta (para Boris):** `Bram` §Mistbound describe
cuarenta años de contratos "contra bestias que bajaban de laderas". Es defendible
como fauna local y no como nidos de The Wilds, pero conviene decidirlo
explícitamente ahora que la ficha de Roen fija Mistbound como **interior y sin
bestias**.


## [2026-08-13] decisión | §0 FIRMADO — el criterio de muerte del Protocolo A

Boris firmó §0 de [[Protocolo-de-Playtest]]: umbrales (§0.3), condición de
validez (§0.2) y regla de lectura negativa (§0.4). Las tres casillas.

**Lo que queda cerrado, textual:**
- 🟢 **P ≥ 3 y T ≥ 20 s** en 2 de 3 testers.
- 🟡 P = 2 en la mayoría, o los 3 divergen. Rama INSTRUMENTO.
- 🔴 P ≤ 1 en 2 de 3. Rama EJECUCIÓN mecánica.
- **Validez previa:** con **U < 2 pulsaciones/min** en la fase CON, la
  sesión no tiene resultado y la fase SIN no se interpreta.
- Un 🔴 **no falsea el pilar**, y está prohibido usarlo para replantear el
  juego, recortar alcance o abandonar. Un 🟢 tampoco lo prueba: es permiso
  para gastar en B.

**Por qué el orden importa y conviene dejarlo escrito:** se firmó **antes de
que existiera la escena gris**, o sea antes de que hubiera un solo dato que
pudiera contaminar el criterio. Era la condición que el consejo del 08-13
puso como no negociable — *medir sin umbral pre-comprometido es confirmación
disfrazada de método*. Cumplida.

Los cuatro números están replicados como constantes en
`godot/tools/telemetry_analysis.gd`, con el comentario de que a partir de
ahora tocarlos es un commit con fecha y autor. El informe imprime la fecha
de firma en cada corrida.

**Casilla que sigue abierta:** el hash del build congelado, porque la escena
gris todavía no existe. Lo que falta ya no es el criterio — es el build.

## [2026-08-13] código | Hook de telemetría del Protocolo A — implementado y verificado

Primera línea de código escrita después del consejo, y es la que el
[[Protocolo-de-Playtest]] §4.1 marcaba como bloqueante de la métrica
primaria: sin esto, el test gris del Bond no tiene P, T ni U.

**Seis archivos en `godot/`:** `scripts/telemetry.gd` (el grabador),
`scripts/ledge_zone.gd` (el volumen de la cornisa), `scripts/bond_driver.gd`
(el botón y el corte del minuto 5), `tools/telemetry_analysis.gd` (deriva y
clasifica), `tools/telemetry_report.gd` (informe y veredicto) y
`tools/test_telemetry.gd` (**50 verificaciones, ALL_PASS**).

**Tres decisiones del código que son del protocolo y no de ingeniería:**
1. **El hook no filtra.** Registra cada pulsación —viva o muerta, dentro o
   fuera de la zona— y filtra el derivador. Si filtrara el hook, el dato se
   perdería sin forma de recuperarlo terminada la sesión.
2. **Flush por línea.** Una sesión no se puede repetir: si el build se
   cuelga en el minuto 9, los 9 minutos tienen que estar en disco.
3. **Los umbrales no se pasan por línea de comandos.** Son constantes.
   Cambiarlos es un commit con fecha y autor, que es lo que §6 pide.

**Un hueco encontrado al correr el informe de punta a punta:** una sesión
cuya fase CON duró 0.1 s salió clasificada 🔴 como si fuera un resultado. El
protocolo lo cubre por el lado humano (el facilitador la marca como fallo
técnico) pero depende de que se acuerde. Se agregó una **bandera** que avisa
cuando la fase CON duró mucho menos de lo diseñado — **y no reclasifica**.
Un umbral que Boris no firmó no puede mover un resultado.

**Tres lecciones a [[Lecciones]], las tres verificadas:**
- **Un error de compilación no hace fallar un test de GDScript.** El test
  imprimió `ALL_PASS` con un bloque entero muerto. Cuarta vez en dos días
  que un instrumento reporta verde sin haber medido. Regla nueva: todo
  script que el test instancia se verifica con `can_instantiate()` antes.
- En `--script` no se puede inferir tipo desde una función que devuelve una
  clase global; la caché de `class_name` no está garantizada.
- Un cuerpo físico que nace en el origen y se teletransporta dispara un
  enter/exit fantasma. **El jugador nace donde arranca.**

**Lo que sigue siendo trabajo:** la escena gris. El hook está listo y
probado; falta el nivel — geometría de caja, cápsula, y una cornisa
alcanzable solo con el botón.

## [2026-08-13] método/playtest | Protocolo de Playtest — dos protocolos y el criterio de muerte firmable

**Encargo de la sesión técnica**, derivado del consejo del 2026-08-13
(`90-Raw/council-2026-08-13-veredicto-motor-y-alcance.md`). Escrito en
[[Protocolo-de-Playtest]].

**Son dos protocolos, no uno**, porque el consejo partió el playtest en
dos etapas de costo muy distinto: **A**, el test gris del Bond (cápsula,
cornisa, 5 min con el botón y 5 sin él, sin arte ni diálogo), y **B**, la
sesión completa del slice con registro separado por eje. **B se corre solo
con verde en A.**

### Lo que el documento resuelve

**§0, el criterio de muerte, va primero y se firma antes de que un tester
toque el build** — es la única sección que pierde todo su valor si se
escribe después. Propuesta de umbrales sobre los 3 testers: 🟢 **P ≥ 3 y
T ≥ 20 s** en 2 de 3 · 🟡 P = 2 o divergencia (rama INSTRUMENTO) · 🔴 P ≤ 1
en 2 de 3. El razonamiento del 3 quedó escrito: **una pulsación es error de
dedo, dos es comprobar, tres es negarse a aceptarlo.**

**Condición de validez previa al resultado**, que es la objeción del
Outsider convertida en gate: si **U < 2 pulsaciones/minuto** durante la
fase con el botón vivo, la fase sin él **no se interpreta**. No es
"resultado negativo": es **sin resultado**. Primero hay que probar que
tener el poder es adictivo.

**La regla anti-suicidio (§0.4), que es lo más importante del documento.**
Un 🔴 en el test gris **no puede falsear el pilar**: un cubo sin vínculo ni
fidelidad mide un reflejo motor, no duelo. Queda prohibido por escrito usar
un negativo de A para replantear el juego, recortar alcance o abandonar el
pilar — solo habilita conclusiones de **ejecución mecánica**. Y la trampa
simétrica también quedó escrita: un 🟢 tampoco prueba el pilar, solo compra
permiso para gastar en B.

**Simetría con el audio (§9.3):** mientras el build esté mudo, **está
prohibido concluir la rama DISEÑO** del árbol de ADR-003, porque con la
mitad del canal ausente "entendieron todo y no les importó" es
indistinguible de "faltaba la mitad del golpe".

### Los 4 riesgos del consejo, con instrumento

**GIF/wishlists** → preguntas 13 (*"contale este juego a un amigo en una
frase"*) y 14 (*"¿qué seis segundos le mostrarías?"*), con una casilla que
codifica si lo que mostraría es **una ausencia**. **Audio** → pregunta 10
más la regla de §9.3. **Objeción del Outsider a Bram** → pregunta 12, con
redacción deliberadamente neutra (no dice "se desbloquea al perder" ni
vende el misterio) y codificación de tres valores. **Posesión antes que
pérdida** → la condición de validez de A, más la pregunta 2 (*"¿qué fue lo
más divertido?"*, ubicada **antes** de cualquier mención de la pérdida) y
los inputs por minuto partidos en tres tramos para ver si el uso **creció**.

### Decisiones de método que quedaron escritas

- **El orden de las preguntas es parte del instrumento**: abierto antes que
  cerrado, comprensión antes que emoción, y ninguna pregunta puede adelantar
  información de las siguientes. En A, la pregunta 5 es la primera que
  revela que el botón dejó de funcionar y **no puede ir antes**.
- **Frase única de deflexión** para las dos sesiones — *"Seguí como te
  parezca."* — con la excepción explícita de que después de la traición
  también aplica, porque ahí es donde más tienta consolar.
- **Cada pregunta mapea a una rama del árbol de fallos o a un riesgo
  declarado**, en columna. Regla escrita: si una pregunta no mapea, sobra.
- **En el Protocolo A el botón NO es Dagna** y no se le pone nombre: meter
  media ficción contamina sin comprar fidelidad, y es justamente lo que
  hace que A no pueda falsear el pilar.
- **El autoinforme se contrasta con la telemetría** (pregunta 6 vs. P
  real): la brecha entre lo que el tester recuerda y lo que hizo es dato.

### Dependencia especificada, no resuelta

**Hook de telemetría** (§4.1), para la sesión técnica: 5 eventos
(`session_start`, `phase_change`, `ledge_zone_enter`/`exit`, `bond_press`,
`session_end`) con sus campos, y la definición operativa de "frente a la
cornisa" como volumen de disparo — **sin filtrar por orientación de
cámara**, porque filtrar mete criterio interpretable justo donde el
documento promete conteo. P, T y U salen del CSV sin trabajo manual.

### Discrepancia detectada y NO resuelta

[[Slice of Bond]] describe **4 escenas** y [[ADR-003 Reset de desarrollo y
motor]] lo recorta a **3**; el slice pide **T1→T3** y el consejo del 08-13
pide **un link de 1 tier**. El Protocolo B funciona con cualquiera de las
dos versiones, pero la hoja del eje gameplay cambia si hay un solo tier.
Anotado como pendiente de alcance, no de protocolo.

**Qué se tocó:** archivo nuevo en `20-State/` · [[00-Index]] ·
[[Current-State]] punto 8. **Linter en 0 críticos, sin correcciones.**

## [2026-08-13] consejo | Veredicto de motor y alcance de v1 — segundo consejo

Boris cerró la decisión del desbloqueo de Bram (**se deja en 2 builds en la
primera partida**, la vitrina flaca se acepta a cambio del beat y del ahorro
de onboarding) y mandó a consejo
[[Veredicto de Motor y Lectura del Proyecto]].

Transcript completo en
`90-Raw/council-2026-08-13-veredicto-motor-y-alcance.md`. Nota de método:
la ronda de peer review corrió con **3 revisores en vez de 5** — la primera
tanda de 5 murió por límite de gasto.

**Unanimidad:** playtest antes que guión (5 de 5) · Godot ratificado y
congelado, cero re-evaluaciones de motor hasta que exista un slice jugable ·
el pilar es una hipótesis sin un solo dato — cinco consejeros
independientes escribieron la misma frase: nadie midió que la ausencia
produzca **duelo** y no simplemente **molestia**.

**Choque principal:** ¿1 Pivote o 3? El Ejecutor y el Contrarian piden
construir Dagna sola cronometrada y dejar que el número decida; el
Expansionista defiende el 3 como enfoque vendible. Resolución del
presidente: **el trío queda en el papel como intención, no como compromiso
de producción**, hasta tener la constante horas/Pivote.

**Bram sobrevive, por una razón distinta a la que se lo eligió.** Tres de
cinco consejeros lo querían fuera de v1 (es la única ruta que no entrega el
pilar). Pero al ser la ruta que se desbloquea es **lo último que se
construye**, o sea cortable a costo cero hasta el final. La objeción del
Outsider —*"nadie rejuega para NO perder algo"; el jugador nuevo percibe
menos contenido, no un misterio*— queda como riesgo a medir en el playtest.

**Corrección del presidente al consejo:** los cinco piden abstinencia total
de escritura. No se acepta. Escribir es donde el director es rápido y donde
se repone, y este proyecto no tiene fecha de fracaso pero sí riesgo de
abandono. **Cadencia mixta:** el guión sigue, deja de ser el frente
principal y se limita al material del slice.

**Lo primero, y único:** el **test gris del Bond** — escena gris, cápsula,
una cornisa, Dagna reducida a un botón que lanza hacia arriba, 5 minutos con
ella y 5 sin ella, sin arte ni diálogo. Métrica contable: pulsaciones del
botón muerto frente a la cornisa, y segundos hasta que el jugador deja de
intentar. **Con el criterio de muerte escrito ANTES de correrlo** — medir
sin umbral pre-comprometido es confirmación disfrazada de método.

**Puntos ciegos que atrapó la revisión por pares y que nadie del proyecto
había nombrado:** el gancho es una ausencia y no se captura en un GIF de 6
segundos (riesgo de wishlists, no de diseño) · el golpe de la pérdida es
**50% audio** · el acoplamiento 1:1 Pivote↔build raza×rol es la causa
estructural de que cortar cueste builds jugables, y desacoplarlo cambiaría
toda la aritmética del trío · el dato de la rampa es costo de curva de
aprendizaje, no ritmo estable · Brothers, Ico y BT en Titanfall 2 ya
validaron variantes del pilar, gratis.

## [2026-08-12] canon + guión | The Long Vigil (primer jefe) y Waypost — Los Cinco: el Acto 1 queda completo

Dos piezas en una tanda, a pedido de Boris: cerrar el hueco del primer
jefe y escribir la escena que cierra el acto.

### 1. The Long Vigil — [[Bestiario]] §The Long Vigil (grado Corrupto)

Cierra el hueco detectado al escribir [[Guion/El Nido — El Primero]]:
[[Geografía y Ciudades]] lo listaba como *"Primer jefe: bestia corrupta
guardiana"* y no existía en ningún documento.

**Qué es, y sale entero de canon ya escrito:** [[Speck]] dice que *"Speck
fue colocada en crisálida por bestias guardianas poco después del
cataclismo"* y que hoy están semi-corrompidas y atacan. The Long Vigil es
**la última de ésas**. No encontró el nido: lo construyó y se quedó. 550
años de guardia, y lo que la corrupción le comió no es el cuerpo sino **la
memoria de para qué estaba ahí** — ejecuta la conducta con el propósito
vaciado.

**El moveset ES la caracterización**, y ése es el punto de la ficha:
- **No persigue.** Si el grupo retrocede, vuelve a su posición frente a la
  crisálida. Único boss del juego que **cede terreno y lo recupera**.
- **Siempre se interpone:** su lógica de posición no busca al más cercano
  ni al más débil, busca quedar **entre el grupo y la crisálida**.
- **Fase 2 por amenaza, no por vida:** cambia cuando alguien se acerca
  demasiado a la crisálida, no al bajar de X% de salud.
- Como es pelea de posición y no carrera de daño, obliga a usar el
  vocabulario de links ya enseñado.

**Lo que le hace a la escena:** el jugador mata, en su primer jefe, a lo
único que seguía cuidando a Speck — **y nadie en la ficción lo sabe**. Es
la hermana de la siembra del God-Core: dos profanaciones involuntarias en
la misma locación, ninguna subrayada. El **loot** es una lámina del
caparazón **del mismo material que la crisálida**: única pista física, sin
explicación.

**Deliberadamente sin decidir:** si la pelea se puede terminar sin matarla,
retirándose. Cruza con la elección ilusoria —dos "no puedo hacerlo"
seguidos serían uno de más— así que queda abierto y anotado, no asumido.

### 2. [[Guion/Waypost — Los Cinco]] — cierre del Acto 1

Darro se suma último (casual, nunca noble: su ficha dice *"estaban en el
mismo bar bebiendo sus fracasos"* — **Waypost es ese bar**), se enseña su
link *Open Seam*, conoce al Pivote y a Speck, y el grupo se vuelve equipo.

**El aporte de la escena al beat de formación** (cuya fuente única sigue
siendo [[Geografía y Ciudades]] §Beats Narrativos por Acto, locación 4 —
el guión lo dramatiza, no lo re-enuncia): **quién lo dispara.** Es
**Darro**, con una pregunta de cortesía — *"So what happens tomorrow?"*.
Es el único que puede hacerla sin que pese: acaba de llegar y no le debe
nada a nadie. Si la hace Roen es liderazgo, si la hace Valen es
diagnóstico, si la hace el Pivote es sospechosa en retrospectiva. **El
grupo se forma porque el recién llegado preguntó algo de cortesía.**

**Nadie contesta**, y eso es el beat: en el lugar de la respuesta hay una
acotación —para el lector, no para el jugador— que dice que los cuatro
tienen a dónde ir, que la puerta está a treinta pasos y que no es tarde.
Roen, el único con contrato explícito y el único que *debería* levantarse,
pide *"Same again."* Nadie comenta que la pidió.

**El puente con el bookend, sin señalarlo:** Roen gira el vaso un cuarto
de vuelta; el Roen viejo gira el anillo de cobre en la misma sala treinta
años después ([[Guion/Apertura — Roen Viejo]]). El guión **no lo marca**.
Si el jugador lo nota, lo nota en la segunda partida o nunca — que es la
forma correcta de cobrar que bookend y formación compartan lugar.

**El silencio del jugador acá ya no es gratis:** habló en El Nido, así que
en esta mesa **puede** hablar y no lo hace. Es la ganancia que dio subir
el gradiente un acto, y la razón por la que la escena no necesitó
reescribirse cuando el gradiente cambió.

**Verificaciones que evitaron errores:** el **Bautizo NO es acá** (es Acto
2, después de que el grupo entero la vea comportarse de forma inteligente)
— para Darro, Speck todavía es *"un zorro raro que el grupo carga con
demasiado cuidado"*. Y Speck bajo la mesa al final **no es un Momento de
Persona**: el Acto 1 tiene uno solo y agregar otro alteraría el gate de F4.

### Estado

**El Acto 1 queda con guión completo**: las 5 escenas escritas, todas
`provisional`, compartiendo una sola re-corrida de QA. Lo que queda es
extracción, no diseño: las **tarjetas por Pivote** (4 slots en El Nido, ya
existentes en las fichas; 2 en Waypost, de los cuales **el de la silla es
nuevo** y no existe en ninguna ficha) y la traducción al inglés de guión.

**Qué se tocó:** [[Bestiario]] (sección nueva) · archivo de guión nuevo ·
[[Geografía y Ciudades]] §Beats (el "primer jefe" ahora nombra la ficha) ·
[[Guion/El Nido — El Primero]] (§Hueco → §cerrado, y el boss entra en el
cuerpo del guión) · [[00-Index]] · [[Current-State]].
**Linter en 0 críticos, sin una sola corrección** — primera vez en el día.

## [2026-08-12] guión | El Nido — El Primero (Acto 1, locación 3): la primera palabra del juego

**Qué se escribió:** [[Guion/El Nido — El Primero]], `status: provisional`
— la escena más cargada del Acto 1. Cinco cosas en orden: guardianas
semi-corrompidas que escalan al **primer jefe** · la crisálida · **el
Pivote se suma** · **la elección ilusoria** · **el primer God-Core**. Entre
las dos últimas cae el **Momento de Persona 1**, el único del Acto 1.

**La decisión de la escena: la primera palabra es "No.", y no es un adorno
— arregla algo.** La elección ilusoria ([[Speck]] §El encuentro, fuente
única) tenía un riesgo de lectura: el jugador aprieta y el juego no lo
deja, lo que se puede sentir como **el motor anulándolo**. Poniendo ahí la
primera palabra del protagonista, el beat se da vuelta: no es que el juego
no te deja, es que **el personaje se niega**. Mecánica y personaje dicen lo
mismo al mismo tiempo, y una limitación pasa a ser caracterización.

Cumple el gradiente al pie de la letra ([[Voz Narrativa]] §Voz del
protagonista): una palabra, reactiva, no propone nada, y **no se la dice a
ninguna persona** — se la dice al contrato, que es lo único que le estaba
dando una orden. Primera desobediencia al Triune Council, en una sílaba.
**Es su única línea en toda la escena** (regla 6, escasez).

**La regla invariable que la escena aporta:** el Pivote **tiene que estar
mirando cuando el jugador duda**, porque la elección ilusoria *"le da a
cada Pivote su primera lectura del jugador"*. Si una ficha lo hace llegar
después, la que está mal es la ficha. Lo demás varía y ya estaba escrito:
**4 slots por Pivote** (llegada · combate · lectura de la duda · reacción
a Speck saliendo), los 9 juegos completos en las fichas — la escena no
duplica ninguno, solo tipifica el hueco. Las 3 preguntas de Valen por rol
cubren los 9 Pivotes.

**La siembra del God-Core.** El jugador apaga el primero **con Speck
mirando**, y en el Acto 3 el Archive revela que *"cada core que el grupo
destruyó en el Acto 1 era un cadáver profanado"*. Ella ya lo sabe acá. La
escena no lo insinúa con música ni primer plano: la deja mirando y sigue.
El único subrayado permitido es el *"That's one." / "That's one."*
duplicado de Roen y Valen — funciona porque el jugador todavía no puede
entenderlo.

**Chequeo que evitó un bug de sistema:** la reacción de Speck al God-Core
**no es un Momento de Persona**. El Acto 1 tiene uno solo (el 1,
desambiguado 2026-08-11) y el gate de F4 se calcula sobre los Momentos
disponibles en esa partida — agregar uno acá habría alterado el cálculo de
**todas** las partidas. Queda como puesta en escena, sin lectura
herramienta/mascota/persona.

**⚠️ Hueco de canon detectado, no cerrado:** **el primer jefe del juego no
tiene ficha.** [[Geografía y Ciudades]] §Beats lo lista como *"Primer jefe:
bestia corrupta guardiana"* y [[Bestiario]] no tiene entrada — sus 7 bosses
con ficha están todos en landmarks o dungeons del mundo abierto. **No se le
inventó nombre**: por la regla del propio Bestiario, lo que tiene nombre
tiene ficha, y una ficha de boss es decisión de diseño, no de guión. Es el
primer combate memorable del juego y hoy no existe en ningún documento.

**Qué se tocó:** archivo nuevo · [[00-Index]] ·
[[Guion/Frontera — Camino al Nido]] §Pendiente · [[Current-State]].
**Linter en 0 críticos** (2 de la primera corrida, ambos `§` sin cerrar —
la trampa de siempre).

## [2026-08-12] canon/ratificación | Los 3 anclajes del gradiente de voz — aprobados

**Boris ratificó la propuesta completa de la entrada anterior** ("de acuerdo
con todo"). Los 3 anclajes dejan de ser propuesta y pasan a canon en
[[Voz Narrativa]] §Voz del protagonista:

- **Primera palabra → El Nido** (Acto 1, locación 3).
- **Pico del Acto 2 → la oficina de Old Tobin Hale.**
- **El discurso, único del juego → el Archive, a solas con Speck**, después
  de la revelación de los Goggles y minutos antes de la ruptura en la sala
  del Fragmento.

Con esto, **toda la sección es canon**: gradiente, las 8 reglas de
escritura, los 3 anclajes y los grados de voz de los 5 finales. Se quitó el
lenguaje de "propuesta / candidato" de la tabla y de las reglas 1 y 3.

**Lo único que queda abierto** (anotado en §Pendiente de esa sección):
cotejar la tabla de finales contra [[Los 5 Finales]] cuando se escriba ese
guión —F4, donde la que responde es Speck, y F2b, donde el silencio total
tiene que sostenerse sin que la escena se sienta incompleta— y la decisión
de **voice-over sí/no**, que sigue sin tomarse en ningún lado del vault y de
la que depende cuánto pesa la regla 5 (ninguna línea nombra raza/rol/género,
para que una línea escrita sean 6 tomas y no 18).

**Qué se tocó:** [[Voz Narrativa]] · [[Current-State]]. Ninguna escena de
guión cambió. **Linter en 0 críticos.**

## [2026-08-12] canon/decisión | Gradiente de voz, 2ª pasada: sube un acto, gana un discurso, y los 5 finales devuelven voz distinta

**Boris revisó el gradiente que se había fijado horas antes** (entrada de
más abajo). Dos cambios de fondo: **todo sube un acto** y aparece un **pico
de elocuencia** en el Acto 3. Además, el cráter deja de tener un grado
único de voz. Reescrito en [[Voz Narrativa]] §Voz del protagonista, que
sigue siendo fuente única.

**Gradiente vigente:** tramo mudo inicial → **primeras palabras en el Acto
1** (cortas, reactivas, nunca discursos) → **líneas completas en el Acto
2**, donde por primera vez *inicia* intercambios → **un discurso, uno solo,
en el Acto 3** → **silencio en la traición** → **grado variable por final**.

**Los 5 finales, grados de voz** (decisión de Boris, F4 explícita):
**F1** mínima (no interviene; el precio lo nombra Valen) · **F2a** presente
pero vaciada, registro casi administrativo — la elocuencia del Acto 3
gastada en un trámite · **F2b** **silencio total, no se levanta nunca**:
la mano fue suya y el arco del habla queda sin pagar a propósito · **F3**
plena pero al servicio de justificarse · **F4** **plena y con el carisma
intacto, porque Speck eligió por sí misma y por nadie más** — el único
final donde hablar bien no es culpa, defensa ni trámite. Regla que ata la
tabla: **en ningún final el jugador explica el final** — la lectura de
consecuencias le sigue tocando a Valen en las 5 ramas.

**Verificación que cambió la propuesta: los dos candidatos de Boris para el
discurso del Acto 3 son de Acto 2.** Old Tobin Hale vive en el Driftmarket,
que es Acto 2 / The Reckoning; Grove of Cycles es explícitamente el cierre
del Acto 2 ([[Valen-Ficha-Expandida-v1]] §Grove of Cycles). Resolución:
- **Tobin queda, pero como pico del Acto 2** — es donde el jugador recibe
  los Goggles y entiende su propio poder, y es **el único personaje de
  poder sin agenda oculta** del juego: el único interlocutor seguro que el
  protagonista va a tener. Que su tramo más largo hablado hasta ahí sea con
  el único que no lo está midiendo es coherente con todo el elenco.
- **Grove of Cycles se descarta como escena de discurso** — y esto es un
  choque real, no una preferencia: ahí el **silencio del jugador durante el
  debate de los élderes ya es un disparador mecánico** del encuentro
  individual. Convertirlo en discurso rompería un trigger existente. Queda
  anotado "dejar el silencio del Grove intacto".

**Propuesta para el discurso del Acto 3: el Archive, a solas con Speck**,
justo después de que los Goggles revelan la proyección residual del duelo
de la última Warden —que es ella misma— y minutos antes de la ruptura en la
sala del Fragmento. **Compatibilidad verificada con el canon de los
Goggles:** [[Geografía y Ciudades]] §ACTO 3 sub-beat 2 dice *"El jugador ve
lo que el grupo no ve. No lo dice. No sabe cómo decirlo"* — esa frase es
sobre **el grupo**, y el discurso no la viola: le habla **a ella**, la
única que ya lo sabe y la única que no puede repetirlo. Los Goggles siguen
estrictamente privados, Valen sigue sin ver la capa, y la revelación se
sigue cargando en soledad todo el Acto 3. Habla mejor que nunca, y lo
próximo que le pasa es quedarse mudo: **la distancia entre las dos cosas es
el arco entero.**

**Efecto colateral bueno, gratis, sobre el beat de Waypost:** con las
primeras palabras en El Nido (locación 3), cuando el grupo se sienta en
Waypost (locación 4) el protagonista **ya tiene voz y no la usa**. Su
silencio en la formación deja de ser el estado por defecto y pasa a ser una
elección más de la mesa, igual que la de los otros tres. **El beat no se
reescribió — se fortaleció solo.**

**Lo que NO cambió:** las 3 escenas ya escritas
([[Guion/Encuentro con Roen]], [[Guion/Caminata y Taberna — Valen se
suma]], [[Guion/Frontera — Camino al Nido]]) caen todas en el tramo mudo
previo a El Nido. Cero líneas tocadas. Y el beat de "Speck" se conserva
**demotado**: ya no es la primera palabra del juego, pero sigue siendo el
**primer nombre** que el protagonista dice — un nombre que inventó otro.

**Barrido de la clase:** grep de "Acto 1 mudo / piso del gradiente /
primera palabra" → 5 lugares enunciaban el gradiente viejo (las 3 escenas,
el beat de Waypost en [[Geografía y Ciudades]], el [[Current-State]]).
Los 5 corregidos. Las entradas viejas de este LOG **no se tocan** (es
append-only: describen lo que era cierto cuando se escribieron).

**Pendiente anotado:** los 3 anclajes concretos (El Nido, Tobin, Archive)
son **propuesta, no decisión de Boris** — el gradiente y los grados de los
5 finales sí son suyos. Y la tabla de finales hay que cotejarla contra
[[Los 5 Finales]] cuando se escriba ese guión, sobre todo F4 (donde la que
responde es Speck) y F2b (donde el silencio total tiene que sostenerse sin
que la escena se sienta incompleta). **Linter en 0 críticos.**

## [2026-08-12] guión | Frontera — Camino al Nido (Acto 1, locación 2): el T1 de Valen y la torre como puerta

**Qué se escribió:** [[Guion/Frontera — Camino al Nido]], tercera escena
jugada, `status: provisional`. Sigue directo de
[[Guion/Caminata y Taberna — Valen se suma]]. Tres tramos: el radio del
reino → la torre de guardia → The Wilds hasta la boca del nido. Sin nuevo
compañero (el Pivote se suma en el nido).

**El hallazgo estructural: la torre ya era la puerta.** [[Geografía y
Ciudades]] §M pone las 3 torres **del lado salvaje**, no en territorio
propio. Así que cruzarlas *es* dejar el reino, y no hubo que inventar
ninguna frontera nueva. Cada variante dice algo distinto del reino con el
mismo trámite: **los humanos anotan** (el puesto es el registro de purgas,
llevan bitácora de qué nidos se limpiaron), **los enanos recuerdan**
(guarnición fija, la misma familia por generaciones: *"Third crossing this
season. Two came back." / "Which two?" / "The ones who turned around."*),
**los elfos miran** (nadie los detiene, nadie anota nada, y el centinela
sigue mirando después — con la línea canónica de Valen, *"vigilamos, pero
rara vez actuamos"*).

**El beat de Roen en el puesto humano sale gratis de la geografía.** Roen
sirvió 15 años como guardia del Council y **renunció por una purga**
([[Roen-Ficha-Expandida-v1]] §Quiebre). Que ahora lo anoten a él en el
registro de purgas, para un trabajo que aceptó, es la ironía que el mapa
ya tenía puesta. No la subraya nadie: pregunta si alguien lee el libro, el
chico contesta una tontería, siguen caminando.

**El T1 de Valen, enseñado en dos beats separados y en ese orden.** Discord
primero (marca a un enemigo — el jugador ve el efecto en el daño que él
mismo hace), Harmony después (marca al jugador — el efecto es sobre su
propio cuerpo). Juntos se leerían como "dos botones"; separados se leen
como un personaje con dos formas de intervenir sin tocar a nadie. El swap
forzado (un solo orbe a la vez en T1) convierte la limitación en decisión.

**La mecánica es la caracterización.** *"I calculated how much of this
they're going to take, and I started paying it back early." / "You
calculated that." / "Before we left the city."* — es la descripción
literal de Steady Variable y, a la vez, la cosa más fría que se le puede
decir a alguien. La tensión Roen/Valen avanza sin escribir una discusión.

**[[Acoplamientos]] sin caja de tutorial:** es el primer tramo donde un
Duelist tiene daño **pleno** sostenido, porque por primera vez hay un
Strategist en el grupo. El jugador lo va a *sentir*; nadie se lo explica.

**Sin fauna con nombre**, a propósito: [[Bestiario]] es explícito en que
los grados Sano y Ambiental no llevan ficha y se generan por sistema. El
primer bicho con nombre del juego debería ser un boss, no relleno de
camino. Lo único que la escena informa de bestiario es el paso de
Ambiental a **Corrupto** cerca del nido, y lo informa visualmente.

**⚠️ Ambigüedad de fuente encontrada, no resuelta:** [[Geografía y
Ciudades]] §M anota que Roen *"fue este puesto, en otra vida"* sobre
Aethelgard Watch, y su ficha lo pone en la frontera **Mistbound**, que es
tierra interior de Aethelgard y no la torre de The Wilds. El guión escribió
lo que las dos lecturas soportan (reconoce el ritual; no se afirma que
estuvo destinado ahí) y dejó la pregunta anotada. Fix de una línea en la
fuente, en el sentido que Boris elija.

**Corrección a una nota propia del [[Current-State]]:** decía que la
primera palabra del jugador iba en este tramo. Es falso — va en el
**Bautizo, Acto 2** ([[Voz Narrativa]] §Voz del protagonista). El Acto 1
entero es mudo, Waypost incluido, y eso es exactamente lo que carga el beat
de formación.

**Qué se tocó:** archivo nuevo · [[00-Index]] · la escena anterior (su
nota de "el T1 se enseña en el tramo siguiente" ahora enlaza) ·
[[Current-State]]. **Linter en 0 críticos** — los 2 de la primera corrida
fueron, otra vez, `§` sin cerrar antes de seguir la frase.

## [2026-08-12] canon/decisión | Waypost: la taberna del bookend + el beat donde el grupo se vuelve equipo

**La pregunta de Boris fue si la taberna del bookend debía ser The Braided
Oar (Rivermeet) o la de un poblado más chico.** La respuesta corta es
ninguna de las dos, y la larga la decidió una restricción de topología que
apareció al verificar.

**La trampa.** [[La Rueda]] / §Topología: la rueda **no es malla**, cada
reino entra a The Wilds por su propio radio y no hay tránsito directo entre
reinos. Una partida enana **nunca pisa territorio de Aethelgard en el Acto
1**. Así que cualquier taberna en Rivermeet —o en cualquier poblado
humano— tiene el mismo defecto: la resonancia de "la mesa donde el grupo se
formó" le llegaría a **1 de 3** jugadores, y a los otros dos tercios les
sería una sala que nunca vieron. Un símbolo que falla en 2 de 3 partidas no
es un símbolo.

**Lo que sí es común a las 3 razas: el centro.** Las tres torres de guardia
están del lado salvaje y "todas mirando hacia el centro"
([[Geografía y Ciudades]] §M). Los tres radios apuntan al mismo punto.

**Decisión (Boris, 2026-08-12): Waypost**, ficha nueva en
[[Geografía y Ciudades]] §K (Refugios / Descanso). Una **sola
construcción**, no un asentamiento: posta de camino que el Triune Council
levantó cuando todavía pretendía administrar rutas dentro de The Wilds, hoy
medio abandonada y sostenida por gente de frontera. Taberna abajo, camas
arriba. **Es el primer lugar del juego que no pertenece a nadie**, y por eso
las 3 razas pasan por ahí en el Acto 1 sin violar la topología.

Descartados y por qué queda escrito: **Rivermeet** (resonancia de 1/3, y
además es la ciudad donde Roen renunció — un Roen viejo bebiendo en la
capital del Council dice, sin decirlo, que volvió adentro de lo que dejó, y
eso filtra tono contra la regla 1 de [[Voz Narrativa]]); **Mistbound
Frontier** (donde *decidió* renunciar — cerrar el círculo ahí lee como
redención, mismo problema de tono).

**Cuidado de canon anotado en la ficha:** Waypost **no es el Driftmarket**.
El Driftmarket es la ciudad flotante del centro, con comercio, política y
Old Tobin Hale, y es de Acto 2. Waypost es un edificio con un barman: sin
mercado, sin facción, sin nadie con poder. Si una escena necesita comercio o
intriga, no es Waypost.

**El beat de formación — [[Geografía y Ciudades]] §Beats Narrativos por
Acto, Acto 1 locación 4, fuente única.** Separa dos cosas que el vault venía
mezclando: el **roster** (Roen → Valen → Pivote → Darro, acumulación) y el
**equipo** (un solo beat). Cómo se escribe:

- **El detonante es que a los cuatro se les termina el trabajo al mismo
  tiempo.** Roen fue contratado para limpiar un nido y el nido está limpio.
  Valen ya tiene su dato. Darro cobró. El Pivote nunca tuvo razón formal
  para seguir. Los cuatro tienen boleto de salida y **ninguno lo usa**.
- **Los ata desconfianza, no afecto:** ninguno sabe qué hacer con lo que
  sacaron del nido —que todavía no tiene nombre, el Bautizo es Acto 2— y
  ninguno la deja en manos de los otros tres. Quedarse es vigilarse.
  **Siembra la traición sin costo extra:** el grupo nace de una sospecha que
  tres actos después tendrá razón.
- **Regla de escritura:** nadie dice "sigamos juntos" y nadie explica por
  qué se queda. El gesto es que Roen —el único con contrato explícito, el
  único que *debería* levantarse— pide la segunda ronda, y nadie lo comenta.
- **Encaja con el gradiente de voz cerrado horas antes:** el jugador no
  habla (Acto 1 mudo), los demás fracasan en decirlo, y se quedan igual. Por
  eso la primera palabra del Acto 2 —"Speck", el nombre que pone Darro— es
  **lo primero que ese grupo consigue nombrar**. Los dos arcos se pagan con
  el mismo golpe.

**El regalo barato:** en el Acto 1 hay un barman que no dice nada; treinta
años después, en la misma sala, es el que insiste ("I keep count of
everything in this room", [[Guion/Cierres — Roen Viejo]]). Que sea el mismo
hombre envejecido o su hijo/a **se deja sin resolver a propósito**.

**El nombre NUNCA se pronuncia en pantalla** (decisión de Boris). Existe
para dirección de arte y para que el vault pueda referirse al lugar.
Verificado que hoy ni la apertura ni los 5 cierres lo nombran.

**Barrido de la clase:** grep de "taberna humana / sin nombre / candidato
Rivermeet / misma taberna" → 3 lugares la describían
([[Guion/Apertura — Roen Viejo]] §Puesta en escena y §Pendiente,
[[Voz Narrativa]]). Los 3 apuntan ahora a la ficha de §K.
[[The Bound Five]] recibió **un puntero, no una re-enunciación**, para que
el beat sea encontrable desde la página del grupo sin duplicar fuente.

**Qué se tocó:** [[Geografía y Ciudades]] (§K ficha nueva + locación 4
reescrita) · [[Nomenclatura]] (§La taberna del bookend, reemplaza el párrafo
que dejaba The Braided Oar como candidato) · [[Guion/Apertura — Roen Viejo]]
· [[Voz Narrativa]] · [[The Bound Five]] ·
[[Guion/Caminata y Taberna — Valen se suma]] · [[Current-State]] (el bloque
del día comprimido — su detalle vive acá). **Linter en 0 críticos.**

## [2026-08-12] canon/decisión | Voz del protagonista: mudo que aprende a hablar + 3 tabernas nombradas

**Boris cerró las 3 decisiones** que la escena de la taberna (entrada de
abajo) había dejado abiertas, el mismo día. Las tres se escribieron **a
fuente**, no en el guión, y de ahí se propagaron.

**1. Roen y Valen no se conocían — confirmado.** El bloque "That's not a
coincidence" / "For the record" queda firme en
[[Guion/Caminata y Taberna — Valen se suma]].

**2. Voz del protagonista — la de más alcance, y una decisión nueva, no la
confirmación de la asunción que estaba sobre la mesa.** Lo que se preguntó
fue si el protagonista es mudo; lo que Boris contestó fue **que es mudo al
principio y va desarrollando su voz a medida que pasan los actos, como
elemento coming-of-age**. Fuente única nueva: [[Voz Narrativa]] §Voz del
protagonista (el archivo estaba `ratificado` y ya era la autoridad de la
pregunta "¿silent protagonist?", que hasta hoy quedaba sin contestar en su
propia cabecera).

Gradiente fijado: **Acto 1 mudo** (cero líneas) → **Acto 2 primeras
palabras** (cortas, reactivas) → **Acto 3 líneas completas**, y es donde
por primera vez *inicia* intercambios → **la traición / Bond Vacío: vuelve
al silencio** → **el cráter: la decisión, dicha.**

Lo que hace que la decisión no toque el pilar del silencio sino que lo
refuerce: al volver mudo en el Bond Vacío, el silencio deja de ser el
estado por defecto y pasa a ser **pérdida** — el mismo recurso de
[[Bond y el Bond Vacío]], ahora con precio. Y 5 reglas de escritura que la
sostienen: la primera palabra es un nombre ajeno (candidata: **"Speck"**,
la que puso Darro en el Bautizo — a confirmar cuando se escriba ese guión);
el gradiente es **de acto, no de bond** (atarlo al Tether lo convertiría en
unlock y dejaría rutas donde el protagonista nunca habla, rompiendo el
clímax); ninguna línea nombra raza/rol/género, que es lo que mantiene el
costo en **6 tomas máximo, nunca 18**; escasez deliberada; y nunca habla
para explicar mecánicas.

Anotado como pendiente de la propia decisión: **VO sí/no no está decidido
en ningún lado del vault** (el gradiente funciona igual en texto), y hay que
verificar contra [[Los 5 Finales]] que las 5 ramas soporten una línea
hablada del jugador — F4 es la de más riesgo, porque ahí la que responde es
Speck.

**3. Tabernas de la ciudad natal — 3 nombres**, a [[Nomenclatura]]
§Tabernas de la ciudad natal: **The Braided Oar** (Rivermeet — el remo
trenzado no rema, y Rivermeet es "donde el río se trenza"), **The Last
Ladle** (Emberdeep — la última colada del turno y la última ronda de la
noche son la misma hora), **Underfall** (The Stillspire — terraza detrás de
la cortina de agua, compuesto sin artículo, misma economía que
Stillwood/Stillspire). **Deliberadamente sin resolver:** si la taberna del
bookend es The Braided Oar. Es el candidato natural (Roen es humano) pero
la coincidencia tiene peso dramático y no se toma por defecto.

**Barrido de la clase, no de la línea:** grep de "silent protagonist /
protagonista silencioso / sin línea de diálogo / asunción de diseño" en
todo el vault → 3 lugares la enunciaban por su cuenta
([[Guion/Encuentro con Roen]], la escena nueva y el [[Current-State]]).
Los 3 ahora **citan** [[Voz Narrativa]] en vez de razonar el tema de nuevo.
Ninguna línea de guión cambió — el Acto 1 ya estaba escrito en el piso del
gradiente.

**Qué se tocó:** [[Voz Narrativa]] (sección nueva) · [[Nomenclatura]]
(sección nueva) · [[Guion/Caminata y Taberna — Valen se suma]] (3 supuestos
→ canon citado, nombres en la tabla de variantes) ·
[[Guion/Encuentro con Roen]] (su nota de asunción → regla con fuente) ·
[[Current-State]]. **Linter en 0 críticos.**

## [2026-08-12] guión | Caminata silenciosa + taberna — Valen se suma (Acto 1, locación 1)

**Qué se escribió:** [[Guion/Caminata y Taberna — Valen se suma]], la
**segunda escena jugada** del juego. Cubre el Inmediato #1 del
[[Current-State]] y sigue directo de [[Guion/Encuentro con Roen]], que
terminaba con Roen ya caminando hacia la ciudad natal. Dos tramos sin corte:
la caminata a solas Roen+jugador (sin una sola línea de diálogo) y la
taberna donde Valen está esperando. `status: provisional`.

**Decisiones de escritura, todas ancladas a fuente:**
- **El silencio del tramo 1 es contenido.** Lo único que "habla" ahí es la
  UI de bonds apareciendo por primera vez, sin caja de tutorial. Coherente
  con [[Bond y el Bond Vacío]] y con el handoff auditivo de la apertura.
- **Valen no rescata: reconoce patrón y ofrece información**
  ([[Valen-Ficha-Expandida-v1]]). Frío, categorizando, no insultante.
  Recicla verbatim los dos beats que la ficha ya fijaba ("Tres Vaciados...
  eso no es ruido, es dato" / "Sobreviviste a tres... nada inesperado —
  todavía"), pasados a inglés por regla 9.
- **Producción acotada:** blocking único + 3 ambientaciones por raza
  (Rivermeet baja al río / Emberdeep desciende a la caverna / Stillspire
  sube por The Ascending Falls) + **una sola línea variable**, la de
  reconocimiento, que sale de la celda raza×rol×género de las 3 tablas de
  18 variantes de la ficha. Mismo criterio que la matriz 3×3 de la viñeta
  muda de la apertura.
- **Lo que Valen NO dice:** nada de su teoría (God-Cores como cadáveres,
  Muda inconclusa) — eso es Acto 2 — y **nunca la palabra "Warden"**, que
  no existe públicamente hasta el Archive en Acto 3
  ([[El Mundo y la Muda]]). Es el mismo error que la 16ª QA ya había
  corregido en su ficha; se escribió sabiéndolo.
- **Sin combate y sin enseñar el T1 de Valen:** *The Long Calculus* necesita
  blancos (Discord/Harmony), y una taberna no los tiene. Se difiere a
  locación 2, que es también el primer punto donde un jugador Duelist tiene
  daño pleno sostenido (hasta ahí no había Strategist en el grupo,
  [[Acoplamientos]]).
- **Variante élfica:** Valen en Stillspire no comenta el lugar. Es
  deliberado (salió de ahí a los 140 tras la negativa de los ancianos) y va
  anotado en el archivo como "no arreglar en una futura pasada".

**Tres supuestos que quedan para VoBo de Boris**, anotados en el archivo y
en el Current-State: (a) Roen y Valen **no** se conocían de antes —ninguna
fuente los cruza— y sobre eso se monta la desconfianza de Roen en la mesa;
(b) protagonista silencioso, que sigue siendo asunción de diseño y ya lleva
dos escenas; (c) el nombre de la taberna, sin fijar, y deliberadamente **sin
asumir** que sea la misma del bookend.

**Qué se tocó:** archivo nuevo · [[00-Index]] (entrada nueva junto a las
otras 3 de `Guion/`) · [[Guion/Encuentro con Roen]] §Pendiente (el ítem "no
escrito todavía" pasó a ✅ con link) · [[Current-State]] (Inmediato #1
cerrado, +compresión del bloque de propagación ya cerrado, cuyo detalle vive
acá). **Linter en 0 críticos** — los 3 que salieron en la primera corrida
fueron míos y de la misma clase de siempre: `§` sin cerrar antes de seguir
la frase (regla 6 del Current-State). Sigue siendo la trampa más barata de
pisar del vault.

## [2026-08-12] canon/fix | Cuña de Dagna reubicada — cierra la ambigüedad del bloque de propagación

**Qué se cerró:** la única ambigüedad que el bloque de propagación (entrada
de arriba) dejó anotada sin resolver. [[Los 9 Links del Pivote]] §Tiers
decía que Dagna clava la **Primera Cuña** *"en la roca del nido"* durante la
traición — pero con la ruptura de dos tiempos ya propagada, su traición
entera pasa en el Sunken Archive y en First Wound, y no vuelve a pisar El
Nido. La ficha de Dagna se había escrito **sin** la cuña para no contradecir
ninguna de las dos fuentes.

**Decisión (Boris, 2026-08-12):** releer la regla completa —*"la cuña...
que todo guardián clava donde monta su guardia definitiva"*— y ubicarla en
el **borde del cráter, en First Wound**, donde Dagna se detiene con Speck en
brazos, escudo en alto, esperando al mensajero de Deepstone: es literalmente
su última guardia. Cierra el símbolo sin inventar escena nueva.

**Qué se tocó:**
- [[Los 9 Links del Pivote]] §Tiers — "roca del nido" → "piedra del borde
  del cráter... su última guardia".
- [[Pivotes/Dagna-Ficha-Expandida-v1|Dagna]] §sub-beat 5 — agregado el gesto
  de clavar la cuña antes de que llegue el mensajero. **En T3**, deja el
  martillo al lado — el mismo que sostuvo por reflejo y bajó sin usar en el
  obstáculo del ascenso (sub-beat 2b), cerrando el arco del objeto en dos
  escenas ya escritas en vez de crear una tercera.

Linter: 0 críticos / 0 medios tras el cambio (27 INFO preexistentes, sin
tocar). Pendiente aparte, no bloquea: [[The Tether]] no contiene la "regla
T3" que [[Los 9 Links del Pivote]] le atribuye — falta verificar esa cita.

## [2026-08-12] canon/propagación | La ruptura de dos tiempos llega a las 12 fichas — bloque cerrado

**Qué se cerró:** el bloque de propagación que era el pendiente más grande del
vault (punto 2 de *Inmediato*). El canon estructural de la 4ª y la 5ª
re-corrida —**la traición del Pivote tiene dos tiempos**— vivía solo en sus
fuentes ([[Bond y el Bond Vacío]] §La traición tiene dos tiempos,
[[Geografía y Ciudades]] §ACTO 3 sub-beats 2b y 3) y no estaba en ninguna de
las 12 fichas. Ahora está en las 12. **Cuatro tandas, linter en 0 críticos
antes de cada commit.**

**Qué se escribió en cada ficha de Pivote:**
- **Sub-beat 2b — la ruptura**, en la sala del Fragmento: el Pivote declara,
  no huye, y **ahí muere el link**. Sube con el grupo el ascenso entero.
- **El obstáculo firma del link perdido** durante el ascenso — contenido nuevo,
  no existía en ninguna ficha. Es la ventana del beat del Bond vacío, y sin él
  el pilar 2 no se pagaba.
- **Sub-beat 3 podado**: la toma deja de ser revelación. Fuera el
  *"¿lo sabías TODO ESTE TIEMPO?"*, fuera el shock de los tres fijos, fuera la
  explicación — todo eso se mudó al 2b. Lo que queda es la acción física y, a
  lo sumo, una frase.
- **Índice a 6 sub-beats** (1, 2, 2b, 3, 4, 5) en el título de sección y en las
  líneas de "estructura ratificada".
- **Ubicación de la línea canónica declarada explícitamente** en la sección
  §Línea Canónica de cada ficha.

**Las nueve formas — se repartieron ANTES de escribir, en una sola pasada
comparativa**, siguiendo la lección de método de [[El Cráter — Matriz de
Rutas]] §4 (escribir N variantes en secuencia contra un mismo criterio las
homogeneiza). El eje anti-convergencia elegido fue **a quién le habla cada
uno**, y no se repite ninguno:

| Pivote | Forma de la ruptura | Le habla a | Línea canónica |
|---|---|---|---|
| **Maren** | dos frases, parte de operaciones; no se justifica | al grupo entero | **2b** — no se repite en el corredor |
| **Torgan** | cuatro líneas, notificación de cláusula | al jugador, de frente | **2b** — en el corredor solo *"Fue verdad todo."* |
| **Iven** | desborde entrecortado; el único que declara pidiendo que lo detengan | al suelo, después a gritos | **2b** — lo único que le sale ordenado |
| **Sereth** | quince líneas didácticas y **ninguna explica el método** | solo al jugador, ignorando al resto | **cráter (5)** — retención deliberada |
| **Bram** | declara igual que los ocho y **no obedece** | al grupo; la negativa al jugador | ya estaba en su escena, que se movió entera |
| **Lyris** | tres frases y vuelve a volar | **a Speck**, a ninguna persona | **toma (3)** — la única frase que le dirige al jugador |
| **Nyael** | **sin diálogo**: no está en la sala | nadie | la nota del nicho, como siempre |
| **Vekka** | dos frases + **desmonta los módulos del jugador ahí mismo** | al trabajo, no a una persona | **cráter (5)** — su declaración se ejecuta con las manos |
| **Dagna** | voz quebrada desde la primera palabra | **a Roen**, no al jugador | **cráter (5)** — abajo solo *"Lo siento."* |

**Decisiones tomadas donde el canon no cerraba (conservadoras, ninguna
re-decide canon):**
1. **Sereth.** Su §sub-beat 5 declara que el cráter es *"la única escena de
   Acto 3 donde Sereth explica su método"*, y la nueva forma le pide quince
   líneas en la ruptura. Se resolvió separando **decisión** de **método**: en
   la sala del Fragmento expone qué va a hacer con precisión total y **aplaza**
   toda pregunta sobre la conducción (*"esa pregunta tiene una respuesta larga
   y este no es el lugar"*). El superlativo del cráter queda intacto, y la
   retención pasa a ser en sí misma su arquetipo — es la única declaración
   larga del elenco que no contiene la tesis de quien la dice.
2. **Vekka.** Su ruptura es **una operación de taller**, no un discurso: le
   desmonta al jugador los módulos del Warforging en la sala del Fragmento.
   Es la única celda donde el jugador **ve** morir el link en vez de
   descubrirlo picando un botón, y sale directo de la regla ya escrita en
   [[Los 9 Links del Pivote]] (*"los desmonta al irse"*).
3. **Nyael.** Se movió su separación al **descenso interno del Archive** (antes
   estaba presente en todo el interior): hace la caricia en el cuello de Speck
   en los corredores exteriores y no vuelve. La ruptura la juega el grupo —
   Roen cuenta cabezas y se detiene en cuatro. Su trampa amorosa es la única
   sin Pivote en cuadro: el encuadre vacío de la Link Cam es literal.
4. **Bram.** Su escena de rechazo **no se reescribió** — se movió entera del
   corredor a la sala del Fragmento, que es donde el canon nuevo la ubica. Se
   le agregó la trampa amorosa **invertida** (el sting completo) y un sub-beat
   3 nuevo: *"El corredor donde no pasa nada"*, con regla de escritura para que
   no lea como alivio.
5. **Valen — convergencia de tanda rota.** Sus reacciones en Maren/Sereth/Iven
   usaban las tres la misma fórmula (*"noté X, lo modelé, esperé estar
   equivocado"*). Se le cambió la **forma** a las tres sin tocar el dato: con
   Maren **pregunta** en vez de afirmar; con Sereth **clasificó mal** el dato
   que sí tenía (*"I filed it as intellectual growth"*); con Iven se lo dice
   **al jugador**, después, como falla de método propio (*"I filed it as
   homesickness"*). La versión duplicada en §Dinámicas de Iven se alineó.

**Los 3 fijos (tanda 4) — pasada de verificación.** La única infracción real de
la regla de [[El Cráter — Matriz de Rutas]] §Regla de uso (*narran su reacción,
nunca el quiebre*) estaba en **Roen**: su §Escena 1 re-narraba la intención de
cada Pivote en una lista propia. Se recortó a una frase de contexto + puntero,
y la tinta se puso en lo que le pasa a Roen durante el ascenso — carga a Speck
y no la suelta, y deja que el Pivote lo ayude aunque le duela más aceptarlo que
negárselo. **Valen y Darro ya cumplían**: sus entradas por Pivote son reacción
+ puntero. Solo se les actualizaron los punteros al par 2b/3 y el encabezado de
la escena de Bram.

**Corolario de superlativos frágiles — verificado, sin contradicción nueva.**
*"Darro se queda mudo, la única vez en la campaña"* sigue siendo exclusivo del
cráter de Vekka ([[Darro-Ficha-Expandida-v1]] §Traición, arbitrado en la 12ª
ronda). La ruptura de Vekka se escribió **con Darro gritando**, no mudo, y con
un puntero explícito a la fuente para que ninguna re-corrida futura lo reclame
dos veces.

**Fuera de las 12 fichas — un fix a la fuente.** [[Geografía y Ciudades]] §ACTO
3 sub-beat 3, *Variante Bram*, seguía narrando el rechazo de Bram **en el
corredor** (residuo del canon viejo, en el mismo documento que ya declaraba el
2b arriba). Corregido: el corredor pasa sin toma y el rechazo apunta al 2b.

**Ambigüedad anotada, sin resolver (no bloquea nada).** [[Los 9 Links del
Pivote]] §Tiers por Tether dice que Dagna clava la **Primera Cuña** *"en la roca
del nido"* durante la traición — pero su traición ocurre en el Archive y el
cráter, no en El Nido. La ruptura de Dagna se escribió **sin** la cuña para no
contradecir ninguna de las dos fuentes. Queda decidir dónde vive ese objeto
firma (y, si llegó a T3, dónde deja el martillo).

**Commits:** `6803688` (tanda 1), `03f2d13` (tanda 2), `18b6b70` (tanda 3),
`23b26f7` (tanda 4). Linter final: **0 críticos, 0 medios**.

## [2026-08-12] spike | Encuadre de Unity: falsa alarma mía — y el coseno, rechazado por medición

Encargo del director: arreglar el encuadre y volver a medir las dos
columnas. **El encuadre no estaba roto.** La alarma la levanté yo, y
estaba mal.

**Cómo se comprobó.** Se volcaron **las 16 muestras** del terreno plano con
la **línea del suelo dibujada encima** y una marca en el píxel más bajo que
el instrumento detecta. El encuadre está bien: vista lateral, personaje
derecho, pies apoyados sobre la línea. Mi alarma salió de mirar **una sola
miniatura**, y encima de una fase del ciclo con **los dos pies en el
aire** — que leí como "personaje rotado y cortado".

**El error de coseno: probado y rechazado.** Desplazar el objetivo del IK a
lo largo de la normal en vez de en vertical **empeoró** la rampa (+0.031 →
+0.055 m). Revertido.

**Y ahora sí hay explicación de por qué el coseno no aplicaba.** El
`footOffsetY` calibrado de Unity da **0.21 m**, cuando un tobillo real está
a 0.08-0.10. Ese número **no es una altura de tobillo**: es un factor que
absorbe la geometría **tobillo→punta de la bota**, que es lo que marca el
píxel más bajo de la silueta. Un factor de corrección así no tiene
dirección física que respetar; girarlo con la pendiente solo lo desalinea.
**El argumento del coseno vale para una altura real, no para un fudge.**
Ese mismo 0.21 que me había olido raro era la pista, y la leí como "el
instrumento miente" en vez de "el parámetro no es lo que creo".

**Tabla final, las dos columnas medidas con el mismo protocolo y
calibradas con el mismo criterio:**

| Métrica | Godot (solver propio) | Unity (`Animator IK`) | Estándar |
|---|---|---|---|
| Penetración, plano | −0.004 m | +0.005 m | ~0 |
| Penetración, rampa 21.8° | +0.005 m | +0.031 m | ~0 |
| Plano → rampa | +0.009 m | +0.027 m | 0 |

**Los dos cumplen el estándar del [[Benchmark Biomecánico]].** La
diferencia en pendiente **queda sin explicar** — puede ser el script, los
clips (el de Starter Assets tiene un despegue de punta más marcado, y el
punto más bajo de la silueta depende de eso) o el motor. **No hay
evidencia para atribuirlo a ninguno**, y no alcanza para decir que un motor
planta mejor el pie.

**La lección, y es distinta de la de la mañana.** Hoy aprendí a desconfiar
de los instrumentos. Esta vez desconfié **de más**: declaré roto un
instrumento sano por mirar una miniatura, y escribí esa alarma en tres
archivos del vault. La regla que faltaba: **antes de declarar rota una
medición, mirar la evidencia completa con la misma exigencia que le pedís
a la conclusión que querés tumbar.** Dudar es barato; declarar, no.

**Índice:** sin cambios.

## [2026-08-12] spike/unity | El arreglo del coseno no confirmó — y el instrumento de Unity tiene el encuadre mal

Encargo del director: arreglar el error de coseno en el script de Unity.
Se aplicó, **y la medición lo contradijo**. Mirando las capturas apareció
un problema más de fondo.

**Lo aplicado.** `SpikeFootIK.cs` ahora desplaza el objetivo del IK a lo
largo de la **normal del terreno** (`hit.point + hit.normal * offset`) en
vez de en vertical (`Vector3.up`). Es lo que hace el lado Godot y es lo
correcto por principio: el tobillo se separa de la superficie
perpendicular a ella.

**Lo que pasó al medir: la rampa EMPEORÓ**, de +0.031 m a +0.055 m. La
explicación del error de coseno **no se confirmó**. O estaba mal, o el
instrumento no mide lo que yo creía.

**Se miró la captura, y es lo segundo.** Guardando el PNG que el
instrumento estaba analizando: **el encuadre está mal — el personaje sale
rotado y cortado**, así que el "píxel más bajo de la silueta" no es
necesariamente el pie. **Los números de la columna Unity publicados hoy no
son confiables.**

**Había una segunda señal que dejé pasar.** El offset calibrado de Unity
salió **0.21 m**, cuando un tobillo real está a 0.08-0.10 m. Del lado
Godot el equivalente total es 0.082 m — físicamente sensato. Un parámetro
que hay que llevar al doble de lo físico para que el número cierre suele
estar tapando un error de medición, no describiendo el sistema. Lo anoté
como raro en su momento y seguí igual.

**Estado corregido:**
- **Columna Godot: confiable.** Encuadre verificado mirando las capturas,
  control validando el instrumento.
- **Columna Unity: en duda.** [[Comparativa de Motores — Godot vs Unity]] y
  [[Current-State]] marcados; la comparación **no da veredicto** hasta
  arreglar el encuadre.
- El cambio del coseno **queda aplicado por principio**, marcado en el
  código como no validado por medición.

**La lección, que es la misma de todo el día en otra forma:** hoy validé
el instrumento de Godot mirando sus capturas y por eso confío en él. Del
lado Unity **no miré las capturas hasta que un resultado me contradijo**.
El control de Unity daba "válido" —y lo era, para lo que probaba: que la
escala píxel→metro responde—, pero **un control no cubre lo que no mide**.
Ninguno de mis chequeos miraba el encuadre. **Mirar la imagen es barato y
lo dejé para el final, otra vez.**

**Índice:** sin cambios.

## [2026-08-12] spike | Foot IK medido de los DOS lados — empate en resultado, diferencia en costo

Encargo del director: correr la medición del lado Unity y comparar. Hecho.
`unity/Assets/_Spike/Editor/SpikeFootIKBenchmark.cs` porta el mismo
protocolo que el de Godot: cámara ortográfica con su "arriba" en la normal
del terreno, silueta contra la línea del suelo, 16 muestras por terreno,
apoyo = el 40% más bajo.

**La decisión de método que hace válida la comparación:** los dos lados se
**calibran con el mismo criterio**. El `SpikeFootIK.cs` de Unity tenía el
mismo defecto que tenía el nuestro —un offset de tobillo fijo, sin
medir— y sin calibrarlo estaríamos comparando nuestras calibraciones, no
los motores. Se barrió por reflexión hasta minimizar la penetración en
plano: quedó en 0.21 (contra 0.045 del lado Godot).

| Métrica | Godot (solver propio) | Unity (`Animator IK`) | Estándar |
|---|---|---|---|
| Penetración, plano | −0.004 m | +0.005 m | ~0 |
| Penetración, rampa 21.8° | +0.006 m | +0.031 m | ~0 |
| Plano → rampa | +0.010 m | +0.027 m | 0 |

**Los dos cumplen el estándar del [[Benchmark Biomecánico]].**

**La ventaja de Godot en pendiente NO es del motor.** Nuestro script de
Unity desplaza el objetivo **verticalmente** (`hit.point + Vector3.up *
offset`); el de Godot lo desplaza **a lo largo de la normal**. En
pendiente el vertical se queda corto: es error de coseno, y arreglarlo en
Unity es una línea. Decirlo así importa — publicar ese +6 mm contra +31 mm
como "Godot planta mejor el pie" sería falso.

**Diferencia real de motor, la única que queda en pie:** en Unity el foot
IK **viene funcionando**; en Godot **hay que escribirlo** (el
`TwoBoneIK3D` de fábrica no produce salida). Es costo, no calidad, y no es
recurrente.

**Una métrica se descartó por no ser comparable.** La raíz continua da
0.0249 m/frame con 7.8% en Godot y 0.0003 m/frame con 600% en Unity. El
número de Unity no dice que su raíz sea peor: el driver mueve en
`Update()` y en batchmode corre a miles de fps, así que el desplazamiento
por frame es minúsculo y el desvío relativo se dispara. La métrica está
atada al timestep de cada motor. Los dos mueven la raíz por código sin
stepping, o sea que cumplen el criterio de Sable por construcción — se
anota como no comparable en vez de publicarla como si dijera algo.

**El CONTROL volvió a ganarse el lugar.** El de Unity hunde al personaje
10 cm y verifica que la penetración medida cambie ~10 cm. La primera
corrida dio **0.0205** y marcó SOSPECHOSO — y no era el instrumento: era
el **foot IK volviendo a plantar el pie**, o sea el sistema funcionando.
Se corrigió corriendo el control con el IK apagado: **0.0995 m,
instrumento válido**. Un control que falla no siempre acusa al
instrumento; a veces te está mostrando el sistema.

**Estado del spike:** el frente de foot IK queda cerrado y medido de los
dos lados. [[Comparativa de Motores — Godot vs Unity]] y [[Current-State]]
actualizados.

**Índice:** sin cambios.

## [2026-08-12] spike/godot | Solver de dos huesos propio — el foot IK cumple el Benchmark

Encargo del director: escribir el solver y seguir. Hecho, y **el criterio
de foot IK del [[Benchmark Biomecánico]] queda cumplido**.

**El solver.** `godot/scripts/two_bone_ik.gd` (`SpikeTwoBoneIK`): ley de
cosenos analítica, sin iteraciones, determinista. Se implementó como
**`SkeletonModifier3D` propio** y no escribiendo huesos desde un
`_physics_process`, porque el framework de modifiers es el que garantiza
el ORDEN — corre dentro del update del Skeleton3D, después de que el
AnimationMixer escribió la pose. **El framework funciona bien; lo que no
funciona es la clase `TwoBoneIK3D`.**

**Validado en el mismo banco mínimo donde el stock falla:** el solver
propio da **2.730 píxeles** de efecto; `TwoBoneIK3D` da 0 en sus 9
variantes; el CONTROL da 2.127.

**Resultado contra el estándar** (§v2 del Benchmark, fila de HZD: *"foot
IK contra el terreno cada frame — pies creíbles en terreno"*):

| Métrica | Sin IK | Con solver propio |
|---|---|---|
| Penetración, plano | −0.213 m | **−0.004 m** |
| Penetración, rampa 21.8° | −0.323 m | **+0.006 m** |
| Plano → rampa | −0.110 m | **+0.010 m** |
| Raíz continua | — | ✅ desvío 7.8% |

**El pie queda a ±6 mm del suelo en los dos terrenos, y se apoya igual de
bien en pendiente que en plano.** Eso es exactamente lo que pide la fila
de HZD. Mejora de ~53× en plano y ~59× en rampa contra la animación sola.

**Calibración medida, no estimada.** El bug del tobillo que quedaba
pendiente se cerró barriendo `ankle_height_offset` con
`tools/footik_benchmark.gd` (0.030 → −0.020 m · 0.045 → −0.004 m · 0.055 →
+0.006 m) y quedándose con **0.045**. Corrige que el rest pose del rig,
tras el retargeting con `fix_silhouette`, no es una pose de pie apoyado y
reporta una altura de tobillo de 0.037 m en vez de los ~0.08 reales.

**Qué le hace esto a la comparativa de motores.** La fila del foot IK
queda con dos caras, y las dos son ciertas:
- **En contra de Godot:** el stock no funciona y hay que escribir el
  solver (~130 líneas con comentarios). Unity lo trae andando.
- **A favor de Godot:** una vez escrito, **cumple el estándar**. No es una
  limitación del motor, es una deuda de una tarde, y no es recurrente.

[[Comparativa de Motores — Godot vs Unity]] actualizada con las dos caras.

**Lo que queda para cerrar el veredicto:** portar esta misma medición al
lado Unity. Ahora sí es comparación justa — de los dos lados hay un foot
IK que funciona.

**Índice:** sin cambios.

## [2026-08-12] spike/godot | Escena minima: `TwoBoneIK3D` no produce salida en 4.7.1 — y el valor del CONTROL

Encargo del director: probar con la escena minima aislada. **Cerro la
pregunta.** No es nuestro rig: es el modifier.

**El montaje.** Nada de Dagna, nada de retargeting, nada de 198 huesos: un
esqueleto de **3 huesos hecho a mano**, en cadena, y un target. El juez es
el **render de una malla pesada 100% al hueso punta** — lo unico que no
depende del bufer de poses, que devuelve la pose anterior a los modifiers.

**Nueve variantes de configuracion, todas en 0 pixeles:** base · `reset()`
despues de configurar · `use_virtual_end` · `extend_end_bone` con largo
explicito · `mutable_bone_axes` en false · configurado ANTES de entrar al
arbol · con un hueso hijo en la punta (como `LeftToes`) · la cadena
colgando de un hueso padre en vez de la raiz · reescribiendo la pose de un
hueso cada frame para ensuciar el esqueleto.

**Y la fila que le da sentido a las otras nueve: CONTROL.** Sin IK,
rotando el hueso raiz 0.5 rad a mano: **2.127 pixeles**. O sea que la
malla, el skin y el render responden perfecto a los huesos. **Los nueve
ceros son reales.**

**Conclusion: `TwoBoneIK3D` no produce salida en Godot 4.7.1**, al menos
armado desde codigo. Queda sin explicar si es un requisito no documentado
o un bug de la build. El repro minimo queda versionado en
`godot/tools/min_ik_repro.gd`, en calidad de reporte de bug.

**Consecuencia para la decision de motor, que es lo que importa:** el foot
IK de Godot **no es "stock, cero codigo"**. Hay que escribir el solver de
dos huesos a mano — unas 40 lineas de trigonometria. Del lado Unity,
`OnAnimatorIK` funciona. Esa fila de
[[Comparativa de Motores — Godot vs Unity]] **cambia de signo**: pasa de
"empate, los dos resuelven con herramienta stock" a un punto duro a favor
de Unity. Actualizada.

**La leccion de metodo del dia, y quedo escrita en [[Lecciones]]:** toda
suite de medicion necesita un **control**. Sin la fila CONTROL, esos nueve
ceros no probaban nada — podrian haber sido una malla mal pesada. El
control es lo que convierte un cero en evidencia. Hoy tres conclusiones se
dieron vuelta antes de aprenderlo: el estimador de pie apoyado, el bufer
de poses, y la A/B con la animacion corriendo.

**Indice:** sin cambios.

## [2026-08-12] spike/godot | Por que el modifier no produce salida — sin causa raiz, pero con el campo despejado

Encargo del director: averiguar por que. **No lo encontre.** Lo que si hay
es una lista de descartes con prueba, dos bugs propios hallados en el
camino, y un test decisivo bien construido.

**El test decisivo, que cierra la ambiguedad que quedaba.** El intento
anterior congelaba la animacion, y eso abria la duda de si el esqueleto
directamente no corria el pase de modifiers. Este corre las dos capturas a
la **misma fase** pero con el esqueleto **actualizandose** (cada captura
hace su propio `seek`), y mueve el objetivo 50 cm entre una y otra.
Resultado: **0 pixeles**. No es que el modifier no se ejecute por falta de
actualizacion: se ejecuta y no hace nada.

**Descartado, cada uno con su medicion:**
- La cadena de huesos ES contigua padre-hijo: Hips → LeftUpperLeg →
  LeftLowerLeg → LeftFoot (indices 184/185/186, cada uno padre del
  siguiente).
- `active == true`, `influence == 1.0`, el esqueleto que reporta
  `get_skeleton()` es el correcto, y el `target_node` resuelve al nodo.
- El `AnimationPlayer` **no** le pisa el resultado: con el mixer detenido
  del todo, sigue dando 0.
- El pole no era: estaba mal seteado (ver abajo), se corrigio, y sigue 0.

**Bug propio 1 — el pole nunca se aplico.** `pole_direction` es un **enum**
(`SecondaryDirection`), no un vector. Se llamaba solo a
`set_pole_direction_vector()`, que sin el enum en CUSTOM no hace nada: el
enum quedaba en NONE y el vector en cero. Corregido a
`SECONDARY_DIRECTION_PLUS_Z`. **No era la causa**, pero era un bug real y
habria mordido despues.

**Bug propio 2 — la altura del tobillo esta mal calculada.**
`_rest_ankle_height()` devuelve **0.037 m**, y un tobillo real esta a
0.08-0.10 m de la planta. Sale de leer el *rest pose*, que despues del
retargeting con `fix_silhouette` no es una pose de pie apoyado. Queda
anotado en el codigo y sin corregir a proposito: hoy no cambia nada
medible, porque el modifier no aplica igual. **Hay que arreglarlo el dia
que aplique**, o el pie va a quedar 5 cm hundido incluso con el IK
funcionando.

**Dato lateral util:** el objetivo del IK y el hueso estan separados entre
0.02 y 0.12 m durante la caminata — o sea que el solver tiene un problema
real que resolver, no esta inactivo por falta de trabajo.

**Sin descartar todavia:** `IKModifier3D.reset()` despues de configurar ·
configurar los settings ANTES de que el nodo entre al arbol (es lo que
exigia el `SkeletonIK3D` viejo, asi que es un candidato con precedente) ·
`use_virtual_end` / `extend_end_bone` · asignar por ruta de propiedad en
vez de por setter.

**Recomendacion para la proxima pasada:** una escena minima aislada —
esqueleto de 3 huesos hecho a mano, un `TwoBoneIK3D`, un target— para
decidir de una si el problema es la API o nuestro rig. Si la escena minima
tampoco anda, el camino barato deja de ser pelear con el modifier stock:
un solver de dos huesos son unas 40 lineas de trigonometria que
controlamos nosotros, y el criterio de "herramienta stock" del lado Godot
ya no se sostendria igual — que es un dato para
[[Comparativa de Motores — Godot vs Unity]].

**Indice:** sin cambios.

## [2026-08-12] spike/godot | Medición sobre el render — el foot IK no produce salida, ahora sí probado

Encargo del director: medir sobre el render y volver a correr el benchmark.
Hecho. Y el resultado cierra un ida y vuelta que se dio **dos veces** hoy
por instrumentos mal validados — vale más la lección de método que el
número.

**El instrumento nuevo.** `footik_benchmark.gd` ahora mide sobre la
imagen: cámara **ortográfica** con su "arriba" en la normal del terreno y
su eje de vista dentro del plano del terreno (así la superficie es una
línea horizontal exacta), fondo de color puro, y se ocultan el otro
personaje, las mallas del suelo —los cuerpos de colisión quedan, para que
el IK tenga contra qué tirar rayos— y **el hacha**, que cuelga por debajo
de los pies y era la que marcaba el píxel más bajo. Penetración =
distancia del píxel más bajo de la silueta a la línea del suelo. Se
descartan las muestras recortadas por el borde inferior en vez de
publicarlas.

**Resultado:**

| Métrica | Con IK | Sin IK | Estándar |
|---|---|---|---|
| Raíz continua | ✅ desvío 7.8% | — | Sable: continua |
| Penetración, plano | −0.213 m | −0.213 m | ~0 |
| Penetración, rampa 21.8° | −0.328 m | −0.323 m | ~0 |

**La validación, hecha bien esta vez.** Con la animación **congelada**
(`pause()` + `speed_scale = 0`), mover el objetivo del pie 45 cm da **0
píxeles de diferencia**. Y con el `AnimationPlayer` **detenido del todo**,
también 0 — así que tampoco es que el mixer le pise el resultado al
modifier.

**Conclusión: ni `SkeletonIK3D` ni `TwoBoneIK3D` producen salida en
nuestro montaje.** Lo que se ve es la animación cruda con el cuerpo
apoyado por física. Lo que **no** se sabe es por qué: los huesos resuelven
a índices válidos, el target resuelve, `active == true`, el esqueleto es
el correcto.

**El error de método, tres veces el mismo día.** Cada vez que un
instrumento me dio un número cómodo, lo tomé por cierto:
1. El estimador de "qué pie está apoyado" — inservible con foot IK.
2. El búfer de poses: `get_bone_global_pose()` y `BoneAttachment3D`
   devuelven la pose ANTERIOR a los modifiers.
3. **Y la propia validación del punto 2**: la A/B de renders que dio 9.053
   píxeles y me hizo retractar la conclusión correcta. Era falsa —
   **me había dejado la animación corriendo entre las dos capturas**, así
   que medí el ciclo avanzando, no el IK.

Regla que queda en [[Lecciones]]: una A/B solo prueba algo si la única
variable que cambia es la que estás probando. Congelar todo lo demás,
explícitamente, antes de mirar el número.

**No se corrió el lado Unity, otra vez a propósito.** Comparar animación
cruda contra un IK que sí funciona le daría a Unity una ventaja que no es
del motor sino de nuestro montaje.

**Próximo paso:** encontrar el requisito que falta en el modifier
(candidatos: cadena de huesos padre-hijo contigua, `use_virtual_end` /
`extend_end_bone`, o el manejo de `mutable_bone_axes`).

**Índice:** sin cambios.

## [2026-08-12] spike/godot | Foot IK migrado a `TwoBoneIK3D` — y me equivoqué de instrumento otra vez

Encargo del director: reemplazar `SkeletonIK3D` por `SkeletonModifier3D` y
volver a medir. Lo primero está hecho. Lo segundo **no**, y hay que
retractar lo de hace un rato.

**Lo hecho — la migración.** Antes de escribir un solver a mano, se
consultó `ClassDB`: Godot 4.7 trae **`TwoBoneIK3D`** de fábrica (junto con
`FABRIK3D`, `CCDIK3D`, `SplineIK3D`, `LookAtModifier3D`, `AimModifier3D`).
O sea que el criterio de "herramienta stock" se mantiene intacto — no hizo
falta escribir nada. `foot_ik.gd` ahora arma un `TwoBoneIK3D` con dos
settings (una pierna cada uno: cadera→rodilla→tobillo) y le da un objetivo
por pierna. Dos cosas del planteo anterior estaban mal y se corrigieron:
- El objetivo del IK **no es el punto del suelo**: es el punto del suelo
  **más la altura del tobillo sobre la planta**, medida del rig en reposo
  (con los huesos `heel.02.*` y `*Toes`). Poner el tobillo en el suelo
  entierra el pie entero.
- El rayo vertical ahora **excluye la cápsula del propio personaje**, que
  antes se comía el impacto.

**Lo NO hecho, y por qué — la trampa del instrumento.** La medición sigue
dando exactamente lo mismo con el IK encendido y apagado. Antes de
concluir nada por segunda vez, se validó el instrumento con un caso donde
el efecto tenía que ser innegable: mover el objetivo del pie **45 cm hacia
arriba** y comparar dos renders. Resultado: **9.053 píxeles de diferencia**
— el modifier **sí actúa**. Los que están ciegos son los dos instrumentos
numéricos:

- `get_bone_global_pose()` devuelve la pose **anterior** a los modifiers.
- `BoneAttachment3D` **lee el mismo búfer**, así que tampoco sirve.

**Consecuencia — se retracta la conclusión anterior.** "`SkeletonIK3D` es
un no-op" **no está probado y probablemente sea falso**: salió del mismo
instrumento ciego. Los números de penetración y adaptación publicados hoy
describen la **animación cruda**, no el resultado final que se ve en
pantalla. Corregido en [[Current-State]] y en [[Comparativa de Motores —
Godot vs Unity]].

**El error de método, que es el mismo de esta mañana.** Es la segunda vez
en el día que un instrumento me da un número tranquilizador y lo tomo por
cierto: primero el estimador de "qué pie está apoyado", después el barrido
de calibración monótono al revés, ahora el búfer de poses. La regla que
queda escrita en [[Lecciones]]: **antes de concluir de una medición sobre
huesos con modifiers activos, validar el instrumento con un caso de efecto
innegable. Si el instrumento dice cero, el ciego puede ser el
instrumento.**

**Próximo paso:** el único canal que demostró reflejar la salida del
modifier es **el render**. Medir la penetración sobre la imagen (silueta
del pie contra la línea del suelo, con cámara ortogonal a la pendiente),
volver a correr `footik_benchmark.gd` con ese instrumento, y recién
después portar la medición a Unity para poner las dos columnas juntas.

**Índice:** sin cambios.

## [2026-08-12] spike/godot | Medición del foot IK contra el Benchmark — `SkeletonIK3D` es un no-op

> **⚠️ La conclusión de esta entrada es CORRECTA, pero la evidencia que
> traía no lo era.** Se retractó y después se re-confirmó con un test
> válido el mismo día. Ver la entrada de cierre "medición sobre el
> render".

Encargo del director: correr la pregunta abierta que quedó de la
comparativa de motores. El resultado **invalida una afirmación que yo
mismo había escrito en el vault dos veces**.

**El estándar, tomado del [[Benchmark Biomecánico]] (§v2), fila de HZD:**
*"foot IK contra el terreno cada frame — pies creíbles en terreno"*, más
el canon de Sable de **raíz continua**. Traducido a tres métricas
medibles en `godot/tools/footik_benchmark.gd`: penetración del pie bajo la
superficie, adaptación del ángulo de planta a la pendiente, y dispersión
del avance de la raíz.

| Métrica | Godot | Estándar |
|---|---|---|
| Raíz continua | ✅ 0.0249 m/frame, desvío 7.7% | Sable: continua, cero pop |
| Penetración del dedo, plano | ❌ −0.132 m | ~0 |
| Penetración del dedo, rampa 21.8° | ❌ −0.205 m (peor −0.247) | ~0 |
| Adaptación de la planta | ❌ 10.9° de 21.8° | ≈ el ángulo del terreno |
| **Aporte del IK (on vs off)** | ❌ **1.4 mm** | — |

**El hallazgo:** con el foot IK apagado los números son idénticos hasta el
cuarto decimal. Verificado además de forma directa: `is_running() == true`,
`target_node` resuelve al nodo correcto, y aun así el hueso del pie se
mueve **1.4 mm** entre tener el IK corriendo y detenido, con el dedo 20 cm
bajo la superficie. **`SkeletonIK3D` no está haciendo nada.** Es coherente
con que esté marcado como deprecado en 4.x — el camino vigente es
`SkeletonModifier3D`.

**Qué se corrigió en el vault, porque estaba mal escrito:** la afirmación
"el foot IK stock alcanza en los dos motores" venía de la sesión anterior
del spike, y yo la repetí en [[Comparativa de Motores — Godot vs Unity]] y
en [[Current-State]]. Es falsa del lado Godot. El grounding que se veía en
las capturas venía del cuerpo apoyado por física, no del IK. Las dos
fuentes quedan corregidas con la medición.

**Por qué NO se corrió el lado Unity todavía, que era la otra mitad del
encargo:** medir Godot en este estado y ponerlo al lado de Unity daría una
ventaja falsa a Unity, por una razón que no es del motor sino del cableado
nuestro. Sería un número engañoso metido en una decisión de motor. Primero
hay que hacer funcionar el IK del lado Godot.

**Próximo paso propuesto:** reemplazar `SkeletonIK3D` por un
`SkeletonModifier3D`, volver a correr `footik_benchmark.gd` (ya deja los
números listos para comparar), y recién ahí portar la medición a Unity y
poner las dos columnas una al lado de la otra.

**Nota de método:** el linter cazó un crítico propio en este mismo
checkpoint — `§v2 pide` sin cerrar la cita de sección, exactamente la
trampa que [[Current-State]] §Pendientes ya advierte. Corregido a
`(§v2) pide`.

**Índice:** sin cambios.

## [2026-08-12] design/motor | Comparativa Godot vs Unity — pros/contras + FODA

Pedido del director tras mirar la lámina cuadro a cuadro. Escrita en
[[Comparativa de Motores — Godot vs Unity]].

**No reabre la decisión** — Godot sigue confirmado ([[ADR-002 Motor
diferido]] + cierre de ADR-003). El documento existe para sostenerla con
los ojos abiertos y para que el veredicto del spike compare lo mismo de
los dos lados. Cada afirmación va marcada por origen: 🔬 medido en el
spike · 📋 hecho verificable de plataforma · ⚖️ juicio.

**Punto de partida — una observación del director que resultó medio
cierta:** "Unity sí renderiza pies y Godot no". Verificado subiendo el
brillo del recorte: **la geometría está**, es que en la captura de Godot
Dagna quedó del lado en sombra (la cámara se movió de costado al corregir
la orientación, y el greybox no tiene GI). Pero abajo de eso **sí había
algo real**: el pie de Godot apunta la punta hacia abajo y penetra la
superficie, mientras el de Unity apoya con la suela plana. `SkeletonIK3D`
coloca el tobillo y rota al normal, pero no ajusta pelvis ni dedo.

**Lo que el spike probó:** el foot IK stock y el retargeting stock
alcanzan en los dos motores; la diferencia visual grande de la lámina es
de **clip**, no de motor (1.12 m de zancada contra 0.825 m).

**Lo que el spike NO probó, escrito explícitamente en el documento:** nada
de rendimiento comparado, combate, IA, UI, audio, build/export ni look
final.

**El eje que más pesa resultó no ser técnico sino de método:** Godot se
deja automatizar y verificar desde CLI (todo el spike se hizo con
`--headless --script`), y Unity mucho menos — hubo que entrar a play mode
en batchmode sobreviviendo el domain reload con `SessionState`, y pelear
el culling del Animator. Para un proyecto que se construye con un
asistente que necesita medir su propio trabajo, eso es un argumento a
favor de Godot que no estaba en la mesa cuando se decidió.

**El contraargumento más fuerte para Unity:** los 55 paquetes del Asset
Store ya comprados (~2.3 GB) funcionan ahí sin conversión.

**Pregunta abierta que debería decidir el veredicto:** si el foot IK y la
animación de Godot alcanzan el estándar del [[Benchmark Biomecánico]] o
si hay que escribir un `SkeletonModifier3D` propio. Tiene respuesta
empírica y todavía no se corrió.

## [2026-08-12] spike/godot | Cierre del moonwalk — la causa raíz era el frente del modelo, y me costó tres rondas

**Boris lo reportó tres veces. Las tres tenía razón, y las dos primeras
veces yo "arreglé" otra cosa.** Vale escribirlo completo porque el error de
método es más caro que el bug.

**La causa raíz, única:** el FBX del warrior está exportado **mirando a
+Z**, y Godot asume que el frente de un modelo es **−Z** —
`Basis.looking_at()` apunta el −Z al objetivo salvo que le pases
`use_model_front = true`. Así que `SpikeCompanionWalk` venía orientando a
Dagna **de espaldas** a su destino desde la primera versión. Subía la rampa
caminando hacia atrás.

**Medido, no supuesto:** los dedos del pie están +0.11 m por delante del
talón en Z, y la nariz +0.11 m por delante de las caderas. Frente = +Z, sin
ambigüedad.

**Por qué me costó tres rondas:**
1. El síntoma visible —"moonwalk"— lo producen **al menos tres causas
   distintas**: orientación invertida, clip espejado, y desajuste de
   cadencia. Arreglar una y ver que mejora **no prueba** que era la causa.
2. La orientación invertida **da vuelta el signo de toda medición sobre los
   huesos**. Yo medí el recorrido del pie plantado, lo leí con el signo
   cambiado, concluí que el clip estaba al revés, y lo cambié por el
   *backward* — o sea, empeoré el sistema mientras el número decía que
   mejoraba. Ese es el peor modo de falla posible de una medición.
3. Hubo una señal clara y la pasé por alto: un barrido de calibración salió
   **monótono al revés de lo que manda la física**. Lo atribuí al
   instrumento. Era el sistema.

**El arreglo, en un solo lugar:** el nodo `Model` se gira 180° al construir
la escena (`build_spike_scene.gd`). Todo lo demás —`Basis.looking_at`, el
vector `forward = -basis.z`— se queda con la convención del motor.
**Aplicar las dos correcciones a la vez (el giro del modelo Y
`use_model_front`) la deja caminando de espaldas igual**, que es como se
rompió en el intento intermedio. También se revirtió el cambio de clip: el
correcto es el *forward*.

**Lo que sí queda de las rondas anteriores** (era real, solo que no era la
causa raíz): el clip in-place aporta su propia velocidad —0.825 m por paso,
2 pasos por ciclo de 1.067 s = **1.55 m/s**— y si el cuerpo se traslada a
otra, el pie patina. La cadencia (`speed_scale`) se ata a la velocidad real
cuadro a cuadro, lo que además resuelve solo el caso de la pendiente, donde
el avance efectivo cae bastante por debajo del pedido.

**Verificación final, con la prueba limpia** (cuánto avanza el cuerpo por
vuelta del clip contra la zancada que el clip aporta): **0% en régimen**
(ciclos 3 y 4: 1.649 m y 1.650 m contra 1.65 m). Y sube la rampa: z va de
−4.16 a +0.06 hacia el objetivo, en vez de alejarse.

**La lámina comparativa Unity/Godot se regeneró** con Dagna orientada bien
en los dos motores. Lo que muestra sigue siendo lo mismo: la diferencia
grande es de **clip**, no de motor — 1.12 m de zancada en Starter Assets
contra 0.825 m en DoubleL.

**Todo esto está en [[Lecciones]] §Godot 4.7**, con la viñeta del frente
+Z marcada como la trampa grande y el chequeo de 30 segundos para
detectarla (dedos contra talón, nariz contra caderas).

**Índice:** sin cambios — no se crearon notas nuevas del vault.

## [2026-08-12] spike/godot | El moonwalk eran DOS problemas, no uno — y comparador cuadro a cuadro Unity/Godot

> **⚠️ PARCIALMENTE SUPERADA.** El diagnóstico de esta entrada era
> incompleto: la causa raíz del moonwalk no era ni la dirección del clip
> ni la cadencia, sino que **el modelo tiene el frente en +Z** y Dagna
> caminaba de espaldas. Ver la entrada de cierre más abajo en esta misma
> fecha ("la causa raíz era el frente del modelo").

Boris volvió a ver el moonwalk en la ventana viva **después** del cambio de
clip. Tenía razón, y la lección es de método: **dos causas distintas con el
mismo síntoma visual**, y haber arreglado la primera me hizo dar la segunda
por resuelta.

1. **Dirección** (cerrado en la pasada anterior): el rig de DoubleL tiene el
   rest mirando al revés, y el clip "forward" del pack hacía caminar al
   revés. Se cambió al clip backward.
2. **Velocidad** (esto): el clip es *in-place* y aporta una zancada propia —
   0.65 m por paso, 2 pasos por ciclo de 1.067 s = **1.22 m/s**. El driver
   la trasladaba a **1.5 m/s**: 23% de patinada contra el suelo en plano. Y
   en la rampa se invierte de signo, porque trepando el avance real cae.
   **La solución no es bajar `walk_speed`** — es atar la cadencia
   (`speed_scale`) a la velocidad real cuadro a cuadro, con la velocidad 3D
   completa sobre el piso (achatar la Y dejaba ~10% de desfase cuesta
   arriba). Es lo que hace cualquier sistema de locomoción real.

**Cómo se midió, que es la parte que costó.** El primer estimador
—"el pie apoyado es el más bajo / el más lento"— **daba basura**: con foot
IK los dos pies tocan el suelo, así que ni la altura ni la velocidad mínima
discriminan. Un barrido de calibración salió monótono **al revés** de lo que
la física manda, que fue la señal de que el instrumento estaba roto, no el
sistema. La medición limpia, sin heurística: **cuánto avanza el cuerpo por
vuelta del clip**, contra la zancada que el clip aporta. De **+23% a +0%** en
régimen.

**Comparador cuadro a cuadro** (lo que Boris pidió): `frame_strip.gd` del
lado Godot y `SpikeFrameStrip.cs` del lado Unity, mismo protocolo —
mismo punto de la rampa con Dagna quieta ahí, mismos 8 cuadros de un
ciclo, misma cámara, y **la fase inicial alineada por el contacto del talón
izquierdo detectado midiendo el hueso**, no elegida a ojo. Sin esa
alineación las dos tiras arrancan en puntos arbitrarios del paso y las
columnas no significan nada.

**Lo que la lámina dice:** la diferencia grande **no es de motor, es de
clip**. La zancada de Starter Assets recorre 1.12 m; la de DoubleL, 0.65 m —
una caminata civil de paso largo contra un paso corto de combate con el
arma arriba. Lo que sí es comparable motor a motor —retargeting stock y
foot IK stock sosteniendo el pie en la pendiente— **funciona en los dos**.

**Trampas del camino, todas en [[Lecciones]] §Godot 4.7:** el culling de
Animator de Unity (en batchmode deja de escribir los Transform de los
huesos: el pose se renderiza bien pero `GetBoneTransform` devuelve siempre
lo mismo) · esperar frames de física y no de render para que Dagna se
asiente · `SpikeCompanionWalk` pisando el `seek()` del capturador con
`play("idle")` · y que `SkeletonIK3D` en 4.7 es un `SkeletonModifier3D`, así
que `get_bone_global_pose_no_override()` **no** es el equivalente de
`Animator.GetIKPosition()` (verificado midiendo: no movió la aguja, se
revirtió).

**Índice:** sin cambios — no se crearon notas nuevas del vault.

## [2026-08-12] spike/godot | Dagna camina de verdad — retargeting stock + 3 bugs de importación que el spike anterior tapaba

> **⚠️ CORRECCIÓN.** El punto 3 de esta entrada ("el clip forward hacía
> moonwalk, el rig del pack viene espejado") **es falso**. El rig del pack
> está bien; lo que estaba invertido era la orientación de Dagna. El clip
> correcto es, y siempre fue, el *forward*. Ver la entrada de cierre.


**Qué se cerró:** la brecha de *feel* entre los dos motores del spike de
ADR-003. En Unity, Dagna caminaba con animación real (retargeting Mecanim
desde Starter Assets). En Godot solo se trasladaba — el FBX del warrior
(`asoliddev`) trae **2 poses estáticas** y ningún ciclo. Ahora camina con un
ciclo real, retargeteado con la herramienta **stock** de Godot
(`BoneMap` + `SkeletonProfileHumanoid`), mismo criterio que en Unity: cero
solver escrito a mano.

**Inventario de packs (paso 1 del plan).** De los 3 candidatos que Boris ya
tenía en disco:
- **ExplosiveLLC** (`RPG Character Mecanim Animation Pack FREE`) — el FBX de
  caminata **no trae Skeleton3D**, solo pistas (`Take 001`, 23 tracks). Sin
  esqueleto no hay `BoneMap`. Descartado.
- **Kevin Iglesias** (`Human Animations`) — rig **también Rigify**
  (`B-thigh.L`, `B-shin.L`, `B-foot.L`), lo más cercano a Dagna de los tres,
  pero la versión free **no trae Walk**, solo Run. Descartado para esta pasada.
- **DoubleL** (`RPG_Animations_Pack`) — 70 huesos con nomenclatura Unity
  Humanoid (`Hips`, `Left_UpperLeg`, `Left_Foot`) y un Walk in-place real de
  1.07s / 81 pistas. **Elegido.**

**Los dos BoneMap** (`godot/assets/bonemap_*.tres`, generados por
`godot/tools/make_bone_maps.gd`, que valida cada nombre contra los huesos
reales del FBX antes de escribir): 55/56 slots del perfil humanoide mapeados
en los dos rigs — solo `Root` queda sin mapear, porque ninguno de los dos
tiene hueso raíz. Con los dos esqueletos renombrados al mismo perfil, las
pistas del pack caen sobre los huesos de Dagna sin tocar nada más.

**Tres bugs encontrados en el camino — los tres pre-existentes, tapados por
el spike anterior.** Están escritos en [[Lecciones]] §Godot 4.7:
1. **Re-apropiar los hijos de una escena instanciada** hacía que
   `PackedScene` guardara el modelo como `instance=` *y* re-declarara cada
   hijo con `type=`: la escena cargaba con **dos árboles**, uno huérfano.
   Era justo el que encontraba `SpikeFootIK` — `is_inside_tree() == false` y
   errores cada frame — y el que se renderizaba, con la escala del FBX sin
   corregir.
2. **Las poses del warrior traen una pista de escala `(100,100,100)`** sobre
   el nodo raíz del modelo (centímetros del FBX original). El importador la
   saca del transform pero la deja en la animación: reproducir "idle"
   inflaba al personaje 100×. Se veía en las capturas como una figura gigante
   detrás de la rampa.
3. **El clip "forward" del pack hacía moonwalk.** El rig de DoubleL tiene el
   rest mirando al revés (+Z, convención de Unity); el retargeting normaliza
   los ejes de cada hueso pero no el rumbo global, así que el torso quedaba
   bien orientado y las piernas caminaban en reversa. **Lo detectó Boris a
   ojo, en mitad de la sesión.** Medido después con el pie plantado: con el
   clip `_F` viajaba hacia adelante durante el apoyo. Bajo el giro de 180°
   que separa los dos rests, el clip **backward** del pack es el forward
   nuestro — con la inclinación y el balanceo de brazos correspondientes.

**Verificación** (`godot/tools/verify_and_capture.gd`, se conserva): corre la
escena ~6.5s, sigue a Dagna con una cámara de costado, saca 4 capturas y
**mide la rotación del muslo izquierdo** — falla con exit 1 si el hueso no se
mueve, que es la única forma de distinguir traslación de caminata. Resultado:
**24° de rotación de muslo, ciclo alternado, pies apoyados en la pendiente
vía IK sobre el pose animado**. `SpikeFootIK` no necesitó cambios de lógica,
solo los nombres de hueso del perfil (`LeftUpperLeg`/`LeftFoot` en vez de
`thigh.L`/`foot.L`).

**Archivos:** `godot/scripts/anim_installer.gd` (nuevo, instala las
animaciones en `_ready()`), `companion_walk.gd` (reproduce walk/idle),
`foot_ik.gd` (nombres del perfil + orden de configuración del
`SkeletonIK3D`), `tools/build_spike_scene.gd`, `tools/make_bone_maps.gd`
(nuevo), `assets/anim/walk_doublel.fbx` + los 2 `.tres`. `.gitignore`
anotado: el pack DoubleL sigue ignorado del lado Unity, se versiona solo el
FBX copiado.

**No entró, por diseño:** nada del lado Unity (ya tenía animación real), la
caminata del jugador (sigue idle en los dos motores), y el veredicto
Godot-vs-Unity. Esta pasada solo empareja las condiciones para que ese
veredicto compare lo mismo de los dos lados.

**Deuda anotada, no bloqueante:** el clip es `1Hand_Up_Walk` — Dagna sostiene
un hacha a dos manos, así que los brazos no cuadran con el arma. Las piernas,
que es lo que esta pasada tenía que probar, sí. Y el foot IK baja los pies
sin ajustar la pelvis, así que en pendiente la deja un poco agachada.

**Índice:** sin cambios — esta pasada no creó notas nuevas del vault.

## [2026-08-12] QA de canon | 5ª re-corrida — 13 críticos, la ruptura reubicada, y una deuda de propagación de 12 fichas

**Fase 0 — linter:** 0 CRITICAL / 0 MEDIUM / 27 INFO antes de spawnear.

**Fase 1 — 2 subagentes Opus en frío**, los dos con instrucción explícita de
barrer las 12 fichas contra el canon escrito el 08-11 (que nunca había sido
auditado). Resultado: **dramaturgia 5C/6M/4L · congruencia 8C/7M/4L.**

**Los dos convergieron en el mismo hallazgo sin verse**, que es la señal más
fuerte que dio cualquier ronda hasta ahora: **el cambio de la traición en dos
tiempos no se propagó a ninguna de las 12 fichas.** Nueve escenas de corredor
siguen escritas como la revelación (*"¿lo sabías TODO ESTE TIEMPO?"*, el shock
de los tres fijos, "nadie lo nota"), ninguna ficha tiene sección de ruptura,
ninguna coloca el obstáculo firma del link en la ventana, y los índices
declaran 5 sub-beats cuando son 6.

### La ubicación estaba mal elegida — corregida

El hallazgo que obligó a rehacer la decisión del 08-11. La ruptura se había
puesto en **Driftmarket**, y chocaba con tres cosas que no se habían leído
antes de decidir:

1. `Geografía` §THE RECKONING declara *"Nadie confiesa. Nadie confronta. Se
   acuestan temprano — al amanecer bajan al Archive"*, cien líneas antes del
   sub-beat que se insertó. El archivo se contradecía consigo mismo.
2. La **trampa de Tobin** (confrontar al fijo equivocado) perdía casi todo su
   valor: la ventana de error se cerraba en minutos si el Pivote se
   autodenunciaba en la misma locación.
3. **En las rutas Lyris, Iven y Maren la orden que motiva la traición llega
   dentro del Archive** — a Lyris el mensaje cifrado en el corredor, a Iven
   una orden condicional (*"cuando entren al Archive…"*), a Maren una señal
   cifrada ahí mismo. La convicción precedía a su propio detonante.

**Decisión de Boris (2026-08-12): la ruptura se muda a la sala del Fragmento,
dentro del Archive.** El Fragmento pasa a ser el detonante — su verdad parcial
está *diseñada para dividir al grupo* ([[Estructura Dramática]] §Nudo), así que
era el disparador natural desde el principio. **La ventana del Bond vacío es
ahora el ascenso.** Las tres colisiones se resuelven solas.

Tocado: `Geografía` §ACTO 3 (sub-beat 0 eliminado, **sub-beat 2b** nuevo,
estructura a 6), `Bond y el Bond Vacío` (fuente única), `Estructura Dramática`
§Clímax, `El Cráter` §1 paso 1.

**Excepciones, ahora en la fuente y no dispersas:** **Bram** declara lo mismo
que los otros ocho y no obedece — su link nunca muere, y la inversión de su
beat firma depende de que la declaración exista. **Nyael declara por
ausencia**: no está en la sala del Fragmento, se separó en el descenso. Su
superlativo ("la traición como ausencia") sobrevive intacto, que era el riesgo
real de aplicarle el beat estándar.

**Forma de la ruptura — nueve formas desiguales, no plantilla** (decisión de
Boris). El beat se define por su función (el link muere y el Pivote no se va),
no por su formato: una frase seca para Maren, quince líneas para Sereth, casi
ninguna palabra para Vekka.

### Errores propios, corregidos

- **La entrada Valen + Dagna escrita el 08-11 estaba mal en dos cosas.** Decía
  que Valen "no la vio venir"; la ficha de Dagna —que es la fuente del beat— lo
  tiene diciendo *"Las cartas desde Emberdeep. Debí haber preguntado"*: sí vio
  el patrón y lo omitió por respeto élfico. Y decía que el beat de la cifra
  errónea llega "poco después", cuando llega **antes** (Grove of Cycles, Acto
  2). Reescrita, y quedó mejor: es la única traición del set donde la falla de
  Valen no es de modelo sino de carácter, y por eso la única que no puede
  convertir en dato sobre el traidor.
- **Dos críticos más de la clase "cita § sin cerrar"**, la misma que ya se
  registró el 08-11. El linter los cazó en el checkpoint. **La lección no
  prendió a la primera: cerrar la cita `§` antes de continuar la oración.**

### Verificado limpio (sin hallazgo)

El barrido confirmó explícitamente que el arco de **90 años de Valen** quedó
correcto, incluidos los dos "200 años" que se dejaron a propósito (antigüedad
de los registros y The Shattered Spire); que **Roen 70-75** es consistente en
las dos fuentes; que la regla de **derribar al portador** está enunciada una
sola vez y citada, no re-enunciada; y que **los 60 epílogos no tienen
desviaciones** de sabor ni de tono (los 12 F2b respetan la prohibición de
"aprendimos algo", los 12 F1 respetan las tres prohibiciones del costo, y los
4 grados de agencia de Speck se respetan en todos).

### Lo que queda — ver [[Current-State]] §Bloque de propagación

La deuda de las 12 fichas se convierte en **su propio bloque de trabajo**, no
en un ítem de QA. Además quedaron ~15 medios y bajos sin tocar, dos de ellos
**pre-existentes y con peso propio**: `Vekka` usa la palabra "Warden" en Actos
1 y 2 (el canon dice que no existe públicamente hasta el Archive, y siendo
enana no tiene vía al término), y la **Primera Cuña de Dagna** —el único pago
mecánico del bond alto con el Pivote— está anclada a "la roca del nido", un
lugar por el que la traición ya no pasa, y ni la cuña ni el martillo heredado
aparecen en su ficha.

**Nota de método de la 5ª:** el patrón de las últimas dos rondas es que **una
decisión de canon tomada sin leer las fichas que la consumen genera más trabajo
del que resuelve.** La reubicación de la ruptura no se descubrió porque un
subagente fuera severo, sino porque leyó tres fichas que no se habían abierto
al decidir. Antes de la próxima decisión estructural: leer los consumidores
primero.

## [2026-08-11] QA de canon | 4ª re-corrida del ciclo de la 17ª — 8 críticos, 6 decisiones de Boris, todos corregidos a la fuente

**Fase 0 — linter:** `check_canon.py` en **0 CRITICAL / 0 MEDIUM / 28 INFO**
antes de spawnear nada. Los 28 INFO son cifras en diálogo (verificación
manual) y wikilinks rotos que viven todos en `LOG.md` y
`Current-State-Historico.md` — bitácora, no canon. Vía libre.

**Fase 1 — 2 subagentes Opus en frío, en paralelo**, los dos con el contrato
de reportar la clase completa y los dos apuntados explícitamente a
`El Cráter — Matriz de Rutas` como fuente única (la nota de método que dejó
la 16ª tras 7 falsos positivos por no encontrarla). **Funcionó: ninguno de
los dos reportó un solo falso positivo de la mecánica del cráter.**

Resultado: **congruencia 4C/12M/6L · dramaturgia 4C/8M/8L.**

### Los 8 críticos y cómo se cerraron

1. **La decisión de la crisálida** (10 archivos la daban como bifurcación
   real; `Speck.md` y `Estructura Dramática` decían que no ocurre).
   **Decisión de Boris: elección ilusoria.** El juego ofrece el gesto y no
   lo completa; lo que el jugador elige es cuánto tarda en no hacerlo y
   quién lo ve dudar. Fuente única nueva en `Speck.md` §El encuentro;
   propagado a los 11 sitios. Re-grep: 0 residuos.
2. **Dónde renunció Roen** (POI de frontera con flashback vs. la puerta del
   Council). **Decisión de Boris: dos momentos, un arco** — decide en la
   frontera, formaliza en Rivermeet. Precisado en `Geografía` ×3.
3. **Darro con escudo** en la escena del cráter de Dagna, contra la matriz
   de armamento ratificada (hachas cortas, sin armadura pesada). Su propia
   ficha ya resolvía la escena bien. Corregido en `Dagna-Ficha` ×2.
4. **El cierre F3 del bookend** tenía a Roen ausente del clímax ("I don't
   know how it finished"), contra su ficha, `Los 5 Finales` §F3 y
   `Dagna-Ficha` (su escudo cae en el cráter en las cinco rutas). **Decisión
   de Boris: se va después del clímax.** Diálogo F3 reescrito: sabe cómo
   terminó, se fue de lo que vino después. Tono frío conservado.
5. **El "Eco final" del Bond Vacío no tenía ventana** — el Pivote se llevaba
   a Speck en el corredor y de ahí iba directo al cráter. El pago entero del
   pilar 2 sin lugar donde ocurrir, y la excepción de Bram apoyada en aire.
   **Decisión de Boris: adelantar la traición.** Ahora tiene **dos tiempos**:
   la **ruptura** en Driftmarket (ahí muere el link, y el Pivote sigue
   caminando con el grupo — la pérdida es una presencia que ya no responde) y
   la **toma** en el corredor, que pasa a ser culminación. El tramo entre las
   dos (approach + interior del Archive) es la ventana de los beats 2-3.
   **El Eco final se ancla en el cráter**, porque E3 solo ocurre ahí
   (`Speck` §Capa 4). Nuevo sub-beat 0 en `Geografía` §ACTO 3; reescrito
   `Bond y el Bond Vacío` §La traición tiene dos tiempos; `Estructura
   Dramática` §Clímax; `El Cráter` §1 paso 1. Excepción de Bram reconciliada:
   en su celda el sub-beat 0 **sí ocurre** (anuncia que se lo pidieron, no
   que vaya a obedecer), lo que hace más fuerte la inversión.
6. **Los 5 gates no eran mutuamente excluyentes** y la fila F4 de la tabla
   omitía las 2 condiciones globales — leída como fuente única, gateaba F4
   en cualquier partida. **Decisión de Boris: F4 gana** si sus 2 condiciones
   están cumplidas; si no, gana el gate de la acción. Añadida regla de
   precedencia + los dos casos resueltos (F1+F4: el mensajero neutralizado
   "no vuelve a levantarse"; F3+F4: cruzar después de que ella contestó no
   es F3).
7. **Vanguard con ventana de remate en T1**, contra la misma sección que
   dice que recién ve el lanzamiento en T2 (dos pasadas distintas, la vieja
   quedó muerta) y contra el guión ya escrito. Corregida la línea vieja.
8. **La cifra de Valen.** **Decisión de Boris: son ~90 años** (230 − 140).
   Corregida la clase real —tiempo desde la negativa de los ancianos— en
   `Valen-Ficha` ×3 y `Los 3 Links` §T3. **Acotación de la 4ª:** de los 7
   sitios que el subagente reportó, **3 no eran de esa clase** (antigüedad
   de los registros, y cuándo estudió en Shattered Spire — con 230 años,
   "hace 200" ahí es correcto). Aritmética fijada en nota de canon. El
   anillo se resolvió como beat: se lo hizo grabar a los 140, al salir de la
   sala donde lo rechazaron.

### Medios cerrados en la misma pasada

Maren "mata con precisión" → Strategist no inflige daño directo · Roen
"moralizador" con signo opuesto en dos fichas vivas · `Acoplamientos` seguía
citando el modelo de "estadios" de Speck que `Speck.md` derogó · el bookend
F1 metía "three winters ago" entre apertura y cierre, rompiendo el
dispositivo · Aethelgard Watch "en el paso de montaña" vs. §M (River Road) +
cita a una "§Los Cuatro Puestos" inexistente (son tres) · Vekka pedía "su
espada" a un jugador cuya celda usa war flail · el superlativo de F4
precisado contra el Momento de Persona 5 · "los tres reinos movilizan
ejércitos" en `Estructura Dramática` era residuo del GDD y contradecía la
escala mínima del Acto 3 · redacción autocontradictoria del epílogo F2a de
Nyael · "The Bound Five talla SPECK" cuando el grupo no siempre es cinco ·
§H listaba un sitio de un fijo bajo "de los Pivotes".

**Y el más visible:** `Guion/Apertura — Roen Viejo` (ratificado, primera
línea del juego) describía el trabajo de Roen como una entrega — *"deliver a
package"*, *"everybody signs that contract"* — reintroduciendo la ambigüedad
del Contrato de Conquistador que se había corregido el 08-10 **solo en la
escena jugable**. Mismo bug, posición más visible del guión. Reescrito.

**Nota de método de la 4ª:** los 8 críticos y la mayoría de los medios son
fallas de **propagación**, no de escritura — un fix correcto aplicado en un
archivo y no en la clase completa. El linter no los ve porque ninguno rompe
un enlace ni una cita §. Es exactamente el cuello de botella que
[[Lecciones]] ya nombra, y sigue siendo el que más cuesta.

**Un crítico propio:** una cita §  que agregué en el fix de Nyael no
resolvía; el linter lo cazó en el checkpoint. Corregido antes de commitear.

### 2ª tanda del mismo día — los medios abiertos, cerrados

4 decisiones más de Boris, todas escritas a la fuente:

- **Roen en el bookend: 70-75 años.** Los cierres dicen "thirty years" ×4 y
  el peso del beat de F2b depende de que sea mucho tiempo, así que manda la
  banda, no al revés. Corregidos `Voz Narrativa` y la puesta en escena +
  la línea de acción de `Apertura` ("75 years old now").
- **Los 2 años de espera de Darro van dentro de las edades 30-33.** El
  rechazo de Vekka llega al primer año del aprendizaje, no al final; Darro
  se queda los 2 restantes. Sale a los 33 y la cadena 33→38→63 y la edad
  ~63 (declarada "no libre") quedan intactas.
- **El Acto 1 tiene un solo Momento de Persona**, el del nido. `La Rueda`
  decía "los 2 primeros" contra `Speck` y `Geografía`; corregida `La Rueda`
  y desambiguado el "Acto 1→2" del Momento 2. Importa porque el gate de F4
  se calcula sobre los Momentos disponibles.
- **Derribar al portador no mata a Speck** — escrita la excepción física en
  `Speck` §Capa 5, que es lo que hace jugable F1 en las dos rutas donde el
  holder es el agente (Nyael, Bram). La sobrecarga necesita que la fuerza
  entre **por el cuerpo de Speck**; golpear al portador la deja caer suelta,
  que es la condición de "cederla". **Regla de escritura nueva:** el jugador
  no pone una mano sobre Speck en F1 — si la agarra, es F2b, y en esas dos
  rutas la tentación de escribirlo mal es máxima. La matriz aseguraba que F1
  funcionaba ahí sin explicar nunca por qué.

**Hueco de contenido cerrado:** escrita la entrada **Valen + Dagna**. Era el
único hueco de la matriz 3 fijos × 9 Pivotes (Roen y Darro tenían 9, Valen
8). Valen la archiva como músculo leal —el error que todo el mundo comete
con Dagna— hasta que ella le señala que "el sistema como fenómeno sin autor"
es también una forma de no mirar. Su traición es la única que Valen convierte
en dato sobre sí mismo, y es el ensayo del beat de la cifra errónea.

**Resto de medios y bajos cerrados:** ritos duplicados de Torgan y Dagna en
dos POIs · Lyris tomando prestado el beat de "Deber Institucional" en F2a
(ahora **no la asciende nadie** — para una cadena así cumplir no es mérito,
es el mínimo) · arnés de Vekka condicionado a la variante viva · beat de
duelo de Maren alineado con su ficha · `Encuentro con Roen` decía "el link no
cambia por rol" contra "split por rol" de su fuente (hablaban de cosas
distintas: la acción de Roen vs. la respuesta del jugador) · Sereth citando
F1 dentro de la ficción de F3 · "sub-acto 1B" (los sub-actos son del Acto 2)
· los tres flashes de Speck colapsados en dos en `Geografía` · nota de
trabajo cruda dentro de `Nomenclatura`, que es `ratificado`.

**Tres críticos propios más**, todos de la misma clase y todos cazados por
el linter en el checkpoint: citas `§` donde el texto que seguía al nombre de
sección se parseaba como parte del nombre. Reformuladas. **Vale como lección
de escritura:** cerrar la cita `§` antes de seguir la frase.

**Queda abierto como decisión de diseño, no de QA:** el caso "rol duplicado"
vive en T1 para Roen y en T2 para Valen y Darro, sin razón declarada, y solo
en Roen sustituye el sabor base en vez de sumarse.

## [2026-07-24] design/QA | §10 generado — 5/6 aprobados + regla nueva anti-texto-en-imagen

**Ronda de QA de los 6 briefs de §10** (Isolde Marrow, Tobin Hale, Threnn,
Ilyara, Maelys, Corwyn) — Boris pasó las 6 imágenes generadas en NB2.

**✅ Corwyn — Aprobado.** Cabello plateado en moño formal, sonrisa
confiada/calculadora, marcas teal discretas en el cuello ("understated"
como pedía el brief), anillo de plata único visible. Sin violaciones.

**✅ Maelys — Aprobado, el mejor logrado.** Cabello plateado suelto/
enredado tapando parte de la cara, chal gris envolvente, postura
encorvada/distante, mirada hacia abajo (cerca de "mirar a través de").
Captura el tono roto perfectamente.

**✅ Harbormaster Tobin Hale — Aprobado.** Abrigo desgastado y remendado,
barba gris, expresión cansada pero cálida, botas gastadas, cinturón
práctico. Detalles nuevos coherentes no especificados en el brief:
astrolabio colgante, catalejo de latón. 🟡 Nota menor: el brief pedía
"dispersión de pequeños amuletos de décadas de comerciantes/refugiados"
(detalle emocional central) — quedó reducido a un solo colgante, no
bloqueante.

**✅ Lady Isolde Marrow — Aprobada, muy fuerte.** Cabello auburn con
soltura, sonrisa confiada, outfit burgundy/bronce con broches de latón
(match casi exacto al brief), escudo de House Marrow en el pecho, anillo
heredado con grabado mostrado en detalle, sin corona (correcto).

**🟡 Threnn — Aprobado con nota menor.** Expresión estoica de guerrero muy
bien lograda. 2 desviaciones menores: marcas de aether demasiado
brillantes (brief pedía "dimmer... as if faded", acá leen como mago
activo); no se ve el cinturón de espada vacío ni la cicatriz del
antebrazo (mangas los tapan). No bloqueante.

**🔴 Ilyara — Falla técnica, mismo glitch que Kadrun v1.** Texto filtrado
dentro de la imagen: caption corrompido *"ILYARA SILVER CALM, CLAIER OF
DEEPLY COMPASSIONATE, AND CLEARLY CARRY OLD GRIEF AND WISDOM WITHOUT NO
BITTERNESS."* (palabras corruptas, doble negativo gramatical). El diseño
del personaje en sí, ignorando el texto, coincide bien con el brief
(robes verde salvia, bolsa de hierbas, tatuaje de antebrazo, rostro
compasivo). Conclusión: el formato de prosa corta que resolvió Kadrun no
garantiza 0% de glitch — hay un componente de azar en NB2, no es 100%
determinístico por prompt.

**Hallazgo adicional — etiquetas de texto limpias (no glitch):** en Tobin
e Isolde aparecieron etiquetas de texto BIEN escritas (nombres de piezas
como "Astrolabe"/"Anchor Coat", listas de negativos) — un formato de
"hoja de spec anotada" que NB2 elige a veces, DISTINTO del bug de texto
corrompido. No arruina el diseño pero no es lo pedido (concept sheet
limpio). **Decisión de Boris:** agregar negativo estándar para evitarlo
por default, útil para cuando las láminas se usen para medir proporción.

**Acción — regla nueva agregada al bloque de estilo compartido:**
*"no text, no labels, no captions, no annotations, no diagram-style
callouts"* — agregado a los 6 prompts de §10 (incluyendo el de Ilyara que
hay que re-correr) y documentado como regla estándar para todo brief
futuro.

**Archivo:** `Briefs de Concept Art.md` — nueva regla en el bloque de
estilo compartido (línea ~14) + negativo agregado a los 6 prompts de §10.

**Pendiente:** re-correr Ilyara (prompt ya actualizado con el negativo
nuevo, sin otros cambios — el diseño en sí ya estaba bien).

---

## [2026-07-24] design | Briefs de concept art del elenco político nuevo (§10)

**Disparador:** en vez de dejarlo en backlog para la próxima sesión, Boris
pidió escribir los briefs de una vez.

**6 briefs nuevos** en `Briefs de Concept Art.md` §10: Lady Isolde Marrow,
Harbormaster Tobin Hale, y los 4 de The Elder Circle (Threnn/Ilyara/Maelys/
Corwyn).

**Cambio de formato deliberado:** en vez de repetir la fórmula "Use the X
phenotype as the exact anatomy and proportion reference" del §9 original
(que causó el glitch de texto filtrado en Kadrun v1 y peor fidelidad de
proporción), estos 6 usan directamente el formato de prosa corta que
resolvió ambos problemas en Kadrun v2 — proporción como primera frase,
negativos como oraciones cortas al final, sin la carga de vocabulario
técnico denso en una sola oración.

**Nota transversal para The Elder Circle:** los 4 deben leer visiblemente
más viejos que cualquier otro elfo ya generado (Valen/Sereth/Lyris/Nyael/
Cyrion, todos 180-250 años) — se acercan al techo de vida élfico (650-700).
Canas totales (raro en elfos), quietud pesada en la postura, piel aún más
translúcida por la edad. Cada uno con detalle específico de su arquetipo:
Threnn (guerrero, cinturón de espada vacío), Ilyara (sanadora, bolsa de
hierbas), Maelys (rota, mirada que atraviesa al espectador), Corwyn
(cortesano, anillo de plata único).

**Destino:** `90-Raw/concept/` — `isolde-marrow-v1.png`,
`tobin-hale-v1.png`, `threnn-v1.png`, `ilyara-v1.png`, `maelys-v1.png`,
`corwyn-v1.png`. Tabla de fenotipos a adjuntar incluida en el doc.

**Con esto, el pendiente de concept art marcado al cierre de la sesión
anterior queda resuelto — listo para que Boris corra los 6 prompts en
NB2.**

---

## [2026-07-24] narrative/retcon | The Bound Five (renombre) + Old Tobin Hale + The Reckoning

**Disparador:** al escribir a Lady Isolde Marrow, Boris identificó un hueco
más — una figura "rey informal" del Driftmarket, no nobiliaria, dueña de
facto del comercio pero por reputación, no corrupción, muy querida, que
ayuda al jugador en algún punto. Eso escaló a una restructuración de acto:
el arco de preparación pre-clímax pasa a vivir en el Driftmarket.

### Renombre: El Quinteto → The Bound Five

Boris preguntó nombre en inglés para "El Quinteto" — se evaluaron 4
opciones (The Bound Five / The Five / The Quintet / The Fivefold). Elegida
**The Bound Five** por trabajo temático extra: conecta directo con el
título del juego (*AETHER BOUND* = atado por el Aether/Bond/rumbo a The
Wilds) — el nombre del grupo describe literalmente el título.

**Alcance confirmado por Boris: retraducción completa, no gradual.**
22 archivos actualizados (todas las fichas de Pivotes/fijos, docs de
worldbuilding, Current-State, 00-Index) — mismo criterio que la
retraducción institucional de antes. Deliberadamente NO tocados: LOG.md y
`.obsidian/workspace.json` (config de app, no contenido).

### Old Tobin Hale — Harbormaster del Driftmarket

**Concepto central:** el único personaje de poder sin agenda oculta en todo
el elenco político. El Council tiene interés institucional oculto, Isolde
Marrow calcula su ascenso, hasta Maren tiene que jugar política pese a
querer evitarlo — Tobin ayuda porque puede, no porque calcula.

- Sin título nobiliario, sin sangre de House — controla derechos de
  atraque/rutas comerciales/flujo económico del Driftmarket por
  **reputación**, no corrupción
- Empezó como contrabandista/refugiado él mismo, décadas atrás
- Querido porque nunca engaña, da crédito a quien lo necesita, protege
  refugiados sin preguntar de qué huyen
- Encarna "Bond sobre Standing" — no le importa el rango oficial, solo la
  decencia
- Línea canónica: *"I don't care who you were before you got here. I care
  what you do while you're standing on my docks."*
- Posible conexión: vouches por Darro desde antes, explica por qué C4 se
  recluta ahí con naturalidad

### The Reckoning — restructuración de Acto 2→3

**Decisión de Boris:** el arco de preparación antes del clímax, y las
decisiones que cambian el rumbo de la historia, deben vivir en el
Driftmarket — no como "interludio menor" sino como su propio beat
estructural entre el cierre de los 3 sub-actos de Acto 2 y el arranque de
Acto 3.

**Por qué funciona:** el Driftmarket es el único territorio neutral, fuera
del control de Council/Corona/Consortium — el único lugar donde el grupo
puede prepararse sin que nadie tenga agenda oculta sobre ellos.

**Beat 1 — Advertencia de Tobin (privada, solo al jugador, no a The Bound
Five entero):** Tobin, vía su red de información del mercado negro, avisa
que algo se mueve en canales del Council para entregar a Speck — sin saber
quién de la tripulación carga esa orden. Agencia real del jugador: ¿confronta
a su Pivote? ¿confía en Speck? ¿observa en silencio? Define cómo el jugador
*vive* la traición, no si la evita.

**Beat 2 — the Wanderer's Goggles:** Tobin le da al jugador unos lentes de
latón viejos que pertenecieron a un extraño de su pasado con "la misma
mirada". No es upgrade mecánico — es revelación narrativa de que el poder
innato del jugador (los flashes que revelan la verdad de Speck) es la clave
de todo. Deliberadamente sin resolución completa (mismo principio que The
Monolith) — ni Tobin ni el jugador entienden del todo qué es el poder, y el
extraño de la historia nunca se nombra.

Cierra con la **última escena de unidad genuina de The Bound Five** antes
de que la traición los rompa.

**Archivos actualizados:** `Nomenclatura.md` (3 entradas nuevas: The Bound
Five, Tobin Hale, the Wanderer's Goggles), `El Quinteto.md` (título +
contenido), `Geografía y Ciudades.md` (sección Tobin + beat The Reckoning
completo + tabla resumen), + 22 archivos con el renombre Quinteto→Bound
Five.

---

## [2026-07-24] narrative | Lady Isolde Marrow — rival político de Regent Edrick

**Disparador:** último ítem del backlog de personajes con peso real —
darle cara individual a "6-8 Houses cayeron en 550 años".

**Diseño:** no es solo "otra House más" — quiere terminar con el Regentado
mismo y restaurar una Corona hereditaria real, lo que la vuelve amenaza
tanto para Edrick como para el **Triune Council** (un trono humano
consolidado rompe la mayoría 2-contra-1 que hoy le conviene al Council,
"La ventaja de la inestabilidad humana").

**Lady Isolde Marrow (House Marrow):**
- Contraste con Edrick: carismática, confiada, populista vs. administrativo,
  nervioso, cauteloso
- Reclamo: linaje que dice predatar incluso a House Ashcombe — verificable o
  no, la gente quiere creerlo tras 550 años de gobernantes de turno
- Base de poder: Houses menores cansadas del ciclo + respaldo militar/
  mercenario de frontera
- Línea canónica: *"Ashcombe borrows the throne every decade. I intend to
  keep it."*

**2 ganchos narrativos abiertos, no desarrollados aún:**
- **Con Bram:** su tipo de compañía mercenaria es exactamente el respaldo
  militar que Isolde busca cortejar
- **Con Maren:** corteja al Trade Consortium para que respalde su ascenso —
  presión directa sobre alguien que se define por mantenerse "práctica, no
  política". Ignorarla también es una posición

**Archivos actualizados:** `Estructura Política.md` (nueva sección "El
Rival" + tabla resumen + conexión Maren), `Bram-Ficha-Expandida-v1.md` y
`Maren-Ficha-Expandida-v1.md` (notas de conexión breves, sin reescribir sus
arcos).

**Con esto, el backlog de personajes sin desarrollar queda cerrado por
completo** — salvo la pregunta abierta de baja prioridad sobre si la cabeza
de the Academy of Sages es distinta de The Elder Circle.

---

## [2026-07-24] narrative | The Elder Circle — 4 miembros nombrados + regla de personaje élfica

**Disparador:** continuación directa de la retraducción a inglés — con
"The Elder Circle" ya nombrado, Boris pidió avanzar con los 4 miembros
individuales.

**Propuesta y confirmación:** 4 arquetipos distintos de reacción a haber
presenciado el genocidio de los Wardens (no 4 versiones del mismo "anciano
sabio"):

- **Threnn** (m) — comandante/guerrero que luchó (y falló) contra la
  masacre. Hoy: proteger el statu quo a cualquier costo — tantos murieron
  construyendo esta civilización, aunque sea sobre una mentira, que no la
  va a dejar caer por Speck.
- **Ilyara** (f) — sanadora que vio el costo físico de la masacre de
  primera mano. Hoy: dejar que la Muda se complete — sanar es imperativo
  moral, sin importar el costo a la civilización actual.
- **Maelys** (f) — presente pero rota, vio algo que nunca ha nombrado. Hoy:
  casi no habla — es la voz-oráculo del grupo, impredecible, a veces la
  más certera.
- **Corwyn** (m) — el más político de los cuatro, mantuvo conexión con la
  corte incluso entonces. Hoy: sin bando fijo — funciona como control
  informal sobre Queen Ithessa, sin tener asiento.

**El quinto — Thessaly** (murió de vejez natural hace 10 años): era quien
mediaba consenso entre los otros cuatro. Con su muerte, el Círculo perdió
su única voz de equilibrio.

**Regla de personaje fijada (nota de Boris, importante para guión futuro):**
su desacuerdo es **pasivo-agresivo, puramente élfico** — nunca pierden
serenidad ni compostura, nunca hay grito ni discusión abierta. Se nota en
la elección de palabras, en silencios calculados, en "honestidad" que es en
realidad la forma más afilada de desacuerdo. Los diferencia tanto del
Triune Council (2-contra-1 mecánico, frío) como de cualquier conflicto
humano (visceral, directo) — es el único tipo de conflicto que se siente
exclusivamente élfico.

**Lugar de reunión:** Grove of Cycles (templo élfico ya establecido en
[[Geografía y Ciudades]], fuente de the Academy of Sages) — conecta
directamente con la institución que ya define su ethos contemplativo.

**Diálogo de ejemplo documentado** (referencia de tono para guión):
Threnn/Ilyara intercambian argumentos sin alzar la voz sobre si dejar
completar la Muda; Maelys rompe un silencio largo con una frase mínima;
Corwyn cierra con ironía seca sobre lo "diplomáticos" que son todos.

**Archivo actualizado:** `Estructura Política.md` — sección "The Elder
Circle" expandida con los 4 miembros, Thessaly, regla de tono, lugar de
reunión y diálogo de ejemplo. Tabla resumen final también actualizada.

**Con esto, el backlog de personajes sin desarrollar del cierre de sesión
anterior queda resuelto en su ítem más importante.** Quedan pendientes de
baja/media prioridad: rival político de Edrick, cabeza de the Academy of
Sages (si es distinta de The Elder Circle).

---

## [2026-07-24] retcon/canon | Retraducción a inglés de nombres propios institucionales

**Disparador:** al retomar el Círculo de los Vivos ("The Elder Circle" —
Boris pidió ese tono), surgió la decisión de estandarizar: **todo nombre
propio de institución/título/casa se crea o retraduce en inglés de ahora en
más** — el vault sigue en español, pero nombres propios siguen la regla ya
vigente para the Aether-Born / the Iron-Blooded / the Restless / the Triune
Council (más globales, más estándar, idioma primario del juego según
[[Nomenclatura]]). Boris eligió explícitamente retraducir también lo ya
escrito, no solo lo nuevo.

**Retraducciones aplicadas:**
- Círculo de los Vivos → **The Elder Circle**
- Gran Clan de Forja → **the Great Forging Clan**
- Academia Élfica (de los Sabios) → **the Academy of Sages**
- Academia Real → **the Royal Academy**
- Alto Mando de Frontera → **Frontier High Command**
- Consorcio de Mercado → **the Trade Consortium**
- Casa Thorne / Casa Ashcombe → **House Thorne** / **House Ashcombe**
- Reina Ithessa / Rey Borran / Regente Edrick → **Queen Ithessa** / **King
  Borran** / **Regent Edrick**
- Regentado → **Regency**

**Regla de estilo fijada:** en prosa española embebida, se usa artículo
español + nombre propio SIN "the" duplicado (ej. "el Great Forging Clan",
no "el the Great Forging Clan") — mismo patrón que ya regía "el Triune
Council". "The" se conserva solo en la tabla canónica de [[Nomenclatura]] y
en citas de diálogo en inglés puro.

**Archivos actualizados (17):** `Nomenclatura.md` (nueva sección con tabla
de 10 términos nuevos), `Estructura Política.md` (reescrito completo),
`El Mundo y la Muda.md`, `Geografía y Ciudades.md`, `Briefs de Concept
Art.md`, `Briefs de Mapa del Mundo.md`, `00-Index.md`, `Current-State.md`,
+ 9 fichas (Torgan, Dagna, Vekka, Sereth, Nyael, Valen, Lyris, Bram, Maren).

**Deliberadamente NO tocado:** `LOG.md` (append-only, nunca se reescribe
historia) y `Current-State-Historico.md` (archivo, snapshot congelado de
sesiones pasadas) — retienen los nombres en español como estaban en el
momento de esas sesiones.

**Nuevo detalle de The Elder Circle (además de la retraducción):**
originalmente 5 elfos que vivieron el cataclismo como adultos jóvenes hace
~550 años — **ahora 4**, el quinto murió de vejez natural hace 10 años.
Deliberadamente 4 (número par), no 3 como el Triune Council — a diferencia
del Council, The Elder Circle no vota decisiones, es un grupo de testigos
que a veces coincide y a veces no, sin mecanismo de resolución. Confirmado
también: **Ambassador Cyrion NO es miembro** de The Elder Circle — es
Royal Academy, diplomático de carrera, cargo formal; mantener separado el
poder institucional (Corona/Council/Academias) de la autoridad de memoria
directa (The Elder Circle, sin cargo alguno) preserva la tensión narrativa
entre ambos.

**Pendiente:** nombres individuales de los 4 miembros de The Elder Circle —
próximo frente de esta misma sesión.

---

## [2026-07-24] design | Cierre de sesión — inventario de elenco + backlog de personajes sin desarrollar

**Disparador:** cierre de sesión. Con el elenco de grupo (13) y las figuras
políticas (6) completos, Boris preguntó qué personajes faltan — se armó
inventario contra todo el vault (docs de lore + `90-Raw/concept/`).

**Completo, confirmado:**
- 13 personajes de grupo: Roen/Valen/Darro (fijos) + Maren/Torgan/Iven/
  Sereth/Bram/Lyris/Nyael/Vekka/Dagna (9 Pivotes) + Speck — fichas y arte
- 6 figuras políticas: Reina Ithessa/Rey Borran/Regente Edrick (gobernantes)
  + Embajador Cyrion/Embajador Kadrun/Consejera Merrit Vance (Triune
  Council) — arte completo (Borran provisional, ver entrada anterior)

**Pendiente (marcado como backlog, no se desarrolla esta sesión):**
1. **🔴 El Círculo de los Vivos** ([[Estructura Política]]) — prioridad más
   alta. <5 elfos que vivieron el cataclismo hace ~550 años, autoridad moral
   que rivaliza con la Reina Ithessa, pieza central de "Los Tres Niveles de
   Conocimiento" ([[El Mundo y la Muda]]). Existen como concepto grupal con
   fricción narrativa ya escrita (choque generacional con la Reina) pero sin
   nombres, caras, ni cantidad exacta definida.
2. **🟡 Rival político del Regente Edrick** — daría cara individual a "6-8
   Casas cayeron en 550 años" (hoy solo estadística en [[Estructura
   Política]])
3. **🟡 Cabeza de la Academia Élfica** — sin resolver si es el Círculo mismo
   o una figura administrativa distinta
4. **🟢 NPCs de locaciones** (ermitaño Hermit's Cave, líder Bandits'
   Hideout) — baja prioridad, solo si ganan diálogo real en guión
5. **🟢 Antagonista individual** — no existe; el "villano" es institucional
   (Triune Council), posible decisión de diseño intencional, no gap

**Archivo:** `Current-State.md` (sección nueva, parte 8 de la sesión).

---

## [2026-07-24] design/QA | Embajador Kadrun v2 — APROBADO (corrige texto filtrado Y proporción)

**Ronda 3:** Boris corrió el prompt §9e-v2 (prosa corta, negativos como
oraciones simples). Resultado: **✅ APROBADO** — sin texto filtrado (el
glitch de la v1 desapareció por completo) Y la proporción trapezoide se ve
notablemente más cerca del canon de 4.5 cabezas que cualquier resultado
anterior del batch — torso ancho, piernas cortas, cabeza proporcionalmente
grande respecto al cuerpo. Sello ceremonial, cuffs con acento ember,
tatuajes de clan — todo coincide con el brief.

**Hallazgo metodológico (relevante para Borran, que sigue sin cerrar):** el
mismo cambio de formato (prosa corta y natural en vez de una oración densa
cargada de vocabulario técnico de estilo + negativos en lista larga tras
"Negative:") pareció mejorar TANTO el glitch de texto COMO la fidelidad de
proporción en el mismo prompt. Hipótesis: cuando el prompt es muy denso, el
modelo pierde precisión de anatomía compitiendo con la carga de instrucción
de estilo en la misma oración. **Recomendación para el próximo intento de
Borran:** aplicar el mismo formato de prosa corta (como en 9e-v2), no solo
agregar un ancla numérica de proporción.

**Con esto, el Council completo queda:** Cyrion ✅ / Kadrun ✅ / Vance ✅
(nota menor). Solo Borran sigue pendiente de una versión que cierre.

---

## [2026-07-24] design/QA | Council completo (Cyrion/Kadrun/Vance) + re-QA Ithessa/Borran v2

**Ronda 2 de evaluación** — Boris pasó Ithessa v2, Borran v2, y los 3
embajadores del Council (Cyrion, Kadrun, Vance).

**✅ Reina Ithessa v2 — APROBADA con nota menor.** Los 2 CRITICAL de la v1
quedaron resueltos: corona metálica eliminada (cabello trenzado como
regalía, tal como pedía el brief) y marcas faciales eliminadas (grabados
discretos en cuello/clavícula, no pintura de mejillas). 🟡 Nota menor: la
silueta sigue sin leer tan alargada/8-cabezas como el canon extremo
(Valen/Sereth), pero mejoró mucho al quitar las hombreras. No bloqueante.

**🟡 Rey Borran v2 — mejoró, no cierra.** Ya no lee "vikingo humano" (barba
trenzada, tatuajes de forja, manto correctos), pero la proporción trapezoide
de 4.5 cabezas sigue sin cerrar — cabeza proporcionalmente chica para el
cuerpo, brazos/piernas no leen tan cortos/gruesos como el canon exige. El
framing verbal de proporción sigue perdiendo contra el sesgo del modelo
hacia "rey grande y musculoso". **Pendiente:** un 3er intento con ancla
numérica más agresiva (ej. "la cabeza ocupa casi 1/4 de la altura total") si
Boris quiere seguir iterando.

**✅ Embajador Cyrion — APROBADO.** Silueta élfica correcta (vertical,
angosta, 8 cabezas se lee bien), rostro y ropa diplomática coinciden con el
brief.

**✅ Consejera Merrit Vance — APROBADA con nota menor.** Hombros
estructurados sin ser armadura, rostro afilado, vestimenta correcta. 🟡 El
arma se ve más espada que "abrecartas ceremonial" — no bloqueante.

**🔴 Embajador Kadrun — FALLA TÉCNICA, no de contenido.** El prompt se
filtró como texto renderizado dentro de la propia imagen (bloque de
instrucciones visible, palabras corrompidas: "waterco-shading", "ceshading",
"jitterd jittered", "Noo work tools") — glitch de generación, probablemente
por densidad/longitud del prompt original (mismo patrón denso que los demás
briefs §9). **Acción:** nuevo prompt §9e-v2, reescrito en prosa más corta y
natural, negativos como oraciones simples en vez de lista larga tras
"Negative:" — mismo contenido, menos denso, para evitar el trigger de
texto-en-imagen.

**Problema sistémico persistente (todos):** el acabado acuarela Sable×BotW
(grano de papel, bandas cel con dry-brush jitter) sigue sin aparecer en
ningún resultado de NB2 — se lee como ilustración digital pulida con
sombreado en degradé. Los negativos agregados en la ronda anterior no lo
revirtieron. **Empieza a oler a techo de la técnica en NB2** para este tipo
de contenido — si persiste después de Kadrun v2, vale la pena que Boris
decida si acepta el resultado (corrección de contenido > fidelidad de
textura para NPCs secundarios) o declara el techo formalmente.

**Archivo:** `Briefs de Concept Art.md` §9e-v2 (Kadrun reescrito).

---

## [2026-07-24] design/QA | Ithessa + Borran (NB2): QA imparcial + prompts reforzados

**Disparador:** Boris generó Reina Ithessa, Rey Borran y Regente Edrick con
los briefs §9a/9b/9c en NB2 y pasó las 3 imágenes para evaluación.

**Evaluación contra brief + Art Bible:**

**Problema sistémico (las 3 imágenes):** estilo desviado de Sable×BotW —
sombreado en gradiente suave, línea de tinta tipo vector limpio, sin grano
de papel visible, sin bandas cel de 3-4 escalones con dry-brush jitter. Más
cerca de "ilustración de videojuego pulida/semi-anime" que de acuarela
lavada — negativo explícito del Art Bible.

**🔴 CRITICAL — Reina Ithessa:**
1. Corona metálica presente pese al negativo explícito ("no separate metal
   crown" — la regalía debía ser el propio cabello trenzado)
2. Silueta no lee como el ancla élfica (hombreras anchas, proporción de
   fantasía estándar en vez de línea vertical continua de 8 cabezas)
3. Marcas teal extendidas por mejillas como pintura facial (brief pedía
   grabados discretos solo en clavícula/antebrazos/sienes)

**🔴 CRITICAL — Rey Borran:**
1. Proporción enana ROTA — lee como vikingo humano grande (~5-6 cabezas),
   no como el trapezoide de 4.5 cabezas blindado en canon (Dagna/Torgan/
   Vekka ya lo respetan en imágenes previas)
2. Corona genérica sin motivo de martillo/forja

**🟡 MEDIUM — Regente Edrick:** el más cercano al brief (cadena de oficio en
vez de corona ✅, sin regalía real ✅) — solo le pesa el problema sistémico
de estilo. Aprobado con reserva menor, sin necesidad de reroll.

**Acción:** 2 prompts reforzados nuevos (§9a-v2, §9b-v2) en `Briefs de
Concept Art.md`, mismo patrón que blindó la proporción enana en el brief 2c
("the proportions are the single most important rule"):
- Ithessa v2: silueta reforzada en positivo (8 cabezas, sin hombreras),
  regalía sin metal reforzada en positivo Y negativo, marcas relocalizadas
  explícitamente fuera de la cara, negativos de estilo mucho más agresivos
  (no smooth gradient, no vector linework, no anime finish)
- Borran v2: proporción enana reforzada como regla #1 (4.5 cabezas,
  trapezoide, NOT viking-human build), corona con motivo de martillo
  explícito, mismos negativos de estilo agresivos

**Pendiente:** Boris corre los 2 prompts v2 en NB2, se re-evalúa.

---

## [2026-07-24] design | Briefs de concept art: Gobernantes + Triune Council (NB2)

**Disparador:** antes de arrancar guión/diálogos, Boris quiere generar
concept art de las figuras políticas definidas en [[Estructura Política]] —
ya no tiene acceso a NB Pro, usa **Nano Banana 2** (prompts ajustados a un
solo turno, sin depender de re-roll iterativo multi-imagen).

**6 briefs nuevos** en `Briefs de Concept Art.md` §9, cada uno con el
fenotipo racial ya ratificado (elfo 8 cabezas / enano 4.5 trapezoide / humano
7.5 atlético) como ancla de anatomía + regalía y personalidad específica del
cargo:

- **9a — Reina Ithessa** (Stillwood): 555 años, madura pero no la más vieja
  del reino — la corona es su propio cabello trenzado, sin corona metálica
  separada (regalía orgánica élfica)
- **9b — Rey Borran** (Ignis Reach): bisnieto directo, corona forjada
  fusionada con la estética del Gran Clan (no ornamento separado) — certeza
  generacional
- **9c — Regente Edrick Ashcombe** (Aethelgard): **deliberadamente menos
  regio** que los otros 2 — sin corona, cadena de oficio en vez de regalía,
  composición nerviosa bajo la compostura (cargo precario, no sangre real)
- **9d — Embajador Cyrion** (asiento élfico del Council): diplomático de
  décadas, paciencia élfica ejercida como poder político puro
- **9e — Embajador Kadrun** (asiento enano del Council): Gran Clan en
  registro diplomático, no artesanal — distinto en tono de Vekka
- **9f — Consejera Merrit Vance** (asiento humano del Council): la más
  afilada y visiblemente ambiciosa de los 3 gobernantes/embajadores — ganó
  su asiento, sabe que puede perderlo

**Nota de diseño transversal documentada:** Reina/Rey deben leer como
gobernantes legítimos (regalía plena); Edrick debe leer administrativo, no
monárquico; los 3 embajadores deben leer diplomáticos/burócratas, no
guerreros ni realeza.

**Archivo:** `Briefs de Concept Art.md` §9 (nueva sección, mismo bloque de
estilo compartido que el resto del documento: Sable × BotW, negativos
Genshin/PBR/anime/neon).

---

## [2026-07-24] lint | Higiene de contexto — Current-State recortado (3ra vez)

**Disparador:** cierre de sesión. `check_vault.py` marcó `Current-State.md`
3,615t sobre su techo blando (6,615t total) — había crecido sin recorte
desde el 2026-07-17, acumulando narrativa de: rework de anatomía (07-17→
07-22), redireccionamiento de Speck (07-23), y las 6 partes del paquete de
worldbuilding político de hoy (07-24).

**Acción:** todo el relato sesión-por-sesión (verbatim, sin editar
contenido) se movió a [[Current-State-Historico]], siguiendo el patrón ya
establecido (2 higienes previas el 2026-07-16). `Current-State.md` quedó
recortado a solo: arranque de sesión actual, Hechos vigentes, y Pendientes
narrativos/lore genuinamente abiertos (los bloques ✅ completados se movieron
también).

**Resultado medido:**
- `Current-State.md`: 6,615t → **1,466t** (bien bajo el techo blando)
- Arranque de sesión total: ~6,912t → **~1,763t**
- Vault sigue 🟢 VERDE (ya lo estaba, pero con mucho más margen ahora)

---

## [2026-07-24] narrative | TRIUNE COUNCIL definido — antagonista institucional del layer político

**Disparador:** con el mapeo político de los 9 Pivotes cerrado, Boris pidió
desarrollar el Triune Council en sí — mencionado desde el inicio del Vault
pero nunca estructurado como cuerpo real.

**Hallazgo central (propuesto y confirmado):** el Council no es solo
burocracia de fondo — es candidato a **antagonista institucional real** del
layer político. Nació hace 550 años gestionando la corrupción del
cataclismo (la "tregua" ya mencionada en [[El Mundo y la Muda]]); su poder
depende de que la crisis siga administrada, no resuelta. Si la Muda se
completa y el mundo sana, el Council se vuelve obsoleto — interés
institucional, no villanía de caricatura.

**Esto explica sin coincidencia sospechosa** por qué las 9 órdenes de
traición vienen de 3 cadenas de poder distintas que convergen en el mismo
cuerpo: Gran Clan de Forja → Rey Borran → Embajador enano; Academia Real →
Reina Ithessa → Embajador élfico; Consorcio de Mercado → Triune Council
directamente (Maren). Una sola estrategia, disuelta en 3 idiomas
institucionales, ejecutada por 9 personas que nunca se enteran de que son
parte del mismo plan.

**Estructura decidida:**
- **3 asientos con voto, uno por raza** — nunca hay empate (mayoría de 2
  contra 1 siempre)
- **Sede en Rivermeet** por conveniencia geográfica/comercial, no por peso
  político humano (que es el más débil de los 3)
- **Corrección de Boris:** los asientos NO son los monarcas en persona (no
  tendría sentido que Reina Ithessa/Rey Borran vivan en Rivermeet) — son
  **embajadores/representantes permanentes**, designados por sus Coronas,
  que sí viven en Rivermeet a tiempo completo
- **Asimetría deliberada:** asientos élfico y enano = nombramientos
  estables/largo plazo (coherente con longevidad y permanencia culturales);
  asiento humano = el más volátil de los 3, cambia con cada reconfiguración
  de poder en Rivermeet — irónico, es el único que vive en su propia casa
- **La inestabilidad humana le conviene al Council:** con 2 votos estables
  formando mayoría natural, el Council rara vez enfrenta oposición
  coordinada — un trono humano fuerte sería la única fuerza capaz de
  cuestionarlo desde adentro, y nunca termina de consolidarse

**Titulares actuales (nombrados):**
- Élfico: **Embajador Cyrion**
- Enano: **Embajador Kadrun**
- Humano: **Consejera Merrit Vance**

**Archivos actualizados:**
- `Estructura Política.md` — nueva sección completa "El Triune Council — la
  Institución Supra-Racial" + tabla de titulares en el resumen final
- `El Mundo y la Muda.md` — 2 enlaces nuevos hacia Estructura Política
  (mención original del Council + nueva nota sobre por qué las 9 traiciones
  convergen)

---

## [2026-07-24] narrative | MAREN: Consorcio de Mercado — CIERRA el mapeo político de los 9 Pivotes

**Disparador:** último pivote sin contexto político/social propio. Su ficha
ya tenía la pieza sin nombrarla como tal: "Jefa de Operaciones de
Aethelgard hace 10 años."

**Decisión:** Maren es Jefa de Operaciones del **Consorcio de Mercado** —
tercer centro de poder humano (junto al Regente y el Triune Council), no
político sino práctico. Con el trono tan inestable (6-8 Casas en 550 años),
el comercio tiene que seguir funcionando sin importar quién gobierne — el
Consorcio se volvió, de facto, institución casi permanente. Maren sobrevivió
ya a 2 cambios de Regente sin perder el cargo.

**Tercer tipo de poder humano completado:**
- Bram → poder heredado (Casa Thorne) que **rechazó**
- Iven → poder **ausente** (pobreza estructural, sin ningún tipo de poder)
- Maren → poder **ganado** (hija de gente común, escaló por pura competencia)

**Consecuencia en el clímax:** quien la contacta para ejecutar el sacrificio
ya no es "el Consejo" genérico, es el **Triune Council directamente** — no
el Regente. Reconocen que decretar no basta, necesitan quien pueda
*ejecutar* — ahí es donde el poder del Consorcio pesa más que cualquier
Casa de turno.

**Archivos actualizados:**
- `Maren-Ficha-Expandida-v1.md` — nueva sección de afiliación, biografía
  ajustada, escena de contacto en clímax (Triune Council, no Consejo
  genérico), "Cómo la ve Roen" ajustado
- `Estructura Política.md` — nueva sección "El Consorcio de Mercado"

---

## ✅ MAPEO POLÍTICO DE LOS 9 PIVOTES + 3 FIJOS — COMPLETO

Con Maren, se cierra el frente abierto desde el retcon del cataclismo
(100→550 años). Los 12 personajes con rol narrativo (9 Pivotes + Roen/Valen/
Darro) tienen ahora origen institucional/social definido:

| Personaje | Raza | Institución/Origen social |
|---|---|---|
| Valen (fijo) | Elfo | Academia Élfica (Sabios) |
| Roen (fijo) | Humano | Ex-guardia del Consejo, Mistbound |
| Darro (fijo) | Enano | Rechazado del Gran Clan de joven |
| Maren | Humana | Consorcio de Mercado (poder ganado) |
| Torgan | Enano | Rechazado del Gran Clan, clan menor propio |
| Iven | Humano | Pobreza estructural (pérdida de origen: Sael) |
| Sereth | Elfo | Academia Real (Corona, visible) |
| Bram | Humano | Casa Thorne (poder heredado, rechazado) |
| Lyris | Elfa | Fuera del sistema — Alto Mando de Frontera |
| Nyael | Elfa | Academia Real (Corona, encubierto) |
| Vekka | Enana | Gran Clan de Forja (100%, clan real) |
| Dagna | Enana | Subclán vasallo del Gran Clan de Forja |

**Ver [[Estructura Política]] para el documento canónico completo.**

---

## [2026-07-24] narrative | IVEN potenciado: pobreza estructural + pérdida de origen (Sael)

**Disparador:** al mapear qué pivotes aún no tenían contexto político/social
(Maren e Iven, humanos), Boris pidió recordar la traición de Iven y
potenciarla desde su origen de pobreza y mortalidad — no agregar Casa
política (no le corresponde), sino profundizar la textura de clase que ya
tenía implícita.

**Cambio de eje:** el asentamiento de Iven **nunca fue una comunidad sana
que luego se enfermó** — fue pobre y de alta mortalidad crónica desde
siempre. La corrupción del Aether (hace 5 años) no creó la crisis, la
**aceleró**. Esto conecta con [[Estructura Política]]: "la frontera no es
prioridad" es política de generaciones del Consejo/Regentado, no frase
nueva.

**Nueva pérdida de origen:** a los 9 años, la hermana menor de Iven (Sael,
5 años) murió de fiebre simple porque no había medicina suficiente para las
2 personas que la necesitaban esa semana — los adultos eligieron a quién
dársela, y no fue a ella. Iven no culpa a nadie por esa decisión (sabe que
fue correcta con los recursos que había) — **eso es lo que más lo rompe.**
Aprendió a los 9 años que amar a alguien no siempre alcanza para salvarlo.

**Consecuencia narrativa:** la "elección imposible" con Speck deja de ser un
dilema moral abstracto que enfrenta por primera vez — es **la más grande de
una vida entera haciendo triage.** Se convirtió en protector no por
heroísmo, sino por la determinación de nunca más ser quien decide sin poder
salvar a ambos. Explica también por qué confía en un trato tan obviamente
predatorio del Consejo: quien creció en pobreza estructural sabe que cuando
el poder ofrece cualquier salida, la tomas — la alternativa es muerte
garantizada, no riesgo.

**Eco añadido al clímax:** Iven menciona a Sael explícitamente al momento de
traicionar ("Tenía nueve años la primera vez que alguien decidió a quién
salvar delante de mí...") — cierra el círculo con la línea privada final.

**Archivo actualizado:** `Iven-Ficha-Expandida-v1.md` (Esencia, biografía
completa reescrita, clímax, línea privada, Notas Narrativas).

**Pendiente:** Maren sigue sin contexto político/social propio — próximo
frente.

---

## [2026-07-24] narrative | ESTRUCTURA POLÍTICA élfica COMPLETA: Lyris + Nyael

**Continuación directa** del paquete de Estructura Política — quedaba
pendiente afiliación para Lyris y Nyael (las 2 elfas sin institución
definida).

**Decisiones:**
- **Lyris:** NO pertenece a ninguna Academia — tercer track élfico no
  académico, el **Alto Mando de Frontera** (coordinación militar/práctica de
  defensa territorial). Nunca fue rechazada de una Academia — nunca la
  invitaron a la conversación siquiera. Explica su frialdad como aislamiento
  estructural heredado, no solo temperamento.
- **Nyael:** SÍ pertenece a la Academia Real — como **brazo encubierto**,
  operativos negables de la Corona que oficialmente no existen. Esto la
  convierte en la contraparte oscura de Sereth: **dos productos de la misma
  maquinaria de Estado** (Sereth persuade, Nyael ejecuta). Su traición
  ("I could not wait") se lee ahora como el primer acto de juicio propio en
  una vida entera de obediencia a una institución que ni siquiera admite
  tenerla.

**Mapa élfico completo (4 pivotes/fijos con institución definida):**

| Elfo | Institución |
|---|---|
| Valen (fijo) | Academia Élfica (Sabios) |
| Sereth | Academia Real (Corona, visible) |
| Nyael | Academia Real (Corona, encubierto) |
| Lyris | Fuera del sistema — Alto Mando de Frontera |

**Archivos actualizados:**
- `Lyris-Ficha-Expandida-v1.md` — nueva sección de afiliación, "Stillspire"
  reemplazado por "Alto Mando de Frontera" donde da órdenes, "Cómo lo Ve
  Valen" ajustado (auto-exilio de Valen vs. nunca-invitada de Lyris)
- `Nyael-Ficha-Expandida-v1.md` — nueva sección de afiliación (brazo
  encubierto de Academia Real), "Cómo lo Ve Valen" ajustado
- `Estructura Política.md` — sección de Academias expandida con el brazo
  encubierto + el track de Frontera

**Pendiente:** Maren e Iven (humanos) sin Casa/contexto político definido —
próximo frente, a construir junto con Boris (sin semilla propia todavía,
a diferencia de Bram).

---

## [2026-07-24] narrative | ESTRUCTURA POLÍTICA de las 3 razas + fichas actualizadas

**Disparador:** continuación directa de la sesión de retcon del cataclismo —
Boris pidió mapear cómo se gobierna cada reino, con 3 semillas: Reina Elfa
joven que era bebé durante el cataclismo, Rey Enano de línea directa
(nieto/bisnieto), Rey Humano sin línea recta (varios golpes/guerras civiles).

**Nuevo documento canónico:** `10-Knowledge/Estructura Política.md`

- **Elfos:** Reina Ithessa, 555 años (tenía ~5 durante el cataclismo). El
  Círculo de los Vivos (<5 elfos que sí eran adultos jóvenes entonces) tiene
  autoridad moral informal que la Reina no puede reclamar. Dos Academias:
  **Élfica** (de los Sabios — observar sin intervenir, de aquí sale el
  Círculo) y **Real** (al servicio de la Corona — el cálculo sirve al
  Estado).
- **Enanos:** Rey Borran, bisnieto directo del Rey del cataclismo — sucesión
  = ritual sagrado, sin disputa. El **Gran Clan de Forja ES el clan real**
  (no un gremio aparte). Estructura de 3 niveles entre pivotes: Vekka (100%
  clan real) / Dagna (subclán vasallo, cadena de obligación de 2 eslabones) /
  Torgan (rechazado del clan real de joven, juró lealtad a un clan menor
  después)
- **Humanos:** sin dinastía estable — 6-8 Casas distintas en 550 años.
  **Regente Edrick Ashcombe** (no "Rey" — cargo precario, "Voice of the
  Council"). El Triune Council en Rivermeet es la autoridad real continua.
  **Apellidos solo en cultura humana** (elfos no los necesitan por longevidad,
  enanos ya tienen el Clan como equivalente) — pero no todos los humanos los
  usan en la práctica (campesinado/tropa rasa no, nobleza sí)

**Fichas actualizadas con la nueva estructura:**
- `Torgan-Ficha-Expandida-v1.md` — reescrita la biografía temprana: rechazado
  del Gran Clan de Forja el mismo año que Darro, encontró pertenencia en un
  clan menor después. "Cómo lo ve Darro" reescrito para reflejar el rechazo
  compartido
- `Dagna-Ficha-Expandida-v1.md` — reescrita como subclán vasallo (no clan
  real directo), cadena de obligación de 2 eslabones. "Cómo lo ve Darro"
  ajustado
- `Vekka-Ficha-Expandida-v1.md` — confirmada como 100% Gran Clan de Forja,
  su autoridad de Maestra es autoridad de Estado. "Cómo lo ve Darro" ajustado
- `Valen-Ficha-Expandida-v1.md` (ficha fija) — nueva sección de afiliación:
  Academia Élfica, explica por qué observa sin actuar
- `Sereth-Ficha-Expandida-v1.md` — nueva sección de afiliación: Academia
  Real. "Cómo lo Ve Valen" reescrito como rivalidad de escuelas de
  pensamiento, no solo personalidades distintas
- `Bram-Ficha-Expandida-v1.md` — nuevo origen: Casa Thorne de Rivermeet, huyó
  a los 15 en vez de tomar el camino político esperado. Nueva sección de
  afiliación + ajuste en "Cómo lo ve Roen"

**Pendiente:** Lyris y Nyael (ambas Stillspire) no tienen afiliación de
Academia definida — abierto para sesión futura si se vuelve relevante.

---

## [2026-07-24] retcon/design | CATACLISMO: 100 → 550 años + longevidad de razas + niveles de conocimiento

**Disparador:** revisión del mapa del mundo (Boris) — Rivendell/Imladris para
Stillwood, torres de guardia por raza, ambigüedad del Monolith, y una
pregunta que destapó una inconsistencia de canon: con el cataclismo a "100
años" y elfos viviendo 180-250+ años (ya establecido en fichas de Pivotes),
40-50% de los elfos vivos habrían presenciado la guerra directamente —
rompía la intención de que fuera un evento semi-mítico.

**Decisión (Boris):** mover el cataclismo a **~550 años atrás** y fijar el
techo de vida élfico en **650-700 años** (no inmortalidad tipo Tolkien —
longevidad finita extrema, más cerca del registro de Eragon). Con esos
números, solo ~5-10% de los elfos vivos hoy (los que ya rondaban 550+ años
en aquel entonces) presenciaron el evento.

**Consecuencia — Los Tres Niveles de Conocimiento** (nuevo, en [[El Mundo y
la Muda]]):
- **Elfos:** ~5-10% con memoria directa + biblioteca de Stillspire — escolar
  y personal a la vez
- **Enanos:** nadie vivo (550 años excede cualquier vida enana, ~200-250)
  pero tradición oral ritualizada — *"la montaña no olvida, y el enano es la
  montaña"*
- **Humanos:** nadie vivo, ni memoria institucional confiable (~18-22
  generaciones de deriva) — folclore regional deformado, tipo La Llorona/Lago
  Ness, sin versión autoritativa

**Consecuencia para Speck:** su soledad pasa de "100+ años" a **"550+ años"**
— coincide con el cataclismo mismo (fue sellada en crisálida poco después de
la guerra por bestias guardianas, y la corrupción del Aether recién ahora,
550+ años después, la está despertando).

**Archivos actualizados:**
- `10-Knowledge/El Mundo y la Muda.md` — cifra base 100→550, sección nueva
  "Los Tres Niveles de Conocimiento"
- `10-Knowledge/Las Tres Razas.md` — tabla de longevidad nueva (elfos
  650-700, enanos ~200-250, humanos ~70-90)
- `10-Knowledge/Speck.md` — 3 menciones "100+ años" → "550+ años"
- `10-Knowledge/Geografía y Ciudades.md` — 4 menciones actualizadas (The
  Battlefield, The Scar of Breaking ×2, Warden's Crypt)
- `10-Knowledge/Briefs de Mapa del Mundo.md` — nota de mapa actualizada

**Pendiente:** el mapa YA GENERADO (NB Pro, ver sesión 2026-07-23) tiene el
texto "The Scar of Breaking (100 years)" horneado en el PNG — no se puede
editar vía markdown, requiere regeneración cuando se itere el asset visual.
No urgente (el brief fuente ya está corregido para la próxima iteración).

**Otros ajustes de la misma revisión (Boris, sesión 2026-07-24):**
1. Mistbound Frontier reposicionado — Rivermeet es la verdadera "puerta de
   frontera" con The Wilds (asentada en River Road); Mistbound es tierra
   interior remota, lejos del río, donde el Consejo pierde control
   administrativo (no por bestias, por distancia)
2. The Monolith: se descartó la propuesta de "Warden Waystone" (duplicaba la
   función cósmica de The First Wound). Queda como misterio sin resolución
   mecánica — solo una línea de Valen citando una leyenda élfica ambigua
   ("esto está aquí desde antes de que los elfos llegáramos") + Warden's
   Crypt debajo (conexión que el juego nunca confirma verbalmente,
   storytelling ambiental puro)
3. Confirmado: El Nido sigue funcionando 1:1 con la iteración actual de Speck
   (crisálida + bestias guardianas semi-corrompidas, ver Speck.md líneas
   41-46) — sin conflicto
4. Nuevas: 3 Torres de Guardia por raza (Aethelgard Watch, Ignis Reach Watch,
   Stillwood Watch), una en cada entrada a The Wilds, arquitectura distinta
   por cultura
5. Stillwood redefinido como continuación orgánica de The Wilds (no frontera
   dura) — el bosque sube en elevación y se cierra progresivamente desde
   Gloomvault hasta Stillspire, con una cadena de cascadas nueva (**The
   Ascending Falls**, referencia Rivendell/Imladris) definiendo la
   arquitectura del reino

---

## [2026-07-23] narrative | FICHAS NARRATIVAS EXPANDIDAS: Los 9 Pivotes (C3) COMPLETOS
**Sesión de profundización narrativa — desarrollo completo de personajes traidores.**

**Scope:** Creación de 9 fichas narrativas expandidas (una por cada Pivote — C3 variable por cell raza×rol).

**Método:** Ficha expandida por Pivote incluye:
- Biografía pre-aventura única
- "Cómo lo ve" personaje fijo de misma raza (Conocimiento Previo)
- Encuentro específico con jugador (contexto race/role/gender)
- Arco 3-actos completo (Lealtad → Comunidad → Desilusión)
- Escena de clímax + traición (patrón narrativo único)
- 4 Epílogos distintos por Final (Perdón/Muerte/Encadenamiento/Síntesis)
- Línea canónica (diálogo de traición)
- Línea privada (introspección)
- Dinámicas con Roen/Valen/Darro
- Diseño visual + arma/técnica
- Notas sobre por qué este Pivote importa

**Pivotes Completados:**

1. **Maren** (Humana Strategist) → vista por Roen
   - Traición: Cálculo frío (ciudad no sobrevive sin sacrificio de Speck)
   - Línea: "I can love her and still do the math"
   - Patrón: Amor genuino + matemática implacable (no son contradicción)

2. **Torgan** (Enano Duelist) → visto por Darro
   - Traición: Juramento de Forja (55 años) supersede grupo
   - Línea: "An oath doesn't care how I feel about you"
   - Patrón: Dolor real + obligación inescapable (enana)

3. **Iven** (Humano Duelist) → visto por Roen
   - Traición: Dilema genuino (salvar asentamiento vs jugador)
   - Línea: "You'd trade her for strangers? I'm trading her for everyone I've ever known"
   - Patrón: ÚNICA opción donde ambas decisiones son moralmente válidas

4. **Sereth** (Elfo Strategist) → visto por Valen
   - Traición: Manipulación amorosa + verdad calculada
   - Línea: "Millions against one. This is me being stubborn about millions"
   - Patrón: Ama genuinamente pero reshapea verdad para conseguir resultado "óptimo"

5. **Bram** (Humano Vanguard) → visto por Roen
   - Traición: RECHAZA traición a pesar de incentivo (burnout exhausto)
   - Línea: "I've been everybody's wall. Just once, let me be the door"
   - Patrón: ÚNICO Pivote que potencialmente se niega (corazón > lógica)

6. **Lyris** (Elfa Duelist) → vista por Valen (CORRECCIÓN: era Darro)
   - Traición: Lógica fría sin emoción
   - Línea: "You were my stillness. Be still now. The world needs sky, not earth"
   - Patrón: Incapaz de sentir / convencida que sentir es debilidad

7. **Nyael** (Elfa Duelist) → vista por Valen
   - Traición: Ausencia total (solo nota deixada, sin confrontación)
   - Línea: "You taught me to set the trap and wait. I could not wait"
   - Patrón: Ejecutora perfecta / respeta a objetivo ejecutándolo sin drama

8. **Vekka** (Enana Strategist) → vista por Bram (dinámicas, no "Conocimiento Previo")
   - Traición: Dogma del gremio (desmonta lo que construyó con amor)
   - Línea: "I built you. Forgive me for finishing the job"
   - Patrón: Llora mientras actúa / deber enano sin escape

9. **Dagna** (Enana Vanguard) → vista por Roen (dinámicas, no "Conocimiento Previo")
   - Traición: Ley del clan (sangre > grupo)
   - Línea: "The mountain doesn't forgive. And I am the mountain's"
   - Patrón: **ÚNICA que quiebra genuinamente a Roen** porque lo respeta más

**Decisiones de diseño validadas:**
- 9 patrones narrativos de traición DISTINTOS (no repetición)
- Cada traición tiene contexto moral válido (no villanos simples)
- Conocimiento Previo mapea: mismo-raza fijo ve mismo-raza Pivote
- Encuentro varía por cell (raza/rol del jugador) — 18 encuentros únicos totales
- 4 Finales con epílogos distinto por cada Pivote

**Correcciones en sesión:**
- Lyris "Cómo lo ve Darro" → cambiado a "Cómo lo Ve Valen" (ambas elfas)

**Archivos creados/actualizados:**
- `Aether Bound/10-Knowledge/Pivotes/Maren-Ficha-Expandida-v1.md`
- `Aether Bound/10-Knowledge/Pivotes/Torgan-Ficha-Expandida-v1.md`
- `Aether Bound/10-Knowledge/Pivotes/Iven-Ficha-Expandida-v1.md`
- `Aether Bound/10-Knowledge/Pivotes/Sereth-Ficha-Expandida-v1.md`
- `Aether Bound/10-Knowledge/Pivotes/Bram-Ficha-Expandida-v1.md`
- `Aether Bound/10-Knowledge/Pivotes/Lyris-Ficha-Expandida-v1.md` (corregida)
- `Aether Bound/10-Knowledge/Pivotes/Nyael-Ficha-Expandida-v1.md`
- `Aether Bound/10-Knowledge/Pivotes/Vekka-Ficha-Expandida-v1.md`
- `Aether Bound/10-Knowledge/Pivotes/Dagna-Ficha-Expandida-v1.md`

**Lecciones aplicadas:**
1. Traición = dilema sin escape, nunca villanía sin matices
2. Patrón de "Conocimiento Previo" (mismo-raza) requiere revisión de qué pares son "fijos de misma raza"
3. Cada línea canónica debe resonar en toda la partida del jugador (memoria de cierre)

---

## [2026-07-23] design | REDIRECCIONAMIENTO + DISEÑO VISUAL COMPLETO: Speck de ajolote a Warden Cristalino
**Sesión guionística + diseño iterativo — análisis temático + visual lock-down de Speck.**

**Problema identificado:** Speck (axolotl mascota-like) no se sentía coherente en universo de tres razas humanoides. El "ajolote" leía como mascota/Genshin, no como ser antiguo.

**Redireccionamiento ejecutado:**
- **De:** Salamandra/axolotl biológica (mascota)
- **A:** Último Warden — constructo cristalino + runas (tecnología biológica diseñada, no evolucionada)

**Especificación nueva RATIFICADA:**
- **Forma Warden real:** Cristalino translúcido, runas geométricas (Warden símbolos), seams aether como grietas de poder, ojos facetados (gema viva), cuerpo sculptural/mineral
- **Forma shapeshifteada:** Zorro 1.5× endémico de The Wilds. Imperfectamente shapeshifteado. Pelaje beige/gris con patrones geométricos sutiles (runas interpretadas como coloración). Pata delantera con cristal visible (glitch). Ojos facetados. Demasiado inteligente.
- **Estadios como MANIFESTACIÓN:** E1 crisálida dormida, E2 despertar (forma real emerge), E3 verdad completa (cristales rojos=God-Core)
- **Tres capas de verdad:** Mundo ve zorro extraño. Jugador (poder innato) ve teals/cristal/facetas en flashes. Quinteto nota inteligencia antinatural.
- **Encuentro:** Accidental en misión de purga. Crisálida en nido. Bestias guardianas semi-corrompidas. Convergencia: Speck despertando + guardianas fallando + jugador presente.
- **Bautizo:** Darro (humor enano) reconoce "opiniones" de Speck = razonamiento. Llama "speck" (mota) irónicamente — no sabe que es ser antiguo.
- **Personalidad:** Humor pragmático-oscuro (enano). Tras 100+ años solo, wit seco. Observa lo absurdo sin buscar risa. Se comporta intencionalmente "off" como zorro (comunica su verdad a través de ironía).
- **Protocolo del silencio:** Mundo no verbaliza la verdad sobre Speck. Quinteto sospecha pero no confronta. Jugador ve pero no dice. Primera revelación verbal = clímax.
- **Coming-of-age:** Jugador descubre su poder en silencio, a través de flashes, sin protagonismo. Crece sin ser "el elegido" — es descubrimiento callado.

**Archivos actualizados:**
- `Speck.md` — especificación completa redireccionada
- `Briefs de Concept Art.md` §5 — E1 brief escrito y ejecutado (NB Pro), E2/E3 pendientes

**Concept art en progreso:**
- E1 (Warden crisálida) — generado 2026-07-23 NB Pro, VALIDADO visualmente
- Forma shapeshifteada (zorro) — pendiente generación

**Lecciones:**
1. Speck es ser de 100+ años, solo, observando universo caer — su humor refleja eso
2. El shapeshifting falla porque despierta, no por debilidad permanente
3. El jugador se descubre a sí mismo EN SILENCIO, paralelo a Speck despertando
4. El nombre "speck" es irónico cósmico — mota insignificante que es en realidad lo opuesto

---

## [2026-07-23] design/production | DISEÑO VISUAL SPECK COMPLETO: Zorro + 3 Flashes + E1 Warden EN GENERACIÓN

**Concepto art completado:**
- ✅ Zorro shapeshifted: rojo-naranja natural, seams gris-casi-blanco, runas beige, pata cristal translúcido, ojos amber facetados
- ✅ Flash 1 (Revelación aether): Seams gris → TEALS BRILLANTES
- ✅ Flash 2 (Revelación mineral): Pata → TRANSLÚCIDA CRISTALINA + venas cristales visibles
- ✅ Flash 3 (Revelación consciencia): Ojos → FACETAS GEM-LIKE + síntesis acumulativa (todos 3 flashes visibles simultáneamente)
- 🔄 E1 Warden (en generación NB Pro): jade pálido casi-blanco translúcido, patas esmeralda pálido (conexión tierra), ojos dorados profundos, runas ORO BRILLANTE, seams aether flujo uniforme, orejas pétalos translúcidos, atmósfera "arqueología vivida"

**Decisiones narrativas cerradas:**
- UN estadio de revelación (no 3 estadios E1/E2/E3) — Speck es Warden adulto desde inicio, shapeshifting es defensa
- Tres capas de verdad: Mundo ve zorro, Jugador ve flashes, Quinteto ve inteligencia antinatural
- Protocolo del silencio: la verdad nunca se verbaliza hasta clímax
- Coming-of-age del jugador, no de Speck — descubrimiento silencioso en flashes
- Humor pragmático-enano (seco, oscuro, sabio)

**Iteraciones de diseño visual:**
- Zorro: color natural rojo-naranja vs beige (✅ rojo-naranja gana)
- Orejas Warden: Opción 5 (runas doradas) vs Opción 3 (pétalos) → ✅ Opción 3 + translúcido (balance elegancia + poder)
- Paleta E1: azul-marino opaco vs jade pálido → ✅ jade pálido casi-blanco (luminoso, antiguo)
- Patas E1: directas vs esmeralda pálida → ✅ esmeralda pálida (alusión tierra, aspecto divino)
- Runas E1: sutiles vs brillantes → ✅ brillantes visibles/prominentes (dios-lenguaje despierto)
- Translucidez E1: uniforme vs variable → ✅ variable (orejas + extremidades más translúcidas)

**Briefs finales archivados:** Zorro shapeshifted (v1), Flashes 1-3 (síntesis), E1 Warden (v1 jade-esmeralda spec)

---

## [2026-07-23] design/production | 3 keyframes de acciones (links de pivotes) + 1 video teaser COMPLETADOS
**Sesión de producción visual — concept art estático + video.**

### Guided Avalanche (Sereth + Torgan) — NB Pro
**Asset:** `Guided Avalanche.jpeg`. Mecánica: "Sereth dobla gravedad/terreno para curvar la carga imparable de Torgan."

Composición cinemática: Sereth (elfo manipulador) izquierda, canalizando poder con manos extendidas. Torgan (enano duelist, 4.5 cabezas, trapezio) centro-derecha en postura de carga potente. Entre ellos: círculos concéntricos de gravedad/espacio doblado alargando la trayectoria de Torgan. Hay blanco separado (silueta brillante) dentro del efecto donde impacta. Bosque envolvente, luz natural.

**Evaluación:** ✅ Mecánica crystal-clear (distorsión de espacio comunica el doblez sin ser literal). Caracterización correcta (etéreo manipulador vs. bruto embestidor). Proporción relativa elf/dwarf correcta. Estilo Sable×BotW locked (ligne claire + hand-painted watercolor, low saturation excepto efecto tealmente). **VALIDADO sin iteraciones.**

### Riposte Runner (Iven + Elfo Vanguard) — NB Pro
**Asset:** `Riposte Runner.jpeg`. Mecánica: "Tu parry-redirect es su vector de lanzamiento al flanco."

Composición: Elfo Vanguard standing (8 cabezas, vertical, orejas atrás) con blade en postura de parry. Iven (humano 7.5 cabezas, acróbata) airborne en arco lateral perfecto, wraps oscuros, capa ondeando. Línea de fuerza tealmente fluye del parry blade hacia Iven — redirección limpida. Cañón con rocas, sunlight diagonal.

**Evaluación:** ✅ Línea de fuerza más explícita que Guided Avalanche (blade→cuerpo). Sincronización perfecta (defensa=offense). Tamaño relativo correcto. Estilo coherente Sable×BotW. **VALIDADO sin iteraciones.**

### Warforging (Vekka + Humano Vanguard) — Higgsfield
**Asset:** `Warforging.png`. Mecánica: "Te atornilla módulos en combate: cada uno cambia tu verbo de brawler."

Composición: Humano Vanguard wide-leg brawler stance (7.5 cabezas, center). Vekka (enana 4.5 cabezas, trapezio) arriba-derecha con goggles enormes de ingeniera, wrench activo atornillando módulo masivo y brillante directamente EN el pecho del humano. Sparks y forge-light ámbar/naranja exploten. Pernos dispersos en suelo, llamas en muros (contexto taller/forja).

**Evaluación:** ✅ Mecánica literal y visual (módulo siendo instalado = "rig siendo upgradado"). Trust implícito (humano permite mid-combate). Saturación ámbar perfecta (forge-light > resto). Estilo Higgsfield coherente con serie (ligeramente más graphic que NB Pro pero sigue Sable×BotW). **VALIDADO sin iteraciones.**

### Speck Sneak Peek — Higgsfield (video)
**Asset:** `Speck sneak peek.mp4`. Prompt: viñeta cinematográfica de primer encuentro/descubrimiento. Criatura salamandra-axolotl pale-mint con seams teal aether, gill-antennae erizables, ojos cálido-oscuros. Caverna oscura, shaft de luz reveladora. Mood: tierno, antiguo, unsettling (belleza + peligro).

**Status:** ✅ Generado y subido. Evaluación pending (ffmpeg setup incomplete).

### Vídeos pendientes de evaluación
- `Arcane Ballistics.mp4`, `Weaver's Net.mp4`, `Seismic Springboard (2).mp4` (re-shoots Higgsfield previos)
- `Speck sneak peek.mp4` (nuevo)

**Notas técnicas:** ffmpeg instalado vía winget (v8.1.2), PATH aún no sincronizado en shell actual. Evaluación de video postponed.

---

## [2026-07-22] feature | Nacimiento de oreja élfico pabellón — paso 3 CERRADO (78%, VoBo provisional)
Ejecutado el paso 3 de [[PRD-Nacimiento-de-Oreja-v1]]: pabellón élfico (`ear_pab`
SphereMesh hermana de `ear_body` en `feature_slot`, r=0.035, scale 0.50/1.40/0.80,
rot.x -0.30, pos 0.148/0.024/0.006) añadido a la rama `aetherborn` de
`character_rig.gd`.

**Ronda 1 (74%):** Dos MEDIUM hallados — pabellón leía como bump separado en 3/4
(silueta "bump-then-cone"), borde inferior delgado en frontal.

**Ronda 2 (78%):** Pabellón elongado (scale.y 1.10→1.40, rot.x -0.10→-0.30) para
fluir hacia el cono; bajado (pos.y 0.032→0.024) para cubrir inferior. Ambos MEDIUM
cerrados. Solo quedan 3 LOWs (inflexión sutil, tinta Sobel sistémica, asimetría
render — ninguno visible a distancia de juego).

Cono élfico intacto (eje 28°/20°, largo ~0.167, punta sin toque — anti-objetivo
respetado). No-regresión: humano 74% pixel-idéntico, enano 70% pixel-idéntico.
Gates ALL_PASS. VoBo provisional de Boris.

## [2026-07-22] feature | Nacimiento de oreja enano + helper — paso 2 CERRADO (70%, VoBo de Boris)
Ejecutado el paso 2 de [[PRD-Nacimiento-de-Oreja-v1]]: helper `_build_ear`
factorizado + rama `ironblooded` de `character_rig.gd`.

**Helper `_build_ear`** (`:117`): defaults = valores del humano cerrado al 74%.
Humano migrado a `_build_ear(side, feature_slot, skin_mat, {})` — verificado
visualmente idéntico. Elfo sin regresión (banco corrido, verificado).

**Enano reparametrizado** (13 overrides): pabellón más ancho/corto (`scale
0.72/0.95/0.85`), radio 0.032, orejas pegadas al cráneo (`rot_z_mul -0.15`),
lóbulo carnoso (`r=0.016`, uniforme), hélix grueso (`outer=0.026`).

QA imparcial (mismo agente, 2 rondas): **63%→70%**. Desglose R2: costura 74,
proporción 70, estructura 65, lectura 65, tinta 78. Los dos CRITICAL de R1
(proporción alto:ancho + ángulo de separación) resueltos. El QA confirma: "lee
como oreja de enano, la reparametrización racial se nota". Techo de 3 primitivas
declarado (mismo que el humano). Gates `test_core.gd` ALL_PASS.

**Nota técnica:** el banco (`tmp_anatomy.gd`) requiere el separador `--` antes
de `--autotest=` para que `OS.get_cmdline_user_args()` lo reciba. Sin él, Godot
arranca la escena principal y se cuelga en "GameDirector booted". Lección
añadida al conocimiento del proceso, no al código.

## [2026-07-22] feature | Nacimiento de oreja humano — paso 1 CERRADO (74%, VoBo de Boris)
Ejecutado el paso 1 de [[PRD-Nacimiento-de-Oreja-v1]]: rama `miststalker` de
`character_rig.gd`. Se reemplazó la esfera desnuda (1 pieza, 4.3% de
penetración) por 3 piezas hermanas en `feature_slot`:

| Pieza | Mesh | Scale | Position (side=1) | Nota |
|---|---|---|---|---|
| Pabellón | `_sphere_mesh(0.030)` | `(0.58, 1.45, 0.75)` | `(0.130, 0.0, -0.024)` | rot.x=-0.15, rot.z=side*-0.06 |
| Lóbulo | `_sphere_mesh(0.012)` | `(0.55, 0.75, 0.55)` | `(0.126, -0.042, -0.020)` | — |
| Hélix | `TorusMesh(0.011, 0.021)` | `(1.0, 1.45, 0.9)` | `(0.140, 0.004, -0.025)` | rot.z=PI/2, rot.x=-0.15 |

Trayectoria QA imparcial (subagente sin contexto, 4 rondas, mismo agente
re-invocado): **55%→69%→71%→74%** (umbral 70%). Desglose final: costura 82,
lectura 78, proporción 75, estructura 70, tinta 68.

**Techo declarado por el QA:** el HIGH de tinta antero-superior resistió 3
rondas de tuning en Z. La concha es imposible con primitivas convexas aditivas.
Lo que falta requiere cambio de enfoque, no más iteración.

**Correcciones al PRD durante la ejecución:** (1) penetración del fallback era
25%, no 46% (semieje ecuatorial ≠ radio en el punto de la oreja); (2) el
fallback neutro NO era "la referencia buena" (portado 1:1 midió 55%, dos
defectos heredados nunca detectados); (3) helper factorizado movido al paso 2.

Gates: `test_core.gd` ALL_PASS en cada ronda. Sin regresión en elfo ni enano
(verificado por diff de píxeles: 3.4% = solo venas animadas del aether).

## [2026-07-22] design | PRD del nacimiento de oreja ESCRITO (propuesto, sin ejecutar)
Boris dio la señal de arrancar el frente detectado en la entrada de
`investigate` de más abajo. Se escribió [[PRD-Nacimiento-de-Oreja-v1]] con el
diagnóstico ya **medido** contra `HairLibrary.SKULL_SEMI` (0.123, 0.141,
0.1425) en vez de descrito a ojo — la causa raíz resultó ser una sola y de
SOLAPE, no de forma:

| Rama | Penetración de la oreja en X | Piezas |
|---|---|---|
| Humano/Mistbound (`:2996`) | ~0.003 (≈5% de su ancho) | 1, esfera desnuda |
| Enano (`:3012`) | ~0.007 (≈11%) | 1, esfera desnuda |
| **Fallback neutro (`:3103`)** | **~0.011 (≈46%)** | **3: pabellón+lóbulo+hélix** |
| Elfo (`:2904`) | sin costura dura, pero sin pabellón | 4 |

El fallback ya resuelve el problema (achata la esfera en X y la hunde casi la
mitad de su ancho) y las razas reales simplemente no lo usan. Encaja con la
lección ya documentada de **fusión por overlap real, no por tangencia**.
Plan en 5 pasos (helper factorizado → humano → enano → pabellón élfico →
QA imparcial vs las 3 láminas de fenotipo), con anti-objetivo explícito de NO
reabrir la oreja de elfo (cerrada al 75% con VoBo). Riesgo anotado: hundir el
pabellón puede apagar la tinta del Sobel en su perímetro — verificar con zoom.
**Estado: `propuesto`, cero código tocado — pendiente VoBo de Boris (incluido
el umbral de fidelidad objetivo, sugerido 70%) antes de ejecutar.**

## [2026-07-22] investigate | Nacimiento de oreja — bug compartido humano/enano detectado, PRD propio pendiente (NO ejecutado)
Cerrada la ronda 10 de la oreja de elfo (75%, VoBo de Boris: "Sí, dale, así
queda" — ver entrada siguiente), Boris marcó que el "nacimiento" de la oreja
(la zona donde se funde con el cráneo) no lee bien en el elfo, y sospechó que
el problema cruzaba razas. Se generaron capturas de banco de los 3 casos
(`ANATOMY_ORIGIN=miststalker|ironblooded|aetherborn`) con zoom 4× sobre la
zona de nacimiento para confirmar antes de tocar código:

- **Humano (`miststalker`) y enano (`ironblooded`):** comparten el mismo
  patrón — una `SphereMesh` desnuda (radius 0.030/0.032) puesta TANGENTE al
  cráneo, sin lóbulo ni hélix, cero blending. Se ve la costura circular
  completa en el zoom — lee "canica pegada", no oreja naciendo del cráneo.
  Confirmado el hallazgo de Boris: es un bug real, no una impresión.
- **Dato clave:** el rig YA TIENE una versión bien resuelta del mismo
  problema — la rama "Origin neutro/desconocido" (fallback humano base,
  `character_rig.gd` ~3097-3146, comentario "M9-r1"/"FASE C paso 7"/"Sprint
  B3") tiene lóbulo colgando (`_sphere_mesh(0.012)`, overlap real) + hélix
  hundida (`TorusMesh` semi-embebido) — exactamente el tratamiento que
  falta en humano/enano. Parece que esa rama de fallback quedó con mejor
  geometría que las razas reales que la reemplazan, probablemente un
  desfase histórico entre cuándo se hizo el pulido de M9/Fase-C (contra la
  cara neutra) y cuándo se separaron las ramas explícitas por origin (C6a).
- **Elfo (ronda 9-10, hoy):** no tiene la costura dura de humano/enano (la
  base-esfera nueva se funde bien), pero comparte la falta de fondo: sin
  pabellón/concha visible en el nacimiento, solo el cono emergiendo derecho
  del cráneo.

**Decisión de Boris:** tratarlo como frente aparte con PRD propio, NO
colarlo dentro del QA loop de la oreja de elfo de esta sesión. Sin código
tocado — solo diagnóstico y capturas de evidencia (no versionadas,
`test_out/` gitignored). Detalle en [[Current-State]] bajo "FRENTE NUEVO
detectado".

## [2026-07-22] qa | Oreja de elfo — ronda 10, reabre la decisión "casi horizontal": QA 35-40%→55-60%→75% — CERRADA, VoBo de Boris
Tras la ronda 9 (ver entrada siguiente), el QA imparcial midió 35-40% y marcó
CRITICAL el eje ("sin rake posterior, sigue leyendo lateral"). Se aplicaron 2
sub-rondas de fix, cada una re-verificada con el MISMO agente QA
(`SendMessage` al `agentId`, protocolo [[QA Loop]]):

**Sub-ronda 1 (proporción + costura):** cuerpo/punta alargados (0.10+0.05 →
0.115+0.06) y adelgazados (bottom_radius 0.024→0.020, medio 0.014→0.011);
yaw subido de 0.35 a 0.70 rad; quiebre angular de la punta (~3°) eliminado
(colineal). QA re-medido: **55-60%** — proporción y costura RESUELTOS, pero
el CRITICAL del eje **persiste** (sigue midiendo ~75-80° desde la vertical).

**Diagnóstico del eje:** se sospechó primero un bug de orden de composición
Euler de Godot (`rotation.z` grande aplicado antes que `rotation.y`) — se
verificó reconstruyendo el giro con matrices `Basis` explícitas
(independiente de cualquier convención de Godot) y dio el MISMO resultado
visual, descartando el bug de cálculo. La causa real: esta oreja quedó
"casi horizontal" por decisión de las rondas 4-5 (validada en su momento
contra Frieren/Zelda). Al re-mirar esas MISMAS referencias
(`zelda_ears.jpg`, `zoom_frieren_ear_left.png`) con el hallazgo del QA en
mente, ambas muestran la oreja apuntando claramente hacia ARRIBA, no casi-
horizontal. **Boris reabrió la decisión de "casi horizontal".**

**Sub-ronda 2 (elevación, cambio de familia de ángulo):** reemplazado el
encadenado de 3 ángulos Euler por una construcción directa de dirección
(elevación ~28° sobre la horizontal + barrido hacia atrás ~20°, vía
producto cruz — sin depender de ninguna convención de composición). QA
re-medido: **~75%**. El QA verificó independientemente la premisa contra
las referencias antes de aceptarla (no la tomó a ciegas), confirmó que NO
cae en el "barrido dramático hacia arriba" que rondas viejas habían
rechazado (~44-46° de la vertical medido, moderado, lejos de los ~0-10°
"look Vulcano" rechazado antes), y que **ya no queda ningún hallazgo
CRITICAL abierto**. Quedan 2 hallazgos menores: MEDIUM (riesgo de que la
punta quede tapada por el pelo definitivo cuando se reemplace el
placeholder — verificar cuando haya geometría de pelo real) y LOW (ángulo
5-6° por encima del techo de 40° pedido, sin impacto visual negativo
reportado).

Gates `test_core` ALL_PASS en cada sub-ronda. **Pendiente VoBo final de
Boris** sobre el 75% — decidir si cierra aquí o se afina más.

## [2026-07-22] fix | Oreja de elfo — REWORK completo ronda 9 (variante Zelda, composición de 4 masas)
Boris rechazó el resultado de la ronda 8 ("Todavía no me gustan") y escribió
su propia spec anatómica (triángulo curvo tipo sable, eje 20-40° hacia atrás,
proporción 1.5-2× una oreja humana MISMO grosor, punta 50-70° redondeada)
contra Zelda TotK + Frieren, pidiendo traducirla a plan técnico vía un
**subagente Opus dedicado** (`subagent_type: Plan`, `model: opus`). El
subagente verificó el código real (líneas exactas), encontró un diagnóstico
no visto antes — el cono de la ronda 8 medía `height=0.24`, **3.1× la oreja
humana del propio rig** (`character_rig.gd:3013-3038`, eje largo ≈0.077),
muy por encima del 1.5-2× pedido — y propuso 3 decisiones a Boris, quien
eligió: (1) sí recortar a la proporción 1.5-2×, (2) **Zelda puro** (no
Frieren, no síntesis), (3) **composición de primitivas sólidas**, NO
reintentar el loft (ya falló 3 veces, rondas 6-8).

**Implementación** (`character_rig.gd`, rama `aetherborn`): reemplazado el
cono de un solo taper por 4 masas — cuerpo (`CylinderMesh` 0.024→0.014,
height=0.10, 6 segmentos, taper lento/borde recto) + punta (`CylinderMesh`
0.014→0.005, height=0.05, quiebre local ~3°) + base (`SphereMesh` chico) +
hélix (`TorusMesh` aplastado discreto), las 3 últimas hijas directas de la
pieza cuerpo (alineación garantizada por parenting, evita el error de la
ronda 8 donde el lóbulo se posicionó a mano con el CENTRO del cono en vez de
su base y quedó flotando invisible). `rotation.y` NUEVO (yaw posterior ~20°,
eje nunca tocado en rondas 1-8 — distinto del rake sagital que falló en
rondas 1-3). Largo total ≈0.14 (≈1.8× la oreja humana).

Verificado en banco visual (`ANATOMY_ORIGIN=aetherborn ANATOMY_HAIR=8`):
de perfil ahora se lee como una oreja real con volumen (antes, el cono se
veía "de canto"/astilla desde ese ángulo); a distancia normal de juego
(`anatomy_full_side.png`) también es legible por primera vez (antes se
perdía en la resolución). Gate lógico `test_core.gd` ALL_PASS, cero
regresión. **Pendiente VoBo visual de Boris** — primera pasada de parámetros
(offsets/quiebre/hélix) sujeta a afinar en banco si Boris pide ajustes.

## [2026-07-22] fix | Oreja de elfo — base un poco más ancha (ronda 2) + lóbulo triangular nuevo
Siguiendo el pedido de Boris de la noche anterior (ver Current-State),
dos cambios aditivos sobre el cono ya validado (60-65%, `character_rig.gd`
rama `aetherborn` de `_build_origin_features`), sin tocar ángulo/largo/
punta:
1. **Base un poco más ancha (ronda 2):** `bottom_radius` 0.024→0.027
   (~+12%, paso más chico que el salto de 25% de ayer).
2. **Lóbulo nuevo:** pieza chica de `PrismMesh` (prisma triangular,
   `left_to_right=0.15` para el perfil ESCALENO pedido — mismo patrón que
   `_wedge()` en `character_signature.gd`) colgando de la base del cono,
   NO una "oreja llena". Primer intento de posicionamiento falló (usó
   `ear.position`, que es el CENTRO del cono en X≈0.148, no su base en
   X≈0.03-0.12 según altura) — el lóbulo quedó flotando invisible cerca
   de la mandíbula (confirmado en banco). Recalculada la geometría de la
   base real del cono (trig sobre su rotación) y reposicionado en
   `Vector3(side*0.135, 0.015, 0.018)`: ahora se lee como un triángulo
   chico bien pegado a la base ensanchada, visible en frente/3-4/perfil,
   sin leer como segunda oreja.
Verificado en banco visual (`ANATOMY_ORIGIN=aetherborn ANATOMY_HAIR=8`,
capturas en `godot/test_out/anatomy_face*.png`) y gate lógico
`test_core.gd` ALL_PASS (cero regresión — único bloque tocado es el de
`aetherborn`). Sin re-medición de QA imparcial (cambio puntual, mismo
criterio que la ronda 1 de ayer) — pendiente VoBo de Boris.

## [2026-07-22] fix | Oreja de elfo — base 25% más ancha (pedido directo de Boris)
Tras cerrar y documentar el experimento fallido de "hoja compuesta"
(entrada anterior), Boris pidió un ajuste puntual sobre el cono ya
validado (60-65%): base 25% más ancha. `bottom_radius` 0.019→0.024
(`character_rig.gd`, rama `aetherborn` de `_build_origin_features`) —
sin tocar ángulo, largo ni punta ya medidos por el QA. Verificado en
banco: más "carne" en la raíz, mantiene el ángulo/punta correctos.
Gates `test_core` + `autotest_biomech` ALL_PASS. Capturas actualizadas
en `godot/test_out/anatomy_elf_face.png`/`_34.png`/`_profile.png`;
baseline humano restaurado en `anatomy_face*.png` normales.

## [2026-07-22] fix | Oreja de elfo — experimento de "hoja compuesta" con HairLibrary._loft/_lock: 3 rondas, todas peor que el cono; REVERTIDO
Siguiendo el plan aprobado por Boris para atacar el hallazgo del QA
anterior ("silueta de hoja compuesta, técnica de un solo cono en su
techo"), se investigó y reusó `HairLibrary._loft`/`_lock`
(`hair_library.gd:181`/`:277` — curva `Curve3D` + perfil de radios, el
reemplazo VIGENTE de la técnica vieja de cadenas de cajas `_ribbon`/
`_s_spine`, esa sí deprecada con 4º intento prohibido). Nunca antes
usada para algo que no fuera pelo — riesgo anotado explícitamente en el
plan.

**3 rondas ejecutadas, con QA imparcial (mismo agente, `SendMessage`)
después de cada una:**
- Ronda 1 (4 puntos, curva sostenida en todo el largo, ~0.205 de
  alcance): QA la comparó contra el cono → **~40-45%**, "cuerno curvo",
  RETROCESO vs el cono (60-65%).
- Ronda 2 (acortada a ~0.165, flick concentrado al final): QA →
  **~40-45%** de nuevo, mismo diagnóstico ("cuerno de toro"), pidió 4
  correcciones concretas (acortar más, colinealidad estricta raíz→2/3,
  eje barrido hacia atrás no perpendicular, radio cayendo rápido en el
  primer tercio).
- Ronda 3 (las 4 correcciones aplicadas literalmente: ~0.11 de alcance,
  P0-P1-P2 exactamente colineales con un solo vector de dirección
  escalado, componente Z negativa real, radios 0.023→0.011 ya en el
  primer punto): QA → **~45-50%**, TODAVÍA por debajo del cono. Nuevo
  diagnóstico: el tramo recto quedó tan delgado que lee "alambre sin
  volumen" y el flick final quedó tan concentrado que lee "gancho/
  garfio", no remate de punta.

**Decisión (Lección aplicada, no una 4ª ronda a ciegas):** revertido
al cono de la ronda 4 anterior (60-65%, mejor medido) — mismo criterio
que "sospechar del andamiaje tras 2-3 intentos": si una técnica nueva,
correcta en teoría, mide peor en CADA ronda pese a corrección dirigida
por QA, es señal de que no encaja a esta escala, no un problema de
calibración. Documentado en [[Lecciones]] (nueva entrada: loft/ribbon
puede leer peor que un cono simple en rasgos chicos y cortos).

**Gates:** `test_core` + `autotest_biomech` ALL_PASS tras el revert.
Estado final: oreja de elfo = cono de la ronda 5 anterior, 60-65% de
fidelidad medida, sin cambios respecto a la última entrega aprobada.
Capturas oficiales sin cambio: `godot/test_out/anatomy_elf_face.png`/
`_34.png`/`_profile.png`. Las capturas del experimento fallido quedan en
`anatomy_elf_face_leaf.png`/`_34_leaf.png`/`_profile_leaf.png` (no se
borran — documentan el intento para no repetirlo sin releer esto).

## [2026-07-22] qa | Oreja de elfo — QA imparcial (protocolo QA Loop) 40%→60-65%, fixes aplicados y verificados
Boris pidió correr QA formal de la oreja (no solo VoBo directo). Protocolo
[[QA Loop]]: subagente `general-purpose` SIN contexto de sesión, con las 2
referencias (`frieren-ears-v0-pgvmflxgahrc1.png`, `zelda_ears.jpg`, en
`Downloads/`) + las 3 capturas del banco (`anatomy_elf_face*.png`).

**Ronda 1 del QA: ~40%.** CRITICAL — ángulo seguía leyendo "barrido
arriba/atrás" (el clásico elfo de fantasía) pese al ajuste de la sesión
anterior, no el ~horizontal+5-15° de las referencias. HIGH — punta roma.
MEDIUM — base gruesa/bulbosa.

**Fixes implementados (`character_rig.gd`, rama `aetherborn` de
`_build_origin_features`):** z-tilt corregido de ~63° a ~82° desde
vertical (ahora ~8° sobre horizontal, dentro del rango pedido);
`rotation.x` (rake trasero) bajado de -0.15 a -0.06; `radial_segments`
del cono bajado a 4 (mismo patrón low-poly ya usado en la nariz — lee
como filo bajo el toon en vez de cono suave/redondeado); `bottom_radius`
0.024→0.019 (base más fina).

**Ronda 2 del QA (mismo agente, `SendMessage`): ~60-65%.** El propio QA
midió por PÍXEL (trazó el contorno en la captura, no solo impresión
visual) — ángulo real ≈7.7° sobre horizontal, dentro de rango. CRITICAL
(ángulo), HIGH (punta) y MEDIUM (base gruesa) confirmados RESUELTOS.
**Hallazgo nuevo (MEDIUM):** la silueta de Frieren/Zelda es una curva
COMPUESTA tipo "hoja" (borde superior casi recto, inferior cóncavo,
"flick" final más pronunciado en la punta) — nuestra oreja es un cono
recto de taper uniforme, lee más "espina/cuerno" que "hoja". El propio
QA lo marca como probable TECHO de la técnica actual (un solo cono/wedge)
— resolverlo de verdad pediría más segmentos a lo largo del eje de la
oreja para meter la curva, no un parámetro suelto. Queda como pendiente
priorizado, no atacado esta ronda (decisión de alcance, no de tiempo:
Boris no pidió seguir más allá del QA + fixes de esta ronda).

**Gates:** `test_core` + `autotest_biomech` ALL_PASS (cambio acotado a la
rama `aetherborn`). Capturas finales en `godot/test_out/
anatomy_elf_face.png`/`_34.png`/`_profile.png`. Baseline humano
restaurado en `anatomy_face*.png` normales.

## [2026-07-21] fix | Oreja de elfo, ronda 2 — Boris pasó referencias nuevas (Frieren + Zelda TotK), reemplaza el criterio de la lámina de concept art
Tras la primera pasada de la oreja élfica (ver entrada anterior, medida
contra `fenotipo-elfo-lavanda-v1.png`: oreja larga muy barrida hacia
atrás), Boris pidió "cambiar un poco las orejas" y, en vez de responder
mi pregunta de dirección (AskUserQuestion rechazada), pasó DOS
referencias visuales nuevas guardadas en `Downloads/`:
`frieren-ears-v0-pgvmflxgahrc1.png` (oreja larga y fina, hacia AFUERA
con ángulo leve arriba, casi sin rake trasero) y `zelda_ears.jpg` (BotW/
TotK, misma lógica, más corta/compacta). Ambas más cercanas al norte de
siluetas limpias del proyecto que el barrido dramático de la lámina
vieja — se toman como el criterio nuevo para ESTE rasgo específico (no
cambia el norte artístico general, que sigue siendo Sable×Hinterberg,
no anime).

**Plan explícito antes de tocar código** (modo plan, aprobado por
Boris): diagnóstico de que `rotation.x` (rake trasero, -0.38 rad) era el
principal culpable de que la oreja leyera "hacia atrás" en vez de "hacia
afuera" — se baja a casi cero, `position.z` se adelanta.

**2 rondas ejecutadas** (regla de freno del proyecto): r1 (rotation.x
-0.08) — frente y 3/4 leen bien (afuera + leve arriba, sin el barrido de
antes), pero el perfil quedó casi de canto (astilla fina: con
rotation.x≈0 la oreja apunta casi puramente sobre el eje X, el mismo eje
que mira la cámara de perfil → foreshortening). r2 (rotation.x -0.15) —
perfil gana algo de presencia sin volver al barrido dramático; frente/
3-4 siguen leyendo bien. **Se cierra aquí** (frente/3-4 — los ángulos de
juego más comunes — leen bien; el perfil estricto a 90° es un ángulo
poco frecuente en gameplay real y el foreshortening residual es
aceptable, no vale una 3ª ronda).

Gates mínimos (cambio acotado a la rama `aetherborn` de
`_build_origin_features`, sin tocar nada más): `test_core` +
`autotest_biomech` ALL_PASS. Capturas actualizadas:
`godot/test_out/anatomy_elf_face.png`/`_34.png`/`_profile.png`. Baseline
humano restaurado en `anatomy_face*.png` normales.

## [2026-07-21] feature | PRD-C6b: geometría nueva — orejas de elfo + mandíbula/ceja de enano
Continuación del piloto de C6b: primera pasada de GEOMETRÍA racial nueva
(paso 4 del PRD, adelantado sobre orejas/mandíbula sin esperar el VoBo de
proporciones — pedido directo de Boris).

**Diagnóstico primero (Lección: medir/mirar antes de autorar):** las
orejas del elfo (ya existían desde antes de C6b) leían como un nudo
horizontal apenas asomando, no la oreja larga barrida hacia atrás de la
lámina — confirmado en banco con `ANATOMY_HAIR=8` ("Shorn Scout", nuevo
override de diagnóstico en `tmp_anatomy.gd` — el peinado default humano
tapaba la oreja y confundía el juicio; el catálogo racial de peinados
sigue pospuesto, esto es solo para ver la geometría).

**Oreja élfica (`_build_origin_features`, rama `aetherborn`):** alargada
0.14→0.24, z-tilt bajado de ~112° a ~66° (menos horizontal, más barrido
hacia atrás/arriba continuando la sien), posición subida y retrasada. 2
rondas verificadas en banco (frente + perfil + 3/4) contra
`fenotipo-elfo-lavanda-v1.png`.

**Mandíbula/ceja por raza (`character_rig.gd apply_phenotype` +
`origins_data.gd`):** nuevo campo `"face"` por origin (`jaw_width`,
`jaw_depth`, `brow_scale`, `brow_y`) — sesgo MULTIPLICATIVO/aditivo sobre
el mismo rango de slider `jaw`/misma ceja compartida (el gap que
[[Fenotipos y Creación de Personaje]] ya había anotado: "jaw/eyeTilt/
eyeShape usan un solo rango para las 3 razas"). Enano: mandíbula +35%
ancho/+20% profundidad, ceja +65% de tamaño y bajada (frente pesada, ojos
hundidos) — contra `fenotipo-enano-varon-v1.png`. Elfo: mandíbula -15%/
-10% (fina), ceja -15% (ligera) — contra `fenotipo-elfo-lavanda-v1.png`.
`face` vacío en humano/miststalker = cero cambio.

**Gates:** `test_core`, `autotest_biomech`, `autotest_footik`,
`autotest_combat`, `autotest_springboard`, `autotest_slice`, `autotest_ui`
ALL_PASS. Capturas guardadas en `godot/test_out/`:
`anatomy_elf_face*.png`, `anatomy_dwarf_face*.png` (+ `_full_front/_side`
del piloto de proporciones anterior). Baseline humano restaurado en
`anatomy_face*.png` normales (7.35 cabezas).

**Pendiente:** VoBo de Boris sobre TODO C6b hasta ahora (proporciones +
orejas + mandíbula/ceja) antes de seguir con ROM por raza y ambos torsos
en juego real (hoy solo verificado en el banco de anatomía).

## [2026-07-21] feature | PRD-C6b arrancado: proporciones raciales enano/elfo (piloto de las 2 razas)
Arrancado [[PRD-C6b-Enano-Elfo-v1]] tras cerrar frente 1 y frente 2. Seguido
el orden del propio PRD: (1) mapear qué % ya resuelve `apply_phenotype` vs
qué necesita geometría nueva, (2) medir contra la lámina ANTES de autorar,
(3) piloto. Hallazgo del mapeo: el CUERPO enano/elfo hoy es un clon exacto
del humano con solo un `scale` UNIFORME por `heightRange` — proporción
(palancas largas/cortas, hombros anchos/caídos) es CERO, porque un escalado
uniforme no puede cambiar una RATIO. Orejas/accent cultural (`_build_
origin_features`) YA existían — el trabajo real faltante era exactamente lo
que el PRD identificó: el cuerpo.

**Implementado (reutiliza los MISMOS hooks de escala que peso/clase, sin
geometría nueva — optimización #1 del PRD):** nuevo campo `"proportions"`
por origin (`origins_data.gd`): `limb_len` (largo de palancas), `shoulder_x`
(ancho de hombro), `neck_len`, `head_scale`, `hand_scale`. `character_rig.gd
_apply_build()` los lee (default 1.0 = comportamiento humano intacto —
`proportions` vacío en humano/miststalker, CERO cambio de comportamiento) y
reposiciona thigh/knee/shin/calf/ankle (pierna) y upper/bicep/tricep/elbow/
fore/forearm_mass/wrist_cap/hand (brazo) por su PROPIO eje local + shoulder_x
sobre `SHOULDER_X`, más neck/head. **Corrección de diseño encontrada
ANTES de romper nada:** escalar solo `leg.scale.y`/`arm.scale.y` (el nodo
padre) parecía más simple pero genera CIZALLA con el codo/rodilla doblado
(Godot escala en el frame local del padre ANTES de rotar) — cada segmento
se reposiciona a mano por su propio offset en cambio. `_Biomech.
solve_knee_for_height` (foot IK, frente 2) también actualizado para usar
`LEG_SEGMENT_LEN * limb_len`, no la constante humana fija.

**Medido en banco (`tmp_anatomy.gd`, nuevo `ANATOMY_ORIGIN=aetherborn|
ironblooded` — reusa el patrón `DIAG_*`), NO a ojo:**
- Enano: r1 5.34 cabezas (objetivo 4.5, canon lámina `fenotipo-enano-
  varon-v1.png` "4.5 heads tall") → r2 4.22 (se pasó) → r3 **4.49** ✅.
- Elfo: r1 8.78 cabezas (objetivo 8.0, lámina `fenotipo-elfo-lavanda-v1.png`
  "8 heads tall") → r2 **8.17** ✅ (cerca, aceptable para piloto).

**Hallazgo colateral (NO introducido por este trabajo, verificado con
`git stash`):** `autotest_classes.gd` tiene una cámara de close-up rota
preexistente (reproduce igual en el commit anterior a hoy) — chip
delegado aparte, fuera de alcance de C6b.

**Gates:** `test_core`, `autotest_biomech`, `autotest_footik`,
`autotest_combat`, `autotest_springboard`, `autotest_slice`, `autotest_ui`,
`autotest_classes` (smoke, sin crash en los 9 combos origen×clase) — TODOS
ALL_PASS. Cero regresión en humano/miststalker (proportions vacío).

**Pendiente (según el propio orden del PRD):** VoBo de Boris sobre estas
proporciones ANTES de seguir a geometría nueva (orejas élficas largas
"que continúan la línea del cráneo", frente/mandíbula pesada de enano,
ROM por raza, peinados/marca cultural — pospuestos explícitamente por
Boris). Este es el piloto que el PRD pedía validar antes de generalizar
más.

## [2026-07-21] feature | Frente 2 (orden Boris): C4 pies IK — nodo ankle nuevo + solver analítico de rodilla/tobillo
Arrancado el frente 2 (C4 — pies IK/ROM) tras cerrar el frente 1. Alcance:
"pies plantados en pendiente" ([[Movilidad Realista]] §"IK como estándar"),
la única pieza de foot IK que el benchmark AAA marcaba pendiente (HZD,
[[Benchmark Biomecánico]] v2). ROM enano/elfo queda para
[[PRD-C6b-Enano-Elfo-v1]] (frente 3), fuera de este frente.

**Hallazgo de partida:** la bota colgaba RÍGIDA del nodo `knee` — cero
pivote de tobillo, así que nivelar el pie contra una pendiente era
imposible sin importar cuánta IK se le pusiera a rodilla/cadera.

**Implementado:**
- `character_rig.gd`: nodo `ankle` nuevo (2-DOF, entre `knee` y la bota —
  antes bota/puntera colgaban directo del knee). Con rotation=0 el mundo
  queda IDÉNTICO a antes (solo cambia la jerarquía) — cero riesgo en
  escenas/bancos que nunca llaman la IK nueva.
- `rig_biomech.gd`: ROM `"ankle"` (x dorsi/plantarflexión, z inversión/
  eversión, y=0 fijo, canon "muñeca/tobillo 2-DOF"). Dos funciones puras
  nuevas: `solve_knee_for_height` (dado el ángulo de cadera YA autorado
  por el gait, calcula cuánto doblar la rodilla —vía composición de dos
  rotaciones sobre el mismo eje X, que se SUMAN— para que el tobillo
  alcance una altura de mundo dada, sin tocar la cadera) y
  `solve_ankle_level` (nivela la suela contra la normal real del terreno,
  expresada en el frame local de la rodilla). Sin `Skeleton3D`/
  `SkeletonIK3D`: este rig es 100% `Node3D` procedural (Lecciones — el
  `class_name` cruzado rompe el load-order en CLI), la IK vive como
  funciones puras igual que el resto de la biomecánica.
- `CharacterRig.apply_foot_ik(l_h, r_h, l_normal, r_normal)` público:
  el rig no sabe de terreno/escenas (mismo principio que `set_motion`) —
  el CONSUMIDOR mide el suelo bajo cada pie con el contrato `get_height()`
  ya existente (PRD-007 alcance 4) y se lo pasa cada frame. Sin llamarlo
  nunca, el rig queda bit-idéntico a antes de C4.
- `player_controller.gd`: muestrea `get_height()` bajo cada pie (offset
  lateral = mismo `FOOT_STANCE` que `leg.position.x` en el rig) + normal
  por diferencias finitas (`_terrain_normal`), llama `apply_foot_ik` justo
  después de `set_motion`.
- Corre TAMBIÉN en el frame HELD del pose-stepping en 2s (no escalonado):
  es necesidad física (no clipping en terreno irregular), no ritmo de
  pose — mismo criterio que los relojes de gameplay que nunca se
  escalonan.

**Gate nuevo `tests/autotest_footik.gd`** (patrón de `autotest_biomech.gd`):
sin llamar la IK nunca → ankle en reposo (cero regresión); suelo llano →
converge a ankle~0 sin violaciones; rampa de 20° con un pie 0.15 m más
alto → rodilla se dobla lo justo (tobillo alcanza la altura objetivo
dentro de tolerancia, verificado por posición global real, no solo el
ángulo) + tobillo se inclina para nivelar, cero violaciones; agujero
fuera de alcance (adversarial) → rodilla clampea a ROM, sin NaN. **Lección
aplicada de entrada** (no repetida): los loops de convergencia se acotan
por TIEMPO REAL (`_drive_ik_for(seconds, ...)`), no por conteo de frames —
un primer intento con conteo fijo dio un falso FAIL por variar el FPS de
la corrida.

**Gates:** `test_core`, `autotest_biomech`, `autotest_footik`,
`autotest_combat`, `autotest_springboard`, `autotest_slice` (juego real
completo en The Wilds con el jugador real, terreno real), `autotest_ui` —
TODOS ALL_PASS. Screenshot de verificación visual:
`godot/test_out/footik_slope.png` (pierna en terreno más alto dobla más
la rodilla + tobillo inclinado, pose creíble).

## [2026-07-21] fix | Frente 1 (orden Boris 07-20): hombro-esfera fundido + cintura con pellizco real
Arrancado el frente 1 del orden acordado (hombro→torso y cintura recta,
hallazgos CRITICAL de Grupo C 07-19). Diagnóstico por color (torso/waist/
pelvis con `material_override` imposible de confundir + brazos ocultos,
`DIAG_TORSO=1` nuevo en `tmp_anatomy.gd`, mismo patrón que `DIAG_AXIS`/
`DIAG_HAND`): el pellizco de cintura SÍ existe en la malla pero es débil
y además queda tapado por el brazo — el brazo cuelga con splay mínimo
("roza el torso todo el trayecto", decisión anti-gorila 2026-07-13) a una
tasa fija mientras el torso se angosta más rápido abajo, así que el ancho
COMBINADO brazo+torso no bajaba pese a que el cilindro sí tapera.
**Fixes:** (1) `waist` bottom_radius 0.071→0.058 (pellizco más profundo,
gana margen real frente al brazo, no solo frente al fondo); (2) `trap_back`
(esfera trasera del trapecio) agrandada (1.5/0.9/0.55→1.7/1.05/0.65) y
acercada al deltoide (0.09→0.105, y 0.30→0.29, z -0.04→-0.025) para tragar
su cuadrante trasero-superior completo — corolario de Lecciones: dos
esferas que solo se TOCAN dejan ver el horizonte propio de cada una,
necesitan INTERPENETRAR de verdad. **Resultado verificado en render:**
closeup hombro-cuello ahora funde en una sola masa continua (antes: bola
con costura de tinta clara alrededor); vista de frente ahora muestra un
hueco real de fondo (verde) entre brazo interior y cintura + curva de
torso visiblemente más angosta que el hombro (antes: silueta recta de
hombro a cadera). **Gates:** `test_core`, `autotest_biomech`,
`autotest_combat`, `autotest_springboard` ALL_PASS — cero regresión.
Perfil (side view) seguía sin mostrar mucho pellizco tras la ronda 1.
Herramienta nueva reutilizable: `DIAG_TORSO=1` en `tmp_anatomy.gd` (aísla
torso/waist/pelvis + oculta brazos).

**Ronda 2 (mismo día, pedido de Boris "ataca el perfil también"):**
diagnóstico por color confirmó que el pellizco de PROFUNDIDAD (Z) era
aún más sutil a ojo que el de ancho (X), aunque el mismo radio de
cilindro controla ambos ejes por igual. Profundizado más: `waist`
bottom_radius 0.058→0.048. Medido por PÍXEL (no solo a ojo — lección
"zoom antes de cerrar"): el ancho de la franja de cintura en perfil baja
de 54px (torso, altura hombro) a 24px (fondo de waist) = ~55% de
reducción real, confirmando que el pellizco SÍ es genuino en las dos
vistas (el ojo lo subestimaba por el tamaño chico de la franja visible).
Frente sigue con hourglass limpio (no se pasó). Gates: `test_core`,
`autotest_biomech`, `autotest_combat`, `autotest_springboard` ALL_PASS.
**Frente 1 CERRADO** (hombro→torso + cintura recta, frente y perfil).
Queda VoBo de Boris sobre las capturas antes de seguir con el resto del
orden (C4 pies IK/ROM, luego C6b).

## [2026-07-20] state | Python 3.12 instalado + check_vault.py verificado en corrida real + gitignore de privados wireado
Boris pidió instalar Python (bloqueaba `check_vault.py` desde el checkpoint
anterior). Instalado vía `winget install --id Python.Python.3.12`
(3.12.10, oficial python.org, hash verificado por winget) en
`%LOCALAPPDATA%\Programs\Python\Python312\`. La terminal ya abierta de la
sesión no releyó el PATH nuevo — se usó la ruta completa del ejecutable
para no depender de reiniciarla; lección actualizada en [[Lecciones]]
(refinada, no acumulada: ya no dice "no instalado").

Primera corrida real del script (antes solo se había estimado a mano):
confirmó **~1,894 tokens de arranque, 🟢 VERDE**, sin `@imports`. Encontró
dos cosas reales, no cosméticas del todo:
1. **Mojibake de acentos** en la salida de consola de Windows (encoding no
   UTF-8 por defecto) — arreglado forzando `sys.stdout.reconfigure(
   encoding="utf-8")`.
2. **Los privados opcionales (`Notas-Privadas.md`/`Bitacora-Privada.md`)
   NO estaban protegidos en `.gitignore`** — el patrón quedó documentado en
   SCHEMA/VAULT-STARTER §5.5 pero nunca se escribió el glob real. Se agregó
   ahora (`Aether Bound/20-State/Notas-Privadas*` y `Bitacora-Privada*`) —
   verificado con `git check-ignore` (no a ojo), aunque los archivos en sí
   siguen sin crearse (nadie los ha pedido todavía).

## [2026-07-20] design | SCHEMA v1.1: dieta de arranque fusionada desde `project-context` + VAULT-STARTER v2 + check_vault.py
Boris trajo una skill externa (`project-context`, de Claude Code) con un
playbook de optimización de contexto que el propio `VAULT-STARTER.md` no
cubría: auditoría objetiva de cuántos tokens se pagan AL ARRANCAR una
sesión (no cuánto cuesta ejecutar una tarea — eso es el frente separado
del PRD-C6b de la entrada de abajo). Se fusionaron ambos métodos:

- **`../VAULT-STARTER.md` → v2**, reescrito completo con: §9 "Dieta de
  arranque" (script de auditoría embebido, semáforo 🟢<10k/🟡10-30k/🔴>30k
  tokens, distinción autoload hard/soft/no), §5.5 niveles equipo/privado
  (`Notas-Privadas.md`/`Bitacora-Privada.md`, gitignored con glob,
  verificado con `git check-ignore` real), detección individual vs.
  colaborativo vía autores de `git log`, puente opcional `AGENTS.md`.
- **[[SCHEMA]] → v1.1**: nueva sección 8 (mismo contenido adaptado a rutas
  reales del proyecto); [[Current-State]] gana un techo verificable
  (~2,500-3,000 tokens) en vez de juicio a ojo.
- **[[Lint Loop]]**: gana un 6º punto — el peso de arranque se audita
  aparte de la completitud/coherencia del Vault (pueden fallar
  independientemente).
- **`Aether Bound/scripts/check_vault.py`**: script real, extraído del
  bloque embebido en VAULT-STARTER §9.1, con el MANIFEST apuntando a las
  rutas reales de este repo (`CLAUDE.md`, `Aether Bound/SCHEMA.md`,
  `Current-State.md`, etc.).
- **`CLAUDE.md`**: nueva regla 6 (arranque barato + referencia al script).

**Bloqueo técnico:** no hay un intérprete de Python real instalado en esta
máquina (solo el stub de Microsoft Store) — el script no se pudo correr
todavía; lección documentada en [[Lecciones]]. Línea base calculada A MANO
con `wc -c`: `CLAUDE.md` (881B≈220t, hard) + `Current-State.md`
(5,678B≈1,420t, soft) = **~1,640 tokens de arranque → 🟢 VERDE** (sin
`@imports` en `CLAUDE.md` — sano). Vault es **individual** (un solo autor,
`tonom`, en el historial de los 3 archivos de contexto), así que no aplica
todavía la restricción de "no reestructurar Current-State/LOG" de
`project-context` — libertad total mientras siga siendo un solo director.

**Pendiente de VoBo de Boris:** la nueva sección 8 del SCHEMA (status
`ratificado` heredado del archivo, pero el contenido nuevo no ha sido
ratificado explícitamente todavía — mismo patrón que la sección 7 cuando
se añadió). `Notas-Privadas.md`/`Bitacora-Privada.md` NO se crearon: son
un patrón documentado, no un archivo — se instancian solo si Boris los
pide.

## [2026-07-20] design | Mentón aceptado como estilo (S20) + orden de trabajo acordado + PRD C6b ampliado con plan de optimización de tokens
Boris cierra la ronda de cara: mentón en 20% se ACEPTA como estilo
(igual que anillos de codo/hombro), no se toca más por ahora. Orden
acordado para lo que sigue: (1) hallazgos restantes de grupo C —
hombro→torso y cintura recta; (2) C4 — pies IK/ROM; (3) C6b — enano/elfo
reales. Catálogo de peinados humano y Fase 4b (warpaint) quedan
POSPUESTOS ("no creo que sea prioridad ahorita" — ambos son trabajo de
catálogo/múltiples variantes, no frente urgente).

Boris preguntó si se puede optimizar el gasto de tokens para cuando
lleguemos a C6b ("cada feature nos toma muchísimos tokens") y pidió
armarlo como PARTE DEL PLAN, con énfasis explícito: cada raza necesita
también su propio catálogo de peinados y marca cultural (warpaint/
tatuajes/birth marks), no solo el cuerpo — ampliando el alcance
histórico de C6b. Nuevo [[PRD-C6b-Enano-Elfo-v1]] registra el alcance
ampliado (confirmado contra [[Fenotipos y Creación de Personaje]]: aether
luminoso élfico, tatuajes de gremio + inlays de forja enanos) y 3
optimizaciones concretas: (1) reusar `apply_phenotype` para reproporción
racial en vez de geometría nueva donde se pueda — el costo alto de esta
sesión fue geometría SIN precedente (loft de pelo), no reproporción;
(2) medir superficies ANTES de autorar (lección `_on_skull`: 3 rondas
del pelo se perdieron por semiejes de cráneo inventados); (3) delegar
el ciclo render→zoom→diagnóstico a un subagente barato (Haiku, validar
con 1 caso antes de generalizar) — el orquestador solo lee capturas de
cierre de ronda y QA formales, no cada zoom intermedio de la iteración
ciega. Nada de C6b se ejecuta todavía — Boris pidió solo verificar
alineación, sin tocar código.

## [2026-07-20] fix+stop | Mentón: 2do intento (biseles verticales) sin ganancia visible — STOP documentado, techo de técnica sobre geometría ratificada
Boris decidió: boca queda ACEPTADA en 35% (no reabrir la estructura de
2 labios); mentón sigue con cuidado. Segundo intento: biseles en las
ARISTAS VERTICALES de `jaw_mesh` (mismo patrón que `chin_chamfer`, boxes
rotados 45° pero en eje Y, inset simétrico ~8.5mm, altura 0.050 para
enterrar tapas). Verificado en captura: SIN regresión (no reabrió tinta
ratificada) pero TAMBIÉN sin cambio visible en frontal/3-4/perfil — el
bisel vertical corta la esquina frontal-lateral, que en perfil recto no
se ve (solo se vería en 3/4, donde queda oculto tras jaw_body) y en
frontal es demasiado sutil a la escala del render. Dos intentos
cuidadosos (bisel horizontal agrandado + bisel vertical nuevo) sobre la
geometría ratificada, cero ganancia de lectura. Regla del Vault
aplicada: PARAR y documentar en vez de seguir a ciegas. Conclusión: el
mentón-cuboide en perfil (20%) es un techo de la MASA base (proporción/
pivote del bloque `jaw_mesh`, no su acabado de bordes) — moverlo
requeriría re-dimensionar el bloque ratificado, fuera del alcance de
"tocar con cuidado". Queda para que Boris decida: aceptar como estilo
(igual que los anillos de codo/hombro) o autorizar una revisión de
proporción del bloque. Gates ALL_PASS.

## [2026-07-20] fix+qa | Última ronda de cara arranca: boca 20%→35%, mentón sin cambio — decisión pendiente de Boris
Arranque de la última ronda de ajustes de cara (objetivos grupo C: boca-
cápsula 20%, mentón-cuboide en perfil). **BOCA:** causa raíz de "bisagra
mecánica" era doble — (a) la cápsula protruía lo suficiente para que el
Sobel entintara TODO su contorno (pared empinada = borde completo,
Lecciones); (b) la comisura era una ranura corta y centrada, leía slot.
Fix: cápsula hundida casi al ras (rampa, el Sobel ya no la recorta como
objeto pegado) + comisura rehecha como 3 segmentos (centro ancho + 2
esquinas que caen, down-turn de boca seria) cubriendo casi todo el
ancho del labio. QA imparcial: 20%→**35%**. Sigue CRITICAL: una sola
cápsula con línea central lee "pieza soldada", falta separación real
labio sup/inf (dos volúmenes con escalón Z, la estructura que Boris
descartó tras 8+ rondas fallidas — NO se revirtió esa decisión sin
consultar). **MENTÓN:** se agrandó con cuidado el `chin_chamfer`
(0.015→0.019, mismo centro, geometría RATIFICADA por Boris) — verificado
en captura que no reabrió tinta, pero QA: el bisel es invisible a
distancia normal de render, mentón sigue en **20%** sin cambio real.
El techo no es de técnica: requeriría biseles en las aristas VERTICALES
del bloque del mentón (más invasivo sobre zona congelada). Gates
ALL_PASS. Ambas decisiones (reabrir estructura de 2 labios; biselar más
la masa ratificada del mentón) quedan para que Boris decida.

## [2026-07-20] decision+fix | Boris RATIFICA VoBo de mandíbula (permanente) + línea del nacimiento más llena; pinhole de coronilla = stop documentado
Boris ratifica el VoBo de la mandíbula: la mini-ronda de quiebres queda
PERMANENTE (deja de ser temporal). Ese frente cierra. Sobre el pelo,
dos ataques a los pendientes: **(1) línea del nacimiento** — la
recesión de sienes bajó de 0.26 a 0.16 → arco lleno y parejo de sien a
sien (la referencia de cráneo tiene arco redondeado, no pico central
con entradas); mejora clara en frente y 3/4. **(2) pinhole de
coronilla** — se probó agrandar el casquete en Z (semi 0.138→0.147, que
ahora supera al cráneo) + correrlo menos atrás, y bajar el arco de los
mechones para que se tiendan en vez de puentear. El pinhole NO cerró:
es un bolsillo cóncavo que la cámara de perfil mira de canto en ese
ángulo puntual — lectura de silueta, no cobertura simple (lección del
Vault confirmada por 3ª vez). A escala de visualización las 4 vistas
leen totalmente cubiertas; el punto solo aparece a 3× zoom. STOP
documentado. Gates ALL_PASS.

## [2026-07-20] qa+fix | QA de ZONAS de pelo vs referencia de cráneo (pedido de Boris): hueco de coronilla + pendientes previos
Boris pasó una referencia de cráneo rapado en 4 ángulos y pidió comparar
las ZONAS donde vive el pelo (no el peinado ni la barba). La referencia
es imagen pegada (no archivo), así que el orquestador hizo la comparación
en píxel directa (regla del Vault). Zonas que YA coinciden: patilla corta
delante de la oreja, cobertura sobre la oreja, occipucio, nuca hasta el
cuello. Hallazgo real de ZONA: **hueco de piel en la coronilla-frontal**
en perfil — los mechones se arquean sobre la masa base y dejan ventanas
de cuero cabelludo. Fixes de la sesión: (a) los 2 pendientes del QA
anterior (nuca baja subdividida con 5 mechones sobre el casquete;
nacimiento con dx a paso irregular y anchos de rango doble), commit
b4b1f20; (b) masa base engrosada probó ser "abultado" (vetado por Boris)
→ revertida, y la coronilla se tapa con BANDAS que hugean el cráneo a
lift bajo (mismo truco del fade de nuca, sin bulto) + arco de los
mechones bajado. Diagnóstico de color (bandas en `darker`): el punto
residual SEGUÍA tan → es piel real, un pinhole que un mechón arqueado
abre, no un brillo. Las bandas cierran ~95%; el residual es invisible a
escala de visualización (solo a 3× de zoom). Lección aplicada: PARAR
tras 3 intentos razonados sobre un hueco y documentar
([[Lecciones]]/[[Principios de Anatomía 3D]]). Gates ALL_PASS.

## [2026-07-19] qa+fix | QA final del pelo (libro 35% / lámina 35%): patilla eliminada por decisión de Boris y "roseta" de nuca rota
Tercer QA doble sobre el estado final, con la observación de Boris
pasada como contexto ya resuelto (el mechón de patilla sobra; el
casquete debe parar por delante de la oreja a la altura donde ese
mechón terminaba). Veredicto: lámina 35%, método 35%. **CRITICAL 1:**
en la vista de espalda las tiras leían una ROSETA/molinete — 5-6
lóbulos-gota de igual tamaño y ángulo convergiendo a un punto de la
coronilla; anti-paralelismo violado de la forma más visible. Fix:
factores `fan` y `endy` por tira — unas convergen, otras siguen rectas
y otras ABREN hacia afuera, con alturas de muerte dispersas.
**CRITICAL 2:** el tercio inferior de la nuca seguía liso sin
subdivisión (pendiente). **HIGH:** el casquete abombaba sobre la oreja
y la dejaba "enmarcada por un agujero" — el propio QA avisó que quitar
solo la patilla no bastaría porque el bulto viene también de arriba y
atrás; fix: casquete angostado en X (0.126→0.121) para que la oreja
(x≈0.136) sobresalga, menos inclinación (0.36→0.28) y centro más bajo
para que su borde delantero baje a y≈-0.035 y dibuje la patilla, como
pidió Boris. **Decisión de Boris ejecutada:** el mechón de patilla
suelto se ELIMINÓ (era una segunda pieza en una zona que el casquete
ya rodeaba). Gates ALL_PASS. Pendientes del QA: subdivisión del tercio
inferior de la nuca y picos del nacimiento aún parejos.

## [2026-07-19] feature+qa | QA doble (libro + lámina) y REESTRUCTURA del pelo: casquete elipsoide continuo, sin flequillo, volumen aplanado
Boris: "ya cumple preliminarmente, falta quitar eso abultado para que
se vea más fluido; corre un QA que compare vs el libro y vs RAW".
**(1) Abultado:** el grosor RADIAL de una pieza de loft es
radio×flatten — la masa de la coronilla iba a 0.92 y protruía ~7.5cm
(un blob). Bajado a 0.50 (masa) y 0.38 (tiras): el ancho lateral, que
da la cobertura, no se toca. **(2) QA doble** (juez único, dos ejes:
página p.156 del libro + lámina): lámina 40%, método 35%, con dos
hallazgos duros — CRITICAL "las bandas apiladas leen anillos
concéntricos / capas de cebolla" y HIGH "los picos frontales no
existen en la lámina". **(3) Verificación en píxel propia** (regla del
Vault: ante un QA que describe forma, mirar la lámina uno mismo; zoom
6× a las 3 cabezas del canon): CONFIRMADOS los dos. El frontier crop
NO tiene flequillo — el pelo nace en una línea alta y barre arriba-
atrás — y la nuca es UNA MASA CONTINUA hasta el cuello, no anillos.
**(4) Reestructura:** las 3 bandas de nuca + 3 de costado por lado se
RETIRARON y se reemplazaron por UN CASQUETE ELIPSOIDE inclinado. Un
elipsoide abraza la esfera craneal por construcción (sin sagita, sin
costuras, sin anillos) y se auto-recorta; la INCLINACIÓN (rot.x 0.36)
es la clave: manda el polo inferior a la nuca (pelo bajo atrás) y sube
el borde delantero por encima de la frente (línea del pelo alta) y por
encima de la oreja (que el canon quiere despejada). Las puntas del
flequillo se subieron a la línea del nacimiento. Gates ALL_PASS.

## [2026-07-19] fix | Costado del cráneo cubierto (Boris marcó los huecos en azul) — 3 bandas envolventes por lado
Boris marcó en azul sobre la captura de perfil los puntos sin pelo:
todos caían en el PARIETAL, entre la masa de arriba y las piezas de
nuca/patilla. Las piezas previas solo cubrían una diagonal fina, así
que el costado quedaba al aire. Fix: 3 bandas por lado que ENVUELVEN el
costado de frente a nuca a tres alturas (y≈0.104 / 0.062 / 0.038), con
solape vertical entre ellas y lift escalonado (regla de la sagita).
Detalle que importa para autorar más: las x hay que acotarlas al
SEMIANCHO REAL del cráneo a cada altura (a y=0.105 el cráneo mide 0.092
de semiancho, no 0.123) — pedir un x mayor da un punto fuera de la
elipsoide y `_on_skull` lo clampea a un z falso. Se RETIRÓ la banda
temporal vieja, redundante con las nuevas: superpuestas apilaban bordes
y el lateral leía acolchado/mosaico (menos piezas = menos siluetas
internas). Gates core+combat+springboard ALL_PASS. Residual: el costado
todavía lee algo geométrico por el apilado de bandas.

## [2026-07-19] fix | Fade completado: nuca hasta el cuello + patillas pegadas a la oreja (circuito cerrado) — lección de la SAGITA
Boris sobre capturas: "la parte de abajo debería llegar cercana al
cuello, las patillas deben pasar lo más pegado a las orejas para
conectar con la parte de atrás". **Nuca:** baja de y 0.040 a y≈-0.048.
NO se hizo con una banda alta única — el anillo del loft es una elipse
PLANA, así que una banda de más de ~6cm de alto deja de abrazar el
cráneo y flota en los bordes (calculado: a ±0.058 del eje el cráneo se
adelanta ~1.4cm). Se APILARON 3 bandas de media altura ≤0.038 con
solape; las costuras horizontales no dentan (los dientes venían de
costuras VERTICALES). **Patillas:** movidas al ANCHO MÁXIMO del cráneo
(x≈0.122, donde la superficie cae en z≈0 = justo delante de la oreja,
que vive en z -0.057..-0.012) y bajadas a y=-0.038; antes iban a
x 0.119/y -0.012 → z≈+0.034, o sea 4,6cm ADELANTE de la oreja y
cortando a media oreja: ni pegadas ni conectadas. La banda de detrás de
la oreja se extendió a y=-0.020 para cerrar el circuito patilla→oreja→
nuca. **LECCIÓN NUEVA (2 rondas perdidas):** al apoyar una banda de
loft sobre una superficie curva, el anillo es una CUERDA, no un arco:
sus bordes se hunden h²/(2R) (h=media altura, R=radio del cráneo). Si
el `lift` no supera esa sagita, el cráneo asoma por los bordes y
aparecen HUECOS DE PIEL entre bandas (fue exactamente el defecto: lift
2mm contra sagita 3.7mm). Fix: lift 0.007 en las bandas de nuca,
escalonado (más afuera arriba) para que cada banda monte sobre la de
abajo como capas. Gates core+combat+springboard ALL_PASS. Residual
menor: las costuras entre bandas apiladas todavía se insinúan.

## [2026-07-19] fix | Refinamiento de pelo pedido por Boris: quiebres suaves + taper + FADE de temporales/patillas/nuca
Tres pedidos del director sobre el rework: (a) suavizar quiebres, (b)
taper, (c) "no tiene nada de cabello en los temporales y patillas, ni
en la nuca". **(a)** `sides` de las secciones del loft subido (clump
8→14, tiras 6→12, contrastantes 5→10): a 8 lados cada faceta medía
~2.5cm y el cel-step la marcaba como panel (el QA leía "placas/tejas").
**(b)** TAPER real: las tiras ganan un punto extra por delante del
nacimiento con radio w*0.22 (era w*0.55) y la irregularidad entre
vecinas se amplificó — el corte pelo→piel dejó de ser el contorno duro
y parejo que leía "gorro/jockey". **(c)** PASADA 0 nueva = FADE: tiras
que hugean el cráneo en temporales (2/lado), PATILLA por delante de la
oreja (que vive en x±0.124, z-0.034), detrás de la oreja (2/lado) y
NUCA (7 solapadas). Cuatro rondas para calibrarlo, cada una con causa
medida: fade en `darker` → casi negro ("garras") → tono medio; tiras
finas y puntiagudas → borde festoneado ("dedos") → más anchas que su
paso + puntas romas; y **`flatten` 0.45→0.15**: el grosor
radial de una tira es radio×flatten, así que a 0.45 protruían ~14mm —
eso es melena corta, no rapado, y por eso leían lóbulos; a 0.15 son
cintas de ~3mm apoyadas en el cráneo. QA intermedio 58% (de 52%) pero
con CRITICAL: patillas/nuca seguían leyendo "picos/garras sobre piel".
**LECCIÓN QUE CERRÓ EL PROBLEMA (rondas 15-17):** el defecto no era el
ancho, el tono ni el largo de las tiras — era que eran TIRAS. Cada
costura entre dos tiras vecinas ES un diente, y toda pieza suelta con
punta en esa zona lee colmillo (probado y descartado también con
"mechitas" cortas para ablandar el filo: salieron colmillos
triangulares). El fade se rehízo como **BANDAS CONTINUAS de una sola
pieza**: la de nuca corre a lo ANCHO (espina horizontal → el radio del
loft se proyecta en vertical, define el alto del rapado y no queda
ninguna costura vertical que dentar), más una banda por lado en
temporal y otra detrás de la oreja. Regla nueva: en zonas de fade/
rapado, superficie continua; los mechones sueltos son solo para pelo
largo. Gates core+combat+springboard ALL_PASS.

## [2026-07-19] feature | FULL REWORK del cabello con jerarquía de 3 pasadas del libro — frontier crop reconstruido, causa raíz del "casco" resuelta
Tras el minado dirigido, `_hair_frontier_crop` reconstruido según el
método del libro (p.156/243): (1) UN clump madre direccional frente→
nuca que ES el cap del domo (no concéntrico al cráneo), (2) 7 tiras que
SIGUEN las trayectorias del clump ("la masa se parte en tiras", no
picos pegados) + 2 laterales que exponen la oreja, (3) mechones
contrastantes. Herramienta nueva `_on_skull(x,y,lift,back)`: devuelve
el punto de la superficie del cráneo REAL (semiejes medidos
0.123/0.141/0.1425 @ y=0.012) — las 3 primeras rondas fallaron por
autorar con semiejes INVENTADOS ("copete flotante"/"mohawk hundido"),
lección: autorar geometría de pelo contra la superficie medida, no a
ojo. Cuatro defectos cazados en captura y resueltos: (a) winding que
dejaba mechones huecos color cielo; (b) tinte AZUL de todas las tiras =
rim del `toon_opaque` (fresnel^3) que en tiras finas baña el perímetro
completo — `hair_mat.rim_strength` 0.18→0.04 SOLO en pelo (causa raíz
del "tinte azulado" que venía desde los conos del piloto); (c) albedo
`darker` que bajo la banda de sombra rendía casi negro-azul → clump a
tono medio; (d) "cuenco/tonsura oscuro" trasero = pared en sombra de la
concha re-añadida → concha RETIRADA, nuca corta que expone piel
(lámina). Front/3-4/perfil leen pelo castaño barrido con mechones;
nuca corta con piel. QA imparcial nuevo: **52%** (vs 38% del piloto —
juez distinto, no comparable directo, pero: defecto de "dientes"
ELIMINADO, sin cuenco trasero, color correcto). Residual HIGH: el
faceting duro entre tiras lee "placas/armadura" y la línea del pelo es
muy pareja (falta taper) — refinable dentro del método (techo estimado
65-75%). Gates core+combat+springboard ALL_PASS. VoBo de Boris
pendiente (su checkpoint de "cabello decente" antes de la última ronda
de cara).

## [2026-07-19] design | VoBo TEMPORAL de mandíbula + piloto de loft RECHAZADO → full rework de cabello con minado dirigido del libro
Boris sobre la mandíbula aligerada: "funciona muy bien y visiblemente
mejor que el principio" — VoBo temporal; la última ronda de cara se
hará cuando el humano tenga cabello decente. El piloto de loft NO lo
convence → full rework del cabello. Validación pedida por Boris: el
Vault solo tenía 3 principios de pelo en [[Principios de Anatomía 3D]]
(masa primero / anti-paralelismo / adaptación Sobel) — exactamente los
que el piloto ya aplicó; la propia página admite que faltan las
"pasadas intermedias de subdivisión progresiva" sin documentarlas.
Veredicto: INSUFICIENTE → se re-abrió "Anatomy for 3D Artists" (copia
personal en Downloads, mutool; el PDF no tiene capa de texto, se
re-renderizaron las 157 pp a JPEG) y se lanzaron 3 mineros en paralelo
dedicados EXCLUSIVAMENTE a pelo (pp.1-55 / 56-110 / 111-157):
proceso de construcción, subdivisión 1ria→2ria→3ria, mechones,
hairline, flow, silueta anti-casco, estilizado vs realista.

## [2026-07-19] feature | FASE 3 pelo: loft IMPLEMENTADO y piloto ejecutado — detenido en regla de cierre con QA 38%
Primera ejecución real del recurso ratificado 2026-07-12: `_loft`
(Curve3D + perfil de radios → malla SurfaceTool facetada, contrato de
ejes documentado generador+consumidor) y `_lock` en `hair_library.gd`.
Frontier crop reconstruido con el orden del libro (masa conservada →
16 mechones loft → 3 rebeldes, anti-paralelismo). 3 rondas: r1 puntas
"garra" hasta la ceja; r2 acortadas/arrimadas; bug real cazado en
captura: WINDING invertido (caras exteriores culled — mechones leían
"V huecas" color cielo); r3 tonal (sin `darker` en flequillo — colgado
bajo el quiff ya vive en la banda de sombra; con darker leía "agujero").
QA imparcial de cierre: 38% (baseline de SU hilo) — mechones con punta
real SÍ, pero conjunto "casco con dentículos": falta separación real
entre puntas y romper el domo trasero; techo estimado 50-55%. Regla del
PRD aplicada: DETENERSE y reportar (no iterar a ciegas). Continuación
diseñada en [[PRD-Catalogo-Peinados-v1]] (draft nuevo: 6-8 estilos ×
género × raza, decisión de Boris). Issue conocido anotado: tinte
azulado del shader en piezas colgantes (preexistente con los conos).

## [2026-07-19] qa | GRUPO C ejecutado — jueces canónicos nuevos: rostro 34%, torso 32% (baselines de SUS hilos)
El presupuesto de subagentes volvió (lección confirmada: ventana de
5h, no mensual — sondeo barato antes de asumir espera). Un juez único
por región sobre el set fresco post-mini-ronda: ROSTRO 34% (peores:
boca-cápsula 20%, mentón-cuboide en perfil 25%; mejores: cráneo 55%,
orejas 45%) y TORSO 32% (CRITICAL: hombro-esfera desconectado, cintura
sin angostamiento; techo declarado: pec/oblicuos/omóplato como forma).
Arbitraje del orquestador sobre hallazgos: "ojos anime" DESCARTADO
(párpado pesado A8 tiene VoBo de Boris), "triángulo verde bajo el ojo"
DESCARTADO (warpaint Mistbound deliberado), "sin clavícula/cuello
esfera" contradice A4/A6 verificados en píxel — se toman con pinzas.
Números NO comparables con los 48-57%/38-55% de jueces anteriores
(varianza entre jueces ±10-17, lección 07-17); estos son los baselines
canónicos de la serie nueva. El VoBo de Boris sigue mandando.

## [2026-07-19] fix | Mini-ronda VoBo: quiebres de mandíbula/mentón aligerados (2 rondas, causa calculada)
Boris revisó capturas (VoBo condicional: cara "90% bien") y circuló en
azul los quiebres de tinta en las junturas de la mandíbula. Diagnóstico
por geometría + zoom 3× (System.Drawing): (1) la esquina frontal-interna
de cada faceta `jaw_body` (yaw 0.40) quedaba ~4mm POR DELANTE de la cara
frontal de la caja central — arista proud que el Sobel entintaba como
trazo vertical junto a la comisura; (2) los fondos de las facetas
colgaban 3.5mm bajo el fondo de la caja central — cada desnivel un jog
en la línea de la mandíbula; (3) el chaflán B2a estaba centrado casi
SOBRE la arista (sobresalía 9.6mm bajo el fondo y 8.6mm frente a la
cara: fabricaba sus propios labios de tinta en vez de cortar la
esquina). Fixes: yaw 0.40→0.30, fondos alineados al ras (-0.0275),
faceta retraída (z 0.002→-0.003, cruce sobre la cara central =
profundidad continua), chaflán hundido a (y-0.019, z 0.032) con inset
~7mm/lado y puntas enterradas, goníacas agrandadas (0.9/0.7/1.05)
envolviendo el vértice de la rama. Verificado con zoom: trazo vertical
MUERTO, línea inferior continua, goníaco curvo en 3/4; turnaround sin
regresiones. Gates: test_core + autotest_combat + autotest_springboard
ALL_PASS. Queda: VoBo final de Boris sobre las capturas nuevas.

## [2026-07-17] fix | Sprint GRUPO B ejecutado — labios sin frontera de material, chaflán+goníaco, oreja con hélix, rodilla/gemelo
La "bolsa de bisel/malla" resultó atacable con primitivas + la regla de
tinta nueva, sin malla custom: **B1** labios re-tonalizados a piel
oscurecida (#dba07c) — la frontera dura de MATERIAL era lo único que
seguía leyendo "curita" (la tinta ya no la dibujaba); la lectura la
lleva la comisura, como la lámina ("labios delgados y serios"). **B2**
chaflán de 45° en el borde inferior-frontal del mentón (parte el
escalón de 90° en dos — vistas bajas) + esferas goníacas (el vértice de
caja de cada rama ahora redondea como masetero). **B3** OREJA con
hélix: toro aplastado semi-hundido en el pabellón (TorusMesh, anillo en
YZ) — el borde emerge en rampa sin tinta propia y el hueco muestra la
elipse de abajo como concha; el óvalo-decal de perfil murió. **B4**
rodilla achatada lateralmente (la esfera 0.066 era más ancha que ambos
tubos = "repisa") + gemelo más largo (entrada/salida de silueta suave).
Los ANILLOS de codo/hombro quedan como estilo aceptado por ahora
(el QA mismo los marcó "consistentes si son intención") — se reabren
solo si Boris los veta en capturas. Gates ALL_PASS. Verificado en
pixel: perfil con oreja estructurada, frente con labios finos, mentón
chaflanado.

## [2026-07-17] fix | Sprint GRUPO A COMPLETO — A8 arbitrado por Boris (párpado pesado + mentón aligerado), gates verdes
Cierre de A8 con VoBo del director sobre captura: (a) esclerótica
achatada (0.85→0.70) + ceja más baja/gruesa — apertura angosta = párpado
pesado/mirada dura del canon (adiós "ojos de cachorro" del juez fresco);
(b) bloque del mentón −13mm de profundidad recortados por la ESPALDA (la
punta frontal calibrada y el canon del mentón no se movieron; la
proporción subió a 7.36 cabezas). Gates ALL_PASS. Con esto el GRUPO A
del sprint queda 9/9. Pendientes: grupo B (bisel/malla — técnica nueva)
y grupo C (re-medición con juez canónico único).

## [2026-07-17] fix | Sprint de ajustes GRUPO A ejecutado (A1-A7, A9) — queda A8 (arbitraje de cara) para Boris
Lote de calibración sobre `character_rig.gd` + verificación por captura:
**A1 ✓** anillo cian del cuello aetherborn muerto (rim 0.28→0.24 + el
surco supraclavicular cerrado por A6); **A2 ✓** panza de peso máximo
calibrada (abdomen z 0.26→0.22, lleno pero tenso); **A3 ✓ SIN CAMBIO,
por diseño** — la cintura escapular no escala con el build porque los
pivotes de brazo (SHOULDER_X) tampoco: la corpulencia del Vanguard la
ponen torso+extremidades, verificado coherente en `rig_arch_vanguard`;
**A4 ✓** espalda con pendiente ÚNICA continua (trap_back más ancha/
afuera, tope de deltoide 1.08→1.02 — los escalones trap/delt/brazo se
fundieron); **A5 ✓** cintura frontal más honda (fondo 0.078→0.071,
apunta al ~77% del hombro de la lámina); **A6 ✓** streaks crema del pec
y divot "moneda" cerrados (chest_mass +6mm, pec z −3mm); **A7 ✓** seam
de muñeca (taper −2mm) y slivers del pulgar (apertura 0.44→0.40)
atenuados; **A9 ✓** nota de familia sobre `tmp_dagna` (requiere boot
con --ally). Gates `test_core`/`autotest_biomech` ALL_PASS. **A8
pendiente de arbitraje del director** (contradicción entre jueces:
ojos "cachorro" vs párpado pesado; mentón "profundo") — se decide con
capturas enfrente. Grupo B (bisel/malla) y C (re-medición) sin arrancar.

## [2026-07-17] feature | R4 CERRADA — integración verificada, batería completa ALL_PASS; la reescritura de la escultura queda COMPLETA, sigue sprint de ajustes
Batería completa en verde: `test_core`, `autotest_biomech`,
`autotest_combat`, `autotest_springboard`, `autotest_slice`,
`autotest_ui` ALL_PASS + galería `autotest_rig` completa (3 orígenes,
extremos de sliders, arcano full). Integraciones verificadas en pixel:
orejas de elfo/iron/mist bien ancladas pese al cráneo retraído de R1;
armadura ironblooded, goggles, prótesis y venas de mana en su sitio;
outfit (faja/bandolera) asienta en la cintura nueva; Dagna (signature +
build pesado) correcta. **Bug real de R4 cazado y arreglado:** las
masas nuevas de pecho/espalda/abdomen no escalaban con `_apply_build` —
en peso máximo el torso crecía y se las tragaba (el "peto" renacía,
visible en `rig_weight_max.png`). Fix estructural: reparentadas a
`torso`/`waist` (heredan el factor elíptico del build; sin skew porque
no están rotadas); el neutro del banco quedó pixel-idéntico y
weight_max ya lee pecho/panza escalados. `tmp_dagna` FAIL "sin
controller" = limitación del banco (requiere boot con --ally), no
regresión. El QA final de cuerpo completo se cortó por límite de gasto
de subagentes — el backlog del sprint se consolidó desde los residuales
documentados de los 3 QA de fase + jueces frescos + hallazgos de
integración propios (está en [[PRD-Reescritura-Escultura-Rig-v1]]).
Cierre real del loop: VoBo de Boris sobre capturas + sprint de ajustes
(pedido explícito del director al arrancar R4).

## [2026-07-17] feature | R3 CERRADA — manos 45%→70% (objetivo cumplido), extremidades 60%→68% (techo de primitivas)
Manos según el libro sobre `character_rig.gd`: palma plana (0.036 de
prof., adiós cubo-mitón) + prisma de taper nudillos→muñeca (hijo sin
descendientes — lección: escala no uniforme del padre sesga a hijos
rotados); dedos con bases abiertas y PUNTAS convergentes (rompen el
mitón de frente), curl distinto por dedo, nudillos hasta la silueta
dorsal, pulgar acortado/hundido naciendo del tenar (el end-cap
entintado murió al caer bajo el umbral de tinta), eminencia tenar;
muñeca encogida (su disco era más ancho que la palma nueva y leía
burbuja — cazado con 2 pases de diagnóstico de color tras 2 edits sin
efecto); gemelo con bulge posterior real en perfil. QA de fase (mismo
hilo, 3 rondas): manos 45→60→70 ✓ objetivo; extremidades 60→68 con
techo de primitivas confirmado (el gap restante es la bolsa de bisel/
malla: anillos codo/hombro, escalón de rodilla, transición del gemelo).
Cierre firmado por el QA condicionado a matar la isla de tinta del
dorso izquierdo (regresión de la ronda 3) — RESUELTA (-0.020→-0.0185)
y verificada en pixel. Gates ALL_PASS. Residuales LOW registrados en
[[PRD-Reescritura-Escultura-Rig-v1]]. Sigue R4 (integración).

## [2026-07-17] feature+lesson | REGLA DE TINTA adoptada (Sobel 0.30→1.00, VoBo con A/B) + la re-medición expone varianza entre jueces QA
Con VoBo explícito de Boris (excepción puntual al anti-objetivo de
shaders del PRD, decidida con A/B enfrente): `melancolia_post.gdshader`
`edge_threshold` 0.30→1.00 — el Sobel deja de entintar saltos de
profundidad <~2cm (las fronteras interiores entre masas del rig, causa
raíz del techo de R1 Y R2) y conserva silueta, pliegues hondos
(mandíbula, cuello→hombro) y clumps de follaje. A/B corrido contra 1.60
(sin ganancia en el cuerpo, más erosión de follaje — descartado) y 0.30
(baseline); sets guardados en scratchpad de sesión. Verificación visual
propia: la diagonal del pecho, los arcos de pec, las costuras del mentón
y la línea caja/abdomen MUEREN; el entorno a 30m conserva su tinta.
Gates ALL_PASS. **La re-medición formal expuso un problema de
metodología:** los hilos de los agentes QA de fase expiraron y los
agentes FRESCOS midieron rostro 48% (vs 57% del hilo de fase) y torso
38% (vs 55%), con veredictos OPUESTOS sobre la espalda ("el salto más
grande" vs "desastre"). Arbitraje visual del orquestador: la pendiente
cuello→hombro es real y continua; los escalones en los EXTREMOS del
hombro (trap/deltoide/brazo apilados) también son reales. Conclusión
registrada en [[Lecciones]]: el % de un QA-LLM solo es comparable DENTRO
del mismo hilo de agente (varianza entre jueces ±10-17 pts); un juez
fresco además no distingue tinta Sobel de banda oscura del cel. Los
números del día quedan como RANGOS honestos: R1 rostro 48-57%, R2 torso
38-55%, ambos claramente arriba de sus baselines (35% / 40%) y abajo
del objetivo 70%. Insumos priorizados de los 4 QA consolidados en
[[PRD-Reescritura-Escultura-Rig-v1]]. El ancla de verdad sigue siendo
el pixel + el VoBo del director, no el número (QA Loop fase 7).

## [2026-07-17] feature | R2 torso/hombros: 40% → 45% → 55% en 2 rondas de QA — freno: el techo de AMBAS fases es la regla de tinta (shader), decisión de Boris pendiente
Reescultura R2 sobre `character_rig.gd` (5 rondas internas): clavículas-
tubo RETIRADAS ("understated collarbones" literal de la lámina), masas
nuevas de pecho/espalda/abdomen (elipsoides-rampa — profundidad de perfil
real, la S completa), trapecio como RAMPA de caja (la pendiente cuello→
hombro es ahora SILUETA, frente y espalda), deltoide gota (adiós
hombreras-globo traseras), cintura sin escalón de radio (pellizco
continuo), pecs subidos al frente de chest_mass. Falso CRITICAL cazado:
la "correa diagonal" era en parte la SOMBRA de la regla de cabezas del
banco (movida a x=-1.05 en `tmp_anatomy.gd`) — pero el QA ronda 2
confirmó que una diagonal REAL persiste (frontera de masas trapecio/
pecho/costado). **QA imparcial (agente propio de fase, 2 rondas): 40% →
45% → 55%.** Espalda = el salto más grande (pendiente continua, sin
globos). Gates ALL_PASS en cada ronda. **Techo declarado por el QA, y es
EL MISMO de R1: el Sobel de profundidad entinta cada frontera interior
entre masas — "una ronda dedicada a la regla de tinta (dónde sí y dónde
no dibuja) probablemente mueva el % más que cualquier retoque de
masas". Esa ronda toca `melancolia_post.gdshader` = anti-objetivo del
PRD aprobado ⇒ decisión de Boris.** R2 queda en 55% commiteada y verde.

## [2026-07-17] feature | R1 CERRADA en 57% (35→40→52→57, techo de primitivas alcanzado) — VoBo de ruta de Boris, sigue R2
Boris eligió "cerrar el margen alcanzable y seguir a R2" tras el freno de
la ronda 2. Ronda 8 de código (pómulos más acostados y menos profundos —
la asimetría era el key offset de 15° de la cámara del banco; base de
nariz angostada; ramas mandibulares más altas, muesca de silueta
RESUELTA; convergencia ocular ~3.5° para la mirada en 3/4) + QA ronda 3:
**57% final, sin regresiones, techo ~60% confirmado — "no gastar más
rondas de ajuste; el costo/beneficio ya es negativo"**. Mejora neta de la
fase: +22 puntos sobre el baseline (35%→57%). Gates
`test_core`/`autotest_biomech` ALL_PASS. **Lista residual (insumo directo
de la futura pasada con técnica nueva, guardada en
[[PRD-Reescritura-Escultura-Rig-v1]]):** HIGH labios decal/malla sin
borde perimetral; HIGH máscara de tinta selectiva (criterio: ninguna
línea de tinta debe formar polígono cerrado alrededor de un rasgo); HIGH
fusión del bloque mandibular en vistas no frontales (bisel);
MEDIUM oreja con volumen (hélix) + quiebre goníaco biselado; LOW mirada
3/4 residual. Lección nueva de mecanismo en [[Lecciones]] (paredes
empinadas vs rampas bajo el Sobel de profundidad). R1 CERRADA — arranca
R2 (torso/hombros, baseline 40%).

## [2026-07-17] feature | R1 cabeza/rostro por masas: 35% → 52% en 2 rondas de QA — freno por regla del loop, decisión de Boris pendiente
Primera pasada de la reescritura ([[PRD-Reescritura-Escultura-Rig-v1]]
fase R1) sobre `character_rig.gd`: mandíbula como ESTRUCTURA de cajas
(cuerpo/mentón central `jaw_mesh` — su AABB sigue siendo el mentón que
mide el banco, slider `jaw` escala la estructura completa vía hijas — +
2 ramas + 2 facets de cuerpo), cráneo con mitad inferior retraída (la
coronilla intacta; la mandíbula pasa a dibujar la silueta de la cara
baja), boca aplastada casi al ras (adiós pico de pato), raíz de nariz
nueva, pómulos acostados sobre la normal local (rampa, no pared), ojos a
mitad de cara (libro), glint espejado (mirada alineada), tono de labio
rosa-tierra (absorbe la Fase 4a del PRD v2). `chin_boss`/`chin_bridge`/
`jaw_angle` retirados. 7 rondas internas de iteración visual con los
close-ups nuevos del banco. **QA imparcial Fable (mismo agente, 2
rondas): 35% → 40% → 52%.** Nada empeoró; el fix de mayor impacto fue la
silueta de mandíbula. Gates `test_core`/`autotest_biomech` ALL_PASS en
cada ronda. **El QA declaró techo parcial de la técnica: con primitivas
puras estima ~60% de máximo; para ≥70% hacen falta (a) labios sin borde
perimetral (textura/vertex color/decal o máscara de tinta selectiva) y
(b) aceptar o resolver el "cartón" del mentón visto desde ABAJO (ángulo
que la cámara de juego casi no usa).** Alcanzable con más rondas de
primitivas: pómulo derecho aún entintado (el izquierdo ya fundió —
técnica probada), outline de nariz, escalón cráneo-mandíbula en silueta,
mirada divergente en 3/4. Por regla de freno del [[QA Loop]] (máx 2
rondas de QA sin reportar + techo declarado ⇒ decisión del director), R1
queda EN PAUSA con el código commiteado y verde, esperando el VoBo de
Boris sobre la ruta (cerrar el margen alcanzable ~60% y seguir a R2, o
atacar primero la técnica nueva de labios/tinta selectiva).

## [2026-07-17] design+feature | Reescritura de la escultura del rig APROBADA — PRD-Reescritura-Escultura-Rig-v1 + Fase R0 (banco confiable) CERRADA
Tras el QA imparcial de rostro (35% vs [[fenotipo-humano-rostro-v1]], ver
entrada anterior del día), Boris pidió plan formal y lo aprobó: reescribir
la construcción de meshes de `character_rig.gd` desde cero, POR MASAS,
conservando el andamiaje completo (API pública de 12 funciones, pivotes
biomecánicos, metas, nombres de nodos/materiales, contrato con outfit/
signature/tests — mapeado por 3 exploraciones dedicadas). Fases R0-R4 en
[[PRD-Reescritura-Escultura-Rig-v1]] (formalizado por subagente PRD;
Fases 1-2 del [[PRD-Rework-Modelado-Personajes-v2]] quedan superseded por
R2/R3). **R0 ejecutada y cerrada:** (a) la cámara de perfil del banco
quedó EXONERADA con diagnóstico empírico — lanzas de eje (DIAG_AXIS=1 en
`tmp_anatomy.gd`) horizontales, paralelas y a longitud completa en el
render: es un 90° real sin yaw acumulado en la cadena; la percepción de
"sobre-rotada ~110-120°" del QA era otro síntoma de la geometría (nariz
sin proyección + mentón huidizo = perfil sin silueta facial). (b) 3
close-ups institucionalizados en el banco (`anatomy_closeup_chin.png`,
`anatomy_closeup_neckshoulder.png`, `anatomy_closeup_chin_front.png`) —
la lección del zoom deja de ser un recorte manual. (c) Baseline A/B
pre-reescritura guardado en
`90-Raw/reviews/baseline-pre-reescritura-rig-2026-07-17/` (14 capturas).
Siguiente: R1 (cabeza/rostro por masas, objetivo ≥70%).

## [2026-07-17] fix | CRITICAL "cuello de camisa de cartón" (Fase 1) CERRADO — el hueco real era mentón↔cuello, no mentón↔mandíbula
Plan del día: atacar el único hallazgo CRITICAL de Fase 1 primero, protocolo
[[QA Loop]] completo. (1) Higiene de entorno: Epic Games Launcher/EA
Desktop corriendo, matados antes de tocar Godot (gotcha ya documentado en
[[Lecciones]]). (2) Confirmado que `_add_outline_pass` (`character_rig.gd`)
es un no-op — el rig NO fabrica outline por-pieza; la tinta la pone el
Sobel de profundidad full-screen de `melancolia_post.gdshader`, sensible a
saltos de pocos mm entre píxeles vecinos — cualquier hueco 3D real se
entinta como borde propio, confirmando que la ruta de fix es geométrica,
no de shader. (3) Diagnóstico de color aplicado por primera vez a la
RELACIÓN entre piezas (no solo "cuál pieza", que ya se sabía) — magenta
`chin_boss`/cian `jaw_mesh`/verde `neck` en `anatomy_face_34.png` — reveló
que el hueco NO estaba entre mentón y mandíbula (esos se tocan bien de
frente) sino entre mentón y CUELLO: `chin_boss` vive bajo `head` (escala
×0.84, montada en `upper_spine`) mientras `neck` es un cilindro fijo
aparte, hijo directo de `upper_spine` — el saliente frontal del mentón no
tenía nada que lo continuara hacia la superficie lisa del cuello, salto
real de varios cm invisible en el render completo a 1280×720 pero
clarísimo en un recorte ampliado. (4) Primer intento de fix (bridge chico
solo hacia la mandíbula) pasó la propia inspección visual pero el
subagente QA imparcial (Opus, sin contexto previo) lo marcó **NO CERRADO**
con precisión quirúrgica — señaló el bloque exacto que yo no había
detectado a resolución completa. (5) Zoom manual (recortar+ampliar 3-4x
con System.Drawing) sobre esa misma zona confirmó el veredicto del QA:
había un bloque real que a tamaño natural se camufla. (6) Segundo fix:
`chin_boss` achicado (0.058×0.032×0.055 → 0.045×0.014×0.030, preservando
su punta frontal ya calibrada) + `chin_bridge` agrandada/estirada hasta
tocar la superficie real de `neck`, no solo la mitad del camino. Gates
`test_core`/`autotest_biomech` ALL_PASS. (7) Mismo subagente QA
re-invocado (`SendMessage` al `agentId`, protocolo del [[QA Loop]]) con
capturas + recortes ampliados nuevos → **CERRADO** en las 4 vistas,
resolución completa y zoom. Reportó 3 hallazgos nuevos sin bloquear el
cierre (mentón/mandíbula blandos sin masas, seam cuello-trapecio, marca
blanca tipo corchete en el cuello — posible artefacto de UV) — anotados en
[[PRD-Rework-Modelado-Personajes-v2]] Fase 1 para la próxima ronda. Detalle
completo en [[PRD-Rework-Modelado-Personajes-v2]]; lección metodológica
nueva (zoom obligatorio antes de dar un hallazgo geométrico por cerrado)
en [[Lecciones]].

## [2026-07-17] chore | Cierre de sesión — 2da higiene de contexto del día + 3 lecciones nuevas documentadas
Boris pidió cerrar sesión con énfasis explícito en documentar aprendizajes
para no repetir una sesión sin avance. Acciones: (1) [[Lecciones]] ganó 3
entradas nuevas — marcar con COLOR (no ocultar) para aislar qué primitiva
causa un defecto visual (el método de ocultar generó falsa sospecha de que
los cambios de código no se aplicaban, hasta forzar un color para
confirmarlo); una pieza validada solo de FRENTE puede fallar en otros
ángulos del turnaround sin que nadie lo note (caso `chin_boss`, 6+ rondas
de calibración, nunca antes visto en 3/4); cuando 2-3 intentos razonados
de overlap no cierran una desconexión pese a que el cálculo 3D dice que
debería funcionar, parar y documentar en vez de seguir ajustando a ciegas
(puede ser un problema de lectura de silueta/Sobel en ese ángulo, no de
overlap puro). (2) [[Current-State]] recortado por 2da vez en el mismo
día (había vuelto a crecer a ~230 líneas tras la ronda de Fase 0/1/5) —
el relato completo se movió VERBATIM a [[Current-State-Historico]]; el
archivo activo queda con SOLO el arranque de la próxima sesión (Fase 1 en
curso, QA ~40%, hallazgo abierto de `chin_boss` con sus 3 intentos
fallidos documentados para no repetirlos) + hechos vigentes. (3) Estado
real al cierre: Fase 1 (torso/hombros) sigue EN CURSO — CRITICAL
`chin_boss` sin resolver, HIGH (hombros-globo, trapecio sin pendiente,
perfil plano) y MEDIUM (cintura por línea, clavícula flotante) sin
atacar todavía. Fase 5 (cara) con VoBo en sus 6 preguntas, pendiente solo
de generar la lámina de rostro (brief 8). Nada bloqueado, nada roto —
gates ALL_PASS en el último commit de código.

## [2026-07-16] investigate | QA imparcial Fase 1 (~40% fidelidad) + "cardboard collar" rastreado hasta chin_boss — 2 intentos de fix sin éxito, revertido
Con el subagente Fable QA imparcial finalmente corrido (2 intentos previos
fallaron por límite de gasto de 5 horas, no mensual como se pensó — el
3er intento con el mismo prompt sí completó), se obtuvo el primer veredicto
medido de la Fase 1: **~40% de fidelidad torso/hombros.** Positivo: la
hipertrofia del trapecio quedó genuinamente resuelta (sin "tercera
cabeza"), la proporción global (~7.5 cabezas) aguanta, y el pipeline de
tinta/sombreado es fiel al estilo — el problema es de fusión anatómica,
no de shader. **CRITICAL #1 y #2** (torso "peto/cartón" + "costura
cuello-hombro sin soldar, bloque rectangular tipo cuello de camisa")
motivaron una investigación de campo: marcado de color pieza por pieza
(torso, cuello, trapecio, clavícula ×2, acromion, pauldron, pec, deltoide)
descartó las 8 primero — **el objeto real es `chin_boss` (el mentón)**,
que en el ángulo 3/4 (`anatomy_face_34.png`) se lee desconectado de la
mandíbula, no una pieza de hombro. Se probaron 3 variantes de overlap
(profundidad, centro Z, alto/centro Y) — **ninguna cerró la desconexión
visual** pese a que el cálculo de solape 3D indicaba que debía funcionar.
Dado que `chin_boss` ya tiene 6+ rondas de calibración validadas de frente
contra la lámina (documentadas en el propio código), se decidió NO seguir
ajustando a ciegas (Lección: no reabrir una pieza ya validada sin
evidencia clara de qué cambiar) — revertido a sus valores originales.
**Queda como hallazgo abierto, sin resolver, para decisión de Boris.**
Los demás hallazgos del QA (HIGH: hombros-globo, trapecio ahora ilegible
en el otro sentido, perfil plano sin profundidad de pecho/curva lumbar;
MEDIUM: cintura solo por línea dibujada, clavícula como trazos flotantes)
**no se atacaron todavía** — la sesión se detuvo en el hallazgo del
mentón para reportar y no seguir gastando presupuesto en ajustes sin
evidencia. Gates `test_core`/`autotest_biomech`/`test_combat`/
`autotest_slice`/`autotest_ui` ALL_PASS con el estado revertido (limpio,
sin cambios netos de comportamiento respecto al commit anterior salvo
comentarios de investigación).

## [2026-07-16] fix | Mist-Stalker reconvertido a Mistbound (raza Beast-Folk → subcultura humana) en `origins_data.gd` + `character_rig.gd`
El canon (`Las Tres Razas.md`, `Fenotipos y Creación de Personaje.md`,
ratificados 2026-07-04) establece solo 3 razas jugables — Elfos, Enanos,
Humanos — y que el kit Mist-Stalker se reinterpreta como **the Mistbound**,
subcultura humana fronteriza del Driftmarket, 100% humana (sin rasgos de
bestia). El código nunca se había actualizado: `origins_data.gd` seguía
definiendo `"miststalker"` como tercera raza completa (tag "Beast-Folk
Outlaw Rogues", `heightRange` propio) y `character_rig.gd` le generaba
orejas cónicas bestiales, una cola de 6 segmentos y mechones de pelaje
falso. Detectado por Boris en sesión paralela mientras trabajaba Fase 1 del
rework de anatomía (nota "colateral" dejada en `00-Index.md`).

**Alcance de la corrección (con 3 puntos de diseño confirmados por Boris
antes de tocar código):**
- `origins_data.gd`: `"miststalker"` → nombre "Mistbound", tag "Driftmarket
  Frontier Outlaws", lore sin beastfolk, passive renombrado "Frontier
  Instinct" (misma mecánica: velocidad en pasto/fog-sight/detección —
  confirmado que no es exclusivamente bestial, solo se renombró el lore).
  `heightRange` [0.9, 1.1] → **[0.9, 1.15]** (el más ancho de las 3 razas,
  reflejando "máxima variación individual" de Fenotipos.md — confirmado por
  Boris). Ciudad/reclutador/rival (Titan's Docks / Quill Marrow / Gilded
  Concord) se mantuvieron como la cara Mistbound específica de esta entrada
  (confirmado por Boris, consistente con "Driftfolk del Driftmarket" de Las
  Tres Razas.md).
- `character_rig.gd`: eliminada la rama completa de orejas cónicas +
  cola de 6 esferas + mechones de pelaje falso (`_fur_slot`, ~70 líneas);
  reemplazada por oreja humana neutra (mismo patrón esfera pequeña que ya
  usa Iron-Blooded). Variable `_fur_slot` eliminada por no tener ya ningún
  productor.
- `substyles.json`: silueta de "Pack-Leader" (Vanguard de este origin) ya no
  describe "beastfolk con pelt/fur bulk".
- El **id interno `"miststalker"` se mantuvo sin cambios** — renombrarlo
  arrastraría ~10 archivos de test que lo usan como string key
  (`autotest_classes.gd`, `test_core.gd`, etc.); fuera del alcance pedido.
  Los efectos visuales de clase (Pack-Leader wisp, Blood-Shaman siphon ring)
  no son bestiales y se dejaron intactos.

Gates verificados tras el cambio: `test_core.gd` ALL_PASS,
`autotest_combat.gd` ALL_PASS, `autotest_springboard.gd` ALL_PASS,
`autotest_classes.gd` (screenshots regenerados, confirmado visualmente sin
orejas/cola/pelaje bestial). Cierra la nota "colateral" del punto 5 del
[[Fase5-Cara-Propuesta-DRAFT]] en `00-Index.md`.

## [2026-07-16] fix | Trapecio corregido: Boris detectó hipertrofia ("tres cabezas") — A/B/C comparadas, elegida B
Boris revisó la captura de espalda del cierre de Fase 1.3 y marcó el
trapecio como hipertrofiado ("¿no dirías que están demasiado
hipertrofiados?") — la vista trasera mostraba literalmente "tres cabezas"
(el trapecio de cada lado, escalado Y=1.5 en la corrección anterior, leía
como un bulto redondo del mismo porte que la cabeza). **Admitido el error
de proceso:** se había escalado el trapecio para que "se viera algo" tras
confirmar que la versión original (Y=0.6) era invisible, sin medir contra
la lámina — exactamente el atajo que la regla del proyecto ("la lámina es
la autoridad de proporción") advierte evitar. Comparado directo contra la
vista de espalda de `fenotipo-humano-torso-v1.png`: ahí el trapecio es una
pendiente suave leída por sombreado, no un bulto separado. Se generaron 3
variantes en paralelo (A 1.2/0.85/0.6, B 1.0/0.7/0.55, C 1.5/0.55/0.6 — C
resultó tan prominente como A pese a ser más corta en Y, porque el ancho
mayor compensaba) con captura de espalda lado a lado (PowerShell +
System.Drawing, composición de 3 crops con etiqueta). **Boris eligió B**
por ser la que menos lee como bulto separado — sigue habiendo un quiebre
chico en la silueta, aceptado como necesario para que el Sobel entinte la
masa (el sombreado solo, como en la lámina, no se lee a esta escala —
confirmado en Fase 0). Gates ALL_PASS. Fase 1.3 se mantiene completa con
el valor corregido.

## [2026-07-16] feature | Fase 1.3 completada: acromion agregado + trapecio corrido para solapar el deltoide
A pedido de Boris ("termina el acromion y el deltoide bajo el trapecio
primero"), se completó lo que faltaba de 1.3. **Acromion:** `_box_mesh`
chico y chato por lado, semi-hundido entre el borde exterior del trapecio
y el tope del deltoide, mismo principio esfera-vs-caja ya confirmado 3
veces en Fase C. **Overlap trapecio-deltoide:** el trapecio se corrió
(centro 0.115→0.135, Y 0.30→0.285) para solaparse DIRECTO sobre el tope
del deltoide — antes quedaba demasiado medial (cerca del cuello) y apenas
tocaba el hombro. **Verificación honesta, no sobre-vendida:** en perfil el
bulto de trapecio sigue leyéndose bien; en frente/3-4 el acromion y el
ajuste de overlap no producen un quiebre claramente visible a esos
ángulos de cámara (un plano en el tope del hombro se luce más desde
arriba) — no rompió nada, pero tampoco es una mejora dramática ahí. No se
sobre-ajustó a ciegas — queda anotado para que el QA de cierre decida si
hace falta otra pasada. Gates ALL_PASS. Con esto, Fase 1.3 (cintura
escapular: clavícula S + trapecio + acromion + deltoide-bajo-trapecio)
queda completa en su primera pasada — falta el QA imparcial + VoBo de
Boris para cerrar formalmente la fase.

## [2026-07-16] feature | Fase 1 (torso/hombros) primera pasada — cintura con pellizco real, trapecio agrandado, clavícula partida en 2
Arranque de Fase 1 tras cerrar Fase 0. **1.1 medido primero** (mandato de
Boris): biacromial en `fenotipo-humano-torso-v1.png` medido por muestreo de
píxeles propio (PowerShell + System.Drawing, cuadrícula de cabezas
superpuesta sobre la regla "7.5 heads tall") — da ~2.05-2.08 cabezas,
coincide EXACTO con lo que el render actual ya produce
(`hombros_w=0.556m, 2.08 cabezas`). **Conclusión: `SHOULDER_X=0.21` no se
toca** — confirma que el problema es de masas faltantes, no de ancho. La
vista de espalda de la misma lámina muestra un trapecio real y visible,
respaldando 1.3. Hallazgo importante al leer código: el trapecio y la
clavícula YA EXISTÍAN (desde 2026-07-13/r3) — la premisa del PRD de que
"no existe bloque escapular" estaba parcialmente desactualizada. El
problema real (confirmado con captura de perfil fresca ANTES del fix: cero
bulto de trapecio visible) era que el trapecio existente tenía escala Y
demasiado chica (0.6, radio efectivo 0.06) para leer como masa propia —
subida a 1.5. Captura DESPUÉS confirma un bulto con contorno propio donde
antes había una curva lisa. Cintura (`waist`): antes copiaba EXACTO el
radio del fondo del torso (0.11=0.11, cero pellizco, torso+cintura leían
como un cilindro cónico continuo) — bajada a 0.095, primer paso real hacia
el bloqueo de 3 masas (la pelvis YA es una caja, no hacía falta crearla).
Clavícula partida en 2 cápsulas cortas con quiebre de Z (medial proa/
lateral recesada) sugiriendo la curva en S del libro de anatomía — mejora
más sutil que las otras dos, candidata a revisar en el QA de cierre.
Gates `test_core`/`autotest_biomech`/`test_combat`/`autotest_slice`/
`autotest_ui` ALL_PASS. Pendiente antes de cerrar la fase: acromion
plano + deltoide-emergiendo-del-trapecio (no implementado todavía, el
brazo sigue montado directo en `±SHOULDER_X`), QA imparcial + VoBo de
Boris con capturas frente/perfil/3-4/espalda.

## [2026-07-16] fix | Fase 0 (pipeline de tinta) ejecutada y cerrada — la premisa "personaje sin tratamiento" NO se sostuvo; fix real fue el ángulo de cámara del banco
Arranque de la ejecución real del PRD-Rework-Modelado-Personajes-v2 tras
el VoBo de Boris. Diagnóstico 0.1 (solo lectura): `tmp_anatomy.gd:115` SÍ
llama `_gs.attach_post(_cam)`; el material del rig SÍ es `toon_opaque` vía
`PipelineConfig.apply_to()` (`character_rig.gd:255`,
`toon_materials.gd:50-56`) — sin desconexión. `ink_fade_dist=70` da
fade≈1 a las distancias de estas capturas — no apaga nada de cerca.
Inspección directa (zoom ×4, PowerShell + System.Drawing ante la
ausencia de Python/ImageMagick en la máquina) de `anatomy_close.png`/
`anatomy_face.png`/`anatomy_full_front.png` confirmó que la tinta Sobel
SÍ entinta al personaje (silueta, cejas, nariz, boca, mandíbula,
pectorales, comparable en peso al entorno) y que el banding SÍ existe con
fuerza en `anatomy_full_side.png`/`anatomy_face_back.png` — **la
afirmación del QA visual previo ("no muestra línea de tinta ni acuarela
en absoluto") no se sostuvo contra el píxel real** (Lección ya escrita:
"un QA de IA parafraseando una imagen es una capa de traducción con
pérdida"). **Causa real:** las capturas "de frente" ponían la cámara
EXACTAMENTE alineada con el eje del sol de "dawn"
(`golden_scene.gd` PRESETS.dawn.sun_azim_deg=190 ≈ eje +Z del personaje)
→ superficie uniformemente iluminada sin contraste que mostrar, mismo
shader que el perfil (que sí banding bien en un ángulo distinto). La
divergencia `golden_scene.gd:98-99` (`ambient_lift`/`rim_strength`
hardcodeados para materiales de escena) vs `pipeline_config.gd:11,15` es
real pero cosmética — no afecta al personaje. **Fix aplicado:**
`tmp_anatomy.gd` — helper `_key_offset()` nuevo, rota 15° alrededor de Y
el offset de cámara en `_frame_close()`, el shot frontal del turnaround
de cabeza y `_frame_full_front()` (misma distancia/zoom, solo ángulo).
Verificado visualmente (capturas regeneradas muestran volumen/sombreado
real) + los 5 gates de la regla de sesión (`test_core`,
`autotest_biomech`, `test_combat`, `autotest_slice`, `autotest_ui`)
ALL_PASS. **Conclusión: el % de fidelidad medido hasta ahora (32→55%) NO
estaba contaminado — Fase 1 (torso/hombros) puede arrancar directo, sin
re-baseline obligatorio.** Fase 0.3 (A/B banding LINEAR) y 0.4
(re-baseline) quedan como opcionales, no bloqueantes. Fase 0.5 (aclarar
el rig de cápsulas en wilds_start/combat/city) sigue pendiente, sin
investigar.

## [2026-07-16] design | Fase 5 (cara) resuelta en las 6 preguntas abiertas — brief de lámina de rostro nuevo
Boris resolvió las 6 preguntas pendientes de [[Fase5-Cara-Propuesta-DRAFT]]
en una ronda de chat: (1) libro sí cubre cabeza/cara [ya resuelto antes],
(2) **generar lámina de rostro nueva** (no medir solo contra reviews
viejas), (3) esta fase toca SOLO la oreja neutra (las 3 variantes de
origen quedan para el frente de elfo/enano), (4) SÍ verificar extremos de
slider (`jaw`/`eyeTilt`/`eyeShape`, no solo el valor base 0.5), (5) **las 5
partes se revisan parejo** (no solo ojos/orejas — mandíbula/mentón/nariz
también, con el protocolo "verificar con captura fresca, tocar solo si
aparece defecto concreto" para no reabrir a ciegas lo ya estable), (6) el
sesgo racial de mandíbula/ojos (detectado esta misma sesión) queda FUERA
de esta fase — entra "en cuanto empecemos con enanos y elfos", con el
mecanismo ya propuesto en §1/§4 del borrador como insumo listo para ese
frente futuro. Redactado brief nuevo "8 — Cabeza/rostro close-up (Humano)"
en [[Briefs de Concept Art]], mismo formato/estilo que los briefs 1-3 ya
ratificados: turnaround de 4 vistas a la misma escala, expresión neutra,
pelo recogido para dejar oreja/mandíbula/pómulos visibles — pensado
explícitamente como lámina de MEDICIÓN (método ya usado para `SHOULDER_X`),
no de personalidad. Pendiente: generar y aprobar contra los 5 ejes del
[[Art Bible]] antes de medir proporciones.

## [2026-07-16] design | Minado completo del humano (piernas/pies/brazos/piel) + brecha racial (mandíbula/ojos) detectada + Fase 5 actualizada por subagente Fable
Boris pidió asegurar que el minado del libro de anatomía cubriera "un rework
completo del humano y todo el work del elfo y el enano", y encargó a un
subagente con modelo **Fable** actualizar el borrador de Fase 5 con temas de
orejas/ojos congruentes con el modelo 3D procedural propuesto. Minado propio
(sin subagente, mismas 7 páginas + 3 nuevas del PDF ya localizado): agregadas
a [[Principios de Anatomía 3D]] las secciones **Piernas y pies** (bloqueo,
refinamiento, proporción pie≈antebrazo) y **Brazos y antebrazos** (codo,
braquiorradial, "el brazo superior se ve corto porque el deltoides lo tapa")
de "3D male Part 01 | Basic form"; **Piel y pliegues** (breve, aplicabilidad
indirecta a malla continua vs. primitivas) de "Part 03 | Skin". Marcadas como
insumo para el frente de piernas/pies (deuda técnica ya conocida, fuera de
esta PRD), no para ejecutar ya. **Hallazgo con más impacto real:** cruzando
[[Fenotipos y Creación de Personaje]] (ratificado 2026-07-04, tabla "rango
racial: mismo slider, rangos distintos" para mandíbula/pómulos/tilt de ojos)
contra `character_rig.gd:1906-1947`, se confirmó que `jaw`/`cheek`/
`eyeTilt`/`eyeShape` usan el MISMO rango para las 3 razas — mientras que
`heightRange` (`origins_data.gd`) y la oreja (`_build_origin_features`, 4
ramas) SÍ son por-origen. Es una brecha real entre diseño ya ratificado y
código, no una hipótesis. El subagente Fable (2 intentos previos fallaron por
error 529 "Overloaded" del servidor, sin tocar el archivo; el 3er intento
completó) actualizó [[Fase5-Cara-Propuesta-DRAFT]]: sección "Brecha real
detectada" en §4 Ojos con propuesta de mecanismo concreto (`match
_origin_id` desplazando la ventana del `_lerp` antes de aplicarlo, interfaz
de slider intacta), nota equivalente en §1 Mandíbula, verificación cruzada
en §5 Orejas (las 4 ramas ya cumplen el diseño por raza — la única brecha
real es mandíbula/ojos, no oreja) y pregunta abierta nueva (#6: ¿el sesgo
racial entra en esta fase o es frente aparte, dado que es código nuevo con
validación visual propia?). De paso se detectó que `origins_data.gd` sigue
tratando a Mist-Stalker como una raza completa (Beast-Folk, lore/pasiva/
ciudad/rival propios) pese a que el diseño ya ratificó "Mistbound 100%
humanos" — se separó como tarea aparte (spawn_task), fuera del alcance de
este PRD de cara. Sigue todo como borrador, sin fusionar al PRD oficial.

## [2026-07-16] design | VoBo de Boris sobre PRD-Rework-Modelado-Personajes-v2 + Fase 5 (cara) propuesta y corrección del minado
Boris revisó los 3 puntos pendientes de ratificación del PRD y dio VoBo a
los 3: (a) orden de fases 0→4, (b) A/B de banding LINEAR autorizado en Fase
0.3, (c) criterio "medición manda" para `SHOULDER_X` en Fase 1 confirmado.
Además pidió agregar una **Fase 5 nueva** (posterior a la boca): rework
dirigido de mandíbula/ojos/nariz/mentón/orejas. Un subagente investigó y
redactó [[Fase5-Cara-Propuesta-DRAFT]] (`20-State/PRDs/`), pero reportó
—incorrectamente— que el libro de anatomía minado no cubre cabeza/cara en
absoluto. **Boris corrigió esto en el acto**, señalando los capítulos
exactos del mismo PDF: "Sculpting an archetypal figure — 3D male — Part 01
| Basic form" §10-11 (pp.94-101, bloqueo general de cráneo/cara) y
"Advanced 3D male — Part 01 | Head, neck, and face" de Djordje Nagulov
(pp.116-121, capítulo completo de cabeza/cuello/expresiones). Se localizó
el PDF en `Downloads` (383 MB, mismo archivo de la sesión anterior), se
usó `mutool` (ya instalado) para ubicar el rango exacto de páginas
(el PDF no tiene outline/marcadores — se ubicó renderizando muestras y
leyendo cabeceras de capítulo) y se minaron las 7 páginas relevantes.
Hallazgo con más señal: **principio hueso-vs-músculo** — "la cara tiene
pocos músculos que definan forma; la mitad superior de la cabeza está
definida por el hueso; error de principiante citado por el libro: levantar
el borde del hueco ocular junto con las cejas, los huesos del cráneo no se
mueven" — aplicable directo a los sliders `eyeTilt`/`eyeShape` de
`character_rig.gd`. También confirma que la regla ya aplicada en código
("hueco entre ojos = 1 ancho de ojo") viene efectivamente de este libro
(§11), no de una fuente sin documentar como se pensó en la primera pasada.
Único vacío real que persiste: el libro NO tiene proporción/estructura de
OREJA (solo una mención tangencial de animación: "las orejas suben un poco
al sonreír"). Agregado como sección nueva "Cabeza, cuello y cara" en
[[Principios de Anatomía 3D]]; [[Fase5-Cara-Propuesta-DRAFT]] corregida en
las secciones de mandíbula/ojos y en el aviso previo. Sigue como borrador
de trabajo, NO fusionada al PRD oficial — pendiente VoBo de Boris sobre 5
preguntas abiertas (lámina de rostro dedicada o no, alcance de las 4
variantes de oreja por origen, verificación de extremos de slider, etc.).

## [2026-07-16] design | PRD-Rework-Modelado-Personajes-v2 — instrucciones ejecutables compiladas
Boris pidió traducir todo el conocimiento acumulado hoy (análisis
motor-vs-ejecución, verificación de recursos sin ejecutar, minado del
libro de anatomía) en instrucciones técnicas concretas que Sonnet pueda
ejecutar para el rework completo de modelado de personajes. Compilado en
[[PRD-Rework-Modelado-Personajes-v2]] con anclas de código verificadas
por grep el mismo día (`SHOULDER_X character_rig.gd:39`, clavícula recta
`:446-448`, waist copiando el torso `:485/1289-1293`, dedos uniformes
`:681-702`, `_hair_frontier_crop hair_library.gd:319`,
`toon_ramp.tres` CONSTANT). Estructura: 5 fases con dependencias — F0
pipeline de tinta en el banco (BLOQUEANTE: los % medidos hasta hoy están
parcialmente contaminados si el banco no aplica el post completo;
incluye re-baseline y el A/B de banding LINEAR), F1 torso en 3 masas +
cintura escapular como bloque propio (clavícula en S, trapecio real,
acromion-caja; SHOULDER_X solo se mueve si la medición en píxeles de la
lámina lo pide), F2 manos (curva de convergencia + inserción en arco +
nudillos como masas puntuales + curl variable), F3 pelo (helper de loft
`Curve3D`+`SurfaceTool` ratificado desde 07-12, orden invertido
masa→mechones, anti-paralelismo adaptado al Sobel; PROHIBIDO 4º intento
con cajas/conos), F4 menores (boca color, warpaint atlas). Reglas de
sesión duras (Lecciones primero, gates + captura por fase, QA imparcial
máx. 2 rondas sin reporte, no tocar pecs/barba/ROM). **Status:
propuesto — espera VoBo de Boris en 3 puntos: orden de fases, banding
LINEAR (look global) y el criterio lámina-primero de F1.**

## [2026-07-16] lint | Higiene de contexto — Current-State.md recortado a solo el presente
Boris pidió evaluar la skill "project-context" (higiene de archivos de
contexto de Claude Code) y, al ver que su diagnóstico aplicaba directo a
este Vault, pidió implementarlo. Su regla central: el archivo que se
auto-carga en cada sesión ("status.md" en su vocabulario) debe describir
SOLO el presente, con techo ~2,500 tokens; la historia va a un archivo
append-only que no se auto-carga. **Diagnóstico confirmado con evidencia:**
[[Current-State]] había llegado a 1,197 líneas / ~21,846 tokens — puro
relato sesión-por-sesión acumulado desde el reseteo (2026-07-04), cargado
entero en CADA arranque de sesión por la regla 1 de `CLAUDE.md`. Ya no era
"estado actual", era el historial completo duplicando lo que [[LOG]] ya
guarda. **Acción:** copia verbatim de todo el contenido a
[[Current-State-Historico]] (archivo nuevo, cero pérdida de dato —
verificado por copia exacta antes de tocar el original), luego
`Current-State.md` se recortó a: el bloque vigente de "ARRANQUE DE LA
PRÓXIMA SESIÓN" (con los hallazgos #0/#0.5/#0.6 de hoy) + una sección
nueva "Hechos vigentes" (branch, motor, bloqueos, deuda técnica, riesgos
abiertos) + punteros a [[LOG]] y [[Current-State-Historico]]. Resultado:
~2,211 tokens (90% menos). Regla nueva documentada en `SCHEMA.md` §7 punto
1 para que no vuelva a inflarse: lo que deja de ser "lo que sigue" se
mueve, no se acumula. **No se instaló la skill ni su script
`check_context.py`** (requiere Python real, no instalado en esta máquina;
la adaptación del script queda como follow-up opcional, no bloqueante).

## [2026-07-16] ingest | Minado de "Anatomy for 3D Artists" — Principios de Anatomía 3D
Boris consiguió un libro (PDF de 366 MB, copia personal, NUNCA copiado al
repo) sobre anatomía para modelado 3D y pidió revisarlo completo en modo
automático. El PDF excedía el límite de extracción de texto (100 MB) por
ser un escaneo de imagen por página a resolución de impresión —
**se instaló `mutool` (MuPDF, vía winget, autorizado por Boris)** para
re-renderizar las 157 páginas a JPEG legible (~1.5-2 MB c/u) sin tocar el
archivo original. 5 subagentes en paralelo (30 páginas c/u) leyeron el
libro completo y reportaron principios en su propia síntesis (disciplina
de copyright: sin transcribir texto ni reproducir imágenes). Compilado en
[[Principios de Anatomía 3D]] (`10-Knowledge/`), cruzado contra
[[Lecciones]] y las prioridades abiertas del rework de fenotipo.
Hallazgos con más señal: **torso** se bloquea en 3 masas (caja torácica
2/3 + cintura deformable + pelvis 1/3, NO un cilindro continuo) con la
cintura escapular como bloque separado y articulado — insumo directo para
reabrir `SHOULDER_X`; **manos** tienen un sistema de proporción por
mitades sucesivas + los dedos NUNCA rectos (curvan convergiendo al medio)
— explica el síntoma "tabla plana"; **pelo** se bloquea como masa
completa primero, mechones individuales al final, con variación
deliberada anti-paralelismo entre mechones vecinos — probable causa real
de los "2-3 lóbulos fundidos". Nota de fricción resuelta en la página: la
recomendación del libro de "transiciones suaves" en pelo no aplica igual
en un pipeline de línea de tinta Sobel (que necesita escalones de
profundidad REALES para entintar mechones como trazos distintos) — se
dejó explícito para no copiarlo ciego. **Nada de esto se aplicó todavía
en código** — es conocimiento compilado, pendiente de ejecución cuando
se retome `SHOULDER_X`/manos/pelo.

## [2026-07-16] ingest | Quinta ronda de plugins — "Godot AI Builder" (framework + 9 skills) descartado
Boris encontró `github.com/HubDev-AI/godot-ai-builder` (plugin de Claude
Code + addon de editor Godot para generar juegos completos desde
prompts) y pidió evaluarlo, primero como framework completo y luego
9 skills sueltas que propuso como candidatas (`godot-builder`,
`godot-director` +Opus orquestando, `godot-polish`, `godot-scene-arch`,
`godot-player`, `godot-enemies`, `godot-physics`, `godot-effects`,
`godot-assets`). **Framework completo: descartado** — sidecar Node.js
(mismo criterio que ya rechazó `godot-ai`), exige el editor de Godot
abierto (mismo costo ya marcado contraindicado para el spike de
Beckett, sin correr todavía), `godot_install_addon` instala addons de
forma autónoma (opuesto a la disciplina de 4 rondas de evaluación
manual), y su protocolo de 6 fases compite con el SCHEMA/Vault ya
funcionando. **Las 9 skills: descartadas en su mayoría por un hallazgo
de fondo, no solo de estilo** — zip extraído a scratchpad (no
instalado) y verificado con grep directo: la mayoría asume Godot
**2D** (`CharacterBody2D`/`move_and_slide()`, `_draw()`, shaders
`canvas_item`), y Aether Bound es 100% 3D con física analítica propia
— choque de dimensión, no de arquitectura de juego. Único ítem
rescatable: el Audio Manager Pattern de `godot-effects` (pool de
`AudioStreamPlayer`), a confirmar contra `godot/autoload/` antes de
portar. `godot-director` aporta solo 4 reglas sueltas de higiene
GDScript como checklist, no su protocolo. Registrado como 5ª ronda en
`90-Raw/research/Plugin-Evaluation-2026-07-11.md`. Nada instalado.

## [2026-07-16] ingest | Cuarta ronda de plugins — skill "Godot-Claude-Skills" evaluado y descartado
Boris encontró y subió un skill de Claude Code para Godot
(`Randroids-Dojo/Godot-Claude-Skills`, deprecated, ahora en el
marketplace `Randroids-Dojo/skills`) pidiendo evaluación antes de
instalar. Trae GdUnit4 (testing GDScript dentro de Godot) + PlayGodot
(automatización tipo Playwright, requiere compilar un FORK CUSTOM del
motor) + export web/Vercel/CI. **PlayGodot descartado**: mismo
anti-patrón ya rechazado con LimboAI (toolchain de compilación
injustificable) pero peor — reemplaza el binario del motor, no un
addon; además duplica 1:1 lo que ya cubre Beckett MCP sin exigir
compilar nada. **GdUnit4 no se adopta completo**: el harness propio de
tests ya funciona y tiene 15+ lecciones específicas pagadas; único valor
real detectado es un spike de 30 min para verificar si su runner
registra autoloads en headless (limitación real y documentada de
`--headless --script`, ver [[Lecciones]]) — no urgente, no bloqueante.
Export web/CI: no aplica a la fase actual (desktop, sin `gh`
autenticado). Registrado como 4ª ronda en
`90-Raw/research/Plugin-Evaluation-2026-07-11.md`. Nada instalado.

## [2026-07-16] ingest | Catálogo Técnico Godot — verificación de campo + huecos nuevos
Boris pidió revisar TODAS las librerías/técnicas de Godot y compilarlas al
Vault con prioridad de uso, para conocer mejor la herramienta de trabajo
tras el análisis de la sesión anterior. 2 subagentes: uno verificó en
código (grep directo, no memoria) el estado real de los 5 recursos de
[[Propuesta-Recursos-de-Modelado]] (ratificada 2026-07-12) — **confirmado:
ninguno de los 5 está ejecutado en el personaje** (`character_rig.gd`
sigue en 0 usos de `SurfaceTool`/`Curve3D`/triplanar; `toon_ramp.tres`
sigue en `interpolation_mode=CONSTANT`, la causa exacta del banding duro
que un benchmark ya había señalado). El otro subagente investigó con web
search el ecosistema Godot 4.6 2026 buscando huecos no cubiertos por
`Plugin-Evaluation-2026-07-11.md`: encontró 2 cosas nuevas de valor real —
**`CompositorEffect`** (API nativa 4.3+ para saldar la deuda del post
manual de `golden_scene.gd:657`, con `PPMagic` como referencia Sobel+
Kuwahara casi 1:1) y el mecanismo técnico concreto para la "vista-esqueleto
de debug" ya pedida (`ImmediateMesh` en el banco, más simple que un
`EditorNode3DGizmoPlugin` completo). Confirmó con evidencia que NO vale
la pena: CSG en runtime, compute shaders sin cuello de botella real,
shaders de acuarela genéricos de comunidad, ningún addon nuevo de
"humanoide procedural", ningún plugin de pelo maduro, y que Beckett
sigue ganando sobre otros MCP servers 2026. Compilado en
[[Catálogo Técnico Godot]] (nueva página, `10-Knowledge/`), sin duplicar
los 2 documentos de investigación previos. **Conclusión operativa: antes
de cualquier técnica nueva, ejecutar el Tier 0 (loft/banding/triplanar/
gradientes/gizmo de debug) — ya ratificado desde 07-12 y nunca tocado.**

## [2026-07-16] research | Análisis técnico + QA visual: ¿motor o ejecución? ¿Ghibli o Art Bible?
Boris, honesto sobre el techo de ~50% de fidelidad o menos, pidió correr
2 subagentes en paralelo (uno técnico leyendo shaders/pipeline sin ver
estética, uno de QA visual mirando renders vs láminas RAW y benchmarks
de estilo sin ver código) para saber si el techo es del motor Godot o de
la habilidad de ejecución del equipo, y si convendría pivotar de
"Melancolía Gráfica" a un estilo tipo Ghibli. **Veredicto convergente de
ambos: no es el motor (Forward+ soporta bien el pipeline; las 4 capas de
`melancolia_post.gdshader` están completas y wireadas), y no conviene
Ghibli** (sería barato en uniforms pero quitaría la línea Sobel que hoy
disfraza la crudeza de las primitivas procedurales del personaje — el
entorno del propio juego ya logra el look objetivo, prueba de que el
pipeline funciona). **Hallazgo nuevo y accionable:** el QA visual detectó
que los renders `anatomy_*.png` (banco `tmp_anatomy.gd`) no muestran
línea de tinta/acuarela — se leen como PBR/plástico genérico — mientras
el entorno (`wilds_start/combat/city`) sí la muestra con el mismo
pipeline; posible desconexión entre `attach_post`/`PipelineConfig` y la
escena de `tmp_anatomy.gd`. Esto puede estar contaminando la medición de
% de fidelidad de toda la ventana `feat/c6-anatomy-rework` (32→55%) — se
registra como prioridad #0 de la próxima sesión en [[Current-State]],
antes de reabrir `SHOULDER_X`. Hallazgo secundario sin investigar: los
renders de gameplay (`wilds_start/combat/city`) muestran un rig de
personaje distinto y más primitivo (cápsulas sin cara) que los renders
`anatomy_*` — sin confirmar si es placeholder intencional o
desincronización real entre bancos. Sesión de solo análisis, sin cambios
de código.

## [2026-07-14] ratificación | Boris autoriza reabrir SHOULDER_X/proporciones de hombro
Al preguntarle qué decisión quedaba pendiente antes de cerrar, Boris pidió
el contexto de la silueta de torso/hombros (mayor punto de apalancamiento
según el QA de la ronda 55%) y **autorizó reabrir `SHOULDER_X`** — el
pivote que varios PRDs venían dejando explícitamente como "no tocar sin
confirmación de Boris" por el precedente de 2026-07-13 (una review vieja
lo fosilizó +30% contradiciendo la lámina). Con esto el punto 1 del
arranque de la próxima sesión pasa de "decisión pendiente" a "autorizado,
ejecutar" — con la salvedad ya anotada de medir la lámina en píxeles antes
de mover el número, mismo método que la vez que se detectó el error
anterior.

## [2026-07-14] state | Cierre de sesión — rutina §7 de SCHEMA ejecutada
Sesión larga en `feat/c6-anatomy-rework`: PRD Rework Fenotipo (13 puntos,
32%→42%), 2 rondas de fixes dirigidos (42%→45%→49%), PRD Geometría Nueva
ratificado y ejecutado (pelo/torso/manos/boca, 49%→55%), y PRD Warpaint
Personalizable (bug de doble-dibujo corregido + 3 estilos curados).
Checklist de cierre ([[SCHEMA]] §7): (1) [[Current-State]] con bloque
ARRANQUE DE LA PRÓXIMA SESIÓN fresco al tope, consolidando las 5
prioridades siguientes en orden de impacto; (2) LOG con una entrada por
operación (9 entradas esta sesión); (3) [[00-Index]] al día con los 3 PRDs
nuevos; (4) [[Lecciones]] — 3 lecciones nuevas pagadas hoy: lookup por
"último hijo" es frágil ante builds que agregan nodos después (bug real de
producción, no solo de banco), una asignación estática se puede borrar
sola si existe un sistema de settle/follow por frame, y un array de datos
compartido entre UI y sistema técnico puede tener longitudes distintas
(no asumir "índice inválido" sin grep completo) — más un refuerzo de la
lección de auditar contra la lámina, extendida a paráfrasis de QA de IA;
(5) working tree limpio, commits descriptivos, push pendiente de este
mismo cierre; (6) todo lo reportado como terminado tiene gate verde o
captura — nada se marcó "listo" sin evidencia.

## [2026-07-14] fix | Warpaint personalizable — bug de doble-dibujo corregido, 3 estilos reales curados
Boris aclaró que "personalizable" no es exponer el slider existente — cada
estilo tiene que verse REALMENTE distinto y con buena pinta antes de que
la elección del jugador tenga sentido. Al investigar se encontró un bug
real: `_face_mark` (la "V" geométrica de Rework Fenotipo ronda 3) se
dibujaba para CUALQUIER `warpaint_idx>0`, tapando los 5 patrones propios
del atlas (`warpaint_atlas.gd`) — ningún índice era visualmente distinto
de los demás. Corregido: la "V" ahora es exclusiva de `warpaint_idx==6`
("Scout Marks"). `WARPAINTS` en `phenotype_data.gd` ganó esa 7ª entrada
(existía en el atlas/geometría pero nunca estuvo expuesta como opción).
Banco nuevo `tests/tmp_warpaint_gallery.gd` renderiza los 6 estilos
aislados para evaluarlos — **3 con buena pinta (Hexbrand: glifo sutil en
la frente; Eye of Ash: banda tipo antifaz, bold; Scout Marks: la "V",
la más pulida) + None = 4 opciones, cumple el mínimo pedido.** 3 rotos o
débiles: **Slash Crimson** (rayas verticales tipo camuflaje, probable
distorsión de UV cerca de la ceja), **Tribal Tide** (invisible de frente,
confirmado con zoom — roto, no solo débil), **Jagged Crown** (línea
delgada casi tapada por el flequillo nuevo). Detalle completo con tabla
y capturas en [[PRD-Warpaint-Personalizable]]. **Pendiente, fuera de esta
sesión:** rework de las 3 funciones de atlas rotas (`_draw_pattern` casos
1/3/5) o reemplazo por patrones geométricos nuevos; la UI de elección en
creación de personaje sigue siendo Fase 4. QA de regresión
(`test_core`/`test_combat`) ALL_PASS.

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

## [2026-07-23] design/narrative | COMPACTACIÓN + BRIEFS E3 × 4 FINALES — Speck redireccionamiento cierre

**Contexto:** Sesión anterior completó E1 Warden concept (NB Pro, ratificado). 
Esta sesión: compactación de [[Briefs de Concept Art]] + refinamiento narrativo 
de transformación de Speck en clímax.

**Refinamiento narrativo (crítico):**
- **Cambio:** Fragmento de la Verdad activa en The First Wound → Speck reacciona 
involuntariamente (hive mind forzado). NO es decisión de Speck; es trigger del dispositivo.
- **PERO:** En finales donde Speck vive (F1 Guided Molt, F4 Warden's Choice), ella 
asume su destino con **gracia divina**. No permanece víctima circunstancial. Es 
anciana Warden aceptando su rol milenario.
- **Implicación:** E1 → E3 (jade → rojo God-Core) es involuntario, pero Speck elige 
su rol post-transformación. En F2/F3 (muere/encadena), esa agencia le es robada.

**Briefs completados:**
- **5a — E1 Warden (ratificado):** especificación vieja reescrita con specs finales 
de imagen (jade pálido translúcido, orejas pétalos Opción 3, runas oro brillante, 
patas esmeralda pálido, seams aether uniforme). Archivo: 
`speck-estadio1-warden-crisalis-v1.png` LOCKED.
- **5b — E2 (descartado):** Decisión de saltear E2. Zorro → E1 (descubrimiento 
silencioso) → E3 (clímax involuntario).
- **5c.1 — E3 Final 1 (The Guided Molt):** Criatura viva, asume rol sanadora, 
luz cálida + propósito, gracia divina.
- **5c.2 — E3 Final 2 (The Long Winter):** God-Core muerto/dormido, monumento 
frío, víctima.
- **5c.3 — E3 Final 3 (The Conqueror's Clause):** Criatura viva encadenada, 
prisionera, trauma, víctima de tu voluntad.
- **5c.4 — E3 Final 4 (The Warden's Choice):** God-Core vivo consciente, calcificada 
en paz, majestuosa, libre, elegida.
- **Forma Shapeshifteada (zorro):** Brief completado. Zorro 1.5× endémico, glitches 
sutiles (seams teal, pata cristalina, ojos facetados, patrones geométricos), 
imperfección legible.

**Archivos actualizados:**
- `[[Speck.md]]` — Sección "Un estadio de revelación" + "Tres capas de verdad" 
reescritas. Narrativa transversal: transformación involuntaria → asunción de destino 
(F1/F4) vs. agencia robada (F2/F3).
- `[[Briefs de Concept Art.md]]` — §5 completo: E1 (locked) · E2 (descartado) · 
E3×4 finales (briefs ratificados) · Forma zorro (brief completado).

**Lecciones narrativas:**
1. Involuntaridad + dignidad = tragedia griega. Speck no elige despertar, pero 
elige cómo vivir después.
2. Los 4 finales no varían solo en gameplay sino en agencia de Speck: F1/F4 la 
dejan elegir; F2/F3 la despojans.
3. E3 como God-Core literal (no solo criatura) añade peso ontológico a F2/F4 — 
es transformación existencial, no visual.

**Pendiente:**
- E3 concept art generación (si Boris lo pide) — tenemos 4 briefs listos.
- Forma zorro concept art generación (si Boris lo pide) — brief completado.
- E3 evaluación contra specs cuando regrese art.

**Checkpoint:** Barrido de [[Briefs de Concept Art]] completado. [[Speck.md]] 
narrativamente coherente. [[Current-State.md]] y [[LOG.md]] actualizados.

## [2026-07-23] production/art | FINALES + GOLDEN SCENES COMPLETADOS — sesión NB Pro cierre

**Contexto:** Sesión anterior completó briefs de E3 para 4 finales + 2 keyframes adicionales. Esta sesión: generación completa en NB Pro de todos los assets.

**FINALES SPECK E3 (4 concept sheets completados):**

**Final 1 — The Guided Molt (criatura viva, propósito):**
- Asset: `Speck - Awakened Warden Form The Guided Molt`
- Status: ✅ GENERADO 2026-07-23, RATIFICADO 100%
- Especificación: Criatura cuadrúpeda, jade rojo translúcido, orejas pétalos rojo, ojos ambar cálidos + conscientes, runas oro brillantes activas, seams aether flujo cálido rojo-ámbar, postura majestuosa serena, luz dorada-ámbar de propósito
- Narrativa: Speck asume rol sanadora, acepta destino con gracia divina, ready to guide the Muda
- Evaluación: Majestuosa-serena, luz cálida vs. frío de F2/F3 perfecta

**Final 2 — The Long Winter (God-Core muerto, monumento):**
- Asset: `Speck - Imprisoned Warden Form Final 2 The Long Winter` (landscape keyframe)
- Status: ✅ GENERADO 2026-07-23, RATIFICADO 95%+
- Especificación: Landscape The First Wound cementerio (desolado, vastedad), Speck como God-Core muerto cristalizado, monumento reconocible pero inerte, ojos congelados, runas dormidas, seams dim, luz fría gris-azul funereal, grupo humano miniatura en distancia, postura mineralized exhaustion
- Narrativa: Speck muere/es entregada, víctima del clímax, agencia robada
- Evaluación: Monumento frio-muerte, solemnidad, pérdida absoluta, comunicación visual sin diálogo

**Final 3 — The Conqueror's Clause (criatura viva encadenada):**
- Asset: `Speck - Imprisoned Warden Form Final 3 Traumatized` (character sheet)
- Status: ✅ GENERADO 2026-07-23, RATIFICADO 95%+
- Especificación: Criatura cuadrúpeda (reference F1 + cadenas), God-Core rojo con cristales CRACKED/fractured, cadenas oro-bronce pesadas + mágicas constraining limbs/torso/neck, ojos hollow ambar, runas suprimidas, seams atenuados por peso, luz fría aislante, postura submission/defeat
- Narrativa: Speck prisionera de tu voluntad, traición, trauma, agencia robada
- Evaluación: Prisionería visible + peso + trauma, hollow betrayal en ojos, cadenas PESAN visualmente

**Final 4 — The Warden's Choice (God-Core vivo consciente):**
- Asset: `Speck - Ancient Warden Form Final 4 Aether Renacido` (landscape keyframe)
- Status: ✅ GENERADO 2026-07-23, RATIFICADO 100%
- Especificación: Landscape The First Wound cementerio (dawn/aurora dorada), Speck como God-Core VIVO radiante en plataforma elevada, nombre SPECK tallado en base, ojos ambar CÁLIDOS conscientes awake, runas oro brillantes activas gloriosas, seams aether flujo cálido rojo-ámbar visible, postura quiet strength calm majestic, grupo humano pequeño abajo en veneración, luz dorada-ámbar warm purpose fulfilled, monumento AND guardian viva
- Narrativa: Speck elige calcificarse en God-Core vivo, síntesis ganada, agencia restaurada, eternidad consciente
- Evaluación: 100% capstone visual del juego, contrastea F2 (fría muerte) perfectamente, inner glow cálido = paz completa

**GOLDEN SCENE KEYFRAMES (4 landscapes monumentales):**

**Rivermeet Keyframe (capital humana):**
- Asset: `Rivermeet keyframe`
- Status: ✅ GENERADO 2026-07-23, RATIFICADO 95%+
- Especificación: Ciudad fluvial golden hour (tarde/atardecer), río como protagonista (ancho, slow, glinting), terraced riverside bluffs, timber-frame architecture, cloth awnings ochre/rust, floating markets, docks, rope bridges, smoke from forges, foreground marketplace con silhouettes humanas, middle city proper ink+watercolor Sable×BotW, background bluffs silhoueta pálida aerial perspective, luz ambar bajo horizonte long warm shadows
- Narrativa: Contraste a The Wilds (vastedad solitaria), comunidad humanidad commerce pero tone melancólico idéntico (Restless spirit)
- Evaluación: Segundo golden scene landscape, establece coherencia visual ubicaciones, río realmente protagonista

**God-Core Night Keyframe (cementerio nocturno):**
- Asset: `God-Core Night keyframe`
- Status: ✅ GENERADO 2026-07-23, RATIFICADO 100%
- Especificación: Underground/highland cemetery vast, deep blue-violet starlit night (no moon), massive crystalline prismático God-Core formations justing como tombstones/sleeping giants, red crystal glowing internally DEEP SATURATED RED pulsing faintly, long geometric shadows crisp sharp (cast by red light), perspective elevada (looking DOWN at sleeping gods), foreground cores silhouetted contra own glow (backlighting perfecto), middle fade to ruby con distance, far distance absolute darkness infinito, cracked stone ground (visible catástrofe/batalla), ink grey/negro flat cel 3-4 bands, paleta greys + deep blues + RED saturado único color intenso, watercolor grain visible, Sable night palette
- Narrativa: Cemetery of ancient gods waiting dormant, no es muerte (F2) sino vigilia dormida
- Evaluación: Third golden scene landscape perfecto, composición elevada comunica "gaze upon sleeping gods", infinidad cósmica

**Lecciones técnicas de generación:**
1. Referencias imagen funcionan PERFECTO para mantener anatomía (F1 → F3 encadenada usó F1 como base)
2. Candados anti-humanoid triple explícitos necesarios para NB Pro
3. Keyframes narrativos (F2/F4 como landscape) comunican más que character sheets en clímax
4. Paleta de luz (cálida vs. fría) es comunicación emocional instantánea sin diálogo
5. Cracked/fractured crystal = trauma visible en estructura, no requiere animación

**Análisis tríada de finales:**
- F1 (Guided Molt): aceptación cálida + renovación (Muda guiada con vínculo)
- F2 (Long Winter): muerte fría + pérdida (sacrificio, agencia robada)
- F3 (Conqueror's Clause): prisión fría + traición (ownership, agencia robada)
- F4 (Warden's Choice): eternidad cálida + paz (síntesis ganada, agencia elegida)

**Visual binary tríada:**
- Warm (F1/F4) = agencia + vida = gracia divina + síntesis
- Cold (F2/F3) = victimhood = desolación + trauma
- Pero TODOS orejas pétalos + ojos amber = Speck sigue siendo Speck incluso traumatizada

**Vault actualizado:**
- [[Briefs de Concept Art]] §5 COMPLETO con 6 assets ratificados (E3 F1-F4 + Rivermeet + God-Core Night)
- [[Current-State.md]] checkpoint final: 100% Speck + 4 Golden Scenes completados
- [[Speck.md]] narrativamente coherente (transformación involuntaria + asunción destino)

**Siguiente fase:** Decisión roadmap post-NB Pro (Trailer formal? Cutscenes clímax? Banda sonora tema?) y evaluación de inversión Higgsfield/audio.

## [2026-07-24] design/QA | Ilyara re-corrida — glitch de texto RESUELTO, §10 completo 6/6

**Contexto:** Ilyara había salido con el bug de caption corrupto ("CLAIER OF DEEPLY COMPASSIONATE...") pese a usar el formato de prosa corta ya corregido. Se agregó la regla estándar "no text, no labels, no captions, no annotations, no diagram-style callouts" al negativo del prompt y se re-corrió sin más cambios.

**Resultado:** ✅ APROBADA. Cero texto/caption visible en la imagen. Silueta élfica alta y esbelta correcta, pelo plateado, vejez visible en rostro, tatuajes/marcas en antebrazos, bolsa de hierbas en cintura, paleta verde salvia + crema, acuarela Sable×BotW sin anime/PBR/neón. 🟡 nota menor: sin marcador de aether visible (no era requisito duro).

**Cierre §10 (elenco político nuevo):** 6/6 aprobados — Corwyn ✅, Maelys ✅ (mejor resultado), Tobin ✅, Isolde ✅, Threnn 🟡 (notas menores), Ilyara ✅ (tras re-corrida).

**Conclusión técnica:** confirma que el glitch de texto corrupto en NB2 es mitigable de forma confiable agregando el negativo estándar explícito, incluso cuando el formato de prosa corta por sí solo no bastó en un caso puntual.

## [2026-07-24] design/vault-hygiene | Catalogación de 90-Raw/concept sin trackear

**Contexto:** material generado en sesiones previas que ayer (sesión con Haiku) no fue reconocido/procesado quedó suelto en `90-Raw/concept/` con nombres en español/Title Case, mezclado con legacy pre-reset. Se catalogó todo en `90-Raw/concept/CATALOGO.md`.

**Resuelto y renombrado a kebab-case (categorías A-F, ~45 archivos):** gobernantes/Triune Council (§9), elenco político nuevo (§10), 9 Pivotes, Fijos (Roen/Valen/Darro), grupo Bound Five, Speck (shapeshifted/trueform/comparativas).

**Duplicado King Borran resuelto:** existían dos re-rolls de la revisión v2 ("King Borran revisado.png" y "Rey Borran revisado.png"). Por timestamp de archivo, "King Borran revisado.png" (20:49) es posterior al que recibió la nota menor de QA — es el vigente. Renombrado a `king-borran-v2.png`; el otro archivado en `_legacy/king-borran-v2-superseded.png`. Brief §9b-v2 actualizado en Briefs de Concept Art.md.

**Legacy archivado en `_legacy/`:** material confirmado pre-reset GDD v2 — "El Nido.png" (huevo/ajolotl, diseño pre-redirect de Speck), "Final 1_sacrificio_silencioso.png" y "Final 4_aether_renacido.png" (paleta gris, título/tono no coincide con Finales canon actuales), rework jpeg de Speck. Criterio: archivar, no borrar (útil como historial).

**Hallazgo — mapa maestro:** `Aether Bound universe.png` es una corrida completa del brief en `Briefs de Mapa del Mundo.md` — resuelve dudas de lore (Rivermeet = Triune Council Seat, confirma Grove of Cycles) pero con texto corrupto en varias etiquetas. Decisión: queda como referencia interna imperfecta; no se re-corre ahora. Plan documentado en la cabecera de ese brief: seguir documentando el mapa por escrito y escribir spec exhaustiva cuando el frente de worldbuilding cierre (AI o dibujo a mano de Boris).

**Hallazgo — arte de combos:** 9 archivos (Arcane Ballistics, Mobile Foundry, Skyhook, The Weaver's Net, Skipping Stone, Riposte Runner, Guided Avalanche, Warforging, Seismic Springboard + videos) son el sistema de vínculos/combos de los Pivotes por par de rol — confirmado real, no legacy, pendiente evaluación conjunta en sesión futura.

**Pendiente:** QA de las 5 ciudades/regiones sin procesar (Aethelgard/Rivermeet, Ignis Reach/Emberdeep, Stillwood/Stillspire, Mistbound Frontier, Driftmarket) lanzado con agente Haiku en background — resultado pendiente. Escenas de traición legacy (§J del catálogo) sin revisar.

Detalle completo, tabla por archivo y estado de cada categoría: [[90-Raw/concept/CATALOGO]].

## [2026-07-24] design/QA | 5 keyframes de ciudad — QA retroactivo con agente Haiku, 4/5 aprobados

Boris confirmó viabilidad de usar un agente en Haiku para QA de imágenes contra criterio de texto (lore + estilo) — resultado: 4/5 aprobados y renombrados, coherente con la calidad esperada.

- ✅ **Emberdeep** (`emberdeep-keyframe-forges-v1.png`) — excelente, excavación vertical + forjas + Aether azul.
- ✅ **The Stillspire** (`stillspire-keyframe-canopies-v1.png`) — muy buena, ciudad en copas + cascadas + Aether verde/teal.
- ✅ **Mistbound Frontier** (`mistbound-frontier-sentinel-post-v1.png`) — buena, postas defensivas + clima árido.
- 🟡 **Rivermeet** (`rivermeet-keyframe-daylight-v2.png`) — aprobada, toma diurna complementaria al golden-hour ya ratificado (§6b), no redundante.
- 🔴 **Driftmarket** — rechazada por técnica: caption de texto quemado en la imagen ("DRIFTMARKET – FLOATING MARKET..."), mismo tipo de falla que Ilyara/Kadrun v1. No se renombró, queda con nombre original. Candidata a re-corrida con la regla anti-texto ya estándar.

Integrado como §6d en Briefs de Concept Art.md. Actualizado 90-Raw/concept/CATALOGO.md.

**Decisión sobre el mapa maestro (`Aether Bound universe.png`):** Boris decide tratarlo como referencia interna imperfecta por ahora — no re-correr. Plan: seguir documentando el mapa por escrito a medida que avanza el worldbuilding, y cuando el frente cierre (meta: próxima semana), escribir una spec exhaustiva para re-generar con AI o para que Boris lo dibuje a mano. Nota de plan agregada a la cabecera de `Briefs de Mapa del Mundo.md`.

**Confirmado — arte de combos (§I del catálogo):** son el sistema real de vínculos/combos de los Pivotes (Arcane Ballistics, Skyhook, Mobile Foundry, etc.), no legacy. Pendiente de evaluación conjunta en sesión futura; no tiene doc propio en `10-Knowledge/` todavía.

**Pendiente:** escenas de traición legacy (§J del catálogo) sin revisar. Driftmarket sin re-correr.

## [2026-07-24] session/close | Cierre de sesión — migración Current-State + pendientes del lunes 27

Sesión cerrada. Current-State.md migrado (partes 7-16 → Current-State-Historico.md, Current-State reescrito y recortado). Vault limpio, check_vault 🟢 verde tras migración.

**Pendientes formalizados para lunes 27 de julio:**
1. QA de congruencia del Vault (sintaxis + semántica) con Opus
2. QA narrativo con Opus (consistencia dramática de los 9 patrones de traición, epílogos de los 4 Finales, peso de The Reckoning, impacto de Speck-Warden en fichas existentes)

Todos los demás pendientes documentados en Current-State.md §Pendientes.

## [2026-07-27] sprint/QA-reparación | 2 QAs con Opus + Fase 0 completa + Fase 1 al 78%

**QAs ejecutados con Opus:**
- QA de congruencia (sintaxis + semántica): 10 CRÍTICOS · 18 IMPORTANTES · 20 MENORES. Causa raíz: 9 fichas de Pivote + Geografía y Ciudades con `updated: 2026-07-23`, un día antes del retcon de nombres en inglés. Nunca pasaron por la retraducción.
- QA narrativo (dramática): 4 bloqueos duros identificados — ubicación de la traición (Sunken Archive vs First Wound), eje de los 4 Finales (destino de Speck vs destino del Pivote), ¿Bram traiciona?, relación Roen-Dagna faltante.

**Decisiones de Boris para el sprint:**
1. Traición: AMBOS — mecánica al salir del Archive → persecución → quiebre en First Wound.
2. Bram: NO traiciona (excepción intencional).
3. F2: partir en F2a (Speck entregada) / F2b (Speck muerta) — desbloquea el peor destino de Torgan.
4. Elder Circle: escena grupal en Grove of Cycles (Acto 2) + encuentro individual por afinidad emergente.

**Plan aprobado:** 4 fases (Opus arquitecto → Opus reescritura fichas ×3 paralelos → Sonnet propagación → Haiku lint). Referencia: `~/.claude/plans/cozy-floating-unicorn.md`.

**Fase 0 completa** (Opus 5 arquitecto narrativo):
- `Los 4 Finales.md` reescrito a 5 finales con matriz 5×3 canónica.
- `Grove of Cycles — Escena del Acto 2.md` nuevo — 3 vectores diegéticos, debate del Elder Circle con 10+ intercambios en tono pasivo-agresivo élfico, encuentro individual por afinidad emergente.
- `Geografía y Ciudades.md §ACTO 3` reescrito a 5 sub-beats.
- `Geografía y Ciudades.md §THE RECKONING` con tabla Tobin corregida (señala a fijos C1/C2/C4 según raza del Pivote real, no a Pivotes inactivos — corrección de un error mío importante que Boris identificó). Wanderer's Goggles ajustados a 40+ años (Tobin joven, no sabio).
- Higiene: "la Queen"/"el Regent"/"el Ambassador" residuales corregidos a título en español (regente, reina) o nombre propio en inglés sin artículo (Queen Ithessa, Regent Edrick).

**Fase 1 parcial (7/9 fichas + Los 9 Pivotes.md):**
- Maren ✅ (F2a/F2b desglosados, beat Warden, superlativo "la más peligrosa por cálculo puro", Rivermeet corregido)
- Torgan ✅ (aritmética unificada 55 años, cadena de mando resuelta, F2b como peor destino canónico)
- Sereth ✅ (reescritura mayor — eje movido de aritmética a manipulación pura, "conducción respetuosa" desde Royal Academy, línea canónica nueva "No te llevé a esta decisión. Te llevé a la persona que la toma.", superlativo "la traición más íntima")
- Iven ✅ (Council mintiendo sobre la promesa; F2b devastador: asentamiento muere lentamente; F1 vs F4 diferenciados por culpa vs propósito)
- Bram ✅ (reescritura mayor con canon "NO traiciona" — mecanismo del segundo agente integrado, aritmética 40 años, Mistbound Frontier en vez de "Frontera Este", único Pivote presente en Acto 3 completo)
- Lyris ✅ (Frontier High Command en vez de Stillspire como cuerpo de mando, F1/F4 diferenciados)
- Nyael ✅ (línea canónica nueva: jugador es alumno, no maestro; ejecutar→entregar viva; brazo encubierto de Royal Academy; género neutro; F4 vuelve como alumna)
- `Los 9 Pivotes.md` ✅ (fila de Bram actualizada al canon nuevo)

**Fase 1 pendiente (2/9):**
- Vekka: reescritura completa (139→~450 líneas). Agente B falló con server error después de completar Torgan.
- Dagna: reescritura mayor (242→~450, eliminar sección duplicada, agregar entrada Roen+Dagna canónica). Agente B falló antes de tocarla.

**Retos técnicos de la sesión:**
- 3 Opus 5 concurrentes rompieron el límite de sesión (5h) en el primer intento.
- Server errors mid-response en 3 lanzamientos posteriores — probable saturación del backend.
- Estrategia que funcionó: relanzar de a 2 con la Maren-Ficha completa como plantilla de referencia (aceleró y homogeneizó el output). Aun así 1 de los 2 falló al escribir Vekka+Dagna.

**Fases 2/3/4:** sin arrancar. Pendientes para sesión siguiente después de cerrar Vekka+Dagna.

## [2026-07-27] sprint/QA-reparación | Fase 1 CERRADA — Vekka + Dagna reescritas (9/9 Pivotes ratificados)

Retomo tras el cierre parcial anterior. Estrategia: 1 agente Opus 5 secuencial (no paralelo — los server errors en la sesión previa vinieron de saturación con 2-3 concurrentes). Plan enfocado guardado en `~/.claude/plans/cozy-floating-unicorn.md`.

**Vekka** (Enana Strategist — Guild Master de the Great Forging Clan):
- Reescritura completa 139 → 459 líneas siguiendo plantilla Maren.
- Bio unificada: 60 años en la forja (eliminada inconsistencia 60/80), 50 años como Guild Master, formó a Darro hace ~30 años y lo rechazó sin explicación — Darro es su "flawed forging viviente" (3 capas: respeto forzado, resentimiento, silencio nunca explicado).
- Traición REAL en el cráter: llega primero, desmonta el core central en silencio metódico, Speck viva pero inmovilizada con arnés técnico. Línea canónica *"I built you. Forgive me for finishing the job."* se dispara ahí. Roen deduce la señal (arnés técnico) desde Acto 1.
- Beat Warden en Archive: *"Los apilaron con precisión ceremonial. Sabían lo que hacían."* — respeto por otros artesanos, pero traiciona igual porque el respeto no altera el dogma.
- 5 epílogos por matriz Deber Institucional. F4: reconoce por primera vez que el gremio se equivocaba en el diagnóstico (no en el dogma) — Speck era obra en proceso, no forja mal hecha.
- Superlativo: **"la traición más precisa"** — no colisiona con las 8 restantes.

**Dagna** (Enana Vanguard — subclán vasallo Deepstone):
- Reescritura mayor 242 → 478 líneas siguiendo plantilla Maren.
- Sección duplicada "Roen y la Quiebre" ELIMINADA — el vínculo Roen+Dagna aparece ahora en una sola instancia integrada, distribuida entre "Cómo la Ve Roen" (subtexto tácito, escena "No tuve tu opción"), quiebre en el cráter, y sección dedicada en Dinámicas.
- Fechas unificadas en 10 años (contacto Great Forging Clan) + 5 años (servicio continuo con jugador). Eliminada ambigüedad "hace 6 años".
- Entrada Roen+Dagna canónica: **canoniza que es Dagna quien quiebra a Roen, no Lyris** (corrección al hallazgo del QA narrativo). Escena del escudo caído explicitada como gesto físico silencioso, no lloro dramático.
- Beat Warden propio: toca el suelo, no un cadáver — *"Los enterraron para arriba. No están descansando. Están vigilando."* Primera vez que dice algo poético.
- Traición: la única que llora en el acto, la que camina en vez de huir, la única que abraza a Speck antes de entregarla, la persecución más corta del elenco.
- 5 epílogos. F2b: renuncia al clan por primera vez en la historia del subclán Deepstone. F4: subclán la libera como acto de reconocimiento a la síntesis; vuelve al grupo.
- Grove of Cycles: encuentro individual más corto del juego con Maelys (hoja del Grove intacta en F4).
- Superlativo: **"la traición que rompe al ancla"** — solo ella hace esto.

**Estado del sprint:** Fase 0 ✅ + Fase 1 ✅ (9/9). Pendientes ordenados: Fase 2 (Sonnet 5, propagación fijos + The Reckoning + Momentos de Persona + Wanderer's Goggles reaparición), Fase 3 (Haiku 4.5, lint mecánico + renames + typos), Fase 4 (re-corrida de los 2 QAs para verificar 0 CRÍTICOS).

**Estrategia validada:** 1 agente Opus 5 a la vez → 0 server errors esta vuelta, ambas fichas al primer intento. Costo: 84k + 123k tokens = ~207k para cerrar Fase 1.

## [2026-07-27] sprint/QA-reparación | Fase 3 CERRADA — Lint mecánico Haiku (orden invertido 3→2)

Decisión previa: invertir orden original 2→3 y ejecutar Fase 3 primero. Razones: cambios mecánicos verificables con grep (barato + confiable), base limpia para Fase 2 antes de que Sonnet 5 escriba contenido nuevo.

**Ejecución:** 1 agente Haiku 4.5, 10 sub-pasos secuenciales con grep entre cada uno. Costo: ~150k tokens.

**Cambios aplicados:**
- **Rename:** `El Quinteto.md` → `The Bound Five.md` (git mv). 10 archivos con `[[El Bound Five]]` actualizados. 2 archivos con `[[El Quinteto]]` residual convertidos a `[[The Bound Five|El Quinteto]]` (alias visible).
- **Longevidad élfica:** Estructura Política:24-26 y El Mundo y la Muda:27 — "rondaban ya los 550+ años en aquel entonces" → "eran adultos jóvenes (~20-150 años) cuando ocurrió; hoy rondan los 570-700 años". Plus fix "bisabuelo" → "tatarabuelo" en línea consistente.
- **King Borran genealogía:** "nieto o bisnieto" → **tataranieto directo** (Estructura Política:122, :334; Briefs de Concept Art:463). Aritmética coherente: vida enana 200-250 años sobre 550 años del cataclismo = 4 generaciones.
- **Contradicciones de origen resueltas:**
  - Tabla Geografía y Ciudades:1077-1081 reorganizada: Bram → Rivermeet (House Thorne), Iven → Iven's Settlement (asentamiento fronterizo), Roen → sub-fila Mistbound de Aethelgard.
  - Mistbound Frontier macro-mapa (:33) y Zonas Neutras (:725-728): reescritos consistentes con §55-67 — Mistbound es tierra interior remota del oeste profundo, NO primera línea contra bestias.
- **Nombres institucionales residuales:** "Maestra del Gremio" → "Guild Master de the Great Forging Clan" (Geografía y Ciudades:96). "Gran Clan" → "the Great Forging Clan" (Briefs de Concept Art:520).
- **Typos:** deixada→dejada, assassinato→asesinato, appecia→aprecia (2), Localizé→Localicé, Misbound→Mistbound, Socópata→Sociópata, sabará→sabrá, recostruir→reconstruir, began visiting→empezó a visitar, Dargo→Darro (2 residuales que Haiku no captó, corregidos en verificación independiente).
- **Género de Speck en Darro-Ficha:** femenino uniforme (línea 307 "His name is Speck" → "Her name is Speck"; línea 212 "esto pequeño es mío" → "esta pequeña es mía").
- **Frontmatters actualizados:** El Mundo y la Muda (2026-07-04→2026-07-27), Geografía y Ciudades (2026-07-23→2026-07-27), Briefs de Concept Art (2026-07-08→2026-07-27).

**Verificación end-to-end (todos = 0):** `[[El Bound Five]]`, `[[El Quinteto]]`, `[[protocolo del silencio]]`, "rondaban ya los 550", nombres institucionales sin traducir, doble artículo (del the/al the/en el the/por el the), typos (post-corrección de Dargo). check_vault 🟢 verde.

**Fuera de scope (queda para Fase 2):** desambiguación de "el Consejo" (Triune Council vs Great Forging Clan vs consejo del clan menor — requiere juicio de contexto que Sonnet 5 lee mejor).

**Lección de proceso:** Haiku es confiable en el patrón general pero puede saltarse residuos aislados (los 2 "Dargo" en Geografía no fueron detectados por su verificación interna). La verificación grep independiente post-agente es indispensable.

**Estado del sprint:** Fase 0 ✅ + Fase 1 ✅ + Fase 3 ✅. Pendientes: Fase 2 (Sonnet 5, propagación semántica) + Fase 4 (re-corrida QAs).

## [2026-07-27] sprint/QA-reparación | Fase 2 CERRADA — Propagación semántica Sonnet 5

Última fase de contenido antes de la verificación final (Fase 4). Ejecutada por 1 agente Sonnet 5 con 7 sub-pasos secuenciales — ~300k tokens, ~10 min. Cero errores de sesión ni server.

**Correcciones críticas aplicadas:**

- **Roen-Ficha (3 fixes):**
  - Línea 157 corregida: Roen ya no "ve a través de los flashes del jugador" (contradecía canon Speck §Capa 2). Ahora *intuye* por la quietud de Speck y el silencio del jugador — canon reafirmado explícitamente en el párrafo.
  - Línea 275 corregida: Lyris ahora "repliega" a Roen (no lo quiebra). Referencia cruzada a Dagna como la única que lo rompe genuinamente.
  - Entrada canónica "Roen + Dagna" agregada a Dinámicas con el Pivote (equivalente a las 8 entradas existentes). Refleja el vínculo canonizado desde Dagna-Ficha en Fase 1: "No tuve tu opción", escena del escudo caído, resolución del hallazgo del QA narrativo original.

- **Torgan-Ficha y Lyris-Ficha:** integración de The Reckoning (0 y 1 hit previos → 5 y 4 hits post). Tobin señala a Darro erróneamente para el Pivote enano; a Valen para el elfo. Escenas breves de reacción del Pivote.

- **Valen-Ficha:** nuevas secciones Grove of Cycles (Vector A: intercede si Tether T2+) y Sunken Archive (lectura de inscripción Warden — sustituye a Sereth cuando este es Pivote).

- **Darro-Ficha:** sección The Reckoning (cuando lo señalan por error) + beat "la escena más grande de Darro" (se sienta junto a Roen post-traición de Dagna, sin palabras).

- **Speck.md:** párrafo "El Pivote como testigo natural" en §Momentos de Persona — canonizando que la traición pesa más si el jugador trató a Speck como persona.

**Desambiguación de "el Consejo" (sub-paso más grande):** ~50 hits en 17 archivos resueltos con juicio de contexto. Cero residuos ambiguos post-fase. Distribución:
- **~42 → the Triune Council** (Roen 8, Iven 12, Valen 6, Darro 5, Torgan 5, Geografía 7, Dagna-Ficha 4, Maren-Ficha 3, etc.)
- **2 → the Great Forging Clan** (Torgan epílogos)
- **8 → el consejo del clan menor de Torgan** (canon 3 eslabones de cadena de mando)
- **3 → sin cambio** (glosario Nomenclatura + "Consejo de Deepstone" ya scoped)

**Verificación end-to-end confirmada:**
- `grep -rE "\bel Consejo\b|\bdel Consejo\b" 10-Knowledge/ | grep -v "Nomenclatura\|Deepstone\|clan menor" | wc -l` = 0
- Roen "flashes" línea 157: intuye, no ve ✓
- Roen: 8 menciones de Dagna ✓
- Torgan Reckoning: 5 hits; Lyris: 4 hits ✓
- check_vault 🟢 verde (3,169 tokens de arranque)

**Nota abierta:** Sonnet flagged 2 residuos en Sereth-Ficha (línea 364-365, diálogo sobre renuncia de Roen) fuera del alcance del prompt. Verificación posterior confirma que YA no hay residuos ahí — Sonnet los resolvió pero no lo registró correctamente en el reporte.

**Estado del sprint:** Fase 0 ✅ + Fase 1 ✅ + Fase 2 ✅ + Fase 3 ✅. Único pendiente: Fase 4 (re-corrida de los 2 QAs con Opus para verificar 0 CRÍTICOS restantes).

## [2026-07-27] session/close | Cierre de sesión — sprint QA al 78% (Fases 0/1/2/3 ✅, Fase 4 pendiente)

Rutina de cierre ejecutada:
- Cross-refs residuales del rename `The Bound Five` capturados fuera de `10-Knowledge/`: `00-Index.md` (línea 30) y `20-State/Task-Board.md` (fila B2) actualizados.
- Current-State reescrito: sección "próxima sesión" simplificada — solo Fase 4 pendiente. Las 3 fases previas ya están registradas arriba en el mismo doc.
- LOG con esta entrada de cierre.

**Estado final del sprint QA:**
| Fase | Modelo | Commit | Estado |
|---|---|---|---|
| 0 (docs-fuente) | Opus 5 | 7b4dbe6 | ✅ |
| 1 (7/9 fichas) | Opus 5 ×3 paralelos | 7b4dbe6 + 379a7a4 | ✅ parcial |
| 1 (Vekka+Dagna) | Opus 5 secuencial | 51dba0c | ✅ (9/9) |
| 3 (lint mecánico) | Haiku 4.5 | 1bf1fec | ✅ |
| 2 (semántica) | Sonnet 5 | 16588b1 | ✅ |
| 4 (verificación) | Opus 5 (mañana) | — | 🔴 |

**Lecciones de proceso validadas:**
- 3 agentes Opus 5 en paralelo → server errors (backend saturado). 1 agente Opus a la vez → 0 errores.
- Maren-Ficha como plantilla de referencia acelera output y homogeneiza estilo en agentes posteriores.
- Verificación grep independiente post-agente indispensable (Haiku dejó 2 "Dargo" residuales que el reporte interno no captó).
- Sonnet 5 (Fase 2) manejó bien un solo prompt exhaustivo con 7 sub-pasos secuenciales — más eficiente que 2 agentes en paralelo para el mismo trabajo.
- Orden invertido 3→2 (Haiku antes que Sonnet) funcionó — Fase 2 escribió sobre base limpia sin necesidad de re-lint.

## [2026-07-27] concept-art/briefs | 14 briefs NB2 nuevos (§11) — item + keyframes de lugar

Batch escrito por 1 agente Haiku 4.5 (~87k tokens, ~3 min). Modelo elegido explícitamente por costo/beneficio: los briefs son texto prescriptivo con plantillas §6b/§6c/§6d/§9a-v2/§10a/§10b ya validadas — Sonnet/Opus habría sido overkill.

**Sección §11 agregada** a `Briefs de Concept Art.md` con 14 sub-briefs (los 12 originales del pendiente, con torres de guardia dividida en 11.7a/b/c por raza):

1. **11.1** — Driftmarket re-corrida (v2 sin caption quemado, regla anti-texto reforzada)
2. **11.2** — The Wanderer's Goggles (**primer item con brief propio, inaugura carpeta `90-Raw/concept/props/`** para items diegéticos futuros)
3. **11.3** — Sunken Archive interior (bóveda Warden + cadáveres calcificados + Fragmento)
4. **11.4** — The First Wound clímax jugable (atardecer, core central pulsando frecuencia jade, distinto del keyframe nocturno §6c)
5. **11.5** — Grove of Cycles interior (templo élfico Elder Circle)
6. **11.6** — Oficina de Tobin (interior íntimo, escena de The Reckoning)
7. **11.7a/b/c** — Torres de guardia por raza (Aethelgard/Ignis Reach/Stillwood Watch)
8. **11.8** — Rivermeet Triune Council Chamber (3 asientos semicírculo)
9. **11.9** — Emberdeep vertical (complemento §6d, múltiples niveles)
10. **11.10** — The Ascending Falls (Gloomvault → Stillspire, Rivendell-like)
11. **11.11** — Iven's Settlement (asentamiento moribundo por corrupción Aether)
12. **11.12** — Mistbound Frontier interior (posta defensiva — canon corregido Fase 3: tierra interior remota, NO fronterizo con The Wilds)

**Reglas transversales aplicadas y verificadas:**
- Formato prosa corta (patrón §10 con 6/6 aprobados)
- Cada sub-brief con archivo destino kebab-case (ej. `sunken-archive-interior-v1.png`)
- Cada sub-brief con **negativos específicos + estilo estándar + regla anti-texto obligatoria** al final ("no text, no labels, no captions, no annotations, no diagram-style callouts") — verificado 14/14
- Estilo maestro: hand-painted graphic novel watercolor, Sable × BotW, cel shading 3-4 bandas, paper grain
- Nombres canónicos en inglés respetados (Triune Council, Great Forging Clan, etc.)
- Cross-references al lore canónico integrados (Tobin 40+ años Goggles, cadáveres Warden calcificados, Elder Circle debate)

**Estado:** batch listo para NB2. Boris decide el orden de corrida — no todos a la vez.

**Costo del batch:** 87k tokens (Haiku). El costo real grande viene después al correr los 14 prompts en NB2 (fuera de esta sesión).

## [2026-07-27] concept-art/QA | Sunken Archive — v1 rechazada, v2 ratificada (§11.3)

Primera corrida real de los 14 briefs nuevos (§11). Resultado: 1 rechazo + 1 iteración exitosa.

**v1 (`sunken-archive-interior-v1.png`):** 🔴 rechazada. Se leyó como catacumba egipcia — momias vendadas en repisas apiladas horizontales. Rompía la identidad Warden de los cuerpos: deberían ser reconocibles como los mismos God-Cores que despiertan en el cráter del Acto 3, no una necrópolis genérica. Geometría gótica regular sin la sensación de "ángulos que no cierran" pedida en el brief. Fragmento perdido al fondo, sin ser foco dominante.

**Diagnóstico:** el brief original describía "cadáveres calcificados" de forma ambigua — no especificaba que el cristal debía emerger visiblemente de los cuerpos como marca de identidad Warden, ni que el Fragmento debía ser el foco emisivo dominante de la composición.

**v2 (`sunken-archive-interior-v2.png`):** ✅ ratificada. Brief reescrito con: cuerpos fundidos a la piedra con cristal prismático azul-jade emergiendo (mismo patrón geométrico del pelaje de Speck), brazos cruzados en formación ritual vertical, Fragmento como foco emisivo dominante que jala el ojo por el corredor, inscripciones marginales apenas visibles (siembra la capa que los Wanderer's Goggles revelarán), negativos explícitos anti-momia/anti-catacumba-egipcia/anti-repisas.

**Resultado:** resuelve el problema dramático central — identidad Warden de los cuerpos inequívoca. 🟡 **Nota menor no bloqueante:** la bóveda salió como nave gótica catedralicia simétrica en vez de "geometría alienígena que no cierra" — decorativo pero no traiciona el canon. Mismo nivel que la nota de Threnn en el elenco político. Si se re-corre: forzar asimetría en los arcos.

**Vault:** §11.3 actualizado en `Briefs de Concept Art.md` — v1 marcada SUPERADO con nota de rechazo, v2 con especificación completa + nota QA ratificada. Sigue el mismo patrón de revisiones usado en §9 (Ithessa, Kadrun) y §10 (Ilyara).

**Pendiente:** guardar `sunken-archive-interior-v2.png` en `90-Raw/concept/` (Boris tiene la imagen del lado de NB2, falta bajarla al repo).

## [2026-07-27] concept-art/QA | Grove of Cycles — ratificada sin re-corrida (§11.5)

Segunda corrida real de los 14 briefs del §11. Resultado: aprobada en el primer intento, sin necesidad de v2.

**Resultado visual:** interior de un túnel-catedral de árboles vivos entrelazados, sosteniéndose sin arquitectura construida visible. Lectura más fiel al espíritu canónico ("sigue siendo el templo que fue durante milenios") que una interpretación literal de salón con columnas — la primera reacción fue que el resultado superó la expectativa mental previa a verla.

**Contra el brief:** silencio, raíces entrelazadas, mood ceremonial-atemporal logrados con precisión. Conteo inicial de figuras del Elder Circle marcado como error (3 en vez de 4) fue corregido tras revisión de Boris — las 4 figuras sí están presentes.

**Notas menores no bloqueantes:**
- Aether verde-teal se lee como wisp/cinta localizado en vez de fluir difuso por el follaje.
- Luz salió más oliva/crema que "dorada" — dentro del rango de paleta ya establecida.
- Marcas ambiguas en ramas superiores: podría ser el "Warden script escribiéndose" pedido explícitamente en el brief, o un residuo del glitch de texto de NB2 ya conocido de sesiones anteriores. No se resolvió la ambigüedad — Boris decidió no re-correr y resolver puntualmente si hace falta en producción.

**Vault:** §11.5 actualizado con nota QA, ratificado. Sigue el mismo patrón de documentación que Sunken Archive.

**Pendiente:** guardar `grove-of-cycles-interior-v1.png` en `90-Raw/concept/`.

## [2026-07-27] concept-art/QA | Cierre del batch §11 — 14/14 briefs corridos y QA'd

Boris corrió los 14 briefs pendientes en NB2 y las 14 imágenes llegaron a `90-Raw/concept/` (2 ya QA'd en sesiones previas — Sunken Archive v2, Grove of Cycles). Se completó el QA de las 12 restantes.

**Resultado: 13/14 ratificadas, 1 con iteración exitosa (Sunken Archive, ya documentada).**

Aprobadas directo:
- **Driftmarket v2** — resuelve el caption quemado de v1, cero texto.
- **Wanderer's Goggles** — primer item con brief propio, salió excelente: latón oxidado, lentes ambar, correa de cuero desgastada, reference sheet de 4 vistas.
- **The First Wound** — core central pulsando jade, cores despertando, 5 siluetas del grupo para escala. 🟡 nota menor: cores se leen como cristales/orbes a esa distancia, no como cuerpos — coherente con la vista aérea pedida.
- **Oficina de Tobin** — ver nota de proceso abajo.
- **3 Torres de Guardia** (Aethelgard/Ignis Reach/Stillwood Watch) — las 3 con identidad racial fuerte y diferenciada; Stillwood la más lograda (silueta vertical exagerada, integración orgánica al árbol).
- **Rivermeet Council Chamber** — 3 asientos con diseño racial distinto, mármol frío institucional.
- **Emberdeep vertical** — múltiples niveles, forjas + Aether azul, complementa bien al keyframe ya ratificado en §6d.
- **Ascending Falls** — tríptico narrativo del ascenso Gloomvault→Stillspire, solución creativa no anticipada en el brief. 🟡 nota menor: puentes de piedra/madera en vez de raíz.
- **Iven's Settlement** — panorámica de declive agrícola, mood logrado con precisión.
- **Mistbound interior** — posta defensiva austera y funcional.

**Nota de proceso importante — falso rechazo corregido:** inicialmente marqué la oficina de Tobin como 🔴 rechazada por un mapa con "Driftmarket" legible en la pared, aplicando la regla anti-texto de forma demasiado literal. Boris corrigió: el texto en un objeto in-world (mapa colgado, carta, libro) es contenido diegético, no el glitch de caption/spec-sheet que la regla anti-texto fue diseñada para prevenir (el problema histórico era texto flotando SOBRE la imagen como watermark/label, no texto dentro de un objeto de la escena). **Se actualiza el criterio de QA:** la regla anti-texto aplica a artefactos de generación, no a texto narrativamente justificado. Documentado en la cabecera de §11 para futuras rondas de QA.

**Estado:** batch §11 completamente cerrado — 14/14 briefs escritos, corridos, QA'd, ratificados y guardados en el vault. Próximo frente de concept art (sin fecha fija): escenas de traición legacy, set de arte de combos, videos Higgsfield.

## [2026-07-28] sprint/QA-Fase4 | Re-corrida de los 2 QAs — cobertura incompleta confirmada

Ejecutada la Fase 4 del sprint QA: los 2 QAs re-corridos con Opus 5 en paralelo contra el vault post-sprint.

**Resultado combinado: 21 CRÍTICOS · 24 IMPORTANTES · 17 MENORES** — pero son ~8 agujeros de cobertura vistos desde dos ángulos, no 21 problemas distintos.

**Confirmado resuelto (validación limpia en ambos QAs):**
- Nomenclatura institucional en inglés (0 residuos salvo 1 en Sereth), doble artículo (0 hits), cataclismo ~550 años, longevidad élfica coherente, King Borran tataranieto (3/3), rename The Bound Five sin enlaces rotos
- **Roen+Dagna** canonizado sin fisuras en ambas fichas
- **Flashes privados** — el arreglo más limpio del sprint; las 6 fichas migradas usan el recurso "ven al jugador ver"
- **Sereth ≠ Maren** — el rework funcionó, mecanismos completamente distintos
- **Vekka y Dagna** pasaron de las fichas más pobres a estar entre las 3 mejores del vault
- **Beat Warden** presente en 6/9 fichas y no repetitivo — cada Pivote reacciona desde su oficio

**Diagnóstico del sprint anterior:** Fase 0 y Fase 3 se ejecutaron al 100%. **Fase 1 cubrió 7 de 9 fichas** — Torgan e Iven nunca se reescribieron. **Fase 2 cubrió Roen+Dagna y el Reckoning** pero nunca tocó las secciones de finales ni las tablas de dinámicas de Roen/Valen/Darro. El efecto es peor que antes del sprint: ahora los documentos-fuente afirman un canon que 4 fichas contradicen frontalmente.

**Error propio corregido:** en el resumen del QA narrativo cité como "acierto elegante" una escena de Sereth donde le hace una pregunta-sonda al jugador "con Maren delante". Boris señaló que Sereth y Maren nunca coexisten (Pivotes de celdas distintas). Verificado: es el bug de headcount C-3 en 3 lugares de la ficha de Sereth (líneas 156, 174, 396). Repetí el hallazgo del agente sin contrastarlo contra la regla de headcount que nosotros mismos fijamos.

## [2026-07-28] sprint/QA-Fase5-D | Bloque D — canon 9 Pivotes simultáneos + fix matriz + rename

Primer bloque de la Fase 5 (cierre real del sprint). Va primero porque fija el canon que los Bloques A/B/C van a citar, y hace el rename antes de que nadie escriba cross-refs al nombre viejo.

**Decisiones de Boris que habilitaron el bloque:**
1. **Segundo agente de Bram → los 9 Pivotes existen simultáneamente en el mundo.** Solo 1 conoce al jugador; los otros 8 siguen sus vidas en paralelo. Torgan como segundo agente funciona porque *existe*, no porque sea un deus ex machina.
2. Alcance de documentación: **medio** (principio + reglas de aparición).

**D1 — Canon nuevo (Opus 5, directo):**
- `Los 9 Pivotes.md`: sección nueva con el principio, la **regla de aparición** (los no-activos pueden aparecer como NPCs externos, **nunca** como miembros del Bound Five — esta es la regla que impide repetir el bug de headcount), el caso canónico Torgan/Bram, la implicación de rejugabilidad ("cada celda cambia qué vida paralela conociste"), y un pendiente abierto declarado (qué hace cada Pivote no-activo durante la partida — se define en el guión).
- `The Bound Five.md`: nota de **headcount inviolable** (5 + Speck, siempre) con puntero al canon.

**D2 — Fix de la matriz de finales (Opus 5, directo):**
- **Celda F2a / Deber Institucional** reconciliada: Dagna, Vekka y Lyris llegaron independientemente a "ascenso" donde la matriz decía "cumple sin resolución emocional". Tres fichas coincidiendo = lectura natural, no error. Nueva redacción: *"Cumple. Asciende por mecánica institucional, sin celebración — el ascenso es automático, nadie brinda."*
- **Nyael movida a Deber Institucional** en las 5 viñetas del cuerpo (F1/F2a/F2b/F3/F4). La matriz ya la ponía ahí y su ficha lo citaba así; las viñetas la tenían bajo Rechazo/Ausencia. Criterio: el arquetipo se define por **motivación** (obedece al brazo encubierto de the Royal Academy), no por **método** (la ausencia es su superlativo, no su columna).
- De paso, 2 fixes del QA: "veinte años"→"cuarenta" en el epílogo F1 de Bram (C-12), y "Stillspire"→"brazo encubierto de the Royal Academy" en F2a de Nyael (M-6).

**D3 — Rename (Haiku 4.5):**
- `git mv Los 4 Finales.md → Los 5 Finales.md`
- 29 cross-refs actualizados en 19 archivos vivos
- `LOG.md` y `Current-State-Historico.md` **deliberadamente no tocados** (append-only, SCHEMA §78) — queda 1 hit histórico esperado
- 4 conteos "4 finales" en texto corregidos (`El Mundo y la Muda`, `Geografía` ×2, `00-Index` con el split F2a/F2b explícito)

**Verificación:** 0 cross-refs viejos vivos · archivo renombrado · 0 conteos en texto · Nyael 6/6 bajo Deber Institucional, 0 bajo Rechazo/Ausencia · check_vault 🟢 verde (2,996 tokens).

**Costo:** ~10k tokens (D1+D2, directo) + 98k (D3, Haiku).

## [2026-07-28] sprint/QA-Fase5-A | Bloque A — Torgan e Iven reescritas (9/9 Pivotes migrados)

Segundo bloque de la Fase 5. Cierra el hueco de cobertura más grande del sprint anterior: las 2 fichas que Fase 1 nunca tocó. **Con esto las 9 fichas de Pivote están al canon nuevo.**

Estrategia: 1 agente Opus 5 a la vez, secuencial (la que dio 0 server errors con Vekka y Dagna). Torgan primero, luego Iven usando a Torgan como plantilla adicional.

**TORGAN (485 → 579 líneas):**
- **Acto 3 migrado** a los 5 sub-beats. Traición en el corredor de salida del Archive, ya no en el cráter. Persecución diferenciada: corre pero **se detiene tres veces a contestar** — la más conversada del elenco. En el cráter no entrega a Speck: la sostiene en el punto medio y deja decidir al jugador.
- **F2b sin suavizar** (el canon lo exigía explícitamente): se borró el "su clan recibe el cuerpo, lo honran como maestro, el Juramento fue completado". Ahora es juramento **incumplido** — ni roto ni cumplido, se le murió en las manos. El tallador baja la herramienta y se va; el altar queda con un hueco liso que generaciones después nadie sabe explicar; funeral sin recitación del Juramento; Darro no va.
- **Beat Warden** = reconoce **oficio y linaje**: el "descanso en círculo" (maestro al centro, aprendices alrededor, manos hacia adentro) y las firmas talladas bajo cada cuerpo. Saluda la piedra con la palma abierta en vez de golpearla. Diferenciado de Vekka (técnica) y Dagna (posición ritual). Tic físico canónico nuevo (pulgar recorriendo el tatuaje) que aparece exactamente 3 veces y ata el beat Warden con el clímax.
- **Aritmética unificada en 55 años**, declarada "fija, no negociable" en la biografía. Cero residuos de "sesenta años" / "treinta años libre" / "vida de 90".
- **Cadena de mando resuelta sin disputa:** la nota ya no dice "esta ficha corrige a Estructura Política". Ahora explica que el resumen es la ruta vista desde arriba (donde nace la orden) y la ficha desde abajo (donde aterriza) — el clan menor no cambia el origen, lo **oculta**. Es el diseño de "la orden se disuelve en idiomas institucionales".
- **Rechazo de Darro a versión Vekka:** Torgan conserva su rechazo a los 15 en la puerta, pero ya no es "el mismo día que Darro". Conoce el caso Darro de oídas años después, como advertencia que circula en Emberdeep (*"ser aceptado no es ser seguro"*).
- **Sección nueva — Torgan como segundo agente de la ruta Bram:** mismo juramento, misma cadena de 3 eslabones, sobre un grupo del que no forma parte y una criatura que nunca vio. **Sin los dos años de afecto que lo harían doler.** Su tesis: en su propia ruta el Juramento pelea contra el cariño y gana con esfuerzo visible; en la ruta Bram no encuentra resistencia, y ahí se ve que siempre fue un mecanismo al que el cariño solo le ponía ruido.
- Superlativo consolidado: **el juramento sin escape** — las tres puertas están cerradas (cumplir lo destruye, no cumplir lo borra, y la tercera opción es su peor final).

**IVEN (511 → 767 líneas):**
- **Acto 3 migrado** a los 5 sub-beats. **Persecución más rápida y desesperada del elenco** — la única sin una sola parada, la única con diálogo gritado a distancia; cruza por arriba lo que el grupo cruza por abajo (es acróbata, y cada minuto es un día menos para su gente). Un solo medio segundo de duda: Roen le pide un nombre y no tiene ninguno.
- **Mentira del Council explícita:** §Nota narrativa clave reescrita en términos absolutos ("FALSA, y el Council lo sabe desde el primer día"), anclada a `El Mundo y la Muda` + `Estructura Política §statu quo`, con regla de escritura para el guionista: **el Council nunca confirma la mentira en escena**. Sección nueva **§Las tres grietas** — Ilyara en el Grove, el pago-en-dinero que oye Tobin, la deducción vía Goggles — puntos donde el jugador *podría* detectar la inconsistencia sin marcador de UI. No cancelan la traición, cambian el epílogo.
- **F2b corregido frontalmente:** decía "su asentamiento recibe el remedio, vive, años después prospera". Ahora **muere lentamente durante años** — Iven entierra a todos con sus manos sabiendo que fue la variable que aceleró todo. Sin línea final.
- **F1 ≠ F4 resueltos:** F1 = la Muda era la cura, su gente vive **a pesar de él**, vive con culpa. F4 = entiende el sacrificio parcial antes que nadie, se queda como **testigo de la tercera vía**, vive con propósito. Explícito en el texto.
- **Beat Warden — el más emocional de los 9:** se cae de rodillas (única vez que su cuerpo de acróbata falla), reconoce **el duelo** (las manos cerradas una por una, los cuerpos mirando hacia adentro como su pueblo entierra), y después la segunda ola: cada God-Core del Acto 1 era una tumba profanada. **Único de los nueve que llora en escena.** El jugador lo ve por los Goggles; Iven no sabe que lo ven.
- **Superlativo con el roce contra Dagna resuelto:** Dagna es la más justificable **institucionalmente** (hay estatuto que señalar); Iven es la que **no tiene lado correcto** — no invoca sistema, señala gente, y el jugador tampoco tiene posición superior desde donde hablar. Segundo piso: el dilema ni siquiera era real.

**Verificación (ambas):** eje viejo 0 hits · F2a/F2b presentes · headcount corregido con cita a The Bound Five · sin "Muda Parcial" en F1 · traición al salir del Archive · cita a `[[Los 5 Finales]]`. check_vault 🟢 (3,645 tokens — creciendo, monitorear).

**Costo:** 152k (Torgan) + 128k (Iven) = ~280k tokens.

**Pendiente de Fase 5:** Bloque B (Roen/Valen/Darro, Sonnet 5) y Bloque C (lint final, Haiku 4.5).

## [2026-07-28] vault/higiene | Migración de Current-State + Bloques B y C documentados para retomar

Boris pidió dejar los Bloques B y C de la Fase 5 documentados como pendientes y cambiar de tema.

**Detallado en Current-State para retomar sin contexto:** ambos bloques quedaron con líneas exactas y citas textuales de los reportes de QA — qué archivo, qué línea, qué dice hoy y qué debe decir. La próxima sesión puede arrancar sin re-derivar los hallazgos.

- **Bloque B** (Sonnet 5): Roen/Valen/Darro — Bram no traiciona (3 fichas lo contradicen con cita exacta), migración al eje de 5 finales, cosmología de Valen como creencia errónea, rechazo de Darro versión Vekka, tablas de dinámicas con 6/9 entradas de raza/rol falsas, aritméticas de edad rotas en Roen y Valen.
- **Bloque C** (Haiku 4.5): headcount >5 en Lyris (8 personas)/Sereth (7 + la cena con Maren)/Nyael, sync de `Los 9 Pivotes` (líneas canónicas viejas de Sereth y Nyael), timeline (Archive Acto 3, Grove tras 3 sub-actos), Bram 40 años, "el Consejo" residual en Sereth, orientación de Mistbound, Torgan/Dagna mal ubicados en `Geografía:96`, menores.

**Higiene ejecutada:** Current-State estaba en 4,392t (+1,392 sobre techo blando). El relato completo de las fases 0-4 del sprint se migró a `Current-State-Historico.md` — ya vivía con más detalle en LOG, así que no se pierde nada. Current-State quedó en **3,322t** con estado compacto + los 2 bloques pendientes detallados (que son largos a propósito). Arranque de sesión: **3,619 tokens** 🟢.

También se limpió la sección "Próxima sesión" que seguía apuntando a Fase 4 (ya ejecutada).

## [2026-07-28] design/marketing | §12 — Key art + 3 mockups de UI (briefs escritos)

Primer batch de material de **marca y producto**, no de mundo. 4 briefs escritos directo (Opus 5) en `Briefs de Concept Art.md §12`.

**Decisiones del director:**
- Poster: enfoque **"el grupo frente a la escala del mundo"** (descartados: Speck como centro emocional, la traición como tesis visual, Speck + God-Core)
- Mockups: menú principal, creación de personaje, pantalla de Tether (descartado el HUD de exploración)

**Regla nueva de texto para mockups de UI** (canonizada en §12): los mockups necesitan texto, lo que choca con la regla anti-texto de §10. Resolución: **el título `AETHER BOUND` va como texto real** (2 palabras, alto valor de marca, NB2 lo acierta); **todo lo demás va como placeholder visual** (barras/bloques de tinta). El mockup comunica composición, jerarquía y tono — no copy final. Se mantiene la excepción diegética de §11.6 (texto que es contenido de un objeto del mundo).

**Restricción de diseño aplicada a los 3 mockups:** el vault ya tenía dos reglas de filosofía de UI que nadie había cruzado con concept art — `Art Bible` ("transición diegética, **sin UI**") y `The Bound Five` ("autónomos + un botón, **cero menús**"). Los briefs las hacen explícitas: **UI mínima, diegética y pintada** — nunca cajas de vidrio, paneles flotantes ni iconografía de MMO. Los negativos de los 3 mockups las blindan.

**Briefs:**
- **12.1 Key Art** (`marketing/key-art-poster-v1.png`, carpeta nueva) — The Bound Five de espaldas en un promontorio, First Wound como herida de luz jade en el horizonte, escala épica de silueta. Configuración canónica de referencia (arco Humano Duelist: jugador + Roen + Valen + Dagna + Darro). **Speck es la única figura que no mira al horizonte: mira al espectador.** Espacio compositivo reservado para el logo (que NO se genera aquí).
- **12.2 Menú principal** (`ui/main-menu-mockup-v1.png`, carpeta nueva) — título en serif de tinta dibujada a mano, 5 barras de placeholder para opciones, sin cajas ni bordes: el texto flota sobre la pintura como anotación en cuaderno. Speck opcional en el borde inferior.
- **12.3 Creación de personaje** (`ui/character-creation-mockup-v1.png`) — grilla 3×3 de la Matriz Raza × Rol con las 3 siluetas raciales en pose neutra comparable (8 / 4.5 / 7.5 cabezas), iconos de rol pintados a mano, celda seleccionada con mancha de acuarela en vez de borde. *"No debe sentirse como un configurador — debe sentirse como abrir un libro y elegir de quién va a ser esta historia."*
- **12.4 Pantalla de Tether** (`ui/tether-screen-mockup-v1.png`) — 5 retratos en semicírculo con Speck al centro, tiers como marcas de tinta (no barras de progreso), líneas de conexión de grosor variable con **una rota a la mitad** (sugiere el Bond vacío sin explicarlo), franja inferior con 7 espacios para los Momentos de Persona. *"Una página de diario donde alguien lleva cuenta de a quién ha dejado entrar."*

Listos para correr en NB2.

## [2026-07-28] decision/ADR-003 | 🔴 BLOQUEO: reset de desarrollo + revisión de motor

El director planteó dos movimientos: **hard/full reset de código y renders**, y **revisar la decisión de motor** (intuición de que Unity encaja mejor que Godot). Pidió opinión y registro como punto crítico bloqueante.

**Creado `ADR-003 Reset de desarrollo y motor` en estado ABIERTO — BLOQUEANTE.** Supersede parcialmente a ADR-002.

**Mi análisis registrado en el ADR:**

- **Sobre el hard reset — de acuerdo.** El código se arquitecturó para un prototipo técnico; el proyecto hoy es un juego narrativo con 9 rutas, 5 finales y un sistema donde la intimidad ES el árbol de habilidades. **Matiz crítico: reset del código, NO del conocimiento** — `Lecciones`, `Benchmark Biomecánico`, `Art Bible`, PRDs cerrados y todo `10-Knowledge/` son el activo caro; el código es lo barato de reproducir.

- **Sobre el motor — ADR-002 no está equivocado en lo que evaluó** (la golden scene probó que Godot renderiza el look, con 7-9× de margen). Pero **evaluó paisaje, no personajes animados**, y el proyecto se movió hacia donde Godot es más débil: rigging procedural (ROM por raza, foot IK tipo HZD, combos trifásicos tipo Sifu). No es casualidad que la deuda técnica abierta sea exactamente eso. Otros argumentos nuevos: consolas (Godot necesita partner externo; ADR-002 lo difirió a "producción tardía"), volumen narrativo (herramientas de branching más maduras en Unity), y el precedente directo de que **Sable se hizo en Unity**.

- **Observación sobre acoplamiento de decisiones:** si el hard reset se ejecuta, el argumento "ya tenemos código en Godot" desaparece y el costo de migrar baja casi a cero. Por eso las dos decisiones se contaminan y hay que resolverlas en orden.

- **El riesgo que ningún motor resuelve (lo más importante del análisis):** el alcance narrativo creció más rápido que la capacidad de producción. **9 Pivotes × 5 finales × 9 celdas es alcance de estudio mediano.** La pregunta de mayor valor no es "¿Unity o Godot?" sino **"¿cuál es el vertical slice mínimo que prueba que este juego funciona?"**

**Secuencia recomendada:** definir slice → definir plataforma → definir alcance v1 → elegir motor **contra el slice** (reconstruir una escena en ambos y medir tiempo real, no specs) → resetear código. En ese orden la decisión de motor casi se toma sola, igual que ADR-002 en su momento.

**Consecuencias mientras esté abierto:** ❌ no se escribe código de producción (frente C del Task-Board congelado); ✅ worldbuilding, guión, concept art, mockups de UI y diseño en papel siguen desbloqueados.

Enlazado desde `Current-State` (bloque de bloqueo activo al inicio) y `00-Index`.

## [2026-07-28] session/close | Poster V2 pasado al vault + 4 ediciones directas de Boris registradas

**Poster V2:** Boris pasó el brief actualizado (vista panorámica desde The Monolith, sin Speck) al vault él mismo como §12.2, renumerando el resto de §12 (menú→12.3, creación→12.4, Tether→12.5). Lo enriqueció con detalle de elevación, degradado bosque→volcánico hacia el este, y proporciones explícitas de las 5 figuras del grupo (2 elfos 8 cabezas, 2 humanos 7.5, 1 enano 4.5). Sin cambios necesarios de mi parte — quedó consistente con la geografía canónica.

**4 ediciones directas de Boris en Obsidian (fuera de conversación), registradas como pendientes en Current-State:**

- **`Nomenclatura.md`** — Isolde Marrow ahora tatara-tataranieta del último rey (verificar consistencia genealógica); Wanderer's Goggles se vuelven accesorio no retirable tras primer uso (verificar contra Los 5 Finales §F4). Boris dejó nota explícita pidiendo revisión de control de cambios.
- **`Speck.md`** — pelaje a rojo/naranja (con un "beige" residual, posible edición a medias), ojos facetados-naranjas + nota de que zorros normales son café-casi-negro. **Se eliminó la sección "Giro Grogu"** (memoria de especie) — sin marcar si fue intencional.
- **`The Bound Five.md`** — pregunta de sistema: diseñar bonds propios para Roen/Darro/Valen (no solo el Pivote), con mecanismo donde los 9 bonds totales sean protagonistas parejo sin importar la celda del jugador. Toca también The Tether y Bond y el Bond Vacío.
- **`Principios de Anatomía 3D.md`** — dump extenso de investigación de DOF biomecánico (hombro, cadera, columna 72 DOF, mano 21-24 DOF, trade-offs de rigging/IK/ragdolls) pendiente de reestructurar en la documentación técnica agnóstica.

**Nota de alcance:** ninguna de las 4 ediciones fue procesada esta sesión — solo verificadas, categorizadas y registradas. Es contenido/diseño real, no housekeeping de cierre.

Current-State creció a 4,007t (+1,007 sobre techo blando) por el detalle necesario para no perder las preguntas de Boris. check_vault sigue 🟢 (4,304t de arranque). Candidato a higiene en la próxima sesión si sigue creciendo.

## [2026-07-28] sprint/QA-Fase5-B | Bloque B CERRADO — propagación a Roen/Valen/Darro

**Bram no traiciona (propagación completa):** las 3 fichas de fijos (Roen, Valen, Darro) tenían la traición/rendición vieja de Bram en sus tablas de dinámica (`Roen:270`, `Valen:329`, `Darro:348`). Reescritas al beat del corredor del Archive: Bram rechaza la oferta del Council, no la acepta ni se rinde. Diálogo tomado del ya canonizado en `Bram-Ficha:356-388`. Aritmética corregida de "veinte años" a **cuarenta** en las 3 fichas.

**Migración al eje de 5 finales:** las secciones "Arco Acto 3" de Roen/Valen/Darro usaban el bloque viejo (Final 1 Perdón/Final 2 Muerte/Final 3 Encadenamiento/Final 4 Síntesis = destino del Pivote). Reescritas contra [[Los 5 Finales]] — el eje es el destino de **Speck** (F1 Guided Molt / F2a Handed Over / F2b Fallen / F3 Conqueror's Clause / F4 Warden's Choice), el Pivote como consecuencia.

**Roen:** aritmética de edad rota corregida (25+15+5 = 45, no "35-40"). Beat de traición (Archive) separado del quiebre (cráter) — antes colapsados en un solo "First Wound"; ahora dos escenas: corredor del Archive (Acto 3, donde se revela la intención del Pivote) y el cráter (donde actúa).

**Valen:** aritmética de edad estandarizada a 230 años (antes alternaba 180-250/200/250/300 en distintas menciones). **Cosmología reencuadrada como creencia errónea** (decisión de Boris): la cifra "cada 300 años" que Valen cargó toda su vida es la que enseña the Academy of Sages, sin revisión desde antes del cataclismo — Valen la desmonta en el debate del Grove of Cycles, no en su infancia. El cálculo sustantivo (God-Cores = cadáveres, Speck = llave) sigue siendo correcto; el marco temporal en que creció, no.

**Darro:** rechazo del gremio reescrito a **versión Vekka** (decisión de Boris) — fue su aprendiz ~30 años atrás, ella le enseñó 2 años, lo rechazó del programa formal en persona al tercer año sin explicar por qué. Verificado contra `Vekka-Ficha:46-90`, ya consistente. Añadida sección "Darro + Vekka" completa en dinámicas (antes trataba el encuentro como si fueran extraños). Género de Speck corregido a femenino en 2 menciones residuales.

**Tablas de dinámicas — raza/rol falsos corregidos en las 3 fichas (Roen, Valen, Darro), 7 de 9 entradas, más de las 6 reportadas en el QA original:** Bram (Duelist→**Vanguard**), Sereth (Duelist→**Strategist**), Nyael (Humana Vanguard→**Elfa Duelist**), Lyris (Enana Duelist→**Elfa Duelist**), Maren (Elfo Duelist→**Humana Strategist**), Torgan (Elfo Strategist→**Enano Duelist**), Iven (Elfo Vanguard→**Humano Duelist**). Solo Vekka y Dagna ya estaban correctas. La causa raíz: los encabezados copiaban la "celda de jugador" del formato de ficha del Pivote en vez de su raza/rol real.

**Pendiente:** re-correr los 2 QAs de Fase 4 tras cerrar Bloque C (criterio 0 CRÍTICOS) para declarar el sprint terminado. Bloque C sigue detallado en el historial de [[Current-State]] del 2026-07-28.

## [2026-07-28] sprint/QA-Fase5-C | Bloque C CERRADO — lint final, Fase 5 completa

**Headcount >5 corregido en 3 fichas.** Las escenas "El Primero" de Lyris, Sereth y Nyael listaban a los 8 Pivotes no-activos apareciendo junto al grupo ("Roen llega. Valen aparece. Maren aparece. Torgan aparece. Sereth aparece..."), violando el canon de Bloque D (el grupo son siempre 5: Jugador+Roen+Valen+Pivote activo+Darro). Recortadas a solo Roen/Valen/Darro. También corregidas dos referencias cruzadas indebidas dentro de la ficha de Sereth: "cena con Maren delante" → cena del grupo (sin nombrar a Maren, que no puede estar presente en la misma partida); "Darro no grita como con Maren" → sin la comparación cross-run.

**`Los 9 Pivotes.md` resincronizado:** la fila de Sereth citaba la línea canónica de Maren ("Millions against one...") — reemplazada por la línea real de Sereth (*"No te llevé a esta decisión. Te llevé a la persona que la toma."*). La fila de Nyael tenía una línea vieja no ratificada — reemplazada por la línea canónica actual de su ficha (*"I set traps my teacher would have waited on..."*).

**Timeline:** Sunken Archive reclasificado Acto 2→**Acto 3** en Geografía (consistente con la decisión de Boris del 2026-07-28). Grove of Cycles corregido de "dos de los tres sub-actos" a **los tres** — así cuadra el conteo de 4 God-Cores destruidos antes del Grove.

**Aritmética Bram:** "20 años de mercenario" / "cortó lazos hace 20 años" en Estructura Política §239-246 → **40 años**, consistente con el resto de la ficha.

**Sereth "el Consejo":** diálogo ambiguo con Roen ("Renunciaste al Consejo") reescrito a "Dejaste la Royal Academy" — Sereth es producto de la Royal Academy, no del Triune Council; la ambigüedad venía de Fase 2.

**Los 5 Finales / Geografía:** "cruzar el borde es F3, retroceder es F2" → desambiguado a **F2a o F2b** según si Speck llega viva o muere en el intento.

**Mistbound:** orientación unificada a **suroeste profundo** en la ficha de Bram (decía "noroeste") y en Geografía §Origen de Bram (mismo error, ambas corregidas) — consistente con las 2 menciones ya correctas en el resto de Geografía.

**Geografía §Emberdeep:96:** "Torgan y Dagna pertenecen al Clan de Forja" contradecía sus fichas — corregido a "Torgan pertenece a un clan menor; Dagna al subclán vasallo Deepstone".

**Menores:** "Roen ve las manos de Vekka temblar" (Roen-Ficha) contradice el canon de Vekka (su única grieta visible es cerrar los ojos un segundo, nunca temblar) — corregido. Fórmula "por primera vez en la historia registrada" aparecía idéntica 3 veces (Los 5 Finales/Dagna, Dagna-Ficha, Sereth-Ficha) — desduplicada en 2 de las 3 apariciones, conservada la de Dagna-Ficha como versión canónica.

**Sprint QA de reparación — Fase 5 completa (Bloques A, B, C, D cerrados).** Pendiente: re-correr los 2 QAs de Fase 4 (criterio 0 CRÍTICOS) para declarar el sprint formalmente terminado. Nota: esta corrida se hizo con el modelo Sonnet 5 de la sesión — Boris pidió Haiku vía `/model`, pero ese comando no está disponible en este entorno no interactivo; se avisó y se continuó con el modelo activo.

## [2026-07-28] sprint/QA-verificación | Re-corrida de los 2 QAs — EL SPRINT NO CIERRA (12 CRÍTICOS)

Los 2 QAs re-corridos con Opus 5 en paralelo, en frío (sin decirles qué se había arreglado, para evitar sesgo de confirmación). **Criterio de cierre = 0 CRÍTICOS. Resultado: 7 críticos de congruencia + 5 de dramática.** El sprint QA de reparación **no cierra**.

### Lo que sí quedó validado limpio (ambos QAs)

- **Los 5 epílogos × 9 fichas:** cero residuos del esquema viejo (Perdón/Muerte/Encadenamiento/Síntesis) en todo el vault. La migración de Bloques A/B funcionó.
- **Bram no traiciona:** consistente en las 5 menciones de su ficha, en `Los 9 Pivotes`, en `Los 5 Finales` y en Geografía. Aritmética de 40 años consistente en las 9 apariciones.
- **Speck femenina:** cero ocurrencias de "él/lo" en todo `10-Knowledge/`.
- **Raza/rol de los 9:** los nueve encabezados coinciden con la matriz maestra.
- **Timeline:** Sunken Archive = Acto 3 en las 9 fichas; 4 God-Cores antes del Grove; cataclismo ~550 años consistente.
- **Dramática:** los 9 Pivotes son genuinamente distintos — ninguno repite el beat de otro; los 3 enanos separados con precisión (elegí la cadena / nací en ella / soy la cadena). F2a vs F2b sostenido sin una sola contradicción en las 9 fichas. Torgan e Iven declarados listos para diálogo sin más trabajo.

### 🔴 Errores propios introducidos o no detectados en Bloques B y C

**Causa raíz de mi parte: hice correcciones a nivel de encabezado sin leer el cuerpo del texto debajo, y di archivos por cerrados tras arreglar la primera ocurrencia de un patrón sin barrer el resto del archivo.** Hallazgos que son míos, no del material previo:

- `Roen:279` — **texto que yo escribí en Bloque B** decía que el Council "le ofrece a Bram la salida — rechazar el contrato, quedarse con lo que queda de su compañía". Invertido: el Council le ofrece el *trabajo*; la salida se la da Bram rechazando. Además sus dos compañías fueron disueltas, no le queda ninguna. **Corregido.**
- `Darro:44` — **texto que yo escribí en Bloque B** presentaba el quiebre de Vekka con el Dogma como hecho biográfico previo a la campaña. Vekka nunca rompe con el Dogma en la línea base (es su identidad entera); el único quiebre ocurre en los epílogos F2b/F4. **Corregido.**
- `Roen:267` y `Darro:358,360` — corregí los encabezados de las tablas de dinámicas a la raza/rol correcta, pero dejé el cuerpo contradiciéndolos ("Dos Vanguards" para Iven que es Duelist; "dos enanos que ven diferente" y "duele viniendo de compañero enano" para Lyris que es Elfa). **Corregidos.**
- `Grove:15` — corregí el gate a "los tres sub-actos" en la línea 9 y dejé la línea 15 diciendo "el segundo sub-acto regional". Dos gates incompatibles a seis líneas de distancia. **Corregido.**
- `Bram:48` — corregí "noroeste"→"suroeste profundo" en la línea 28 y dejé la 48 con el error. **Corregido.**
- `Darro:359` — la línea de tensión con Lyris era copia literal de la entrada Valen+Lyris, y contradecía a Lyris (que no bromea). **Reescrita.**

### 🔴 CRÍTICOS de congruencia pendientes

- **C1 (BLOQUEANTE, requiere decisión de Boris) — el "segundo agente" de la ruta Bram tiene 3 versiones incompatibles.** `Los 9 Pivotes:32-38` y `Torgan:377` dicen que el segundo agente **es Torgan**, que toma a Speck él mismo. `Bram:257` dice que es **un mensajero enano anónimo** que le entrega orden sellada "a Torgan (o al enano fijo/Pivote más cercano si Torgan no está)" — ese paréntesis convertiría a **Darro** en ejecutor del Council. `Geografía:1025` dice que el mensajero "buscó específicamente a Torgan". Agravante: `Bram:261` describe al segundo agente como "no lo conocíamos, no le debíamos nada", que describe a un NPC anónimo, no a Torgan. **Nadie puede escribir la salida del Archive en la ruta Bram hasta que esto se decida.**
- **C2, C3, C4, C5, C6, C7 — corregidos en esta sesión** (ver bloque de errores propios arriba, más `Geografía:1015` que ponía a Sereth como lector por defecto en las 9 partidas, y `Vekka:459` que autorizaba explícitamente dos Pivotes en el grupo).

### 🔴 CRÍTICOS de dramática pendientes (los 5 son decisiones de diseño de Boris)

- **D1 — Roen y Darro solo tienen arco en la ruta Dagna; en las otras 8 son cámaras de eco.** Y está canonizado explícitamente ("A Roen lo rompe Dagna, no Torgan" aparece literal en Torgan, Iven y Dagna). El escudo caído de Roen y la escena más grande de Darro viven ambas en la celda Humano Duelist. Contradice `The Bound Five:68` ("la experiencia del jugador sea la misma sin importar el personaje que escoge"). **Propuesta del QA:** darles quiebre por *arquetipo* (Aritmética / Deber / Rechazo), no por Pivote — 3 versiones del escudo caído en vez de 1, ~6 escenas nuevas que salvan 7 rutas. Presupuesto sugerido: reciclar los 54 encuentros por celda de Roen/Valen/Darro, de los que el jugador ve exactamente uno.
- **D2 — F4 etiquetado "final verdadero" y los 9 Pivotes mejoran ahí.** Es el mejor final para todos los personajes, para el mundo, el único con consentimiento de Speck, y no cuesta nada. Los otros 4 dejan de ser alternativas morales y pasan a ser fracasos de ejecución. **Propuesta:** borrar la palabra "verdadero" del canon + darle a F4 un costo real que ningún otro final tenga (el propio Grove ya tiene el argumento: la cura cuesta civilizaciones).
- **D3 — Speck sigue siendo MacGuffin.** No hay una sola escena escrita donde haga algo que la vuelva querible; su personalidad está en viñetas de dirección, nunca dramatizada. Los ~7 Momentos de Persona (que son el gate de F4) están sin diseñar. Borrar el "Giro Grogu" quitó la capa de interioridad. Si el jugador no la quiere, las 5 respuestas del clímax dan igual. **Propuesta:** escribir los 7 Momentos ANTES del guión de actos, no después.
- **D4 — Dos rutas llegan al clímax sin Pivote funcional.** Bram (el segundo agente es, textual, "un traidor sin arco… función puramente mecánica" — ver C1) y Nyael (no aparece en el cráter; la ficha nunca resuelve quién lleva a Speck ahí ni cómo llega el jugador).
- **D5 — F2b se abre por pasividad (timeout) y carga los 5 mejores epílogos del material.** El jugador lo leerá como castigo por dudar, no como tragedia — y la tragedia requiere elección. **Propuesta:** que F2b tenga una elección activa que lo produzca (ej. el jugador fuerza el forcejeo y la sobrecarga del Fragmento mata a Speck), con el timeout como ruta secundaria al mismo final.

### Patrón de fondo señalado por ambos QAs

**Casi todo lo grave está fuera de las fichas de Pivote y dentro de los documentos que las citan.** `Geografía y Ciudades`, `Estructura Política` y las 3 fichas de fijos quedaron en estado pre-rework mientras las 9 fichas avanzaban. 5 de los 7 críticos de congruencia y 6 de los 14 importantes son residuo de esa asimetría. **El próximo pase debe ser de propagación hacia afuera, no de más profundidad hacia adentro.**

### Importantes/menores registrados (no corregidos aún)

14 importantes + 11 menores del QA de congruencia, con archivo:línea y cita. Los de mayor peso: aritmética de Lyris rota en 3 cifras (170/90/45 años); esencia de Lyris contradictoria en 3 lugares ("incapaz de sentir" vs. el superlativo ratificado "siente y suprime"); Sereth muriendo de viejo a los ~205 cuando los elfos viven 650-700; Nyael con 80 vs 100 años de servicio; encabezados biográficos de Vekka y Dagna que no cuadran con sus edades; `Estructura Política` con 3 residuos pre-rework (cadena de mando de Vekka, eslabones de Dagna, "Torgan y Darro rechazados juntos"); Valen en femenino en `Vekka:401`; voseo argentino en `Lyris:82`. Del QA dramático: colisión del superlativo "la más fría" entre Lyris y Vekka; **Lyris es la ficha más débil por margen grande y necesita rework mayor**; 3 personajes mueren con la misma imagen en F2b; la traición usa el mismo blocking 9 veces.

## [2026-07-28] sprint/QA-verificación | C1 CERRADO — Torgan es el segundo agente, sin mensajero anónimo

**Decisión de Boris:** resolver C1, el único crítico bloqueante que impedía escribir la salida del Archive en la ruta Bram.

Tres fuentes (`Los 9 Pivotes:32-38`, `Torgan-Ficha:369-381` — sección dedicada completa "Torgan como Segundo Agente de la Ruta Bram", y `Geografía:1025`) ya eran consistentes entre sí: **Torgan es el segundo agente y actúa él mismo**, activado por su propia cadena de mando (clan menor → Great Forging Clan), sin conocer al grupo ni a Speck. El outlier era `Bram-Ficha:255-261`, que inventaba un "mensajero enano de bajo perfil — NPC nuevo" entregando la orden "a Torgan (o al enano fijo/Pivote más cercano si Torgan no está)" — ese paréntesis habría convertido a **Darro** en ejecutor del Council, rompiendo headcount y canon simultáneamente.

**Corregido:** `Bram-Ficha` sub-beat 4a reescrito para que Torgan aparezca directamente (sin intermediario), con referencia cruzada a su propia sección dedicada. `Geografía:1025` alineada — ya no habla de "un mensajero que buscó a Torgan" sino de Torgan mismo, activado por su cadena de mando.

**Los 12 críticos del sprint quedan en: 0 de congruencia (C1-C7 todos cerrados), 5 de dramática (D1-D5, pendientes — son decisiones de diseño, no lint).** El sprint QA de reparación sigue sin poder declararse cerrado hasta resolver D1-D5, pero **ya no hay ningún bloqueante que impida empezar a escribir guión en 8 de las 9 rutas** (todas salvo Nyael, cuyo clímax sigue sin resolver — D4).

## [2026-07-28] sprint/QA-verificación | D1 CERRADO — Roen, Valen y Darro con quiebre propio por arquetipo

**Decisión de Boris:** Dagna sigue siendo el techo emocional de Roen (no se empareja hacia abajo); en cambio, cada fijo recibe un **pico** (su quiebre más hondo, ligado a un Pivote específico) y **dos versiones más suaves** — una por cada una de las otras 2 filas de arquetipo de [[Los 5 Finales]] (Aritmética/Manipulación: Maren, Sereth, Vekka · Deber Institucional: Torgan, Iven, Dagna, Nyael · Rechazo/Ausencia: Bram, Lyris). Así los 9 Pivotes siguen sin ser intercambiables entre sí, pero ninguna de las 9 rutas deja a los 3 fijos como pura cámara de eco.

**Mapeo ejecutado:**

- **Roen** — pico: **Dagna** (Deber Institucional, sin cambios, sigue siendo "la que lo rompe más hondo"). Suave-Aritmética: **Sereth** (`Roen:274`) — reescrito para registrar como quiebre real, "la que más cerca llega de romperlo" de las ocho no-Dagna. Suave-Rechazo/Ausencia: **Lyris** (`Roen:284`) — antes decía explícitamente "Roen no se quiebra aquí, se repliega"; reescrito para que sea un quiebre propio y real, más liviano que Dagna pero no un repliegue. Ajustada la entrada de Dagna (`Roen:296,304`) y el espejo en `Dagna-Ficha:387` para que digan "la que lo rompe más hondo" en vez de "la única que lo rompe" — ya no es cierto que sea la única.

- **Darro** — pico: **Vekka** (Aritmética/Manipulación) — ya era la escena más suave que tiene Darro en todo el juego (el abrazo); ahora marcada explícitamente como su quiebre más hondo (`Darro:375`). Suave-Rechazo/Ausencia: **Lyris** (`Darro:360`) — ya tenía shock genuino, marcada como su versión suave. Suave-Deber Institucional: **Dagna** — **gap real encontrado en el proceso: no existía entrada "Darro + Dagna"** en la tabla de dinámicas (8 de 9 Pivotes cubiertos, faltaba ella). Agregada (`Darro:363-370`): Darro se sienta junto a Roen en el cráter sin decir nada — su propio quiebre suave es elegir el silencio de otro antes que el suyo.

- **Valen** — pico nuevo: **Nyael** (`Valen:345-349`) — reescrita de una viñeta plana a el reconocimiento más hondo de su arco: Nyael observa sin intervenir, el mismo entrenamiento de la Academy of Sages que a Valen le enseñaron como virtud y que él mismo practica con Speck y con el jugador. Verla traicionar así es verse desde afuera. Suave-Aritmética: **Sereth** (`Valen:333`) — nota agregada de que es un segundo lugar, más frío que Nyael.

**Nota de proceso:** el pase reveló un gap real (Darro sin entrada para Dagna) que ninguno de los 2 QAs había señalado — quedó expuesto recién al construir la matriz de picos/suaves de forma sistemática. Vale la pena tenerlo en cuenta: los gaps de "falta contenido" son más difíciles de detectar por QA que las contradicciones, porque no hay texto que contradecir.

**D1 CERRADO.** Quedan D2 (F4 "final verdadero"), D3 (Momentos de Persona de Speck), D4 (clímax de la ruta Nyael) y D5 (gate de F2b).

## [2026-07-28] sprint/QA-verificación | D2 CERRADO — F4 pierde la etiqueta "verdadero" y gana un costo real

**Problema:** `Los 5 Finales.md:83` etiquetaba F4 *"síntesis — final verdadero, ganado"*. Los 9 Pivotes mejoran ahí sin excepción, es el único con consentimiento de Speck, y no costaba nada — lo que convertía a los otros 4 finales en fracasos de ejecución en vez de alternativas morales.

**Corregido:**
- Etiqueta cambiada a *"síntesis — el único con consentimiento de Speck"* (descriptiva, no jerárquica). Mismo cambio propagado a `Bram-Ficha:332`, que citaba la etiqueta vieja.
- **Costo agregado, consistente con canon existente:** Speck no vuelve con el grupo — la calcificación en F4 es permanente, ella se queda en el cráter para siempre. Es el único final donde el jugador rompe su propio Bond por elección, sabiendo lo que suelta. Ilyara ya había sembrado el argumento en el Grove (*"sanar el Aether cuesta algo"*) pero atado solo a F1 — F4 ahora paga el mismo principio en otra moneda: en F1 el costo es civilizaciones, en F4 es una sola vida que el jugador llegó a querer.
- **Sabor explícito agregado:** agridulce, no triunfal — misma familia sonora del eco Bond/Link Cam que F2b, no una victoria limpia. La única diferencia entre F4 y F2b es que en F4 la pérdida tuvo consentimiento.

**No se tocó la matriz 5×3 ni las 9 fichas de Pivote** — el cambio es puramente en el marco de F4 (`Los 5 Finales.md`), las reacciones de cada arquetipo en esa fila siguen siendo válidas tal como están escritas.

**D2 CERRADO.** Quedan D3 (Momentos de Persona de Speck), D4 (clímax de la ruta Nyael) y D5 (gate de F2b).

## [2026-07-28] sprint/QA-verificación | D3 CERRADO — los 7 Momentos de Persona escritos

**Problema:** `Speck.md §Momentos de Persona` era una frase-placeholder ("~7 escenas fijas... el detalle específico no se fija aquí") sin una sola escena escrita, pese a ser el gate mecánico de F4 y — según el QA narrativo — la única vía real para que Speck deje de ser MacGuffin.

**Diseño aplicado:** cada Momento no es al jugador reaccionando a Speck — es **Speck actuando primero**, sin que nadie se lo pida, con una acción ambigua entre 3 lecturas (herramienta / mascota / persona). El molde es el Vector C del Grove ya existente (gira la cabeza al noreste, no se mueve 20 segundos) — el QA lo señaló como la mejor escena no reconocida como tal; ahora es oficialmente el **Momento 6**, con los otros 6 escritos alrededor del mismo molde:

1. Acto 1 — se detiene antes del nido, sin que nadie le pida nada (orejas planas, se niega a avanzar).
2. Acto 1 — en el bautizo, inclina la cabeza hacia Darro específicamente, no hacia el chiste.
3. Acto 1→2 — tras el primer flash privado del jugador, sostiene la mirada más de lo normal y la rompe ella primero.
4. Acto 2 — se retrae de un NPC que la toca sin permiso, gruñido deliberado, no reflejo.
5. Acto 2 — se comporta distinto específicamente cerca del Pivote activo, antes de la traición.
6. Acto 2 — Grove of Cycles, Vector C (ya existente, re-clasificado).
7. Acto 3 — antes de The Reckoning, se adelanta y elige un camino por su cuenta — la única vez que dirige en vez de seguir.

Cada uno documentado con las 3 lecturas posibles (herramienta/mascota/persona) para que el sistema pueda evaluar sin UI, consistente con el diseño ya fijado ("sin UI deliberadamente").

**Colateral resuelto de paso:** el residual "beige" que el QA de congruencia había marcado como menor en 4 archivos (`Speck.md` ×2, `Bram-Ficha:215`, `Nyael-Ficha:221`, `Geografía:1011`) — quedó de la paleta vieja de Speck (pre-retcon a rojo/naranja). Corregido en los 5 puntos (se dejó sin tocar `Briefs de Concept Art.md`, que es fuente congelada de prompts ya corridos en NB2).

**D3 CERRADO.** Quedan D4 (clímax de la ruta Nyael) y D5 (gate de F2b).

## [2026-07-28] sprint/QA-verificación | D4 CERRADO — la ruta Nyael tiene antagonista funcional en el cráter

**Problema:** `Nyael:259-265` decía textual "Nunca hay confrontación final. Nunca hay batalla. Solo ausencia" — la ficha nunca resolvía quién lleva a Speck al cráter ni cómo el jugador llega a una decisión física ahí. Contradecía la arquitectura fija de `Los 5 Finales:9` ("el clímax físico… abre el abanico") y `Geografía:1040` ("El Pivote llega al centro con Speck").

**Diseño aplicado (distinto del de Bram/C1 a propósito — Nyael no falla, tiene éxito, así que la solución no podía ser "otro Pivote actúa"):** el pulso del core central que responde a Speck **no distingue quién la carga** — cualquier intento de sacarla de The Wilds central se rompe en el mismo punto, para cualquiera. La "ruta 7" de Nyael, diseñada para una extracción limpia, se rompe ahí. Ella personalmente ya no está — su ausencia total sigue intacta, patrón preservado — pero quien el jugador encuentra en el borde es **el equipo de extracción institucional del brazo encubierto** que ella activó: operativos sin nombre, sin arco, la maquinaria funcionando sin ella. No son un segundo Pivote (eso ya se usó en Bram/C1); son antagonismo institucional puro, consistente con el propio arquetipo de Nyael.

**Corregido:**
- `Nyael-Ficha` sub-beat 5 reescrito: Speck imposible de transportar más allá del cráter, equipo de extracción como antagonista físico, Nyael nunca reaparece.
- `Geografía:1044` — variante Nyael agregada, mismo patrón que ya tenía la variante Bram.
- **F2a de Nyael reescrito:** antes decía que ella entregaba a Speck viva "sin complicación técnica" fuera de escena — ahora es el jugador quien, en el cráter, elige no interponerse y deja que el equipo de extracción complete la entrega. Es el único de los 9 Pivotes donde el jugador mismo cierra la traición que el Pivote empezó.
- **F3 de Nyael reescrito:** antes la tenía "a distancia observando la decisión" en el cráter — contradecía su ausencia total recién establecida. Ahora es al equipo de extracción a quien el jugador aparta; el reporte le llega a Nyael por otra vía, sin que ella esté presente.

**D4 CERRADO.** Queda solo D5 (gate de F2b).

## [2026-07-28] sprint/QA-verificación | D5 CERRADO — F2b pasa de timeout a elección activa. LOS 12 CRÍTICOS EN 0.

**Problema:** `Los 5 Finales:49` definía el gate de F2b como *"se abre cuando el jugador no elige a tiempo"* — un timeout. El QA narrativo señaló que un jugador lee eso como castigo por dudar, no como tragedia, y que F2b carga los 5 mejores epílogos del material (Torgan, Iven, Dagna, Vekka, Maren) detrás de la peor puerta de entrada.

**Corregido:** el gate ahora es una **elección activa**: el jugador intenta arrancarle a Speck por la fuerza al Pivote (o al equipo de extracción, ruta Nyael) en vez de negociar, esperar, o retirarse — el forcejeo sobrecarga el Fragmento, que reacciona a fuerza física cerca del core, no a inacción. Congelarse demasiado tiempo puede llegar al mismo resultado por la misma vía física, pero queda como ruta secundaria, no como definición del final. Propagado a `Geografía:1042` (la mecánica del borde del cráter ahora liga F2b al forcejeo, no a "retroceder") y a las 2 fichas que describían el trigger con lenguaje pasivo residual: `Bram-Ficha` ("el Fragmento la sobrecargó antes de que nadie decidiera" → forcejeo explícito) y `Nyael-Ficha` (mismo ajuste, ligado al equipo de extracción de D4). Las otras 7 fichas ya describían solo el epílogo sin especificar el trigger, así que no necesitaron cambios.

**D5 CERRADO. Los 12 críticos del sprint (7 de congruencia + 5 de dramática) quedan en 0.**

## [2026-07-28] design/UI-mockups | 4 brief concepts generados + review archivado

**Generación de 4 mockups de UI y key art** (2026-07-28 ~02:00-02:30):

1. **`ui-character-creation-mockup-v1.png`** ✅ — Tabla Raza × Rol (9 celdas), preview de personaje. Estructura clara, navegable. **Issue menor:** barras T1/T2/T3 bloqueadas — necesita claridad de qué miden (stat? tether?). **Severidad:** MEDIUM. **Estado:** aprobado.

2. **`ui-main-menu-mockup-v1.png`** 🟡 — Pantalla principal: título "AETHER BOUND" + árboles acuarela neblinosos. Atmósfera acertada pero falta elemento narrativo que lo "ancle" a Aether Bound (Speck o detalle de First Wound). **Severidad:** MEDIUM. **Estado:** aprobado con ajuste visual.

3. **`ui-tether-screen-mockup-v1.png`** ✅ — Mecánica Tether: 4 personajes en vértices + Speck centro, Persona Moments en base. Excelente comunicación visual del sistema. **Verificación pendiente:** símbolos Ω/✱ en `Speck.md` §7. **Estado:** aprobado.

4. **`marketing-key-art-poster-v2.png`** 🟡 → **v2 generada** — Poster épico (5 personajes, acantilado), feeling/prompt medianamente acertados pero **tone mismatch vs art bible**: parece heroic-fantasy (aventura épica) cuando el producto es cozy-fantasy (Bonds, Speck como companion). Enano muy pequeño pierde presencia. Falta Speck o elemento que lo identifique como Aether Bound vs generic fantasy. **Severidad:** CRITICAL. **Plan:** re-generar v2 con brief enfatizando cozy-fantasy + Speck visible/implied + peso visual Iron-Blooded.

**Review archivado:** `90-Raw/ui/REVIEW-2026-07-28.md` (issues por severidad, % fidelidad, próximos pasos).

**CATALOGO.md actualizado:** §L (UI Mockups, 3/3) + §M (Marketing, 🟡 v2 pending).

**Current-State.md actualizado:** sección Concept art con nuevo status.

**Próximo paso:** re-correr los 2 QAs de Fase 4 una última vez, en frío, contra el estado actual del vault — es el criterio de cierre real del sprint. Si pasan con 0 CRÍTICOS, el sprint QA de reparación queda formalmente cerrado después de 3 re-corridas (Fase 4 original, verificación C1-C7/D1-D5, esta última).

## [2026-07-28] sprint/QA-verificación | Tercera re-corrida (post-ediciones-directas) — 8 CRÍTICOS nuevos, sprint sigue abierto

**Contexto:** tras procesar las ediciones directas de Boris (Nomenclatura: Isolde linaje + Goggles no-retirables; Speck: Giro Grogu eliminado), se lanzaron los 2 QAs de verificación en frío con **Opus**, contra el estado actual completo del vault. Es la tercera re-corrida (Fase 4 original → C1-C7/D1-D5 → esta).

**Resultado: no sale limpio. 4 CRÍTICOS de dramática (+1 MEDIUM) + 4 CRÍTICOS de congruencia (+2 MEDIUM).**

### Validado limpio (re-confirmado)
Los 3 fixes de la 2ª re-corrida siguen en pie: Speck actora en los Momentos de Persona (`Speck.md:119-128`), F2b como elección activa (`Los 5 Finales:49`, replicado en Bram:318/Nyael:291), Nyael con antagonista funcional (equipo de extracción, `Nyael:263`). También limpio: Bram no traiciona (Roen:184/279, Valen:338, Darro:355, Geografía:943/1025), Speck femenina (0 residuos), Speck como Warden anciana sin residuos de "criatura joven", los 9 Pivotes existen simultáneamente/solo 1 conoce al jugador (`Los 9 Pivotes:25-38`), Raza×Rol de los 9 correcta, Roen 45 con aritmética interna cuadrada.

### CRÍTICOS de dramática

1. **Darro F1 (`Darro-Ficha-Expandida-v1.md:280-282`)** — *"cuando entiende que ella eligió esto […] 'Speck eligió. Nombre honra elección.'"* Colapsa la distinción central de F4: `Los 5 Finales:83,96` titula F4 "el único con consentimiento de Speck" y remata que el consentimiento "es lo único que lo distingue de F2b". Si en F1 Speck también "eligió", F4 pierde su superlativo. Raíz en `Speck.md:70-73` ("en F1, F4 […] asume su destino con gracia divina") que agrupa ambos finales bajo la misma agencia — F1 debe ser aceptación sin ser preguntada; F4, la única vez que se le pregunta.

2. **Darro F2b (`Darro-Ficha-Expandida-v1.md:298`)** — *"al menos sé que la promesa era real. Seguimos."* Viola `Los 5 Finales:55`: F2b es "tragedia pura […] ningún beat de 'aprendimos algo'". Roen y Valen respetan la regla en sus propios epílogos F2b (`Roen:234`, `Valen:284`); solo Darro la rompe.

3. **Nyael F2a (`Nyael-Ficha-Expandida-v1.md:285` vs `:261`)** — `:261` establece que Speck es "imposible de transportar […] sin importar quién la cargue" (es lo que sostiene la ausencia total de Nyael). `:285` (F2a) introduce que Speck "no puede ser movida sin el consentimiento del propio jugador" — una llave que `:261` niega. Las dos reglas no pueden ser verdad a la vez; la ruta Nyael pierde F2a o pierde su mecanismo de ausencia.

4. **Cita rota (`Los 5 Finales.md:49`)** — apunta a *"[[Speck]] §Capa 4 — el Fragmento reacciona a fuerza física cerca del core, no a inacción"*, pero `Speck.md` §Capa 4 (`:64-73`) no contiene esa regla (solo describe la activación del Fragmento en The First Wound). La regla que hace de F2b agencia y no timeout —el fix central de la 2ª re-corrida— se apoya en una fuente inexistente.

**MEDIUM:** `Grove of Cycles — Escena del Acto 2.md:68` sigue anclando F2b a que "el jugador se congela sin decidir" — desalineado con `Los 5 Finales:49`, que degradó el congelamiento a ruta secundaria. La escena que siembra los 5 finales en Acto 2 telegrafía el gate equivocado.

### CRÍTICOS de congruencia

5. **Darro/Vekka aritmética (`Darro-Ficha-Expandida-v1.md:44` vs `:376`, espejado en `Vekka-Ficha-Expandida-v1.md:46,54,72,86,88`)** — `:44` sitúa el aprendizaje "a los 30" con el presente en edades 39-45 (rechazo hace ~12 años); `:376` y toda la ficha de Vekka dicen "hace ~30 años". El mismo archivo de Darro se contradice a sí mismo.

6. **Longevidad de los 3 fijos (`Roen-Ficha:40,50`, `Valen-Ficha:96,106`, `Darro-Ficha:90,100`)** — las 3 fichas afirman "elfos viven 150+ años" / "enanos ~60-120 años", contra el canon de `Las Tres Razas:24-25` (elfos 650-700, enanos 200-250). Con "150+" Valen a 230 sería anciano en vez de "joven para un elfo" como dice su propia ficha. Patrón ya señalado en la 2ª re-corrida: fijos pre-rework.

7. **Valen "vio cinco Mudas" (`Valen-Ficha:100`, refuerzo en `:11`)** — *"He visto tu tipo caer cinco veces en cinco Mudas."* Imposible bajo cualquier marco: ninguna Muda se ha completado en los últimos 550 años (`El Mundo y la Muda`). No es la creencia errónea de la Academy ya resuelta (esa es sobre la periodicidad) — es una experiencia personal declarada que no pudo ocurrir.

8. **Isolde Marrow "tatara-tataranieta del último rey" (`Nomenclatura.md:51` vs `Estructura Política.md:154,175,190`)** — 3 choques: (a) Estructura Política dice que su sangre real es "leyenda, sin necesidad de ser verificable" — Nomenclatura la afirma como hecho; (b) 5 generaciones ≈125-150 años humanos, pero el "último rey" debería preceder 550 años de Regencias (6-8 dinastías distintas); (c) `Nomenclatura:47` sella que el título humano nunca fue "King" y no existe ningún "último rey" documentado en el vault. Ya estaba marcado como worldbuilding gap en la sesión de procesamiento de ediciones, pero el cambio quedó aplicado como canon — la contradicción está viva.

**MEDIUM (Goggles):** `Geografía:1017` + 9 fichas de Pivote (Bram:213, Dagna:223, Iven:371, Lyris:254, Maren:239, Nyael:223, Sereth:226, Torgan:271) describen "el jugador se pone los Goggles" repetidamente, incluyendo un "segundo uso" explícito en el Archive — pero Nomenclatura los declara no-retirables desde el primer uso en Driftmarket. No rompe el gate de F4, pero el lenguaje narrativo en 10 archivos asume que se los quita.

**MEDIUM (Valen-110-años):** `Valen-Ficha:52` — "la última Muda fue hace 110 años, no 300" sigue afirmándose como dato válido (`:217`: "el texto de sus cálculos sigue siendo correcto"), pero choca con `Geografía:748` (Muda rota hace ~550 años). Falta marcar el 110 explícitamente como parte del error de la Academy.

### Diagnóstico de fondo

Los críticos de esta 3ª ronda cambian de naturaleza respecto a la 2ª: ya no son huecos de cobertura (algo no escrito), son **contradicciones archivo-contra-archivo** (Darro vs Vekka, Nyael consigo misma, F2b vs su propia fuente citada) y **ediciones/fixes que no se propagaron a todas sus menciones** (longevidad de fijos, Valen-Mudas, Isolde). Varios están interconectados: fijar Isolde toca worldbuilding (construir el Último Reino); fijar longevidad/Valen-Mudas toca la timeline general de los 3 fijos; fijar Darro toca 2 fichas simultáneamente.

**Decisión de Boris (2026-07-28 noche):** sesión de diseño mañana para resolver los 8 críticos + la pregunta abierta de bonds fijos en `The Bound Five.md`. Nada se toca hasta entonces. Current-State actualizado con la agenda completa.

---

## [2026-07-29] design/QA | Sesión de diseño — 8 críticos + 3 MEDIUM resueltos; 2 contradicciones raíz que el QA no había visto

Sesión de diseño de la agenda fijada anoche. Plan de abordaje con asignación de modelos por
sprint en `~/.claude/plans/haz-un-plan-de-dazzling-lemur.md`.

### Hallazgos nuevos durante la exploración (no estaban en el reporte de la 3ª ronda)

1. **`Speck.md:69-73` era la fuente real del crítico de Darro F1.** Declaraba que Speck "elige
   con dignidad" en **F1 y F4**, contra `Los 5 Finales:83,94,96` que reserva el consentimiento
   solo para F4. Arreglar la línea de Darro sin tocar `Speck.md` habría reintroducido el crítico
   en la siguiente ficha que escribiera un epílogo F1.
2. **Colisión de gates F2b/F4.** `Los 5 Finales:88` definía F4 como *"quedarse quieto en el
   cráter en vez de decidir"* — el mismo verbo que `Grove:68` usaba para sembrar F2b. El MEDIUM
   del Grove no era de arrastre: era una colisión de gates entre dos finales opuestos.
3. **La cita rota era un bucle circular, no un enlace muerto.** `Los 5 Finales:49` → `Speck
   §Capa 4` (inexistente) y `Geografía:1042` → `Los 5 Finales §F2b`. Ningún documento del vault
   enunciaba la regla como canon primario.

### Decisiones de Boris

- **Agencia en F1:** manda `Los 5 Finales`. F4 es el único con consentimiento; en F1 Speck
  **acepta sin ser preguntada**. Vocabulario fijado: el verbo de F1 es *aceptar*, el de F4 es
  *responder*.
- **Regla del Fragmento:** sobrecarga por **transferencia de fuerza mecánica a corta distancia
  de un core activo**. Ni el tiempo ni la inacción la dañan. Vive en **`Speck.md` §Capa 5**, nueva
  y declarada fuente única.
- **Transporte de Speck (F2a vs Nyael):** *la entrega corta el pulso.* El tirón del cráter es
  absoluto solo mientras los God-Cores pulsan; ceder a Speck corta el hive mind y recién entonces
  es transportable. No inventa canon — `Los 5 Finales:32` ya decía que el pulso se corta en F2a;
  ahora es la causa del transporte, no un efecto suelto. Salva el texto de `Nyael:261`.
- **Gates:** quietud informada (termina en pregunta) = F4; forcejeo = F2b; **parálisis = F2a**,
  porque el Pivote entrega por defecto. No decidir no es neutral: hace ganar a la institución.
- **Isolde Marrow:** degradada a reclamo/leyenda. El "Último Reino" pasa a Pendientes como ítem
  de worldbuilding propio, sin bloquear el cierre del sprint.
- **Bonds de fijos:** después de cerrar el QA, no en paralelo.

### Cambios aplicados

**Canon nuevo (`Speck.md`):** §Capa 4 reescrita con los tres grados de agencia (le preguntan F4 /
deciden por ella y acepta F1 / se la arrebatan F2a-F2b-F3) + regla de escritura explícita para
epílogos. **§Capa 5 nueva** con la regla física y sus 4 derivaciones. Encabezado "Tres capas de
verdad" → "Las capas de verdad" (tenía 4 capas desde antes; ahora 5).

**`Los 5 Finales`:** cita de F2b apunta a §Capa 5 real; se eliminó la ruta secundaria por timeout
("el forcejeo es la única vía"); F2a declarada final por defecto de la parálisis y con el
transporte explicado por el cese del pulso; gate 3 de F4 pasa de "quedarse quieto" a "callarse
para preguntar", con párrafo nuevo que separa la quietud de F4 de la parálisis de F2a.

**`Geografía y Ciudades`:** `:1042` deja de enunciar la regla por su cuenta y cita §Capa 5 como
fuente única; `:965` reescrito — **los Goggles no salen** (el jugador intenta quitárselos y no
puede; línea nueva de Tobin sobre el extraño anterior); `:1017` deja de decir "segundo uso".

**`Grove of Cycles:68`:** F2b resembrado como forcejeo; se declara explícitamente que congelarse
**no** siembra F2b sino F2a.

**Darro:** F1 reescrito — Darro ya no dice que Speck eligió, sino que nota que *no peleó* y que
nadie le preguntó, él incluido. F2b: eliminado *"al menos sé que la promesa era real. Seguimos"*;
el epílogo ahora no cierra, con nota de que ninguna versión puede dar consuelo. Aritmética
sincronizada al canon de **~30 años**: edad ~63 (era banda 45-65 con presente en 39-45),
"Aprendizaje Truncado" 30-33, "Salida de Emberdeep" 33→presente, y párrafo nuevo que cubre los
25 años sin narrar entre los 38 y los 63 (y los usa para explicar por qué el rechazo no se le curó).

**Nyael:285:** reescrito — el equipo se traba donde `§sub-beat 5` dice; lo que desatasca la escena
es la entrega, no la fuerza. Ya no inventa el "consentimiento del jugador".

**Valen:** *"He visto tu tipo caer cinco veces en cinco Mudas"* → autoridad archivística (*"He
leído tu caso cinco veces, con cinco nombres distintos"*); `:11` explicita que no presenció
ninguna Muda; el **110 años queda marcado como error de la Academy** en `:52` y `:217` (las dos
puntas de su medición eran falsas); el anillo de `:389` se vuelve un objeto que conmemora un
evento que nunca ocurrió — y que no se quita después del Archive.

**Longevidad (6 líneas / 3 fichas):** Roen `:40,:50`, Valen `:96,:106`, Darro `:90,:100` alineadas
a `Las Tres Razas` (elfos 650-700, enanos ~200-250), con la consecuencia de escala reescrita en
cada caso, no solo la cifra sustituida.

**`Nomenclatura:51`:** Isolde pasa de afirmación a reclamo de House Marrow, con nota de que el
vault no ratifica ese trono y que el título humano registrado nunca fue "King".

**Goggles (cubeta b — 10 líneas):** *"El jugador se pone los Goggles"* en el Sunken Archive → *"mira
a través de"* en las 9 fichas de Pivote + Valen. Se conserva `Geografía:961` (el primer uso en la
oficina de Tobin, que sí es un acto de ponérselos). Total de menciones auditadas: 43 en 14 archivos.

**`Iven:592`:** residuo del gate viejo de F4 ("quedado quieto lo suficiente para que Speck hable
primero") → hacerle la pregunta, con nota de que la quietud sin pregunta es F2a. **Este residuo no
estaba en el reporte del QA** — salió del barrido post-fix.

### Verificación

Barrido de grep de los 8 datos corregidos: **0 residuos** (único hit es el primer uso legítimo de
los Goggles). Verificado además que el error de F1 **no se propagó**: los 22 "Speck elige" del vault
están todos en secciones F4, donde el verbo es correcto. `check_vault.py` 🟢 verde, arranque ~5,125t.

### 3 críticos extra, encontrados en el barrido objetivo del cierre

Ninguno estaba en el reporte de la 3ª ronda. Mismo patrón que el resto: una corrección previa que
no barrió la clase completa de menciones.

- **`Valen:58`** — los ancianos de Stillspire: *"The Stillspire ha sobrevivido cuatro Mudas.
  Sobreviviremos la quinta."* **Era la fuente del "cinco Mudas" de `:100`** que se corrigió más
  temprano en esta misma sesión. Marcada explícitamente como cosmología heredada de the Academy,
  con el beat de que la negativa que Valen recibió a los 140 se apoyaba en un recuento inexistente.
- **`Geografía:613`** — ermitaño élfico de Hermit's Cave: *"he visto dos mudas. Esta es la
  tercera…"*. Imposible (ninguna Muda completada en 550 años). Reescrito: vio **dos falsas
  alarmas** que los archivos élficos asentaron como Mudas. Queda como testigo vivo del error de
  registro que Valen descubre en el Grove — y da razón concreta al "respeto mutuo" con Valen que
  la ficha ya afirmaba sin fundamentar.
- **`Torgan:11`** — "Edad aparente: 75-80 años" contra `:66`, que fija la aritmética en 75 y se
  declara "no negociable". Alineado a 75.

**Verificado además:** la aritmética de Valen cierra (hallazgos a los 140 → 40 años solo, 180 →
God-Core hace 30 años, 200 → presente 230, coherente con el encabezado "edades 100-180"). Las 17
citas `§Capa` del vault resuelven todas a secciones existentes con el contenido que el citante
afirma.

### 🔴 Cierre de sesión sin commit — leer antes de retomar

**Nada de esta sesión quedó commiteado.** El clasificador de Opus cayó a mitad de sesión y bloqueó
Bash, PowerShell y el Agent tool; lectura y edición siguieron operativas, así que todos los
cambios están en disco. Dos consecuencias:

1. **El Sprint 0 (baseline) nunca corrió**, así que los cambios de hoy están mezclados en el
   working tree con los 16 archivos que ya venían modificados de la sesión del 07-28. Revisar el
   diff antes de commitear.
2. **Los 2 QAs de la 4ª re-corrida no se lanzaron.** Lanzarlos con **Opus, en frío, en paralelo**
   (dramática + congruencia).

### Ficha de Old Tobin Hale + regla de idioma para el guión (2026-07-30)

**Old Tobin Hale, escrita.** `10-Knowledge/Old-Tobin-Hale-Ficha-Expandida-v1.md`
— personaje de apoyo, sin arco de traición ni epílogo en los 5 finales.
Consolida canon ya disperso en `Geografía y Ciudades §The Driftmarket / §THE
RECKONING` (los dos beats fijos: la advertencia con falso positivo sobre uno
de los 3 fijos, y la entrega de the Wanderer's Goggles) y en `Briefs de
Concept Art §10b/§11.6` (visual, ya ratificado). No duplica el guión existente
— lo resume desde el punto de vista de Tobin y agrega 3 líneas de voz nuevas.

**El extraño que le dejó los Goggles hace 40+ años queda deliberadamente sin
resolver.** El vault no tiene canon sobre su identidad y la ficha dice
explícitamente que no hay que inventar uno sin que Boris lo pida — es una
siembra a propósito, mismo patrón que The Monolith (aporta peso sin
resolverse). Se dejaron las tres lecturas abiertas por si se retoma: otro
portador del poder innato, un Warden distinto, o sin relación con Speck.

**Regla de idioma (decisión de Boris):** el guión y todo el contenido de
front-end (diálogos, líneas canónicas, UI, textos in-game) se escribe en
**inglés** de acá en adelante. El vault sigue en español — es donde Boris y
el asistente conversan, no lo que ve el jugador. Registrado en `CLAUDE.md`
regla 9 y en `Nomenclatura.md` (extensión de la regla de nombres propios en
inglés ya vigente desde 2026-07-24). Las 3 líneas de voz nuevas de Tobin ya
se escribieron en inglés siguiendo la regla; el diálogo viejo del Reckoning
(en español, de antes de esta decisión) queda anotado como pendiente de
traducción para cuando se aborde el guión completo — no bloquea nada.

**Limpieza de `Current-State.md`:** la sección `## Pendientes` había quedado
desactualizada desde antes de la 5ª ronda (seguía listando "6ª re-corrida"
como pendiente, "5c.4/5c.2 sin escribir" cuando ya estaban cerrados, y la
ficha de Tobin como pendiente cuando ya se escribió). Reescrita completa,
comprimidas las 3ª-5ª rondas a resumen de una línea cada una (detalle
completo sigue en este LOG), y agregada la regla de idioma como pendiente
transversal del frente de guión.

**Estado:** `check_canon.py` 0 críticos; `check_vault.py` 🟢 (~2,9k, bajó
respecto a la sesión anterior por la limpieza). **Pendiente: 7ª re-corrida QA.**

### 6ª re-corrida QA — 9 críticos, 8 cerrados (2026-07-30)

Dos QAs Opus en frío: **6 de dramática + 3 de congruencia.**

**Patrón nuevo esta ronda:** los 3 críticos de congruencia estaban en material
*viejo que nadie había vuelto a mirar* — `Geografía y Ciudades §Beats
Narrativos por Acto` — no en la propagación de la 5ª ronda, que el QA
confirmó limpia. Y uno de los críticos de dramática era mío, de la ronda
pasada: el gate de F1 que escribí se contradecía en la misma frase
("detenido en el borde del cráter" + "carga a Speck hasta el centro" — un
agente no puede estar en las dos partes a la vez).

#### Dramática (6 críticos)

- **C1 — gate de F1 autocontradictorio.** Reescrito: el punto exacto de
  intercepción queda **abstracto por diseño** (borde, centro, o entremedio),
  citando la abstracción que `Geografía §ACTO 3 sub-beat 5` ya declaraba
  explícita ("cada ficha de Pivote escribirá su variación"). Ya no fuerza una
  geometría única que las 9 fichas no podían cumplir a la vez.
- **C2 — Lyris F1/F3 contradecían su propio sub-beat 5.** Su F1 saltaba
  directo a "se queda quieta en su cielo" sin el paso de ser neutralizada
  mientras sostenía a Speck; agregado el beat de que cede sin forcejeo antes
  de retirarse. Su F3 decía "se va antes del cráter" cuando su staging la
  tiene ahí sosteniendo a Speck — corregido a que suelta y asciende
  **específicamente cuando ve al jugador cruzar hacia el core**, mismo
  patrón de salvaguarda que ya tenía Bram.
- **C3 — Nyael y Bram: los dos casos para los que se reescribió el gate no
  lo mencionaban.** Ninguna de las dos fichas nombraba a su agente sustituto
  (equipo de extracción / Torgan) en su propio epílogo F1. Agregado a las dos.
- **C4 — Iven rompe la fila Deber Institucional en F1 y F2a.** **Sin
  resolver — decisión de Boris registrada en Current-State.** Su ficha ya se
  declara "variante envenenada"; falta decidir si eso justifica la excepción
  o si hay que reescribir los epílogos para calzar con la fila.
- **C5 — "sin reloj autónomo" nunca bajó a la fuente.** `El Mundo y la
  Muda.md:44` (el documento raíz) seguía diciendo "si Speck madura, terminará
  la Muda" sin condición de cráter. Reescrito ahí, y barrida la clase
  completa: `Iven:20` (la promesa del Council como "físicamente imposible"),
  `Iven:576` (F2b, tenía literal "estaba en camino a madurar" — contradecía a
  `Iven:522`, arreglado la ronda pasada, 54 líneas antes en el mismo
  archivo), `Valen:70` y `Valen:219` (presentado como lectura confirmada del
  Archive, no como creencia de personaje).
- **C6 — ítem huérfano en `Bond y el Bond Vacío.md`.** El "5. Eco final" de
  la lista original (ítems 1-4) quedó pegado dentro de la sección de la
  excepción de Bram al insertarse esa sección — y ahí contradice, porque en
  la celda de Bram no hay link degradado que Speck pueda puentear. Reubicado
  a su lista original, con nota explícita de que no aplica a Bram.

#### Congruencia (3 críticos — todos en `Geografía §Beats Narrativos`)

- **C1 — Cuándo se forma The Bound Five: Acto 1 vs Acto 2.** Las 9 fichas de
  Pivote + los 3 fijos + `Speck.md` sitúan al grupo completo desde el Acto 1.
  `Geografía` (bloque de sub-actos 2A/2B/2C) y `Estructura Dramática:14`
  seguían con "Encuentro con Maren/Torgan/Dagna/Lyris/Sereth" en Acto 2 —
  residuo de antes de que las fichas fijaran el canon. Corregido: los 3
  sub-actos ahora dicen "el Pivote [raza] ya está en el grupo desde el Acto
  1 — territorio natal, no encuentro", con la lista correcta de qué Pivote es
  de qué raza (enanos: Torgan/Dagna/Vekka; elfos: Sereth/Lyris/Nyael;
  humanos: Maren/Iven/Bram — verificado contra `Los 9 Pivotes.md`, cometí y
  corregí un error de raza propio en el camino). También corregido
  `Estructura Dramática.md:14` y el residuo "Segunda traición visible" (no
  hay segunda traición, era la misma corrupción del asentamiento de Iven ya
  etiquetada dos veces).
- **C2 — topología "rueda, no malla" contradicha en 4 lugares.** La regla que
  fijé esta sesión (*"los tres reinos no se conectan entre sí
  directamente"*) chocaba con texto viejo de `Geografía §Reinos`: Cinder
  Ascent y Gloomvault descritos como accesos directos reino-a-reino en vez de
  radios hacia The Wilds. Corregidas las 4 menciones (Cinder Ascent Base como
  puesto de Aethelgard, accesos de Aethelgard e Ignis Reach).
- **C3 — Momento de Persona 7 fechado en el Acto equivocado.** `Speck.md:215`
  decía "Acto 3 — antes de The Reckoning", pero The Reckoning es de **Acto
  2** en 4 fuentes (`Grove of Cycles`, `Geografía`, ficha de Bram). Un beat no
  puede ser "Acto 3" y "antes de un evento de Acto 2" a la vez. Corregido ahí
  y en `Geografía:894` y `La Rueda:32` (que agrupaba los 7 Momentos en Acto 2
  sin reconocer que los 2 primeros son de Acto 1).

#### MEDIUM cerrados (5 de los reportados)

- Gate de F4 sin el calificador "Momentos disponibles en esa partida" en
  `Los 5 Finales:118` — las 2 fuentes que lo declaran obligatorio
  (`The Tether`, `Grove of Cycles`) ya lo tenían.
- Mecanismo de activación de Torgan: `Geografía:1038` negaba el mensajero y
  ponía la cadena en el Great Forging Clan; 3 fuentes (ficha de Torgan, ficha
  de Bram, `Los 9 Pivotes`) dicen mensajero + clan menor. Alineado.
- "3 cadenas de poder, 9 personas" como regla absoluta — Lyris (Frontier High
  Command, un cuarto track) y Bram (contrato directo, sin cadena) la rompían.
  Suavizado a "casi todas" en `El Mundo y la Muda` y completada la lista de
  `Estructura Política:298-304` a las 9.
- "El sabor de la traición lo dicta la raza" (`The Bound Five:59`)
  contradecía la matriz ratificada en 3 de 9 (Iven y Bram humanos no son
  pragmatismo; Nyael elfa no es lógica fría). Corregido a "por arquetipo".
- `5c.2b` apuntaba a un archivo que no existe en disco
  (`Speck - Imprisoned Warden Form Final 3`) — el asset real es
  `Final 2 The Long Winter.png`. Corregido, y actualizado `CATALOGO.md`, que
  seguía hablando de "4 finales" cuando son 5.

Más 3 MEDIUM de barrido rápido: residuo del modelo de "estadios" de
crecimiento (abolido en `Speck.md`) en `Los 9 Links del Pivote` y
`The Bound Five`; violación de la regla de Goggles en `Geografía:1030`
("que Valen no puede traducir sin los lentes" es un contrafáctico inválido —
Valen nunca accede a esa capa, punto); Lyris F2a entregaba a Speck "en el
punto acordado" fuera del cráter, imposible por la regla física de
`Speck.md §Capa 5`; Dagna F1 elidía el beat de neutralización.

**C4/Iven — decisión de Boris (2026-07-30): excepción intencional.** Iven
se queda rompiendo la fila Deber Institucional en F1/F2a; es el único de
los 4 cuya institución le mintió activamente para reclutarlo. Registrado en
`Los 5 Finales §matriz` como excepción declarada, para que ningún QA futuro
la vuelva a reportar como crítico.

**Estado:** `check_canon.py` 0 críticos; `check_vault.py` 🟢 (~3,4k). Los 9
críticos de la 6ª ronda quedan todos cerrados. **Falta la 7ª re-corrida.**

**Pendiente sin tocar, de menor prioridad:** `Los 9 Links del Pivote`/ficha
de Bram no anotan la excepción del Bond invertido; 3 epílogos F4 (Maren,
Iven, Bram) cierran en alza sin la fricción de "agridulce, no triunfal";
Roen F4 sin la pasada de tono de Valen/Darro. Y una nota lateral: existe un
worktree de git real en `.claude/worktrees/quirky-wiles-afa8a0/` (rama
`claude/strange-galileo-243fc7`, 62MB) con una copia vieja del vault — no se
tocó, revisar si hace falta.

### Los 5 finales visuales completos + hook de check_vault.py (2026-07-30)

**F1 (5c.1) — falsa alarma resuelta.** Boris mostró una imagen de un ciervo con
astas alegando ser el resultado de F1. Verificado abriendo `Final 1 The Guided
Molt.png` y `speck-trueform-translucent.png` con el tool de lectura: los dos
YA eran zorro/cuadrúpedo, sin astas — el arte ratificado estaba bien. El ciervo
salió de una regeneración nueva desde el texto viejo del brief (sin ancla
anatómica), no del asset. Corregido el registro (había quedado mal anotado
como "regenerado, falta VoBo" en la sesión anterior).

**F4 (5c.4) — problema real, resuelto.** El asset viejo (`Final 4 The Warden's
Choice.png`, aprobado 23/07, pre-split de 5 finales) sí violaba el canon
actual: pedestal con nombre grabado, halo dorado, grupo en actitud de
veneración — apoteosis, no *"agridulce, no triunfal"* (`Los 5 Finales §F4`). Sin
reciprocidad (el único beat que distingue F4: ella responde, mirada al
jugador). Prompt nuevo con ancla vulpina + composición íntima (ella mirando
directo al jugador, sin pedestal, sin halo, el resto del grupo atrás
procesando su propio duelo). Generado y **ratificado por Boris**. Guardado
como `Final 4 The Warden's Choice v2.png`.

**F2a (5c.2a) — nunca existía, brief escrito de cero.** La lámina de "Final 2"
que existía era, en rigor, el brief de F2b (cadáver calcificado); F2a (Speck
viva, cedida al Council, sin cuerpo) no tenía brief propio. Reorganizada la
sección: `5c.2a` = brief nuevo de F2a, `5c.2b` = la lámina vieja re-etiquetada
correctamente. El prompt de F2a se distingue de los otros 4 en los tres ejes
que importan: **vive** (a diferencia de F2b), **está sola** — sin grupo ni
jugador, a diferencia de F4 — y el tono es **frío/administrativo**, no trágico
(F2b) ni de encadenamiento de villano (F3): contención clínica (vendaje/collar,
no cadenas oscuras), cámara institucional, paleta fría con su cuerpo como
única nota cálida. Generado y ratificado. Guardado como `Final 2a The Long
Winter Handed Over.png`.

**Nota de canon reforzada en el proceso:** E3 es *"desvelamiento, no
crecimiento"* ([[Speck]]) — el cuerpo debe leerse reconociblemente zorro, no
esqueleto/robot genérico, y las orejas deben mantener la forma de pétalos
establecida. Las dos primeras generaciones (F4 y F2a) derivaron a costillar
expuesto/orejas simples pese al ancla vulpina — anotado como nota abierta no
bloqueante en `Briefs de Concept Art §Base visual común a todos los finales`,
para refinamiento futuro si hay margen.

**Con esto, los 5 finales visuales (F1/F2a/F2b/F3/F4) quedan completos y
consistentes con el canon actual.**

#### Hook de `check_vault.py` — construido y probado (corrige el registro falso de la sesión anterior)

La sesión anterior había registrado "✅ Resuelto" sin haber creado el archivo
de hook — Boris lo detectó preguntando directamente "¿el hook lo armaste?".
Esta vez se construyó de verdad, vía la skill `update-config`:

- **`.claude/settings.json`** (nuevo, proyecto — versionado, no local): hook
  `PostToolUse` con matcher `Edit|Write`.
- **`Aether Bound/scripts/hook_current_state.sh`** (nuevo): si el archivo
  tocado es `Current-State.md`, corre `check_vault.py` y devuelve el semáforo
  de arranque como `additionalContext` — inyectado de vuelta al modelo en el
  mismo turno, no como texto de terminal que se pierde.
- **`jq` no está instalado en este Git Bash** — el hook usa Python puro para
  parsear el JSON de stdin y construir la respuesta. Encontrado y corregido
  un bug de encoding en el primer intento (acentos llegaban como mojibake
  `Ã©`/`Ã±`) forzando `PYTHONIOENCODING=utf-8` en el subproceso.
- **Probado en vivo**, no solo con pipe-test sintético: una edición real a
  `Current-State.md` disparó el hook y el contexto adicional llegó limpio
  (*"última fecha 2026-07-29"* sin corrupción de encoding).

### `check_canon.py` +2 clases: duplicados e índice (2026-07-29)

Pregunta de Boris tras el hook de peso: *"¿algún otro script .py que sea buena
idea implementar?"* Respuesta: sí, la clase que ya costó 4 fichas archivadas.

- **`duplicados` (CRITICAL).** Detecta dos archivos de `10-Knowledge/` con el
  mismo nombre de personaje en carpetas distintas — la heurística es pelar
  sufijos de versión (`-v1`, `-Ficha-Expandida`) del nombre de archivo y agrupar
  por stem normalizado. `Darro.md` y `Pivotes/Darro-Ficha-Expandida-v1.md`
  colapsan al mismo stem `darro`, en carpetas distintas → hallazgo. Hace
  cumplir mecánicamente la regla "una sola fuente viva por personaje" que quedó
  escrita en `00-Index` tras archivar Dagna/Darro/Roen/Valen. **Hoy en 0**
  (verificado con test directo del stem: la lógica sí detecta el patrón).
- **`indice` (INFO).** Archivos de `10-Knowledge/` que ningún wikilink de
  `00-Index.md` referencia — huérfanos o simplemente sin indexar. Primera
  corrida encontró 2, ambos reales (verificado con grep, no falsos positivos):
  `Benchmark-Musculatura-Torso.md` y `Grove of Cycles — Escena del Acto 2.md`.
  Los dos ya quedaron indexados en esta sesión.

**Estado:** `check_canon.py` ahora en 12 clases, 0 críticos. Actualizada la
skill `canon-qa` con las dos clases nuevas.

### 5c.1 (F1) regenerado con ancla vulpina — PASS aproximado (2026-07-29)

El primer intento de regenerar la lámina de F1 (tras corregir el brief en la 5ª
re-corrida) produjo un **ciervo con astas** — rompía la regla de que los 3 estadios
de Speck comparten ADN de silueta con la forma zorro ([[Briefs de Concept Art]]
§Redireccionamiento). Causa probable: *"crest branches... tendrils of light
extending outward"* se leyó como cornamenta al no anclar la anatomía base en el
prompt.

**Fix:** prompt reescrito con `ANATOMY LOCK: FOX skeleton`, cuadrúpedo, y negativos
duros (`NO DEER, NO STAG, NO ELK, NO CERVID, NO ANTLERS`). De paso corregida la
frase de agencia que ya se había marcado (*"stands beside the player as equal"* era
el verbo de F4, no de F1).

**Corrección posterior (misma sesión):** al abrir los dos archivos de referencia
con el tool de lectura, **ambos ya eran zorro/cuadrúpedo, sin astas** —
`Final 1 The Guided Molt.png` y `speck-trueform-translucent.png` estaban bien
desde antes. El ciervo no salió del arte ratificado: fue una regeneración nueva
hecha desde el texto viejo del brief (sin ancla anatómica), que sí necesitaba el
fix. **No hace falta regenerar el arte de F1** — el asset viejo sigue siendo el
bueno. El ancla anatómica en el brief queda como seguro para futuras
regeneraciones, no como corrección de un asset roto.

**Pendiente de la línea de finales, sin tocar esta sesión:**
- `5c.4` (F4) no tiene prompt de texto escrito — solo referencia la imagen vieja
  pre-split de agencia. Necesita el mismo ancla vulpina + la reciprocidad de F4.
- `5c.2` — la lámina existente (cadáver calcificado) es en rigor el brief de
  **F2b**. El brief de **F2a** (Speck viva, cedida, sin cadáver) nunca se escribió.

### 5ª re-corrida QA — 15 críticos, 13 cerrados (2026-07-29)

Dos QAs Opus en frío: **6 de dramática + 9 de congruencia**, ambos con el brief de
NO auditar lo mecánico (el linter ya está en 0).

**Dos de los críticos eran fixes míos de la misma sesión, hechos en la línea y no en
la clase.** Es literalmente el patrón que la regla 8 del CLAUDE.md existe para evitar,
y volvió a pasar en la sesión que escribió la regla:
- Reclutamiento de C4 en Driftmarket: corregido en **1 de 4** lugares
  (`Geografía:704`, `:731`, `:1081`, `La Rueda:24`).
- Rechazo de Darro: corregido en **2 de 5** (`Geografía:108`, `:683`, `:550`, y dos de
  ellos lo hacían además público y en el lugar equivocado).

#### El crítico de premisa

El F1 de Iven decía que la Muda *"iba a ocurrir sola"* en dos años. Eso **revienta
F2a**: si madura sola con Speck viva, el statu quo administrado es físicamente
imposible y el clímax entero es un trámite. Y contenía **literal la frase que la
prohibición 2 nombra como prohibida** — que escribí yo, en el mismo commit que escribió
la prohibición.

Reescrito: **la Muda no tiene reloj autónomo.** La crueldad de Iven no es que traicionó
en vano, es que **traicionó contra su propio objetivo** — su gente vive porque él
perdió. Frase disponible para el jugador: *"Tu gente vive porque perdiste."* Y lo que su
gente se ahorró no fue gratis: es un pueblo con agua limpia en un continente sin
comercio. Prohibición 2 ampliada a las dos cosas, con *"iba a ocurrir sola"* marcado
como crítico de **premisa**, no de tono.

#### Decisiones de Boris

- **Speck durmió 550 años en crisálida.** 3 líneas outlier de `Speck.md` contra 15
  archivos. **Su humor se refundó:** no viene de haber mirado caer la civilización (no
  vio nada) sino de milenios de Warden previos + **el desfase del despertar** — todo lo
  que el grupo trata como normal a ella le resulta absurdo y no puede explicar por qué.
  La ironía es el único registro disponible para quien entiende el chiste y no puede
  contarlo; por eso funciona en gestos y por eso los Momentos de Persona pesan. El POI
  del avistamiento pasó a **The Guardians' Trail** (rastros de las bestias custodias).
- **Las 4 fichas cortas archivadas** (`Dagna`, `Darro`, `Roen`, `Valen`) → `90-Raw/`.
  Verificado antes: líneas canónicas y secciones visuales ya vivían en las expandidas.
  Contradicciones que las condenaron: si Darro y Dagna se conocían de antes, si Darro
  grita o **se calla** en la traición (la expandida dice que es la única vez que se
  calla), y el gesto de Roen en el cráter (**dejar caer el escudo**, no la mano en el
  hombro). **Regla nueva en `00-Index`: una sola fuente viva por personaje.**
- **El Bond vacío se invierte en la celda de Bram.** Es el único Pivote que rehúsa, así
  que nunca pierde el link y el beat obligatorio no tenía ruta. Ahora se juega al
  revés: el jugador pica Bond esperando el vacío que el juego entero le enseñó a temer,
  **y Bram responde** — sting completo, que no debe mezclarse con el truncado de dos
  notas de las otras ocho celdas. Le paga su superlativo con mecánica en vez de
  diálogo. Su costo llega igual en el cráter: rehúsa **y el Council entrega con las
  manos de Torgan.**

#### Gates, matriz y canon visual

- **Gate de F1 al borde del cráter, no antes.** Como estaba, choca con la puesta en
  escena (el agente carga a Speck hasta el centro y el jugador llega segundos después),
  y seis fichas lo escribían bien contra el gate. Ahora con las 3 variantes por ruta:
  Pivote / equipo de extracción (Nyael) / **Torgan como segundo agente** (Bram).
- **F1 faltaba en la enumeración de gates de `Geografía`**, que fijaba 4 de 5. Agregada
  la lista completa de los cinco.
- **Vekka movida a Deber Institucional** en la fila de la matriz: su ficha, el cuerpo de
  `Los 5 Finales` (5 líneas) y Torgan ya lo decían; la matriz era el outlier. Clase
  barrida (`Darro:392`).
- **Briefs §5c reescritos.** Colapsaban F1 y F4 en "aceptación con gracia divina", que
  borra lo único que distingue F4, y decían *"finales donde vive (F1, F4)"* cuando en
  F2a Speck **también vive**. Ahora llevan la tabla de los 3 grados de agencia. **El
  arte generado hereda el error: el par F1/F4 hay que rehacerlo**, y `5c.2` quedó
  escrito antes del split F2a/F2b (muestra un cadáver, que es F2b).
- **Propagación de F4 a los fijos:** Valen decía *"The Molt completes"* donde la Muda es
  **parcial** — en boca del confirmador de realidad; ahora nombra el precio. Darro
  cerraba F4 **celebrando** con el sabor declarado agridulce; ahora la celebración se le
  cae encima: el nombre fue suyo y Speck no vuelve.
- **Residuos del modelo viejo:** `Speck.md` decía *"nueve personas del grupo"* y que
  *"varía el C4 según quinteto"* (C4 es Darro fijo); `Darro+Iven` eran "dos Vanguards"
  siendo los dos Duelists; dos personajes tenían la reacción *"más devastadora del
  grupo"* en el mismo beat (Roen queda con el silencio, Valen con la más fría).

**Estado:** `check_canon.py` 0 críticos; `check_vault.py` 🟢 (~3,5k).
**Pendiente:** rehacer el set de láminas de finales + 6ª re-corrida.

### Los 12 epílogos F1 bajo la regla de costo (2026-07-29)

Cierra el crítico C1 del QA de dramática: `Los 5 Finales:100` declaraba que F1
"cuesta civilizaciones enteras" y los 12 epílogos mostraban las instituciones
operando con normalidad décadas después. Con el canon de Boris (colapso
tecnológico, no exterminio) reescritos los 12, aplicando las 3 prohibiciones.

**El patrón que salió:** en casi todos, el costo civilizatorio **mejora** el beat
en vez de recortarlo, porque le da al epílogo un antagonista de escala que antes
no tenía.

- **Iven** — su gente sobrevive porque la periferia **nunca fue
  Aether-dependiente**: era la zona que el Council no cableó porque no valía la
  inversión. Cruza de vuelta un país que no reconoce y llega a un asentamiento
  que hereda el mundo por no haber tenido nada que perder. La ironía queda más
  fuerte: traicionó por nada, y encima las instituciones que le negaron ayuda se
  están cayendo mientras el agua le llega igual.
- **Maren** — no puede evitar el colapso, solo volverlo sobrevivible. Raciones al
  gramo, rutas de agua sin bombas, un invierno casa por casa. No muere nadie que
  ella pudiera haber salvado; es un logro enorme que suena a poco, y administrar
  esa distancia es el resto de su vida.
- **Vekka** — bisagras, herrajes de tumba, tornillos de carreta. Y en el mundo
  nuevo **eso es el oficio**, porque no queda forja de Aether en ninguna parte.
  Termina siendo una de las pocas personas con oficio para el mundo que empieza y
  lo vive como degradación, porque su dogma no tiene vocabulario para "la escala
  cambió".
- **Lyris** — única del elenco que ve el costo completo: sobrevuela las tres
  capitales apagándose una por una, Stillspire con los árboles siendo por primera
  vez en siglos lo único que brilla. El Frontier High Command se deshace solo: no
  hace falta desertar de algo que se disolvió.
- **Nyael** — el brazo encubierto alcanza a marcarla "no retornada" y ese es su
  último asiento. **El expediente queda abierto para siempre porque no quedó
  nadie para cerrarlo.** Pasó su vida siendo un renglón en un registro ajeno, y el
  registro murió antes que ella.
- **Bram** — en una ciudad que se cae, un cuerpo grande que sabe estar quieto vale
  más que nunca: barcazas a pértiga, mercado nocturno todas las noches. El
  Council manda a un hombre que **ya no es mensajero sino funcionario sin
  institución**, con una moneda que casi no compra nada.
- **Sereth** — no llega a renunciar a la Royal Academy: no queda Academy. Se
  disuelve en dos años, sin voto, dejando de convocar. Para un hombre cuyo método
  era preparar el terreno, el terreno se disolvió solo.
- **Darro** — **beat nuevo:** se apaga la forja que lo rechazó. Treinta años
  practicando por si algún día volvía, y le sacaron el a dónde. No se resuelve.
- **Valen** — el que nombra el precio en voz alta, que es su función. Cierra
  además el **M3**: su línea ya no asume un Pivote vivo (en la fila Deber
  Institucional F1 es muerte o autoexilio, y en Torgan/Dagna es desaparición
  total), con nota de escritura que lo prohíbe explícitamente.
- **Roen** — no consuela, organiza. Ya vio de qué vivía el mundo cuando era
  guardia del Council y no le sirve de nada tener razón.
- **Torgan** / **Dagna** — nadie los borra ni los persigue: con las forjas
  apagadas, un clan menor y un subclán vasallo tienen problemas más grandes que un
  juramento sin cerrar. Sostuvieron una orden sesenta años y el mundo no tuvo
  tiempo de notar que la soltaron.

**Verificado:** `check_canon.py` 0 críticos; grep de las 5 formulaciones
prohibidas sobre los 12 bloques F1 → los 2 hits son las versiones ya corregidas.

### Herramienta nueva: `check_canon.py` + skill `canon-qa` (2026-07-29)

**Diagnóstico que la motiva:** de los 18 críticos de la 4ª re-corrida, **10 eran
mecánicos** — citas rotas, aritmética que no cerraba, clases de menciones
barridas a dos tercios, reglas de fuente única re-enunciadas. Se estaba usando un
LLM (~234k tokens, 14 min, no reproducible) para el trabajo de un linter, y encima
el LLM olvidaba parte de la clase: la longevidad humana quedó en 2/3 y la
aritmética de Lyris pasó **dos rondas reportada** sin cerrarse.

- **`Aether Bound/scripts/check_canon.py`** — hermano de `check_vault.py` (ese
  audita peso, este consistencia). 10 clases: wikilinks rotos, citas `§` a
  secciones inexistentes, violaciones de fuente única, `hace N años` imposible
  contra la edad declarada, encabezados `(edades A-B)` que no encierran sus datos,
  longevidad contra `Las Tres Razas`, epítetos de género, reinos usados como
  ciudades caminables, POIs con cuadrantes divergentes, y cifras en diálogo (INFO).
  Exit 1 si hay críticos → usable como gate.
- **Skill `canon-qa`** (`.claude/skills/canon-qa/`) — orden no negociable: linter
  hasta 0 críticos → subagentes en frío **solo** para juicio → fixes a la fuente
  con re-grep → checkpoint → re-corrida.
- **[[QA de Canon Loop]]** — registro del método en el vault, como puntero a la
  skill (no se duplica el procedimiento: dos copias de una regla es justo la clase
  de error que el loop caza).
- **CLAUDE.md reglas 7 y 8** — linter antes de subagentes; todo fix va a la fuente.

**Primera corrida: 85 hallazgos brutos → 9 críticos reales** tras afinar cuatro
falsos positivos del script (índice de wikilinks sin sufijos de ruta, citas
compuestas tipo `§ACTO 3 sub-beat 5`, secciones citadas entre comillas, y
precedencia de alias de cuadrante). Los 9 corregidos:

- **3 violaciones de fuente única que ningún subagente reportó** — `Dagna:225`,
  `Maren:241`, `Vekka:206` decían "Los Goggles son privados" sin citar
  `Nomenclatura §the Wanderer's Goggles`
- `The Tether` — "Gate del Final 4" era prosa inline, ahora es sección citable y
  alineada con `Los 5 Finales §F4` (con el "vivos" divergente marcado como
  pendiente de ratificar)
- Citas rotas: `Geografía:752` (§SOUTH, que yo mismo rompí al regenerar los
  cuadrantes), `Speck:192` (§Vectores diegéticos)
- `Geografía:632` — "el último Warden caído" ambiguo con Speck viva
- `Current-State:97` y `PRD-007:3` — género y ref a la ficha archivada

**Estado: `check_canon.py` en 0 críticos / 0 MEDIUM, `check_vault.py` 🟢 (~3,4k).**

### Pendiente inmediato

**4ª re-corrida QA con 2 subagentes Opus en frío** — criterio real de cierre del sprint. No se
declara cerrado sin 0 críticos.

**Nota de método:** que un barrido objetivo de ~20 minutos al final de la sesión sacara 3 críticos
nuevos indica que el cuello de botella del sprint no es el QA sino el **barrido**. A los QAs de la
4ª hay que pedirles explícitamente que traten cada dato como una **clase de menciones** y no como
una línea suelta.

## [2026-08-02] sprint/QA-verificación | 7ª re-corrida — 13 CRITICAL + 18 MEDIUM, el volumen más alto desde la 1ª ronda

**Motivo del salto:** las rondas 2ª-6ª habían quedado auditando `Geografía y Ciudades` y
`Estructura Dramática` — ya corregidos — pero nunca bajaron con el mismo detalle a las 12
fichas de personaje (9 Pivotes + Roen/Valen/Darro), que son las que narran las escenas en
disputa. La 7ª corrida (2 subagentes Opus en frío, QA-Dramática + QA-Congruencia) entró ahí
por primera vez.

**4 decisiones de diseño, resueltas por Boris:**
1. **Gate F1/F2a** (`Los 5 Finales.md`): el portador se detiene y cede la decisión al
   jugador — un **mensajero del Council** completa la entrega si nadie interviene. Ya no
   es "el Pivote completa la entrega por defecto".
2. **Orden de "El Primero"** (formación del grupo, Acto 1): **Roen → Valen → Pivote →
   Darro**, fijo para las 12 fichas (antes había dos versiones incompatibles: fijos-ya-están
   vs Pivote-ya-está).
3. **Bautizo de Speck**: manda `Speck.md` — ocurre en Acto 2, cuando el grupo entero ve su
   comportamiento inteligente. Se movió de Acto 1 (dormida en la crisálida) en la ficha de
   Darro, que además ahora se une último al grupo, no desde el inicio.
4. **Gate F3**: el jugador cruza el borde **sin** Speck en la mano; el portador la suelta
   después de que cruza.

**13 CRITICAL resueltos** — las 4 decisiones arriba, propagadas a `Los 5 Finales`,
`Estructura Dramática`, `Geografía y Ciudades`, y las 12 fichas; más 9 fixes de propagación
mecánica: `Speck.md §Capa 4` pasó de 3 a **4 grados de agencia** (cedida ≠ arrebatada — F2a/F3
no matan a Speck, solo F2b) y se propagó a `Briefs de Concept Art:187`; agente sustituto
(Torgan/equipo de extracción) completado en F3/F4 de Bram y Nyael; Vekka corregida a Acto 1
en dos lugares distintos de su propia ficha (se auto-contradecía); "Darro reclutado en el
Driftmarket" purgado de la ficha de Bram (ya estaba resuelto en 6 archivos, solo faltaba
propagarlo); los 5 años de servicio de Dagna, mal atribuidos a Roen en 2 líneas, corregidos
a "el jugador"; topología de Cinder Ascent realineada a Ignis Reach en 3 lugares de
`Geografía y Ciudades` (tenía 2 líneas asignándola a Aethelgard); Valen F2b y Roen F2b
reescritos — el primero afirmaba que la muerte de Speck "era inevitable" (contradice la regla
física de `Speck §Capa 5`), el segundo violaba la prohibición de tono de F2b ("ningún beat de
aprendimos algo") con una línea casi idéntica a su propio F2a.

**Quedan MEDIUM sin tocar para la 8ª** (no bloquean): mapeo Elder Circle→Final con dos
versiones sin fuente declarada, si "exactamente tres flashes" sigue siendo regla (hay 4
menciones de flashes extra en el texto), línea de Tobin sin traducción fiel del guión,
aritmética de Torgan (20-72 → debería ser 20-75), hueco de 5 años en la cronología de Dagna,
duplicación parcial del bloque de Old Tobin en `Geografía`, repeticiones de imagen entre
epílogos (muerte de Maren/Vekka/Dagna, gesto de Torgan/Iven, tratado fantasma de Sereth),
símbolo tallado de Darro que nunca aparece en su F3.

**Estado: `check_canon.py` en 0 críticos / 0 MEDIUM tras los fixes, `check_vault.py` 🟢
(~3,6k).**

### Pendiente inmediato

**8ª re-corrida QA con 2 subagentes Opus en frío** — validar que los 13 CRITICAL cerraron de
verdad y no reabrieron nada antes de declarar el sprint cerrado. Las 2 decisiones de diseño
pendientes (Elder Circle, conteo de flashes) quedan para resolver con Boris antes o durante
esa corrida.

## [2026-08-02] sprint/QA-verificación | 8ª re-corrida — ~9 CRITICAL + 16 MEDIUM, los fixes no habían bajado a los epílogos

**Diagnóstico:** los 6 fixes de la 7ª ronda quedaron bien en las fuentes (`Los 5 Finales`,
`Geografía y Ciudades`, `Speck.md §Capa 4/5`), pero el barrido no llegó a los **45 epílogos**
donde vive la ejecución real de los gates. Mismo patrón de siempre: fix a la línea reportada,
no a la clase completa.

**1 decisión nueva de Boris:** en las rutas Torgan, Iven y Vekka el Pivote llegaba al
**centro** del cráter con Speck (no al borde como las otras 6 rutas), lo que obligaba al
jugador a cruzar el borde para alcanzarlo — disparando F3 por defecto e imposibilitando
F1/F2b/F4 en esas 3 rutas. Se resolvió moviendo a los 3 Pivotes al borde, igual que las
otras 6 — cambio de staging, no de gate.

**Fixes aplicados:**
- **Gate F1 reescrito en 7 epílogos** con el mensajero correcto de cada cadena institucional
  (el enunciado "7 rutas: mensajero del Council" en `Los 5 Finales` era falso — 4 de esas 7
  usan su propio mensajero): Maren y Sereth (Council directo), Dagna→Deepstone, Torgan→su
  clan menor, Vekka→Great Forging Clan, Lyris→Frontier High Command, Iven→contacto del
  Consortium. Dagna y Vekka tenían el gate invertido (el jugador detenía al Pivote, no al
  mensajero); Lyris cedía sola, sin acción del jugador.
- **Sub-beat 5 de Vekka reescrito por completo** — seguía siendo la versión vieja: desmontaba
  el core central sola, con Speck atada a un yunque, sin ningún mecanismo de espera/mensajero.
  Ahora se detiene en el borde con su propio yunque portátil, y el mensajero del Great Forging
  Clan sube desde el cráter a buscarla — se preserva toda la caracterización de oficio/ritual.
- **Bautizo de Speck** — `Speck.md` (la fuente declarada de los Momentos de Persona) seguía
  rotulando el Momento 2 como Acto 1; se movió a Acto 2 y se reordenaron los Momentos 2/3 en
  consecuencia. Residuo en `Geografía:808` también corregido.
- **`Estructura Dramática:29`** ya no dice que el Pivote traidor concluye "esto debe morir" —
  contradecía todo el canon (matar a Speck no cura nada). Ahora dice que busca entregarla viva
  a su institución. Eco corregido en `Roen-Ficha:218`.
- **Agencia de Speck**: `Briefs de Concept Art` todavía decía "3 grados" en dos encabezados
  pese a que la tabla ya tenía los 4 correctos desde la 7ª ronda — corregido.
- **Topología**: `Briefs de Mapa del Mundo` repetía el error de Cinder Ascent que ya se había
  cerrado en `Geografía` — el barrido de la 7ª ronda no había salido de ese archivo.
- **Flashes**: `Grove of Cycles:27` llamaba "Flash privado" al evento del Vector C, que en
  realidad es el Momento de Persona 6 — desambiguado. Encabezado "Grove of Cycles (a mitad del
  Acto 2)" corregido a "cierre del Acto 2" en las 10 fichas que lo replican (la fuente ya se
  contradecía a sí misma sobre cuándo ocurre).
- Menores: Vekka agregada a la fila "Deber Institucional" en 3 fichas donde faltaba, wikilink
  roto de "protocolo del silencio" por salto de línea en `Speck.md` corregido, cita rota de
  los Goggles en `Geografía:1140` (apuntaba a §ACTO 2 Interludios, es §THE RECKONING).

**Quedan MEDIUM sin tocar** (no bloquean): línea de Tobin sin traducción fiel, aritmética de
Torgan, hueco de 5 años en cronología de Dagna, duplicación de Old Tobin en `Geografía`,
símbolo tallado de Darro ausente en su F3, sujeto de la cesión sin resolver en el F1 de Nyael.

**Estado: `check_canon.py` en 0 críticos, `check_vault.py` 🟢.**

### Pendiente inmediato

**9ª re-corrida QA con 2 subagentes Opus en frío** — criterio de cierre: 0 críticos de ambos.
Si el patrón se repite (fix en la fuente, no propagado a fichas), buscar dónde más puede estar
pasando esto antes de declarar cerrado cualquier futuro sprint.

## [2026-08-02] sprint/QA-verificación | Barrido de MEDIUM de la 8ª ronda — 6 cerrados, 1 verificado como no-error

Boris pidió cerrar los MEDIUM que quedaron abiertos de la 8ª re-corrida antes de lanzar la 9ª.

- **Error de raza de Tobin.** `Old-Tobin-Hale-Ficha-Expandida-v1.md:94` decía que el error de
  Tobin siempre apunta al fijo de la **raza equivocada**; la tabla fuente en
  `Geografía y Ciudades.md:923-939` (mucho más detallada, con los 9 casos por Pivote) dice que
  apunta al fijo de la **misma raza** que el Pivote real. Corregido para citar la tabla como
  fuente.
- **Hueco de 5 años en la cronología de Dagna.** El encargo del Great Forging Clan (hace 10
  años) y su llegada al puesto de escolta (hace 5 años) dejaban 5 años sin explicar en el
  medio. Se fusionaron los dos eventos: el encargo pasó a "hace 5 años" y ella llegó casi de
  inmediato — el contrato de 5 años vence justo en el presente de la historia, lo cual además
  suma tensión al clímax en vez de ser un hueco.
- **Edad de Dagna sin cerrar.** `Dagna:11` daba un rango "90-100 años" que no cerraba con la
  aritmética del resto de la ficha. Fijada en **100 años** (encabezado "edades 40-90" corregido
  a "40-100" para que las cuentas cierren con "sesenta años de muralla").
- **Duplicación de Old Tobin.** `Geografía y Ciudades.md:709-735` reproducía en prosa la bio,
  el contraste con el elenco político y la línea canónica que ya vive en
  `Old-Tobin-Hale-Ficha-Expandida-v1.md` — el mismo patrón que obligó a archivar 4 fichas
  cortas en la 5ª ronda. Colapsado a un puntero de 3 líneas; la ficha expandida queda como
  fuente única.
- **Símbolo tallado de Darro ausente en su F3.** `Los 5 Finales.md:106` lo fija como su
  despedida ritual (deja su símbolo tallado en la mesa del último campamento); su propia ficha
  no lo mencionaba. Agregado.
- **Sujeto de la cesión sin resolver en Nyael.** En su ruta, el equipo de extracción intentaba
  "completar la entrega" sin quedar claro que la tenían en brazos — la física de
  `Speck.md §Capa 5` exige que alguien la sostenga y la ceda para que el pulso se corte.
  Reescrito para que el equipo la sostenga explícitamente desde el sub-beat 5.
- **Aritmética de Torgan (20-72) — verificada, no era un error.** El encabezado cubre su
  servicio *previo* a la Misión Clasificada que arrancó "hace 3 años" sobre una edad actual de
  75 (72 + 3 = 75). Ya lo había señalado la 8ª ronda; se confirma y se saca de la lista de
  pendientes.

**Quedan, no bloqueantes:** traducción al inglés de la línea de Tobin (parte de la pasada de
guión completo pendiente), doble asignación de cuadrante en el POI de entrada de Stillwood en
`Briefs de Mapa del Mundo` (categoría ya documentada de ~16 POIs con este problema, sin
prioridad propia).

**Estado: `check_canon.py` en 0 críticos, `check_vault.py` 🟢.**

### Pendiente inmediato

**9ª re-corrida QA con 2 subagentes Opus en frío** — sigue siendo el criterio real de cierre
del sprint.

## [2026-08-02] sprint/QA-verificación | 9ª re-corrida — 7 CRITICAL únicos + varios MEDIUM, mismo patrón otra vez

**QA-Dramática: 7 CRITICAL + 9 MEDIUM. QA-Congruencia: 5 CRITICAL + 13 MEDIUM** (con
superposición entre ambos). Confirmado lo bueno primero: el staging borde/centro y la
identidad del mensajero por ruta habían cerrado bien en 7 de las 9 fichas, igual que el
bautizo en Acto 2, el tono de F2b, y los 4 grados de agencia. El patrón que se repite ronda
tras ronda es el mismo: **la fuente se corrige, la propagación hacia atrás (sub-beats
anteriores en la misma fuente) o hacia las fichas que no estaban en la lista de esa ronda
queda sin barrer.**

**7 críticos únicos, todos de propagación — ninguno pidió decisión de diseño nueva:**

1. **`Geografía y Ciudades.md` se contradecía a sí misma.** El sub-beat 4 (persecución)
   todavía decía "dejarlo llegar hasta el centro con Speck" y "la carga hacia el centro en
   todos los casos" — 7 líneas antes de que el sub-beat 5 dijera "siempre en el borde, nunca
   en el centro". El sub-beat 5 se corrigió en la 8ª ronda; el 4, nunca.
2. **La orden institucional de Vekka seguía siendo "destruir", no "entregar viva".** Se
   reescribió su escena de cráter en la 8ª ronda, pero la premisa que la origina ("a flawed
   forging must be unmade by its maker", "Termínala. Unmake it.") seguía sonando a muerte,
   contradiciendo `Estructura Dramática:29` (entregar viva). **Resuelto con el precedente que
   la propia ficha ya tenía:** Vekka "deshizo" a Darro hace 30 años sin matarlo — lo expulsó
   del programa. "Unmake" nunca significó matar; significa terminar el proceso. Se reescribió
   la Esencia de la ficha para dejar esto explícito, y se ajustó la orden citada.
3. **Vekka se contradecía sobre si toma a Speck en el corredor.** Un sub-beat decía que no
   ("Vekka no toma a Speck en el corredor... espera que Speck le sea llevada"), la escena del
   cráter la tenía llegando con Speck en brazos. Reescrito el sub-beat 3 para que la tome en
   el corredor como las otras 8 rutas — "no hay versión en la que Speck llegue al cráter
   sola" es regla sin excepciones.
4. **F3 de Vekka era físicamente imposible.** El arnés que la fija al yunque no tenía ningún
   mecanismo de liberación que no contara como forcejeo. Agregado el beat "suelta el arnés al
   verlo cruzar", igual que las otras 8 rutas.
5. **Maren F2a trataba a Speck como muerta** ("millones viven porque una murió"), en el único
   final donde queda viva. Reescrito. De paso, purgado un residuo de la premisa vieja
   ("sacrificar variable crítica") en la motivación del Council hacia Maren.
6. **Bram tenía un mensajero fantasma.** Su sub-beat 5 decía que Torgan "se detuvo... a
   esperar al mensajero" — inventando un tercero que el propio gate de F1 no contempla:
   Torgan **es** el agente a neutralizar, no alguien que espera a otro. También se cerró una
   vía de muerte imposible en su F2b ("del punto de entrega, si ya había sido tomada" — si ya
   fue entregada, el pulso se cortó y no puede morir ahí, per `Speck.md §Capa 5`).
7. **Sereth usaba "mensajero del Council"** en 3 lugares de su ficha y en la clasificación de
   `Los 5 Finales:22`, pero su cadena real es la Royal Academy vía Queen Ithessa — nunca
   negoció con el Council directamente. Corregido en ambos archivos.

Más un fix estructural: **Dagna tenía el vector de aproximación del mensajero invertido**
("espera al fondo del cráter" / "viene bajando hacia el centro" — el patrón correcto en las
otras 4 rutas con mensajero físico es "sube desde dentro hacia el borde"). Y **faltaba el
beat "el Pivote suelta a Speck al ver cruzar al jugador"** en el F3 de Maren, Sereth y Dagna
(Vekka se resolvió con el fix #4 de arriba).

**Estado: `check_canon.py` en 0 críticos, `check_vault.py` 🟢.**

### Nota de método — el costo por ronda no está bajando

Cuatro rondas seguidas (6ª→9ª) encontraron críticos del mismo mecanismo: un fix en la fuente
no se re-grepea hacia atrás (otros sub-beats de la misma fuente) ni hacia los lados (fichas
que no estaban en el radar de esa ronda). Si la 10ª repite el patrón, vale la pena parar de
parchar línea por línea y hacer una pasada de reescritura completa de las 9 escenas de
cráter como una sola unidad coherente, en vez de seguir corrigiendo por ronda.

### Pendiente inmediato

**10ª re-corrida QA con 2 subagentes Opus en frío** — criterio de cierre: 0 críticos de ambos.

## [2026-08-03] design/arquitectura | Sesión de diseño — se corta el ciclo de re-corridas con un fix estructural

**Contexto:** 10 re-corridas de QA, cinco de ellas (6ª-10ª) con el mismo mecanismo de falla y
sin bajar el volumen de críticos (13 → ~9 → 7 → ~10). Boris planteó que repetir el método
esperando otro resultado no iba a funcionar, y pidió una sesión de diseño con entregable de
plan en vez de otra ronda de parches. Tenía razón.

**Diagnóstico:** la escena del cráter mezcla dos capas en un mismo texto — una **mecánica**
(idéntica en las 9 rutas salvo parámetros) y una **dramática** (única por Pivote). La capa
mecánica estaba copiada a mano en **13 archivos**: 9 fichas de Pivote + Roen + Valen + Darro +
`Los 9 Pivotes`. Cada corrección de regla exigía 13 transcripciones con redacción propia. No
era un problema de disciplina en el barrido: era un método que garantizaba divergencia y que
además no dejaba nada verificable por el linter.

**Las 4 clases de error, con evidencia de 4 rondas:** (A) parámetro divergente — mensajero del
Council vs cadena propia, vector de aproximación, borde vs centro; (B) regla global
re-enunciada con variación — gate de F4 con condición inventada, "unmake"=matar, reloj de
maduración; (C) beat obligatorio faltante — soltar a Speck en F3, el mensajero apartándose en
F4; (D) cita cruzada podrida — cuatro archivos describiendo el quiebre de Vekka como su
epílogo F2b.

**Decisiones de Boris:** (1) el gate de F4 son 2 condiciones globales y **ninguna depende del
Pivote** — en consecuencia cada epílogo F4 se escribe en dos variantes, Pivote vivo y Pivote
muerto; (2) fuente única en ficha nueva dedicada; (3) reescritura quirúrgica, preservando toda
la prosa dramática ya ratificada.

**Fases 1-5 ejecutadas en la misma sesión** (plan completo en
`~/.claude/plans/plan-craterculata-fix-arquitectura-crater.md`):

- **F1 —** `10-Knowledge/El Cráter — Matriz de Rutas.md`: secuencia fija de 7 pasos, tabla de
  parámetros por ruta (cadena institucional, mensajero, quién sostiene a Speck, excepciones),
  los 5 gates enunciados una sola vez, beats obligatorios por final, y las 7 reglas globales
  que las fichas citan y nunca reformulan.
- **F2 —** `Los 5 Finales` y `Geografía §ACTO 3` podados. El primero se queda con filosofía,
  sabor, líneas canónicas y ecos Bond; el segundo, con el lugar. Los dos archivos que se
  autocontradijeron entre secciones vecinas en las rondas 9ª y 10ª ya no enuncian mecánica.
- **F3 —** las 9 fichas heredan (verificado: 9/9 citan la matriz, 0 residuos del gate de F4
  inventado). Se cerraron de paso todos los críticos de la 10ª y se escribieron las 7
  variantes de epílogo F4 "Pivote muerto".
- **F4 —** los 3 fijos y `Los 9 Pivotes`, barridos **por primera vez en todo el sprint**. De
  ahí había salido la clase D entera.
- **F5 —** 6 chequeos nuevos en `check_canon.py` (18 clases en total): `crater-mensajero`,
  `crater-borde`, `gate-f4`, `premisas`, `crater-beats`, `quiebre-fijos`. Verificados contra
  un fixture con los errores reales de la 10ª: los cazan todos, y dan 0 falsos positivos sobre
  el vault corregido.

**Reglas de canon nuevas que salieron del trabajo:**
- **En F4, Speck cruza el borde sola.** Nadie la carga al core central — eso la devolvería a
  la categoría de objeto que ese final existe para negar. Es el reverso exacto de F3.
- **Nyael y Bram no tienen variante de epílogo "Pivote muerto"**, y es intencional: al jugador
  nunca se le presenta la oportunidad de matarlos.
- **Los superlativos de reacción de los fijos** ("la única vez que Darro se queda mudo") tienen
  que existir en un solo lugar del vault. Dos fichas habían reclamado el mismo para escenas
  distintas.
- **La variante muerta no agrega tragedia genérica** — cobra algo específico que solo ese
  personaje podía dar. Si se resume como "y además murió", está mal escrita.

**Regla de método nueva:** si un QA encuentra un crítico de una clase que el linter ya cubre,
**el bug es del linter** — se agrega el chequeo, no se parcha la línea.

**Estado: `check_canon.py` en 0 críticos (18 clases), `check_vault.py` 🟢.**

### Pendiente inmediato

**11ª re-corrida (Fase 6)** — con las 4 clases mecánicas cubiertas por el linter, esta ronda
debería medir dramaturgia real por primera vez en el sprint.

## [2026-08-03] sprint/QA-verificación | 11ª re-corrida — el reporte cambia de naturaleza

**Primera ronda del sprint donde el QA no reporta errores de propagación.** El encargo a los
subagentes fue distinto: se les dijo explícitamente que **no re-verificaran lo mecánico** (el
linter ya lo cubre) y que si encontraban algo de esas clases lo marcaran como **bug del
linter**, no como hallazgo de ficha.

**Lo que validaron (y no existía antes):** `Matriz §2` y `§4` coinciden celda por celda con
las 9 fichas — las 9 cadenas, los 9 mensajeros, las 3 excepciones, las 7 variantes de F4. La
aritmética completa del elenco cierra (Torgan 75, Vekka 80, Darro 63, Bram 55, Dagna 100,
Lyris 180, Roen 45). Y las zonas que el sprint **nunca había tocado** — `The Tether`, `Bond y
el Bond Vacío`, `La Rueda`, `Nomenclatura`, `Progresión y Contrato`, `Old-Tobin-Hale` — están
sin contradicciones. Cita textual del reporte sobre la propagación del escudo de Roen en tres
archivos: *"cero divergencia — es el modelo de cómo debería verse el resto"*.

**Lo mecánico que quedaba, cerrado en esta pasada.** Los cinco eran defectos introducidos en
esta misma sesión:

- **`Matriz §1` tenía el orden mal.** La activación del Fragmento estaba en el paso 6 (después
  del mensajero) cuando ocurre al llegar al borde. No era cosmético: `Speck §Capa 5` dice que
  mientras los cores pulsan Speck no se deja transportar — que es *lo que sostiene la ruta de
  Nyael*. Con el orden mal, **F2a de Nyael era mecánicamente imposible**. Se agregó un **paso 0**
  explícito (el pulso viene desde el descenso al Archive) que además explica por qué las 9
  rutas terminan en el cráter y no en otro lado.
- **`Matriz §5` omitía la regla del tirón del cráter** — justamente la que seguía transcrita a
  mano en tres archivos. Agregada; Nyael ahora la cita en vez de re-narrarla.
- **La fila Vekka de `Los 9 Pivotes`** agregaba mecánica, violando la nota escrita tres líneas
  arriba en el mismo archivo.
- **Dos huecos del linter:** `quiebre-fijos` detectaba que un fijo *describiera* el quiebre
  pero no que lo *ubicara* mal — los 3 fijos lo tenían escenificado en el cráter cuando ocurre
  en el corredor. Y el corolario de superlativos estaba escrito en la Matriz y nunca
  implementado: "Darro se queda mudo, la única vez en la campaña" estaba reclamado por cuatro
  escenas.

**Dos chequeos nuevos (20 clases en total):** `quiebre-lugar` (agrupa por sección y acepta la
sección si declara dónde ocurrió la toma) y `superlativos` (un «única vez» de un fijo vale en
un solo lugar; acepta los que tienen eje declarado, tipo "el único **donde** X elige Y").
Verificados: cazan los hallazgos de la 11ª y dan 0 falsos positivos sobre el vault corregido.

### Pendiente — 3 críticos de homogeneización de prosa

Todos de la tanda de epílogos F4 escrita en esta misma sesión, y todos de la misma causa:

- **Torgan y Dagna F4-muerto son el mismo epílogo** con distintos sustantivos (papeleo ritual
  póstumo, consejo que delibera, registro que queda sin cerrar).
- **Torgan e Iven F4-vivo cierran con el mismo gesto** (bajar al cráter una vez al año, apoyar
  la palma sobre el core) — y la variante muerta de Torgan se lo dio también a Darro, así que
  el beat está triplicado. Es un buen beat; es **uno solo**.
- **5 de las 7 variantes F4-muerta usan el mismo molde:** *saber único que se pierde +
  institución que archiva la versión equivocada + jugador como custodio impotente*. Cuatro
  cierran con la misma frase estructural.

**Lección de método, para el vault:** escribir N variantes en secuencia contra la misma regla
**las homogeneiza**, aunque cada una cumpla la regla por separado. La regla de la Matriz ("la
muerte cobra algo específico que solo ese personaje podía dar") se cumplió una por una y el
conjunto igual falló, porque *lo específico terminó siendo idéntico*. La des-homogeneización
tiene que hacerse **comparando las variantes entre sí**, en una sola pasada — de a una vuelven
a converger.

### Pendiente — 2 decisiones de diseño para Boris

1. **El sabor de F4.** `Los 5 Finales` lo declara *agridulce, no triunfal*, pero hoy nueve
   personajes alcanzan su mejor versión y **solo Darro paga el agridulce** (con una nota de
   escritura que se lo ordena). Roen tiene una línea sin duelo. Es un problema de escala, no
   de tres fichas.
2. **Los grados de agencia de Speck.** De los 4 de `§Capa 4`, solo *responde* (F4) y
   *arrebatada* (F2b) están dramatizados. *Acepta* (F1) se paga en un solo lugar del vault
   (Darro F1) y *cedida* (F2a/F3) no tiene interioridad en ninguna parte: en los 12 epílogos
   F3, Speck es un objeto sin punto de vista.

## [2026-08-03] design/narrativa | Pasada de des-homogeneización — los 3 críticos de prosa de la 11ª

**Hecha en una sola pasada comparativa, no de a una ficha.** Ese fue el punto: los 3 críticos
venían de haber escrito 7 variantes de epílogo F4 en secuencia contra la misma regla, y
corregirlas por separado las habría vuelto a hacer converger.

**Método:** primero se asignó **un eje de pérdida distinto a cada una de las 7**, con la tabla
completa a la vista; recién después se reescribió. Tres se conservaron por orgánicas (Vekka —
el cuaderno; Sereth — la refutación; Torgan — el juramento sin enmendar) y cuatro cambiaron
de eje:

- **Maren → la redundancia.** Antes: "sus cálculos sobreviven y nadie recuerda de quién era la
  letra". Ahora: Rivermeet se reconstruye **sin ella y sin su modelo**, mal y lento, y funciona
  igual. Maren construyó su ética entera sobre *si yo no calculo, la gente muere* — y era lo
  que le permitía entregar a Speck sin romperse. La corrección de su tesis existe y **ella
  nunca la recibe**.
- **Iven → muere creyendo que falló.** Es el único de los nueve que traicionó por un resultado
  **medible** (doscientas personas, unos pozos). Todos los demás pueden morir sin saber si
  tenían razón; lo suyo se podía verificar. Y se muere entre saber que lo estafaron y saber
  que el asentamiento se salva igual. Consiguió exactamente lo que quería comprar y nunca lo
  supo.
- **Lyris → el timing.** No es lo que se pierde con ella, es **cuándo**. Noventa años en el
  margen, y el mundo nuevo de F4 es el primero que tiene lugar para alguien que lee corrientes
  y no pertenece a ningún reino. Muere el día anterior a eso.
- **Dagna → Roen.** Se sacó el pergamino póstumo entero (colisionaba con Torgan). Su epílogo
  ahora es relacional: los dos hicieron la misma pregunta con la vida, **el mundo le dio la
  razón a Roen por accidente**, y él carga esa respuesta levantando otra vez el escudo que
  dejó caer en el cráter y no soltándolo nunca más.

**El gesto de la palma sobre el core** estaba en tres lugares (Torgan F4-vivo, Iven F4-vivo,
Darro en Torgan F4-muerto). Queda solo en **Torgan**, que tiene la raíz establecida — el mismo
gesto que le hizo a la piedra del Archive. Iven recibe uno propio y agrícola: lleva **un
cántaro de agua del pozo que volvió** y la vuelca al borde del core. Darro, en la variante
muerta de Torgan, hace algo que solo él puede hacer: **se agrega al propio tatuaje incompleto
la línea que le habrían puesto a Torgan** si hubiera llegado vivo al consejo. Ningún tatuador
enano debería habérselo grabado; encuentra uno que sí.

**MEDIUM de prosa compartida, también cerrados:** Maren y Sereth ya no comparten la frase de
F2a ("los ojos midiendo") ni el remate de F3 — ahora se diferencian por lo que hacen con la
caída del tirano (Maren anota el reloj y no lo toca; Sereth interviene). Maren y Vekka ya no
comparten el párrafo molde de F2b. Lyris y Nyael ya no comparten "el silencio que habría
diseñado": ahora la ficha de Lyris **usa el contraste explícitamente** — Nyael desaparece
porque la ausencia es su método, Lyris porque nunca aprendió a estar presente.

**Registrado en la Matriz §4:** la tabla de los 7 ejes (para que la próxima tanda arranque con
los ejes repartidos) y la lección de método como advertencia obligatoria antes de escribir
variantes en tanda.

**Estado: `check_canon.py` en 0 críticos (20 clases), `check_vault.py` 🟢.**

### Pendiente

**2 decisiones de diseño para Boris**, ambas de la 11ª y ninguna resoluble sin él: el sabor de
F4 (hoy se lee como final feliz — solo Darro paga el agridulce declarado) y los grados de
agencia de Speck (*cedida* no tiene interioridad en ninguna parte del vault). Después de eso,
**12ª re-corrida**.

## [2026-08-03] design/narrativa | Sabor de F4 — beat de duelo obligatorio en las 9 rutas + fijos

**Decisión de Boris:** "Beat de duelo obligatorio en las 9 (Recomendado)" — de las 3 opciones
planteadas (solo los 3 fijos cargan el peso / excluir a Bram / obligatorio en las 9), se eligió
que **todo epílogo F4-vivo** lleve un beat de duelo específico, no genérico, escrito **en una
sola pasada comparativa** para no repetir el error de homogeneización de la ronda anterior.

**Diagnóstico:** de 9 rutas + Roen (fijo), solo Darro y Valen tenían el costo agridulce
declarado en [[Los 5 Finales]] §F4 realmente dramatizado. Los otros 8 cerraban en triunfo puro
— Speck cruza, el mundo sana, nadie paga nada personal.

**Método:** mismo que los 7 ejes de F4-muerta — tabla de ejes asignada *antes* de escribir,
para que cada uno sea mecánicamente distinto de los demás. Los 9 (+Roen):

| Personaje | Eje |
|---|---|
| Roen | lo dice en voz alta — distingue actuar bien de salir ileso |
| Torgan | el cuerpo recuerda cargarla; el hábito no se rompe |
| Iven | se excluye a sí mismo de la historia que cuenta |
| Dagna | no puede volver al cráter transformado |
| Vekka | deja una pieza sin cerrar — rompe su propia regla |
| Lyris | vuela sola sobre el cráter, no lo cuenta |
| Nyael | escribe una nota que no tiene a quién entregar |
| Bram | casi talla un nombre en la pulsera y no lo hace |
| Maren | deja de usar una variable sin decírselo a nadie |
| Sereth | intenta escribir la pregunta que le falta y tacha la mitad |

**Roen** recibe además una reescritura completa de su sección F4 (antes era una sola línea de
"ve el futuro"): ahora es quien, esa misma noche y a solas con el jugador, dice la parte que
no iba a decir — *"You did it right. That doesn't mean you get to keep her."* Es la única vez
en el juego donde distingue haber actuado bien de haber salido ileso.

**Maren y Sereth** ya tenían cobertura parcial de una ronda anterior (recalibración
profesional); se reforzó con el eje específico de arriba para que el duelo sea por la persona,
no solo por el método.

**Registrado en la Matriz** (`El Cráter — Matriz de Rutas.md` §4, nueva sub-sección "La
variante viva — beat de duelo obligatorio") como regla + tabla de los 9 ejes, con la misma
advertencia de método que la tabla de F4-muerta.

**Estado: `check_canon.py` en 0 críticos / 0 medium (20 clases), `check_vault.py` 🟢.**

### Pendiente

**1 decisión de diseño para Boris**: los grados de agencia de Speck (*cedida* no tiene
interioridad en ninguna parte del vault). Después de eso, **12ª re-corrida** (criterio de
cierre del sprint: 0 críticos de 2 subagentes Opus en frío).

## [2026-08-03] checkpoint | Cierre de sesión

`Current-State.md` reordenado: la decisión de agencia de Speck queda como primer ítem de
"Inmediato" para arrancar la próxima sesión directo ahí, seguida de la 12ª re-corrida y recién
después la pregunta de bonds de fijos. Se corrigió además una referencia stale a "7ª
re-corrida" en `## Estado general` que había quedado de antes del fix de arquitectura —
apunta ahora a la 12ª.

**Estado al cierre:** `check_canon.py` 0 críticos / 0 medium (20 clases). `check_vault.py`
🟢, arranque de sesión ~3,670 tokens. Working tree limpio tras commit + push.

## [2026-08-04] design/narrativa | Agencia de Speck — "cedida" recibe un beat mínimo

**Decisión de Boris:** "beat mínimo de conciencia sin agencia (Recomendado)" — de las 3
opciones planteadas (dejarlo intencionalmente vacío / interioridad solo en el epílogo / un
beat mínimo escrito una vez y citado), se eligió la última.

**Diagnóstico:** `Speck.md §Capa 4` declara 4 grados de agencia (F4 consentimiento, F1
aceptación, F2a/F3 cedida, F2b arrebatada), pero de los 7 epílogos F3 que la tienen en escena
bajo el régimen del tirano (Maren, Sereth, Torgan, Dagna, Iven, Nyael, Lyris), ninguno le da
una sola línea de punto de vista. Revisión más fina: solo **Maren y Sereth** conviven con ella
durante años (son las únicas dos que se quedan sirviendo al tirano); Torgan/Dagna/Iven/Vekka
mueren confrontando al jugador en el mismo instante del cruce, Nyael/Lyris se retiran antes de
que empiece el régimen, y Bram nunca llega a verla encadenada. El vacío de interioridad
afectaba en la práctica solo a las dos fichas que realmente la tienen presente en el tiempo.

**El beat:** Speck sostiene la mirada de quien la retiene, sin apartarla — ni desafío ni
súplica, la misma atención inmóvil de un animal no domesticado ante lo que no controla.
Confirma que hay alguien adentro sin cruzar a voluntad ni consentimiento: no es una pregunta
que ella responde (exclusivo de F4) ni una resistencia que ella opone (eso la mataría, `Speck
§Capa 5`).

**Fuente única:** `Speck.md §Capa 4`, en la bala de "cedida". `Los 5 Finales §F3` cita el beat
sin reescribirlo (regla de fuente única). Maren y Sereth reciben una línea cada una,
diferenciada por cómo cada quien *no* la lee: Maren, que fuerza todo a una variable, es la
única cosa de su modelo que nunca logra leer; Sereth, que lee intenciones hace 200 años,
decide no leerla porque hacerlo sería tratarla como un dato más.

**Estado: `check_canon.py` 0 críticos / 0 medium (20 clases), `check_vault.py` 🟢.**

**Cierra la última de las 4 decisiones de diseño abiertas de la 11ª ronda** (gate F4,
homogeneización F4-muerta, sabor de F4, agencia de Speck — las 4 resueltas). Solo queda la
**12ª re-corrida** para cerrar formalmente el sprint.

## [2026-08-04] sprint/QA | 12ª re-corrida — 6 críticos encontrados y cerrados

**2 subagentes Opus en frío** (QA-Dramática, QA-Congruencia), sin contexto de los fixes
previos, sobre el vault completo. Resultado combinado: **6 críticos únicos** (con
solapamiento entre los dos reportes), ~15 medios, ~13 menores. El sprint no cerró en esta
pasada — se resolvieron los 6 críticos y una porción sustancial de los medios en la misma
sesión.

**Los 6 críticos y su fix:**

1. **"Darro se queda mudo" reclamado por 4 escenas** (cráter de Vekka, traición de Dagna,
   Darro+Roen sentados, The Reckoning) — el corolario de superlativos de `Matriz:249` estaba
   escrito pero el chequeo del linter no cubría las variantes de frase ("única traición",
   "no tiene broma lista"). **Fix de contenido:** Vekka conserva el "se queda mudo" literal
   (el más cargado, ligado a su propio pasado); Dagna pasa a "no le sale ningún chiste"
   (pierde el registro, no la voz); The Reckoning pasa a "titubea un segundo". **Fix de
   linter:** `RE_SUPERLATIVO` extendido con "la única traición", "el único de los nueve",
   "la única que" — 21 clases en total.
2. **Lyris sin beat obligatorio en F1 y F2b** — única de los 45 epílogos así. F1: ahora se
   queda sosteniendo a Speck (no la suelta sola). F2b: gate agregado, el jugador se la
   arranca en el aire.
3. **Los 10 epílogos F4-vivo homogeneizados en FORMA** (9/10 "secreto que no comparte con
   nadie", 3 con "peregrinaje anual al cráter" literal) — pese a que el contenido de cada
   eje ya era distinto. **Segunda lección de método registrada en `Matriz §4`:** contenido
   distinto con forma idéntica sigue siendo homogeneización. Fix: eliminado el peregrinaje
   duplicado de Torgan (quedó solo en Iven); Lyris y Maren pasan a visibilidad parcial (el
   jugador/un tercero nota algo sin que se explique) en vez de secreto total.
4. **Iven F2b le sacaba la agencia al jugador** ("se murió antes de que nadie decidiera
   nada") — reescrito: el jugador se la arranca activamente, Iven lo ve de cerca.
5. **Ruta Nyael reinventaba la física del Fragmento** (el equipo forcejea junto al core y
   Speck sobrevive, con un "se corta el hive mind al dejar de forcejear" inexistente en
   ninguna otra parte). **Fix en la fuente:** nota de excepción nueva en `Matriz §2`
   explicando cómo se satisface el beat de F2a cuando holder = agente (el equipo simplemente
   espera, como cualquier mensajero retenido — no forcejea, no hay mecánica nueva). La ficha
   de Nyael se reescribió para citarla.
6. **"Solo Dagna rompe a Roen" contradicho dentro del mismo archivo que lo canoniza** —
   residuo de propagación, no decisión nueva: `Dagna-Ficha` corrige explícitamente el
   hallazgo ("es Dagna, no Lyris") y 300 líneas después lo reintroduce. Restaurado en las 3
   menciones (`Dagna-Ficha`, `Roen-Ficha` ×2) a "Sereth y Lyris doblan, Dagna rompe".

**Una decisión de diseño real, no residuo, consultada a Boris vía AskUserQuestion:** Iven
declara "soy el único de los 9 Pivotes que llora en escena", pero Dagna tenía un sub-beat
titulado "la única que llora" con múltiples menciones, y Geografía le daba a Bram una línea
de "llora aquí, única vez". **Decisión de Boris:** Iven conserva la exclusividad; Dagna pasa
a "se le quiebra la voz, una lágrima suelta" (no llanto); Bram pierde el "única vez". Barrido
completo de la clase en `Dagna-Ficha` (×4), `Los 9 Pivotes`, `Slice of Bond`, `Geografía`,
residuo cruzado en `Iven-Ficha:724`.

**Medios cerrados en la misma pasada (no exhaustivo, ver commit):** rango "§1, pasos 1-7"
corregido a "1-6" en 7 fichas + la plantilla de la Matriz (el rango real es paso 0 + pasos
1-6); puntero circular entre `Speck.md` y `Los 5 Finales.md` sobre el beat de "cedida"
resuelto (fuente única real: `Speck.md`); eco Bond de F3 aclarado (la traición corta el Bond
aunque la persona se quede sirviendo); línea canónica de Sereth restaurada a inglés (única de
las 9 que estaba en español, con nota de traducción pendiente para la escena completa); edad
de Bram en línea privada corregida (60→55); Geografía de "Bram's Last Stand" reescrita
(desgaste administrativo, no masacre puntual — contradecía la biografía de la ficha); Dagna
F2b/F3 con lenguaje mecánico corregido (mensajero no puede ser holder; "eso la mataría", no
"eso mataría al Fragmento"); 8 epílogos sin cita de gate ahora la tienen (Iven F2a/F3, Sereth
F3, Torgan F3, Nyael F2a/F2b); Vekka's doble "única grieta" escalado (persecución = menor,
cráter = la grande); M3 Roen/Valen (ambos "explicaban lo mismo" en F4) resuelto acotando la
exclusividad de Roen a "él mismo lo distingue", no "es el único que se lo dicen al jugador".

**Estado: `check_canon.py` 0 críticos / 0 medium (21 clases), `check_vault.py` 🟢.**

### Pendiente

Quedan menores sin cerrar (ubicación de la negociación de Maren en Geografía vs su ficha,
Sereth "calculista" vs su propio contraste declarado, cruce de fechas Maren×Roen contra la
cadencia de Regents, aritmética interna de Nyael, fuerza mecánica de Nyael sobre Speck en el
corredor) — no bloquean el cierre del sprint. **13ª re-corrida** pendiente de lanzar.

## [2026-08-04] sprint/QA | 13ª re-corrida — 4 críticos únicos, todos de residuo

**2 subagentes Opus en frío**, sin contexto de los fixes de la 12ª. Resultado combinado
(con solapamiento): **4 críticos únicos**, ~10 medios, ~11 menores. Ninguno fue una decisión
de canon nueva — los 4 eran **residuo**: la 12ª ronda arregló la línea reportada y no barrió
la clase completa, o un fix de la 12ª introdujo un bug nuevo sin querer.

**Los 4 críticos y su fix:**

1. **"Darro se queda mudo" seguía colisionando** — la 12ª ronda arbitró el desempate en
   `Dagna:439` (Vekka conserva el literal, Dagna pasa a "no le sale ningún chiste") pero no
   tocó las 3 menciones que seguían reclamando el superlativo para la escena de Dagna+Roen:
   `Darro-Ficha:402`, `Valen-Ficha:391`, `Dagna-Ficha:441`. Las tres reescritas a "elige el
   silencio pudiendo hablar" — ya no compiten por la mudez, que queda solo en Vekka.
2. **Bug nuevo introducido en el fix de Lyris F1 (12ª ronda):** al escribir "se queda
   sosteniendo a Speck" se agregó sin querer "y él se la quita de los brazos" — es
   literalmente el gate de F2b (arrancarla cerca de un core activo) escrito dentro de F1.
   Corregido: la Muda se completa en sus brazos, nadie se la quita.
3. **Cadena institucional de Iven contradicha en `Estructura Política.md:305`** ("sin cadena
   intermedia") contra la fuente única de `Matriz §2` (Triune Council → Trade Consortium →
   agente sin nombre → Iven). Reescrita la tabla completa de cadenas enanas y de Iven en
   `Estructura Política` para coincidir con la Matriz, incluyendo los subclanes de Torgan y
   Dagna que también faltaban ahí.
4. *(Ya cerrado por un fix hecho al inicio de esta misma sesión, antes de que terminaran los
   subagentes — QA-Congruencia lo confirmó de forma independiente sin saberlo.)*

**Medios cerrados en la misma pasada:** tabla de duelo F4-vivo de la Matriz corregida para
incluir a Darro y Valen (antes solo tenía a Roen entre los fijos, con conteos "9" y "10"
inconsistentes); `00-Index.md` seguía diciendo "7 pasos" después de que la 12ª normalizara a
1-6; `Los 5 Finales §F2a` describía a Nyael "entregando" a Speck cuando su ficha dice
explícitamente que es el equipo, no ella; `Slice of Bond` tenía a Dagna llevándose "el
Fragmento" en vez de a Speck; contradicción interna en el epílogo F4 de Bram (la pulsera "es
para los que perdió" invalidaba el propio beat de agregar el nombre del jugador, que no está
perdido); superlativo de Darro ("única vez que completa algo") alojado en la ficha de Torgan
sin contraparte en la ficha de Darro; residuo de staging en `Darro-Ficha:228` ("no puede
perseguir porque Speck ya se fue" cuando la Matriz dice que llega al borde en brazos del
Pivote, no ausente).

**Estado: `check_canon.py` 0 críticos / 0 medium (21 clases), `check_vault.py` 🟢.**

### Pendiente

Menores sin cerrar de rondas anteriores más los nuevos de esta (aritmética de Vekka 50 vs 60
años, "estuvo a un forcejeo de conseguirlo" en Iven, longevidad de los tres muertos que se
leen como continuidad inmediata, frase rota en Vekka:326). No bloquean. **14ª re-corrida**
pendiente de lanzar para confirmar el cierre.

## [2026-08-04] sprint/QA | 14ª re-corrida — 10 críticos únicos, patrón nuevo identificado

**2 subagentes Opus en frío.** Resultado combinado: **QA-Dramática 6 críticos**, **QA-Congruencia
4 críticos** (sin solapamiento esta vez — son clases distintas), más ~12 medios entre ambos.
**Diagnóstico de patrón, explícito en el propio reporte de QA-Dramática:** de los 6 críticos
dramáticos, 4 eran el mismo bug estructural — **superlativos de exclusividad copiados en 3
archivos distintos** (bloques "Superlativo Consolidado" idénticos en `Dagna-Ficha`, `Iven-Ficha`
y `Torgan-Ficha`), que las secciones "Esencia" de **Vekka** y **Nyael** podían contradecir sin
que ningún archivo lo notara — porque ninguno de los dos citaba la tabla, cada uno tenía su
propia frase.

**Fix estructural (no solo de línea):** se creó **`Los 9 Pivotes.md` §Superlativo Consolidado**
como fuente única de los 9 ejes de traición. Las 3 copias en Dagna/Iven/Torgan se reemplazaron
por una cita de una línea. Vekka ("la más fría" → "la más precisa") y Nyael ("la más peligrosa"
→ sin reclamo, cede a Maren) se alinearon con la tabla ya establecida en vez de competir con
ella. Mismo patrón que resolvió la Matriz del cráter en la 11ª ronda, aplicado ahora a un
segundo tipo de dato triplicado.

**Los otros críticos de QA-Dramática:** colisión residual "quién llora" (Dagna:243/261 seguían
narrando llanto sostenido pese al desempate de la 12ª — corregido a coherente con "una
lágrima"); "quién camina en vez de correr" (Dagna vs Vekka, diferenciado por motivo: Dagna para
ser alcanzada, Vekka por eficiencia); "único quiebre de fijo en el cráter" (Dagna:269 vs la
escena de Vekka/Darro, reformulado sin exclusividad); "cadena más corta" de Iven (factualmente
falsa contra `Matriz §2` — Maren/Vekka/Bram son más cortas; corregido a "la que menos rastro
deja").

**Los 4 críticos de QA-Congruencia — todos residuo del propio fix de cadenas institucionales de
la 13ª ronda:** al reescribir `Estructura Política.md` se insertó **King Borran** en las
cadenas de Vekka, Torgan y Dagna de forma pareja, cuando el canon real no es uniforme (Vekka no
pasa por Kadrun ni Borran; Torgan y Dagna sí pasan por Kadrun pero nunca por Borran). Reescritas
las 3 líneas contra `Matriz §2` exacta. `Torgan-Ficha:38` tenía además una "nota de cadena" que
citaba **verbatim** la versión vieja de `Estructura Política` para reconciliar una contradicción
que ya no existía — eliminada. Y `Roen-Ficha:199` / `Darro-Ficha:220` describían al Pivote
"llevándose el Fragmento" en el cráter — beat pre-Matriz (de cuando la traición ocurría ahí) que
sobrevivió en los dos fijos con prohibición de narrar mecánica; corregido a que Speck simplemente
reacciona, sin narrar qué pasa con el Fragmento.

**Medios cerrados:** tabla de duelo F4-vivo de la Matriz ajustada para Darro (colapsa en público,
no "a solas" — la ficha manda) y Roen (acotado a "él mismo lo distingue", no "el único que se lo
dice al jugador"); doble beat de duelo de Iven en F4-vivo (se quitó el peregrinaje repetido,
dejando solo la exclusión narrativa); Sereth F3 "de los pocos que se queda" → "el único"; segundo
beat de interioridad de "cedida" en el eco Bond de F2a (Los 5 Finales:68) reformulado a señal
mecánica, no respuesta con voluntad; superlativo de "traición más honesta" (Roen:282, de Sereth)
realineado a "la más íntima"; "tercer/cuarto track" de Frontier High Command unificado a tercero,
consistente con "las dos Academias"; rango "pasos 3-6" del equipo de extracción de Nyael
corregido a "3-5" (el paso 6 es del jugador); "única vez que no deja nota" de Nyael en Los 5
Finales alineado a "no escribe"; edad de Dagna corregida de 100 a 105 (la aritmética de la propia
ficha suma 40+60+5); diálogo Sereth/Roen sobre dejar la Royal Academy re-anclado como epílogo de
F1, no como algo que ya pasó durante la campaña activa.

**Estado: `check_canon.py` 0 críticos / 0 medium (21 clases), `check_vault.py` 🟢.**

### Pendiente

Queda sin resolver un hueco de canon genuino (no un dato roto): en la ruta Iven, quien mueve el
dinero de la promesa falsa es el Trade Consortium — que Maren dirige como Jefa de Ops — y ningún
archivo aborda ni excluye esa intersección bajo el canon de "los 9 existen simultáneamente".
No bloquea el cierre. Quedan menores de rondas anteriores + nuevos de esta sin cerrar.
**15ª re-corrida** pendiente de lanzar.

## [2026-08-04] design/worldbuilding | Bestiario, Flora, Villanos Menores — hueco de mundo abierto cerrado

**Diagnóstico de Boris:** el vault tenía worldbuilding narrativo completo (9 Pivotes, fijos,
Speck, geografía, política) pero **cero** contenido de mundo abierto: sin bestiario, sin flora
sistemática, sin ecosistemas por región, sin villanos menores, y los 5 dungeons ya bocetados en
`Geografía y Ciudades` no tenían bosses propios. Auditoría confirmó: 4 bosses ya nombrados sin
ficha (Crowned Leviathan, Burning Shepherd, Mirror Stalker, Aether Wyrm — cada uno con una sola
línea), fauna genérica dispersa sin sistematizar, flora solo ambiental ("musgo", "enredaderas"),
y 0 facciones antagonistas de mundo abierto.

**Decisiones de Boris antes de escribir:**
1. **Sin jefe final de mundo abierto** — el antagonismo real es institucional y personal (los
   Pivotes), no un villano de mapa. No se fuerza uno.
2. **Villanos menores: ambas capas** — facciones de las 3 razas existentes + 2-3 razas
   fantásticas nuevas, máximo.
3. **Jacarandá** (árbol favorito de Boris) plantado en Rivermeet, avenidas/plazas de la capital
   humana.
4. **Dungeons: solo formalizar los 5 ya bocetados** (Echoing Archive, Hollow Deep, Submerged
   Halls, Shattered Cascade, God's Throne), sin agregar dungeons nuevos — evita inflar más el
   alcance ya señalado como riesgo mayor del proyecto.

**3 archivos nuevos:**

- **[[Bestiario]]** — eje de salud del Aether (Sano → Ambiental → Corrupto → Aberración)
  aplicado a toda la fauna. Los 4 bosses ya nombrados reciben ficha completa (viven en landmarks,
  grado Aberración). 3 bosses nuevos completan los dungeons formales: **The Hollow Warden**
  (Hollow Deep, caza por eco), **The Drowned Choir** (Submerged Halls, 3-5 unidades coordinadas),
  **The Cascade Warden** (Shattered Cascade, alfa territorial no corrupto — la excepción). God's
  Throne queda deliberadamente sin boss nombrado: no debe competir con el peso de The First
  Wound, mismo principio de fuente única que protege los superlativos de personaje.
- **[[Flora y Ecosistemas]]** — mismo eje aplicado a plantas. **El Jacarandá de Rivermeet**:
  crece en la avenida principal, florece en púrpura una vez al año, plantado por alguien que
  nadie recuerda en una ciudad que no tiene tiempo para jardines — contraste deliberado con el
  pragmatismo de Rivermeet. Explícitamente **sin** grado de corrupción: no todo tiene que
  significar algo sobre Speck. Sistematiza también la Hoja de Maelys ya existente (ficha de
  Dagna, fuente única, no reescrita) y agrega 2 especies menores (Sauce de Vidrio, Musgo de Eco).
- **[[Villanos Menores]]** — Capa 1 (facciones de las 3 razas, ancladas a política ya escrita):
  **Compañías Impagas** (mercenarios humanos sin contrato — el destino que Bram esquivó),
  **Los Sin Nombre** (enanos expulsados de clan — la sombra de Torgan/Dagna), **Los No
  Licenciados** (elfos rechazados por ambas Academias, contrabando de Aether — eco distorsionado
  de Sereth). Capa 2 (2 razas nuevas, **no sapientes**, nacidas de la corrupción — no rompen
  [[Las Tres Razas]]): **Los Vaciados** (ex-personas mutadas por exposición a Aether corrupto,
  espejo oscuro de Speck — ella reacciona distinto frente a uno, sin diálogo que lo explique) y
  **Las Motas** (enjambre pequeño nacido de Aether cristalizado, alivio cómico, roban objetos
  brillantes).

**Propagación:** 2 líneas de reacción agregadas a fichas existentes (Bram ante las Compañías
Impagas, Torgan ante los Sin Nombre — *"Pude haber sido yo. Casi lo fui, dos veces."*); los 3
bosses nuevos asignados en `Geografía y Ciudades` (Hollow Deep, Submerged Halls, Shattered
Cascade); Mirror Stalker referenciado en Echoing Archive. `00-Index.md` actualizado con los 3
archivos nuevos.

**Estado: `check_canon.py` 0 críticos / 0 medium (21 clases), `check_vault.py` 🟢.**

### Pendiente

Mistbound Frontier sigue sin flora/fauna propia (anotado en `Flora y Ecosistemas`, no bloquea).
**Esta pasada entra al loop de QA mañana** (decisión de Boris) — no se lanzó ronda de re-corrida
hoy para este contenido nuevo.

## [2026-08-04] concept-art | Briefs de Bestiario para NB2 (9 prompts)

Boris pidió briefs de concept art sobre el bestiario recién diseñado, para correr en NB2 durante
la tarde. Agregada `Briefs de Concept Art.md` §13, siguiendo el formato ya establecido del
documento (bloque de estilo compartido, negativos estándar, nota de eje de corrupción por
criatura).

**9 prompts:**
- **Los 4 bosses ya nombrados** (nunca habían tenido brief, solo una línea en Geografía): Crowned
  Leviathan (superviviente sana, no mutada), Burning Shepherd (guardián corrupto de fuego/sombra),
  Mirror Stalker (aberración pura que imita movimiento), Aether Wyrm (aberración semi-corpórea,
  la más pura de las 4).
- **Los 3 bosses nuevos de dungeon**: Hollow Warden (cueva, caza por eco, brillo jade mineral —
  aclarado en el brief que no tiene relación real con el Bond), Drowned Choir (unidad coordinada
  de 3-5, brief describe una sola unidad para repetir en implementación), Cascade Warden (la
  excepción no corrompida del batch — vieja y territorial, no mutada).
- **Los Vaciados y Las Motas** (Villanos Menores §Capa 2): nota narrativa explícita en el brief
  de los Vaciados para que el artista no los diseñe como monstruo de fantasía genérico —
  cicatrices de una anatomía que fue persona, no colmillos/cuernos inventados. Las Motas con tono
  deliberadamente liviano (alivio cómico, no horror).

**Estado: `check_canon.py` 0 críticos / 0 medium (21 clases), `check_vault.py` 🟢.**

### Pendiente

Los 9 briefs están listos para correr en NB2 pero **no generados todavía** — ninguno tiene
archivo en `90-Raw/concept/` ni ratificación de Boris. Sigue pendiente meter la pasada completa
de bestiario/flora/villanos/briefs al loop de QA (mañana).

## [2026-08-04] concept-art | Evaluación de los 9 renders — 7/9 ratificados

Boris corrió los 9 briefs de §13 en NB2 durante la tarde. Evaluación contra cada brief + la
regla estándar de "no text/labels/captions" (§10 de `Briefs de Concept Art.md`):

**RATIFICADOS y copiados a `90-Raw/concept/`:**
- `burning-shepherd-v1.png` — fuego contenido/sombra sin borde/vetas rojas, PASS sin reservas.
- `hollow-warden-v1.png` — sin ojos, bigotes, vetas jade, match casi exacto.
- `drowned-choir-v1.png` — cámara resonante y aletas violeta correctas; ojos más agresivos de
  lo pedido ("milky, small") pero funcional para un boss de dungeon.
- `cascade-warden-v1.png` — rapaz vieja sin corrupción, exactamente la excepción del batch.
- `the-hollowed-v1.png` — el mejor resultado de los 9: tragedia física exacta, sin cliché de
  orco (sin colmillos, sin piel verde).
- `the-chaff-v1.png` — tono liviano logrado, sin deriva a mascota.

**ARCHIVADOS pero pendientes de re-roll (el diseño sirve, la lámina no):**
- `crowned-leviathan-v1.png` — corona de espinas y vetas teal correctas, pero trae texto y
  etiquetas incrustadas ("FRONT VIEW", título, párrafo) — rompe la regla estándar §10.
- `aether-wyrm-v1.png` — atmósfera correcta, pero (1) etiquetas "FRONT VIEW"/"SIDE VIEW"
  incrustadas y (2) mandíbula de dragón visible, cuando el brief pedía explícitamente
  *"no true head shape... no visible mouth"*.

**RECHAZADO, no entra al vault:**
- **Mirror Stalker** — se leyó como gólem de piedra genérico, con rostro tallado y textura
  mineral en vez de superficie de espejo/vidrio reflectante. El concepto central del boss
  ("copia tus movimientos") no se transmite visualmente. Pendiente de re-roll real (no solo de
  texto) en la próxima corrida — reforzar en el prompt la superficie de vidrio explícita y la
  ausencia total de rasgos faciales tallados.

Evaluaciones completas anotadas en `Briefs de Concept Art.md` §13.1-13.9 (formato
`**Archivo:**`/`**Evaluación:**` ya establecido en el documento) y cross-referenciadas en
`Bestiario.md` y `Villanos Menores.md` en la entrada de cada criatura.

**Estado: `check_canon.py` 0 críticos / 0 medium (21 clases), `check_vault.py` 🟢.**

## [2026-08-04] sprint/QA | 15ª re-corrida — 10 críticos únicos, mejora estructural al linter

**2 subagentes Opus en frío.** QA-Dramática: 4 críticos, 8 medios, 9 menores. QA-Congruencia:
6 críticos, 9 medios, 8 menores. Con solapamiento (Sereth F1/F2b lo reportaron los dos), **10
críticos únicos**. Todos cerrados en la fuente esta sesión.

**Críticos, todos residuo de fixes previos a medias o del contenido nuevo del 04:**

1. **Sereth F1 vs §Dinámicas** — el diálogo Roen+Sereth sobre "dejar la Royal Academy" citaba
   una frase que en realidad vive en §F2b (`:338`), y §F1 declara explícitamente que no hay
   Academy de la que renunciar. Referencia corregida a F2b, donde la institución sí sigue
   existiendo.
2. **Funeral mudo Lyris/Torgan** — Lyris reclamaba "el único funeral del elenco donde no se
   dice una palabra", colisionando con el funeral silencioso de Torgan (ámbito distinto: clan
   menor, no elenco). Quitada la exclusividad de elenco de Lyris.
3. **Lyris "incapaz de sentir"** — el header y las Notas Narrativas ya decían "capaz de sentir,
   convencida de que sentir es debilidad"; el cuerpo de §Esencia seguía diciendo "incapaz de
   sentir" sin matiz, como causa de la traición. Reescrito para coincidir.
4. **"Torgan el único que espera de frente"** — colisionaba con Dagna e Iven, que también
   esperan de frente en su propia ruta. Quitada la exclusividad, queda la postura sin reclamo.
5. **Cadenas élficas invertidas en `Estructura Política`** — Sereth y Nyael se habían escrito
   con la jerarquía al revés (terminando en un asiento del Council en vez del Pivote) en la
   reescritura de la 13ª ronda, que corrigió el tramo enano y no el élfico. Reescritas contra
   `Matriz §2` exacta.
6. **"Se lleva el Fragmento" sobreviviente en `Estructura Dramática.md`** — última mención viva
   del beat pre-Matriz (lo que se lleva el Pivote es a Speck, no un dispositivo), y agravado
   por ser la fuente declarada de la regla de orfandad mecánica. Corregido.
7. **Escena del escudo caído, dos tiempos incompatibles** — Darro (×2 menciones) la ataba a
   "cuando Dagna entrega a Speck" (F2a consumado); Roen la canoniza como "antes de que el
   jugador decida nada", ocurre en las 5 rutas de la celda. Las 2 menciones de Darro corregidas
   para coincidir con Roen.
8. **Bestiario: superlativo de Speck contradicho por su propia fuente citada** — decía que el
   Burning Shepherd era "la única de las 4" con reconocimiento de Speck, pero la fuente que el
   propio archivo cita (Geografía §I) le da ese beat a 3 de las 4. Reformulado sin exclusividad.
9. **Ruta Lyris: mecánica aérea no declarada** — su ficha decía "sin excepciones" y a la vez la
   narraba suspendida en el aire en vez de parada en el borde (contra `Matriz §1 paso 3`), lo
   que además rompía el beat obligatorio de F3 (Speck no se puede recoger "del otro lado del
   borde" si cae desde altura). **Fix estructural, no de línea:** se declaró la excepción
   "holder aérea" en `Matriz §2` — mismo patrón que las excepciones de Nyael/Bram — explicando
   cómo se satisface cada gate sin que Lyris deje de ser la única duelist con vuelo del elenco.
10. **(dedup)** — mismo hallazgo que #1, reportado independientemente por los dos subagentes.

**Medios cerrados en la misma pasada:** contradicción real de regla en `Los 5 Finales` (F4
tenía una condición de "si lo perdonaste" que el propio documento prohíbe — quitada); Vekka
con una copia completa de la tabla de superlativos en vez de una cita (alineada al patrón que
ya seguían Dagna/Torgan/Iven/Nyael); header residual "Rechazo" en la ficha de Lyris (el canon
vigente dice que nunca la rechazaron); beat de F3 de Torgan incompleto ("deja que caiga hacia
donde caiga" en vez de que el jugador la recoja); colisión de nomenclatura "Warden" entre los
bosses nuevos y la especie de Speck (nota de desambiguación agregada); Villanos Menores:
Roen citado como canon de una cultura mercenaria que no es la suya, superlativo de Bram
endurecido respecto a su propia ficha, los Vaciados descritos como "raza nueva" cuando son
personas transformadas (no nacen), cita a una sección de Estructura Política que no sostiene
lo que se le atribuía; una línea inventada sobre Torgan ("casi expulsado dos veces") que no
tiene base en su biografía, reemplazada por una reflexión real sobre la fragilidad de su clan
menor; **regla 9 del repo aplicada retroactivamente**: los 5 nombres de facciones/criaturas
nuevas de Villanos Menores pasan a inglés como canon primario (The Unpaid Companies, The
Nameless, The Unlicensed, The Hollowed, The Chaff) — coincide además con los nombres de archivo
que ya usaba el concept art (`the-hollowed-v1.png`, `the-chaff-v1.png`), que habían quedado
desalineados del texto en español.

**Mejora estructural al linter, sugerida por el propio QA-Dramática:** `check_superlativos`
solo vigilaba a los 3 fijos y solo detectaba colisiones del mismo personaje repitiendo su
propio superlativo en dos archivos. 3 de los 4 críticos de QA-Dramática eran la misma clase
aplicada a Pivotes, o colisiones **entre dos personajes distintos** reclamando la misma
exclusividad de elenco (el caso Lyris/Torgan). Extendido: `NOMBRES_ELENCO` ahora cubre a los 9
Pivotes además de los 3 fijos; `RE_SUPERLATIVO` gana los patrones "el único que", "del elenco",
"único funeral", "primera vez en (la/toda la) campaña" y los superlativos de grado ("más
fría/precisa/corta/íntima/peligrosa/honesta"); y se agregó un segundo diccionario
(`vistos_elenco`) que detecta colisiones cross-personaje cuando el reclamo es explícitamente
"de elenco" — antes esa clase de bug era estructuralmente invisible al chequeo, sin importar
cuántas rondas de subagentes se gastaran en encontrarla. 22 clases en total.

**Estado: `check_canon.py` 0 críticos / 0 medium (22 clases), `check_vault.py` 🟢.**

### Pendiente

Quedan algunos menores sin cerrar de ambos reportes (aritmética de Nyael y Darro con huecos de
2-años y de tramos que no cierran del todo; algunas referencias § que apuntan a secciones con
nombre distinto al real; un residuo en un worktree de git viejo que no se tocó). No bloquean.
**16ª re-corrida** pendiente de lanzar para confirmar si la mejora del linter bajó el volumen
de críticos de juicio narrativo, que es la hipótesis a probar.

## [2026-08-05] canon-qa | 16ª re-corrida — 9 críticos reportados, 7 falsos positivos, 2 reales cerrados

**Linter primero:** `check_canon.py` 0 críticos / 0 medium antes de spawnear (22 clases). Se
lanzaron los 2 subagentes Opus en frío de rigor (dramaturgia + congruencia semántica), sin
contexto de rondas previas.

**Resultado combinado: 9 CRITICAL, 14 MEDIUM, 9 INFO.** Verificación manual línea por línea
contra el archivo real (no contra la cita del subagente) mostró que **7 de los 9 críticos eran
falsos positivos** — ambos subagentes citaron contenido que ya no existe en el vault. La causa:
`El Cráter — Matriz de Rutas.md`, creada el 2026-08-03 como fuente única de la mecánica del
clímax (geometría borde/centro, excepción Nyael, quién se lleva el Fragmento, gate F4), no fue
descubierta por ninguno de los dos subagentes — auditaron una versión mental del canon anterior
a esa sesión de diseño, no el archivo real. Los 5 críticos correspondientes (geometría del
cráter en 8 fichas, gate de la ruta Nyael, línea "inevitable" de Valen en F2b, línea duplicada
de Roen en F2b, Fragmento llevado por el Pivote en 3 fichas de fijos) estaban **ya bien** al
leer el archivo directamente.

**2 críticos reales, corregidos en la fuente:**
- `Valen-Ficha-Expandida-v1.md:223` — tenía invertido quién lee la inscripción Warden del
  Sunken Archive: decía que correspondía normalmente a Sereth y que Valen la reemplazaba cuando
  Sereth era el Pivote activo. Es al revés y además lógicamente imposible (Sereth es 1 de 9
  rutas — si fuera el default, 8 de 9 partidas no tendrían lector). Corregido contra
  `Geografía y Ciudades.md:1016` y `Sereth-Ficha:216`, ambas ya correctas: Valen lee por
  defecto, Sereth solo en su propia ruta.
- `Valen-Ficha` — la Escena 3 del Acto 2 hacía que Valen revelara "los God-Cores son Wardens"
  como hecho confirmado, contradiciendo `El Mundo y la Muda.md:31-36` (la palabra "Warden" no
  existe en el conocimiento público de ninguna raza; el Sunken Archive del Acto 3 es "la primera
  fuente que confirma, sin ambigüedad, lo que hasta entonces era mito"). Reescrita la escena y
  el bloque de backstory de hace 30 años para que sea teoría/hipótesis sin fuente de Valen, con
  la confirmación real ocurriendo recién en el Archive — incluyendo el beat de la cifra errónea,
  que ya vivía correctamente ahí.

**+ 3 residuos MEDIUM reales, corregidos en la fuente:** "9 traiciones" → reformulado (Bram no
traiciona, son 8) en `El Mundo y la Muda.md` y `Bond y el Bond Vacío.md`; superlativo de Sereth
en F4 ("único final donde aprende algo") suavizado a "único final donde el aprendizaje le
cambia el método" para no contradecir el aprendizaje que también tiene en F1/F2b; línea
residual de Lyris ("Lyris no siente nada") en `Lyris-Ficha:227`, que no se había actualizado
cuando el header del arquetipo se corrigió a "siente y suprime, no ausencia de sentimiento".

**Otros MEDIUM/INFO del reporte quedaron sin verificar/cerrar** (beats de duelo por final,
Goggles/Tobin sin eco en los 60 epílogos, sección de Reckoning faltante en Nyael, aritmética
menor) — no bloquean el criterio de cierre (0 críticos) y quedan para la 17ª si Boris quiere
tratarlos.

**Estado: `check_canon.py` 0 críticos / 0 medium, `check_vault.py` 🟢.**

**Nota de método para la 17ª:** el prompt de los subagentes de QA debe apuntar explícitamente a
`[[El Cráter — Matriz de Rutas]]` como fuente única de la mecánica del clímax — es reciente
(2026-08-03) y ninguno de los dos subagentes de esta ronda la encontró por su cuenta, lo que
produjo la mayoría del ruido de esta corrida. Es la primera ronda con **más falsos positivos que
críticos reales**: vale la pena verificar cada hallazgo contra el archivo real antes de tocar
nada, no asumir que la cita del subagente refleja el estado actual del vault.

## [2026-08-05] design | Links de los 3 fijos — Second Catch, The Long Calculus, Open Seam (provisional)

**Origen:** pregunta abierta de Boris en `The Bound Five.md` — los bonds no debían suceder
solo entre jugador y Pivote; faltaba desarrollar los links propios de Roen, Darro y Valen a
partir de su raza y rol, de forma que la profundidad de vínculo se sintiera pareja sin importar
la celda del jugador.

**Diagnóstico de partida:** Roen, Valen y Darro son fijos (misma raza y rol en las 9 celdas) y
**ya forman su propia tríada de acoplamiento** entre ellos (Vanguard + Strategist + Duelist) —
a diferencia del Pivote, diseñado a propósito para nunca duplicar el rol del jugador. Consecuencia
no documentada hasta ahora: el rol del jugador **siempre** coincide con el de uno de los tres
fijos, en las 9 celdas.

**Decisiones de la sesión:**
- **3 links, no 9.** Ir a 3 fijos × 3 roles de jugador sumaría 9 links más a los 9 del Pivote
  (18 en total) sin necesidad — de los 3 roles posibles, 2 son variantes de la misma
  complementariedad y solo 1 (rol duplicado) es genuinamente distinto.
- **Sin tope de tier visible.** Se descartó un primer diseño que capaba a los fijos en T2 para
  simular "el bond del Pivote se vuelve el más útil con los actos": un tope de sistema detectable
  es exactamente el tipo de pista que delata quién va a traicionar antes de que la historia lo
  diga. Reemplazado por **pacing de contenido**: el arco de cada fijo (Encuentro, Nido de Speck,
  El Primero / La Rueda, Speck Despierta, La Verdad) ya está concentrado en Actos 1-2: en Acto 3
  su contenido es reactivo. El Pivote, en cambio, ya sigue sumando contenido propio hasta el
  final (The Reckoning en Acto 2, corredor y cráter en Acto 3) — la asimetría que pedía Boris
  ya estaba en la estructura existente, no hizo falta inventar una regla nueva.
- **Mismo presupuesto de poder, distinto tipo de poder.** Los 3 links quedan en el mismo tier
  numérico que un link de Pivote equivalente. La diferencia no es cuánto pegan: el Pivote
  reconfigura el verbo de combate del jugador ("su partida rompe tu forma de jugar", ya canon en
  `The Bound Five`); los fijos son fuertes y constantes sin alterar la identidad de combate. Así
  el balance queda parejo sin abrir una segunda pista mecánica.
- **3 tiers con objeto/beat firma en T3**, igual que Seismic Springboard (Dagna): cada T3 ata a
  un beat de personaje ya existente en la ficha del fijo, no es solo un power-up — Roen usa por
  primera vez el escudo real que dejó atrás (sus 15 años de guardia del Council), Valen aprende
  a confiar en el dato de ahora en vez del cálculo heredado (eco directo del beat de la cifra
  errónea), Darro pega en serio por primera vez sin chiste después.
- **Roen — dos pitches, Boris eligió el segundo.** *Borrowed Ground* (relación con el mundo:
  agarra objetos del entorno) vs *Second Catch* (relación con personas: agarra y reposiciona
  aliados/enemigos, más cerca de "el corazón del grupo" de su Esencia). Queda **Second Catch**.
- **Valen — pedido específico de Boris:** un link de dos botones estilo Zenyatta (Overwatch) —
  Discord (marca de vulnerabilidad) + Harmony (regeneración sostenida), ambos justificados como
  cálculo, no magia. Encaja con su arquetipo ya escrito en `Matriz Raza x Rol` (Elfo Strategist =
  "manipulador psíquico: recoloca aliados/enemigos").

**Archivo nuevo:** [[Los 3 Links de los Fijos]] — fuente única, `status: provisional`. Citado
desde `Acoplamientos.md`, `The Bound Five.md` (resuelve la pregunta abierta de Boris) y las 3
fichas de fijos (Roen, Valen, Darro), sin re-enunciarse en ninguna.

**Estado: `check_canon.py` 0 críticos / 0 medium, `check_vault.py` 🟢.**

**Pendiente:** ronda de QA de dramaturgia + balance antes de pasar a `status: ratificado`;
nombres de iconografía UI para los 6 estados T2/T3 nuevos; links directos de Speck en su fase
de desvelamiento previa a E3 (pregunta que ya estaba abierta en `The Bound Five`).

## [2026-08-05] design | Council: resolución del botón Bond con 4 links activos

**Contexto:** con los links de los 3 fijos recién diseñados ([[Los 3 Links de los Fijos]]),
la pregunta pendiente de `Bond y el Bond Vacío` ("¿a quién mapea Bond con dos links posibles?")
dejó de ser teórica — el botón único ahora tiene 4 candidatos posibles en pantalla a la vez,
no 1. Se corrió un council de 5 perspectivas (Contrarian, First Principles, Expansionist,
Outsider, Executor) con ronda de revisión cruzada anonimizada antes de decidir.

**Veredicto:** la pregunta original ("¿cuál de las 3 opciones — proximidad, prioridad por rol,
ping manual — elegimos?") estaba mal planteada. Consenso 5/5 en la revisión cruzada: la
respuesta más fuerte fue la que rechazó el marco de arbitraje y señaló que el conflicto es
síntoma de **encounter/level design** (dos telegraphs simultáneos igual de válidos), no un
problema de input.

**Decisiones:**
- **Regla primaria (fuente del problema):** un encuentro no debe generar dos telegraphs de
  link igualmente válidos y simultáneos, salvo que sea un dilema narrativo intencional.
  Aplica a diseño de encuentros cuando exista contenido jugable — no auditable hoy, sin
  vertical slice, detrás de ADR-003.
- **Sistema de respaldo, solo para el residuo:** proximidad/contexto dispara el link +
  desempate por urgencia real (ventana de telegrafía más corta, no rol memorizable) +
  feedback visual post-hoc de la oportunidad no elegida.
- **Descartado:** prioridad fija por rol (memorizable, frágil ante nuevos compañeros); ping/
  marca manual (viola "un solo botón" y agrega titubeo); **"caracterización emergente"**
  (compañeros compitiendo por el link vía IA) — la idea más atractiva del council y también
  la más peligrosa: rompe la atribución del jugador sobre el resultado, contaminando
  exactamente el silencio que hace funcionar el beat de traición ("aprietas Bond y no
  responde nadie"). Blind spot identificado por 5/5 revisores independientes.

**Archivo actualizado:** [[Bond y el Bond Vacío]] §Resolución de Bond con más de un link
posible — reemplaza el pendiente (❓) anterior.

**Estado: `check_canon.py` 0 críticos / 0 medium, `check_vault.py` 🟢.**

## [2026-08-05] concept-art | Links de los 3 fijos -- 3/3 ratificados

Primer concept art de Roen, Valen y Darro en accion (antes solo tenian el fenotipo generico
de su raza). 3 briefs nuevos en `Briefs de Concept Art.md` SS14, escritos y corregidos de
formato para igualar el patron de brief pre-generacion ya establecido (SS7 Dagna, SS9
Queen Ithessa/King Borran): parrafo de referencia en prosa plana, sin etiquetas en negrita,
terminado en "Destino:", seguido del bloque de codigo con el prompt completo.

**Resultado:**
- `roen-second-catch-v1.png` -- RATIFICADO. Cumple el brief; nota menor no bloqueante:
  expresion lee a esfuerzo en vez de instinto calmado.
- `valen-long-calculus-v1.png` -- RATIFICADO. Broke el brief literal (pedia los dos orbes
  activos a la vez en una sola pose de accion; salio como ficha frente/dorso, cada vista
  con un solo orbe). Boris ratifica igual: funciona para el proposito del concept art,
  diferencia con claridad Discord (rojo filoso) de Harmony (dorado fluido). Si hace falta
  la pose de accion con ambos orbes simultaneos, es un brief nuevo, no un re-roll de este.
- `darro-open-seam-v1.png` -- RATIFICADO. Cumple el brief; nota menor no bloqueante:
  deriva de proporcion (menos trapezoide/4.5-cabezas que el fenotipo enano), mismo patron
  ya visto con King Borran (SS9b-v2).

**Estado:** `check_canon.py` 0 criticos / 0 medium, `check_vault.py` verde.

## [2026-08-05] concept-art | Re-rolls del Bestiario escritos + limpieza de flags viejos

Continuacion del pase de concept art (lista de "Concept art pendiente" en Current-State).
Antes de escribir nada nuevo se audito el estado real contra los flags que traia la lista,
y aparecieron dos falsos pendientes:

- **Driftmarket ya estaba resuelto desde el 2026-07-27** (SS11.1, `driftmarket-keyframe-v2.png`,
  RATIFICADO) -- el 6D nunca actualizo su propio flag 🔴 despues de esa re-corrida, y
  Current-State lo seguia arrastrando como pendiente. Limpiado en ambos lugares.
- **Rivermeet daylight ya estaba 🟡 aprobado** (SS6d) sin ningun problema real -- tambien
  arrastrado sin necesidad en la lista de pendientes.

**Trabajo real, 4 briefs re-escritos:**
- **SS13.1-v2 Crowned Leviathan** -- mismo diseno (ya aprobado en contenido), reescrito en
  prosa corta estilo Kadrun (SS9e-v2) para sacar el texto/etiquetas "FRONT VIEW" quemadas
  en la v1.
- **SS13.4-v2 Aether Wyrm** -- mismo tratamiento de texto, mas refuerzo explicito y repetido
  contra la mandibula de dragon que aparecio pese a que el brief v1 ya la prohibia una vez.
- **SS13.3-v2 Mirror Stalker** -- rediseno real, no solo limpieza de texto: la v1 leyo como
  golem de piedra porque "glass-like facets" es vocabulario ambiguo (tambien describe roca).
  Fix: vocabulario inequivoco de vidrio -- especificamente el **respaldo plateado de un
  espejo real**, visible en las grietas entre fragmentos, un detalle que ninguna roca tiene
  y que un modelo de imagen no puede confundir. Negativos nuevos contra piedra/golem/tallado
  que la v1 no tenia.
- **SS9b-v3 King Borran** -- el propio doc ya marcaba que si se retomaba habia que aplicar el
  formato de prosa corta que salvo a Kadrun; reescrito con el mismo tratamiento.

Los 4 estan escritos y listos para correr en NB2 -- no se ejecutaron esta sesion (Boris corre
NB2 externamente). Quedan sin tocar los items de la lista que no son briefs de imagen: revisar
4 escenas de traicion (legacy o canon), set de combos sin doc, QA de 4 variantes de The Wilds,
videos Higgsfield (bloqueo ffmpeg), POIs sueltos. key-art-poster (SS12.1/12.2) ya estaba
completo y listo para correr, sin cambios.

**Estado:** `check_canon.py` 0 criticos / 0 medium, `check_vault.py` verde.

## [2026-08-06] concept-art | Evaluacion de los 4 re-rolls -- 3/4 ratificados, Mirror Stalker v3 escrito

Boris genero los 4 briefs escritos la sesion anterior y los dejo en Descargas. Evaluacion
contra brief:

- **Crowned Leviathan v2** -- RATIFICADO. Cero texto, corona de espinas, vetas
  bioluminiscentes, sin cristales de corrupcion. La prosa corta resolvio el glitch de la v1.
- **Aether Wyrm v2** -- RATIFICADO. Cero texto, sin mandibula de dragon (cabeza cristalina
  puntiaguda, sin boca), cuerpo alternando solido/traslucido.
- **King Borran v3** -- RATIFICADO. Sin texto ni glitches, corona forjada sin gemas,
  martillo en reposo. Nota menor no bloqueante: proporcion mejorada pero sigue sin ser tan
  extrema como el trapezoide de 4.5 cabezas del canon.
- **Mirror Stalker v2** -- FALLA DE NUEVO, no archivado en produccion. El vocabulario de
  vidrio (SS13.3-v2, respaldo plateado) no alcanzo: el resultado leyo como armadura de
  placas cristalinas/metalicas, mas caballero que espejo. Ningun panel mostro reflejo real.

**Diagnostico del fallo repetido de Mirror Stalker:** el problema no era el vocabulario de
material -- es la **estructura** de la descripcion. "Shards fused into a humanoid shape
covering the body" lee como armadura sin importar que material se nombre. Escrito SS13.3-v3:
cambia la estructura completa, describiendolo primero como un **panel de espejo roto** que
apenas adopto contorno humanoide (plano antes que volumetrico, traslucido antes que solido),
con un reflejo distorsionado real del entorno visible dentro del vidrio, y negativos directos
contra armadura/caballero/robot que las dos versiones anteriores no tenian. Pendiente de
correr en NB2.

**Archivos movidos a `90-Raw/concept/`:** `crowned-leviathan-v2.png`, `aether-wyrm-v2.png`,
`king-borran-v3.png`.

**Estado:** `check_canon.py` 0 criticos / 0 medium, `check_vault.py` verde. Concept art del
Bestiario: 9/9 salvo Mirror Stalker, que va por su tercer intento.

## [2026-08-06] concept-art | Mirror Stalker v3 -- pivote de canon aceptado, batch del Bestiario cerrado 9/9

Tercer intento de Mirror Stalker (SS13.3-v3, estructura de "panel de espejo roto" en vez de
"cuerpo cubierto de placas"). Resultado: mejora parcial -- huecos reales entre paneles con
el fondo visible, luz teal en las grietas -- pero sigue sin mostrar reflejo literal ni
respaldo plateado de espejo; lee como automata de cristal/vidrio articulado, no como espejo
roto en sentido estricto.

**Decision de Boris: aceptar el pivote en vez de un cuarto intento.** Tres corridas
convergieron en la misma familia de resultado (cristal/vidrio articulado, no reflejo
literal) pese a cambiar vocabulario y estructura -- señal de que es el limite razonable de
la tecnica para este concepto exacto, no un prompt mal escrito.

**Canon actualizado en `Bestiario.md` SSThe Mirror Stalker:** se mantiene la habilidad
("copia tus movimientos", "aprende, no solo imita" -- cita de Valen intacta) pero la
descripcion visual pasa de "superficie de espejo con reflejo literal" a "automata de
cristal/vidrio fracturado, cuerpo articulado de facetas traslucidas con vetas de luz teal
en las grietas". El nombre "Mirror Stalker" queda igual -- describe la habilidad, no la
superficie.

**Archivo:** `mirror-stalker-v3.png`, RATIFICADO, movido a `90-Raw/concept/`.

**Estado: batch de concept art del Bestiario cerrado, 9/9** (los 4 re-rolls de esta sesion
mas los 5 que ya habian pasado directo el 2026-08-04). `check_canon.py` 0 criticos / 0
medium, `check_vault.py` verde.

## [2026-08-06] decision | Regla de trafico para arrancar guion sin QA hasta el domingo

Boris quiere empezar dialogos/screenplay manana (2026-08-07) pero conservar el presupuesto
semanal de subagentes de QA hasta el domingo. Se evaluo si hacia falta una ronda de QA
antes de arrancar: el linter mecanico sigue en 0 criticos (gratis, no consume presupuesto),
y todo lo agregado desde la 16a re-corrida (links de los 3 fijos, resolucion del boton Bond,
concept art) es mecanica/sistemas/visual -- no toca arcos, finales ni epilogos, que es lo
que audita el QA de dramaturgia. El terreno narrativo ya paso limpio por la 16a.

**Reglas de trafico establecidas para la semana, escritas en `Current-State.md`:**
1. El linter sigue corriendo antes de cada checkpoint, sin excepcion.
2. Dialogo sobre terreno ya auditado (arcos, encuentros, traiciones, los 60 epilogos) se
   escribe con confianza.
3. Cualquier linea de guion que toque los links de los 3 fijos se trata como provisional
   hasta que pasen QA.
4. El domingo, una sola ronda de subagentes audita todo lo acumulado de la semana (guion
   nuevo + links de fijos) en vez de dos corridas separadas.

**Estado de cierre de sesion:** `check_canon.py` 0 criticos / 0 medium, `check_vault.py`
verde. Sprint QA (16a) cerrado, links de los 3 fijos diseñados (provisional), boton Bond
resuelto via council, concept art del Bestiario y de los links de fijos cerrado 9/9 + 3/3.
Proximo frente: guion y dialogos por actos, en ingles, arrancando manana.

## [2026-08-07] design | Voz Narrativa -- ratificada via 2 rondas de council

Pregunta abierta desde hace semanas ("Voz narrativa" en Current-State, sin nada escrito en
el vault) bloqueaba el arranque real del guion. Se resolvio con 2 rondas de council (5
asesores + revision cruzada anonimizada cada una) antes de escribir una sola linea de
dialogo.

**Ronda 1 -- pregunta general (¿narrador si o no, y de que tipo?):** consenso fuerte hacia
sin narrador. El pilar "el silencio es el beat mas fuerte del juego" (Bond y el Bond
Vacio) fue el argumento decisivo -- cualquier narrador, externo tipo "Book" (It Takes Two)
o diegetico recurrente tipo Gimli (Return to Moria), esta presente durante el cuerpo del
juego aunque hable poco, y su silencio en el climax se vuelve una eleccion notable de la
voz en vez de un vacio puro -- contamina exactamente el beat que se queria proteger.

**Ronda 2 -- propuesta refinada de Boris:** no un narrador recurrente, sino un bookend
estricto -- Roen viejo (60-70 anos, 20-30 anos despues) narra la apertura literal del
juego (pantalla negra, antes de que exista nada que espoilear) y un cierre variable segun
el final (5 versiones). Verificado contra el canon: Roen sobrevive los 5 finales sin
excepcion. El council encontro que el bookend resuelve la mayoria de las objeciones de la
ronda 1 (no compite con el silencio del climax porque vive fuera del tiempo de juego), pero
el Contrarian (ganador 3/5 en la revision cruzada) señalo con precision que el riesgo de
spoiler se **reubica, no se cierra**: la sola apertura ya confirma que hay una historia que
merece contarse 30 anos despues, y cualquier tono que le den (eleccion, quien falta en la
mesa) es informacion. La propuesta de Expansionist de vender "los 5 finales de Roen" como
gancho de marketing/replay fue marcada como punto ciego por los 5 revisores independientes
-- optimiza retencion antes de resolver si el objeto central es sano para el pilar, y abre
una fuga de spoiler extra-diegetica (comunidad filtrando el final de un jugador que todavia
no termino el suyo).

**Decision final de Boris: adelante con el bookend**, con las 4 condiciones que salieron de
la critica de la ronda 2 (ver [[Voz Narrativa]] para el detalle completo): apertura sin
direccion tonal, auditar cada cierre contra fuga de info de los otros 8 Pivotes, no
fabricar el gancho de marketing pre-lanzamiento, y un test de aprobacion (escribir la
apertura sola, aplicarle la pregunta de spoiler) antes de tocar los 5 cierres. Taberna gano
4/5 sobre fogata/feria como puesta en escena -- coherente con que Roen "nunca busca al
jugador, no se explica de mas".

**Archivo nuevo:** [[Voz Narrativa]] -- fuente unica, `status: ratificado`. Actualiza el
pendiente de "voz narrativa" en Current-State y el indice.

**Proximo paso inmediato:** escribir la apertura, sola, y correrla contra el test de la
regla 4 antes de escribir ningun cierre.

**Estado:** `check_canon.py` 0 criticos / 0 medium, `check_vault.py` verde.

## [2026-08-07] guion | Apertura del bookend (Roen viejo) -- escrita y ratificada

Primer guion real del juego, siguiendo la regla 4 de [[Voz Narrativa]]: escribir la
apertura sola, testearla contra fuga de spoiler, antes de tocar ninguno de los 5 cierres.

**Primer borrador y auto-test:** paso el test de la regla 1 (unico dato que se filtra es
que Roen sobrevive, aceptado como residual del dispositivo). Presentado a Boris para
lectura.

**Revision de Boris, 2 cambios reales:**
- La linea "Nine of us took that same job, near enough" le metia a Roen conocimiento de
  la estructura de diseño (los 9 Pivotes) que no tendria manera de tener en la ficcion --
  el vivio solo su propia version. Corregida a "Wasn't just me who got that job offer. I
  know that much." -- insinua que hubo otros sin numero ni certeza.
- Se saco tambien "Same girl" de la version anterior (no hacia falta confirmar genero del
  "package" tan temprano).
- **Agregado un bloque de worldbuilding publico** (pedido explicito de Boris, dado que la
  escena transcurre en una taberna humana): el cataclismo, el Aether corrupto usado desde
  entonces como combustible/tecnologia/comercio/poder -- sin tocar el secreto del Acto 3
  (God-Cores = Wardens muertos, que sigue reservado para el Sunken Archive). La cifra
  "almost six hundred years" es intencional, no error: el canon fija el cataclismo en 550
  años, pero Roen es humano, y los humanos son la raza con memoria institucional mas
  degradada (El Mundo y la Muda, tabla de memoria por raza). Que el mismo protagonista
  redondee mal la cifra es la dramatizacion directa de esa regla de canon -- anotado en el
  archivo para que una futura QA no lo "corrija" a 550 pensando que es un descuido, mismo
  patron que las "cuatro Mudas" de Valen.

**Archivo:** [[Guion/Apertura — Roen Viejo]] -- `status: ratificado`. Primera pagina de la
nueva carpeta `10-Knowledge/Guion/`.

**Estado:** `check_canon.py` 0 criticos / 0 medium, `check_vault.py` verde.

**Proximo paso:** escribir los 5 cierres (F1, F2a, F2b, F3, F4), auditando cada uno contra
la regla 2 de [[Voz Narrativa]] (fuga de informacion sobre los otros 8 Pivotes).

## [2026-08-07] guion | Los 5 cierres del bookend (Roen viejo) -- escritos y ratificados, bookend completo cerrado

Continuacion de la apertura ([[Guion/Apertura — Roen Viejo]]). Escritos los 5 cierres
variables por final (F1, F2a, F2b, F3, F4), cada uno anclado en la linea canonica que
Roen ya tenia en su propia ficha para ese final -- no se invento contenido nuevo, se
extendio el que ya existia.

**Primer borrador:** monologo V.O. puro, igual que la apertura. Auditado contra la regla 2
de [[Voz Narrativa]] (fuga de info sobre los otros 8 Pivotes) -- ninguno de los 5 nombra
al Pivote ni menciona detalle institucional exclusivo de una ruta (Juramento de Forja,
pagos del Council, Royal Academy), siguiendo el mismo patron que ya usaba la propia ficha
de Roen.

**2 rondas de ajuste de Boris:**
- **Formato:** de monologo a conversacion -- se agrego un BARKEEP fijo (mismo personaje en
  las 5 variantes, no uno nuevo por final) que le pregunta a Roen y saca sus lineas en vez
  de que las narre corridas. Nunca pregunta por nombres, solo por hechos.
- **Ritmo:** la primera version en conversacion quedo en ~45 segundos; Boris pidio
  estirarla a ~1:30. El tiempo extra sale de que el Barkeep habla e insiste mas, no de que
  Roen se explique de mas -- su economia de personaje ("no se explica de mas") se mantuvo
  intacta a proposito, incluso en la version larga.

**Nota de craft, F2b:** unico cierre donde estirar la duracion sin romper la prohibicion
de moraleja ("aprendimos algo", regla ya establecida para F2b en QA anteriores) significo
alargar el silencio, no el contenido -- el Barkeep insiste y es rechazado, Roen no dice
mas de lo que ya tenia que decir.

**Archivo:** [[Guion/Cierres — Roen Viejo]] -- `status: ratificado`.

**Bookend completo, cerrado:** [[Voz Narrativa]] + [[Guion/Apertura — Roen Viejo]] +
[[Guion/Cierres — Roen Viejo]], los 3 `ratificado`. Primer tramo de guion real del juego,
de punta a punta.

**Estado:** `check_canon.py` 0 criticos / 0 medium, `check_vault.py` verde.

**Proximo frente:** guion de actos, arrancando por el Encuentro del Acto 1.

## [2026-08-07] guion | Puente narrado al Acto 1 -- apertura del bookend extendida, ratificada

Boris pidio resolver el corte entre la apertura de Roen y la primera escena jugable: en
vez de CUT TO BLACK duro, propuso que Roen siga hablando ~30-60 segundos mientras la
camara ya muestra al jugador en su propia escena de origen -- valido para las 9 celdas
(18 con genero) porque el audio de Roen nunca es especifico de raza/rol, solo la viñeta
visual lo es.

**Estructura acordada (propuesta como guionista senior, ratificada sin cambios de
estructura):** match cut del fuego de la taberna a otra fuente de luz en la escena del
jugador (fogata/forja/amanecer segun raza) -> Roen sigue narrando en terminos
universales (por que la gente firma el Contrato de Conquistador, [[Progresión y
Contrato]]) sobre una viñeta silenciosa del jugador sin dialogo propio todavia -> la voz
de Roen se apaga bajo el ambiente de The Wilds -> handoff real es auditivo, no visual (ya
no hay corte a negro intermedio).

**Linea sobre el poder del jugador, pedido explicito de Boris:** una alusion al poder
anti-ilusion sin nombrarlo. Verificado contra canon antes de escribir: el poder es
explicitamente privado ([[Speck]] §Capa 2, "el Bound Five no ve lo que ves") -- Roen
nunca lo supo en la ficcion. Se dieron 3 propuestas, todas como observacion externa sin
explicacion; Boris eligio la mas seca: "Some walked in green and came out seeing things
the rest of us never learned to see. Still don't know what that was. Wasn't my business
to ask."

**Nota de produccion:** la viñeta silenciosa no necesita 18 tomas distintas -- matriz 3x3
de raza x rol (bosque/forja/rio cruzado con chequeo de arma/armadura/mapa segun Duelist/
Vanguard/Strategist), genero como swap de asset sobre esas 9, no contenido nuevo.

**Archivo:** [[Guion/Apertura — Roen Viejo]] actualizado, sigue `status: ratificado`
(3a ronda de revision: linea de los 9 Pivotes, worldbuilding humano, puente al Acto 1).

**Estado:** `check_canon.py` 0 criticos / 0 medium, `check_vault.py` verde.

**Proximo frente:** guion de actos, Acto 1 - Encuentro (primera escena jugable completa,
donde arranca la viñeta que el puente deja sembrada).

## [2026-08-07] design | Estructura del Encuentro con Roen -- confirmada, Acto 1 empieza a cristalizar

Boris pidio un desglose en bullets de todo lo que pasa en Acto 1 antes de empezar a
comentar cada uno. Se reunio lo que ya estaba disperso en el vault (arco de 3 escenas en
la ficha de Roen/Valen/Darro, secuencia macro de Estructura Dramatica, zona de tutorial
de Geografia y Ciudades, los 2 primeros Momentos de Persona de Speck que La Rueda ya
marcaba como parte del Acto 1) y se armo la cronologia real (las fichas narran "Escena
1/2/3" relativas a cuando CADA personaje aparece, no un orden universal -- hubo que
reconstruir la secuencia verdadera cruzando las 3 fichas).

**Decision de Boris sobre estructura macro:** el prologo es el bookend completo de Roen
(apertura + puente + handoff auditivo) MAS la zona tutorial en solitario (Los
Desfiladeros de Zephyr, sin companeros). El title card "AETHER BOUND" corta **a mitad**
de ese tramo solo -- no al final -- dejando un pedazo de caminata despues del logo antes
de llegar al punto de encuentro con Roen.

**Decision sobre el Encuentro con Roen, estructura completa:**
1. Tramo solo (tutorial de movimiento) -> TITLE CARD a mitad de camino.
2. Resto del tramo solo, acercandose al punto de encuentro ya acordado con Roen (la
   contratacion ya es un hecho previo -- Roen-Ficha:101 ya dice "el jugador lo contrato"
   -- esta escena es el primer encuentro FISICO en pantalla, no la contratacion en si;
   resuelto asi para no pisar el dato ya escrito).
3. Emboscada de 3 Hollowed (Villanos Menores, sin restriccion de ubicacion en canon) --
   imposible en solitario, calza con la Zona B de Acoplamientos ("obstaculo imposible sin
   tu primer companero").
4. Roen interviene, llega justo cuando los Hollowed ya encontraron al jugador. Ahi se
   enseña su link (Second Catch) -- **el camino de tutorial varia por ROL del jugador, no
   por raza**, porque el link no cambia con la raza: Duelist/Strategist reciben el modo
   estandar (Roen atrapa/lanza), Vanguard (rol duplicado) recibe el modo "doble ancla" ya
   diseñado en Los 3 Links de los Fijos.
5. Primera linea de Roen post-combate, coherente con su propia ficha (competente sin
   fanfarria, asiente, no aplaude).
6. Roen + jugador siguen a la ciudad natal, donde los alcanza Valen -- ya fijado en
   Geografia y Ciudades.

**Archivo actualizado:** [[Geografía y Ciudades]] §El Encuentro con Roen, dentro de §Los
Desfiladeros de Zephyr.

**Estado:** `check_canon.py` 0 criticos / 0 medium, `check_vault.py` verde.

**Proximo paso:** escribir el guion real de la escena del Encuentro (dialogo, 3 variantes
de rol) -- lo de hoy es estructura, todavia no hay texto escrito.

## [2026-08-07] design | Briefs de concept art de Los Desfiladeros de Zephyr

Boris pidio arrancar el concept art del tutorial de Acto 1 -- vital porque es el primer
entorno jugable del juego (el tramo solo antes del title card y de la emboscada de
Roen, ya estructurado en Geografia y Ciudades §El Encuentro con Roen). El vault no tenia
ninguna pieza de esa zona todavia (confirmado por barrido de 90-Raw/concept/ y grep de
"zephyr"/"canyon"/"desfiladero" -- cero archivos).

**3 briefs nuevos en [[Briefs de Concept Art]] §15**, uno por skin racial ya fijada en
Geografia y Ciudades §Los Desfiladeros de Zephyr:
- §15.1 skin humana (Mistbound Frontier / Aethelgard) -- canon arido, paso de guardia
  militar, introduce Standing.
- §15.2 skin enana (Ignis Reach) -- descenso volcanico, geotermia/lava, introduce
  recursos subterraneos.
- §15.3 skin elfica (Stillwood) -- ascenso boscoso, enredaderas hostiles, introduce el
  mecanismo de locomocion.

Mismo bloque de estilo compartido (hand-painted graphic novel watercolor, Sable x BotW)
que el resto de la pagina; formato calcado de los keyframes de lugar ya ratificados
(§11.7a-c, torres de guardia). Ninguno de los 3 se corrio todavia en NB2 -- quedan
listos para generar. Fuera de alcance: la escena de la emboscada de los 3 Hollowed (beat
de guion, no de entorno) queda con brief propio pendiente.

**Archivos actualizados:** [[Briefs de Concept Art]] §15 (nuevo) · [[Current-State]]
§Concept art pendiente · [[00-Index]].

**Estado:** `check_vault.py` verde tras el edit de Current-State (~3,857 tokens de
arranque). `check_canon.py` no corrido -- el brief nuevo no toca canon narrativo, solo
cita a Geografia y Ciudades ya ratificado.

**Proximo paso:** correr los 3 briefs en NB2 y traer las 3 laminas para QA visual.

## [2026-08-07] QA | Los Desfiladeros de Zephyr — 3/3 ratificadas

Boris trajo las 3 laminas generadas de los briefs de §15 (Briefs de Concept Art) --
zephyr-canyons-human-v1.png / -dwarf-v1.png / -elf-v1.png, corridas en NB2. Evaluacion
contra brief + los 5 ejes de la Art Bible, sin subagente (juicio directo sobre imagen).

**15.1 humana (Mistbound Frontier) -- Ratificada, nota menor.** Canon amplio, figura
diminuta en el sendero, cartel de madera sin texto, paleta ochre lavada, perspectiva
aerea correcta en la lejania. Nota no bloqueante: luz difusa en vez de la luz dura de
mediodia del brief; arbustos algo mas verdes que "arido".

**15.2 enana (Ignis Reach) -- Ratificada, nota menor.** Contraste calido/frio logrado
con precision (magma abajo vs apertura azul-fria arriba, tal como pedia el brief),
vapor, embers flotando, charcos de lava, escala vertiginosa. Nota no bloqueante:
escalera de tablones de madera en vez de "narrow carved stone stairway".

**15.3 elfica (Stillwood) -- Ratificada, nota menor -- la mas lograda de las 3.** Vides
enredadas agresivamente, musgo, rayos de luz verde-dorada, sin cielo visible (ascenso
sin terminar). Nota no bloqueante: composicion lee mas "parado entre raices" que
pendiente en ascenso -- el mecanismo de locomocion (handholds) no es evidente.

**Hallazgo transversal:** mismo icono de destello/diamante blanco repetido identico en
esquina inferior derecha de las 3 -- probable filtracion de UI de NB2, no bloqueante.
Nota agregada a §15.4 del brief para negativos de futuros re-rolls del batch.

**Archivos:** las 3 laminas copiadas de Downloads a `90-Raw/concept/` (ahora canon
inmutable). [[Briefs de Concept Art]] §15.1-15.4 actualizado con QA + RATIFICADO en
cada header. [[Current-State]] §Concept art pendiente movido a cerrado. [[00-Index]]
actualizado.

**Estado:** `check_canon.py` pendiente de re-correr como cierre del checkpoint.

## [2026-08-07] design | Brief de la Emboscada de los 3 Hollowed + llegada de Roen

Boris pidio el brief pendiente de la escena que cierra el tutorial de Los Desfiladeros
de Zephyr -- la emboscada ya estructurada en Geografia y Ciudades §El Encuentro con
Roen (pasos 4-5): 3 Hollowed cierran el circulo sobre el jugador solo, Roen entra en
cuadro justo a tiempo.

**Nuevo brief en [[Briefs de Concept Art]] §16.** Decision de encuadre: el brief
captura el INSTANTE ANTES del rescate (Hollowed ya cerraron el circulo, Roen recien
entra en cuadro, sin contacto todavia) -- no el rescate en si, que ya existe ratificado
en §14.1 (roen-second-catch-v1.png, el mecanismo del link Second Catch aislado sobre
fondo neutro). Los dos son complementarios: §16 es el establishing shot narrativo con
entorno, §14.1 es el close-up del link en accion.

Ambientado en la skin humana de Zephyr Canyons (§15.1, ya ratificada) por ser el
registro default del elenco fijo -- Roen y su brief de link ya usan esa referencia.
Reusa el diseño ya ratificado de los Hollowed (§13.8: piel agrietada, vetas
violeta-rojas, cara en blanco) y de Roen (§14.1: cuero remachado, capa tierra, sin
VFX de contacto todavia). Regla de la Art Bible aplicada: peligro = rojo saturado,
unico color intenso del frame son las vetas de los Hollowed.

**Archivos actualizados:** [[Briefs de Concept Art]] §16 (nuevo) · [[Current-State]]
§Concept art pendiente · [[00-Index]].

**Estado:** brief escrito, sin correr en NB2 todavia.

**Proximo paso:** correr §16 en NB2 y traer la lamina para QA.

## [2026-08-07] QA | Emboscada de los 3 Hollowed + llegada de Roen — ratificada

Boris trajo zephyr-ambush-roen-arrival-v1.png (brief §16), corrida en NB2 con las 3
referencias adjuntas segun instruccion del brief (roen-second-catch-v1.png,
the-hollowed-v1.png, zephyr-canyons-human-v1.png).

**Ratificada, con nota menor.** Los 3 Hollowed correctos (piel agrietada, vetas
violeta-rojas en las articulaciones, postura de manada agachada, ropa hecha jirones),
Roen sin VFX de contacto todavia -- mano extendida, el rescate aun no paso, exactamente
el instante que pedia el brief. Capa tierra ondeando, cuero remachado, entorno de
cañon arido consistente con §15.1. El peligro (vetas violeta) es el unico color
saturado del cuadro.

**Nota no bloqueante:** el pelo de Roen sale gris/blanco aca, en la lamina ya
ratificada del link (§14.1, roen-second-catch-v1.png) es castaño oscuro --
inconsistencia de continuidad entre 2 laminas del mismo personaje. No se corrige ahora
(no bloquea), queda anotada para si se re-corre algo de Roen a futuro. Nota menor
adicional: el jugador queda en medio del sendero, no literalmente "acorralado contra
la pared" como pedia el brief -- no afecta la lectura general.

**Archivos:** lamina copiada de Downloads a `90-Raw/concept/`. [[Briefs de Concept
Art]] §16 actualizado con QA + RATIFICADO en el header. [[Current-State]] §Concept art
pendiente cerrado. [[00-Index]] actualizado.

**Cierre de sesion:** con esto, el tutorial completo de Los Desfiladeros de Zephyr
(3 skins raciales del entorno + la escena de la emboscada que lo cierra) tiene su
concept art completo y ratificado. Proximo frente: guion real de la escena del
Encuentro con Roen (dialogo, 3 variantes de rol) -- sigue siendo estructura sin texto
todavia, como quedo anotado el 2026-08-07 anterior.

## [2026-08-07] guion | Escena del Encuentro con Roen — primer guion jugado del juego

Boris pidio escribir el guion real de la escena que ya tenia estructura confirmada
(Geografia y Ciudades §El Encuentro con Roen, cerrado antes en la sesion): la emboscada
de los 3 Hollowed que resuelve el tutorial de Los Desfiladeros de Zephyr, con Roen
interviniendo justo a tiempo. Es el primer guion JUGADO del juego (distinto del
bookend de Roen viejo, que es pre/post-partida).

**Nuevo archivo: [[Guion/Encuentro con Roen]], `status: provisional`.** Retoma el
tramo solo justo despues del title card, calca el staging de la lamina ya ratificada
(zephyr-ambush-roen-arrival-v1.png, §16) y escribe las 3 variantes por rol:
- Duelist: Roen agarra un Hollowed y lo lanza para que el jugador lo remate.
- Strategist: Roen atrapa al jugador a media caida y lo repone en terreno firme.
- Vanguard (rol duplicado): modo "doble ancla", ya fijado en Geografia y Ciudades,
  no es decision nueva de hoy.

**Decision nueva de esta sesion, sin fuente previa:** el split Duelist/Strategist
dentro del "modo estandar" de Second Catch (Los 3 Links de los Fijos solo describia
2 sabores de T1 sin asignarlos a un rol especifico). Queda marcado explicitamente en
el archivo como pendiente de confirmacion/veto de Boris.

**Asuncion de diseño sin regla escrita:** el jugador no tiene linea hablada en esta
escena -- ninguna fuente fija "protagonista silencioso" de forma explicita, pero seguir
el mismo patron de la viñeta muda de Guion/Apertura -- Roen Viejo se uso por
consistencia. Anotado como asuncion a confirmar antes de generalizarla al resto del
guion de actos.

Verificado contra canon antes de escribir: la linea "Contract wasn't wrong" es la
primera confirmacion hablada en pantalla de que el jugador ya contrato a Roen
(Roen-Ficha:101), sin re-narrar la contratacion en si. El tono de la primera linea
post-combate ("competente sin fanfarria, asiente, no aplaude") cita directo
Roen-Ficha §Escena 1 y el paso 6 de Geografia y Ciudades.

**`status: provisional`** -- toca Second Catch, que sigue provisional en Los 3 Links
de los Fijos, pendiente de la ronda de QA del domingo (regla de trafico ya fijada en
Current-State).

**Archivos actualizados:** [[Guion/Encuentro con Roen]] (nuevo) · [[Current-State]]
§Narrativa/guion · [[00-Index]].

**Cierre de sesion (pedido de Boris):** con esto para hoy. Resumen de lo cerrado:
concept art completo de Los Desfiladeros de Zephyr (3 skins + emboscada, todo
ratificado) + primer guion jugado del juego escrito (provisional, pendiente 2 puntos
de confirmacion: split de rol + asuncion de jugador silencioso). Proximo frente
cuando retomen: caminata silenciosa hacia la ciudad natal donde los alcanza Valen, o
la ronda de QA del domingo sobre todo lo provisional de la semana.

## [2026-08-07] fix | Correccion: el link de Roen no cambia por rol (Duelist=Strategist)

Boris corrigio el guion recien escrito de la Emboscada/Encuentro con Roen: el primer
borrador de [[Guion/Encuentro con Roen]] inventaba un split Duelist/Strategist dentro
del "modo estandar" del link (remate de enemigo lanzado para Duelist, atrapada a media
caida para Strategist) -- **no tenia base en canon.** Los 3 Links de los Fijos §Roen
describe 2 sabores del T1 de Second Catch, pero contextuales (segun la situacion de
combate), no atados a rol. Geografia y Ciudades §El Encuentro con Roen ya decia esto
con precision desde que se cerro la estructura: "Duelist o Strategist: modo estandar
del link... Vanguard (rol duplicado): modo doble ancla" -- solo Vanguard difiere.

**Fix a la fuente** (regla 8 del repo -- fix va a la fuente, no a la linea reportada):
[[Guion/Encuentro con Roen]] fusiono las 2 variantes en una sola ("Variant A:
Duelist/Strategist, modo estandar"), usando el sabor de "atrapa a media caida" por
match directo con la lamina ya ratificada (roen-second-catch-v1.png, §14.1). El sabor
de "lanza a un enemigo" del sistema no se descarta en general -- solo no es el que se
uso en ESTE guion especifico, por consistencia visual con lo ya aprobado. Se elimino
la nota de "pendiente de confirmacion de Boris" del split, porque ya no existe split
que confirmar.

**Archivos actualizados:** [[Guion/Encuentro con Roen]] · [[Current-State]] ·
[[00-Index]].

## [2026-08-07] fix | 2a correccion: modo estandar pasa a "lanza y remata", nuevo frente de verbos por celda

Boris pidio simplificar aun mas: en vez de "atrapa a media caida" para el modo
estandar (Duelist/Strategist), usar el otro sabor ya descripto en Los 3 Links de los
Fijos -- Roen lanza un Hollowed, el jugador remata. Lo unico que varia es la animacion
del remate, y eso deberia pensarse a nivel de la habilidad inicial/melee de cada
raza x rol, no como coreografia completa de rescate por celda.

**Pregunta de fork resuelta con Boris antes de tocar la fuente:** ¿Vanguard tambien se
unifica a "lanza y remata", o mantiene el modo "doble ancla"? Boris eligio mantener
doble ancla -- tiene razon narrativa propia (mismo arquetipo que Roen) que las otras 8
celdas no comparten, y Geografia y Ciudades ya lo fijaba asi.

**Fix aplicado en [[Guion/Encuentro con Roen]]:** el modo estandar (Duelist/Strategist)
ahora usa "Roen lanza un Hollowed para que el jugador remate", con el remate escrito a
NIVEL DE ROL (Duelist = melee, Strategist = ejecucion a distancia) -- no a nivel de las
6 celdas raza x rol completas, porque esos verbos no estan compilados en el vault
todavia (Combate.md §C y Matriz Raza x Rol citan al GDD §4.2C congelado sin
reproducirlo). Vanguard sin cambios (doble ancla).

**Frente nuevo detectado, sin ejecutar:** verbos/armas de ataque base por las 9 celdas
raza x rol. Boris pidio llevarlo al consejo (skill llm-council) para que propongan
base attacks coherentes con el lore, con ejemplos de referencia (mandoble, espada
doble, dagas, arco+daga, espada, magia ignea, etc.) -- se corre a continuacion.

**Archivos actualizados:** [[Guion/Encuentro con Roen]] · [[Current-State]] ·
[[00-Index]].

## [2026-08-07] design | Consejo de armamento base + tabla final de las 9 celdas raza x rol

Boris pidio llevar al consejo (skill llm-council) el diseño del ataque base/remate de
las 9 celdas de la Matriz Raza x Rol -- el hueco que quedo abierto al escribir
Guion/Encuentro con Roen (el remate solo estaba resuelto a nivel de ROL, no de celda).

**Ronda de consejo (5 asesores + peer review + chairman):** convergencia fuerte en
tratar el remate como problema BIOMECANICO (Roen fija trayectoria/timing, el rig de
cada raza define como intercepta) en vez de "que arma le queda linda a cada raza" --
reduce las 9 celdas a 3 verbos por raza (Elfo=intercepcion, Enano=absorcion-negada,
Humano=variable por rol) con el rol como inflexion. El consejo detecto 2 colisiones de
identidad sin resolver (Enano Duelist vs. hachas de Darro, Humano Vanguard vs. agarre
de Roen) y una pregunta abierta: que pasa si el jugador falla el remate (whiff).

**Boris resolvio las 3 cosas en la misma sesion:**
1. Whiff: hay ventana de input para apretar ataque/melee -- si falla, NO es fail state,
   el combate sigue pero se anula el bonus de daño del link. Agregado a la fuente en
   [[Los 3 Links de los Fijos]] §Roen (T1).
2. Equipamiento final de las 9 celdas, con nombres concretos que resuelven las 2
   colisiones detectadas (Enano Duelist = war pick & hammer, no hachas; Humano Vanguard
   = war flail + kite shield, no agarre a mano limpia):
   - Elfo Duelist: elven double-bladed sword
   - Elfo Vanguard: elven glaive + escudo arcano
   - Elfo Strategist: elven bow (debuffs+daño ligero) + magia de marcado tipo Valen
   - Enano Duelist: dwarven war pick & hammer
   - Enano Vanguard: dwarven great warhammer + brazaletes reforzados (escudo)
   - Enano Strategist: dwarven hand cannon + kit ingeniero de curas (estilo Rocket
     Raccoon, Marvel Rivals)
   - Humano Duelist: scimitar + parrying dagger
   - Humano Vanguard: war flail + kite shield
   - Humano Strategist: Hunting Hanger + Signal Horn + granadas de cura

**Archivo nuevo: [[Armamento Base — Matriz Raza x Rol]], `status: borrador`.** Tabla
completa (verbo/ejecucion/arma/nota) + la regla de la ventana de remate. Arranca a
compilar la seccion C de [[Combate]], enlazada desde ahi. [[Guion/Encuentro con Roen]]
actualizado para citar el arma especifica en vez de la descripcion generica por rol, y
para incluir la mecanica de ventana de input en el beat del remate.

**Archivos actualizados:** [[Los 3 Links de los Fijos]] · [[Armamento Base — Matriz
Raza x Rol]] (nuevo) · [[Combate]] · [[Guion/Encuentro con Roen]] · [[Current-State]] ·
[[00-Index]].

**Estado:** `status: borrador`, sin pasar por QA de canon todavia -- decisiones de
Boris de esta sesion, no verificadas contra Movilidad Realista/Game Feel Bible
(peso, timing de hit-stop por celda).

## [2026-08-07] fix + design | Cierre de las 12 celdas: fix de canon del parry + giro de Strategist + equipamiento de los 3 fijos

Boris trajo su propia propuesta de mecanicas clave para las 9 celdas y goteo hacia
un problema real: yo habia introducido un error de canon en la ronda de consejo
anterior, diciendo "parry redirige, no absorbe" como regla transversal del juego.
Combate.md §B4 (ratificado) dice lo contrario -- el parry es de SABOR RACIAL: Elfo
redirige, Enano absorbe-planta (roba Equilibrio), Humano roba-desarma (usa el
VectorFuerza del rival). El error se habia filtrado a Armamento Base — Matriz Raza x
Rol.md, donde el mecanismo del Enano Vanguard estaba mal etiquetado como
"redireccion" en vez de "absorcion". Corregido a la fuente.

**Revision celda por celda de la propuesta de Boris contra el canon real:**
- 7 de 9 sin conflicto.
- Enano Vanguard: la propuesta de Boris ("absorbe daño frontal") es la que estaba
  BIEN -- coincide exacto con el canon. El error era mio (mi doc decia
  "redireccion").
- Elfo Vanguard: fix de framing, no de mecanica -- la carga del escudo sale de
  "canalizar el impulso de cada redireccion exitosa", no de "absorber el golpe",
  para no romper "no absorbe, redirige" (Matriz Raza x Rol + Combate §B4).
- Humano Duelist: fix de lenguaje -- "le arrebata el control del golpe usando el
  impulso del rival" en vez de "desvia", para coincidir con el sabor humano
  (roba-desarma, no redirige).

**Giro de los 3 Strategist (pedido explicito de Boris):** la primera pasada
convergia los 3 en "sanador de area" (marca curativa / vapor curativo / granadas de
cura), alejandose de los arquetipos originales de la Matriz. Vuelta al sabor
original:
- Elfo Strategist: Corriente Psiquica (Tether Arcano) -- marca que tira/empuja
  enemigos y aliados, "manipulador psiquico: recoloca" literal.
- Enano Strategist: Torreta de Forja -- torreta de area + buff de armadura,
  "ingeniero: torretas/drones/buffs de armadura" literal.
- Humano Strategist: Trampero de Caza -- trampas de red/cepo + Signal Horn como
  detonador/señuelo, "gadgeteer: hooks/redes/trampas" literal.

**Equipamiento de los 3 fijos (cierra las 12 celdas):**
- Roen: mandoble + espada, cargados todo el juego pero SIN USAR -- pelea a mano
  limpia hasta T3 ("Nothing Borrowed"). Reconcilia la contradiccion real que
  aparecio al hacer el ejercicio: Roen-Ficha §Diseño Visual Ratificado ya decia que
  carga un arma de dos manos + escudo, pero Los 3 Links de los Fijos y el concept
  art ratificado (§14.1) lo muestran peleando sin arma. Reconciliado: carga el
  mandoble/espada visibles pero no los usa hasta T3 -- no contradice "confia solo
  en sus manos". **Cabo suelto sin resolver:** el escudo especifico de T3 se
  describe como "su escudo real... no como herramienta encontrada", pero la ficha
  tambien dice que lo dejo en la puerta del Council al irse -- falta el beat de
  como volvio a sus manos. Anotado en ambos archivos, pendiente de Boris.
- Darro: hachas cortas (ya ratificado) + cuchillas lanzables (agregado, sin
  conflicto).
- Valen: hueco real confirmado -- su Diseño Visual no tenia ningun objeto. Cierra
  con una "calculation blade" (hoja corta ceremonial, herramienta de precision
  para anclar sus marcas, nunca arma de combate) -- coherente con "academico, no
  guerrero".

**Archivos actualizados:** [[Armamento Base — Matriz Raza x Rol]] (reescrito
completo, `status: ratificado`) · [[Roen-Ficha-Expandida-v1]] · [[Darro-Ficha-Expandida-v1]]
· [[Valen-Ficha-Expandida-v1]] · [[Los 3 Links de los Fijos]] · [[Guion/Encuentro con
Roen]] · [[Current-State]] · [[00-Index]].

**Estado:** decisiones de diseño (arma/mecanica/verbo) RATIFICADAS por Boris.
Implementacion (hitbox/timing/peso contra Movilidad Realista/Game Feel Bible) sigue
sin verificar -- no bloquea. El cabo suelto del escudo de Roen tampoco bloquea nada.

## [2026-08-07] guion | Reconciliacion del escudo de Roen -- regalo anonimo

Boris eligio la opcion del regalo anonimo para cerrar el cabo suelto del escudo de
Roen (dejado en la puerta del Triune Council al renunciar, pero descripto en T3 como
"su escudo real... no una herramienta encontrada" -- contradiccion real detectada al
hacer el ejercicio de equipamiento de los fijos).

**Beat agregado a la fuente:** semanas despues de renunciar, el escudo aparece --
dejado junto al fuego o en la puerta de una posada, sin nota ni testigo. Roen nunca
sabe quien se lo devolvio. Reutiliza a proposito el mismo recurso narrativo de los
Wanderer's Goggles de Old Tobin Hale (regalo/objeto que llega sin explicacion,
deliberadamente sin resolver) -- consistencia de tono, cero maquinaria nueva. Roen
carga el escudo (+ mandoble + espada) visible todo el juego pero no lo usa hasta T3,
donde recien se permite aceptar el gesto.

**Archivos actualizados:** [[Roen-Ficha-Expandida-v1]] (beat en la seccion de origen
+ Diseño Visual Ratificado) · [[Los 3 Links de los Fijos]] §Roen · [[Armamento Base
— Matriz Raza x Rol]] (tabla de fijos) · [[Current-State]].

**Estado:** cabo suelto CERRADO. Las 12 celdas de equipamiento (9 raza x rol + 3
fijos) quedan sin pendientes de canon abiertos.

## [2026-08-07] fix | Barrido de armamento contra los 9 Pivotes -- 2 colisiones cerradas

Boris pregunto si los 9 Pivotes ya tenian equipamiento como los fijos y las 9
opciones del jugador. Verificacion: 8 de 9 SI tenian arma ratificada (Sereth es la
unica excepcion, consistente con Valen -- mismo Elfo Strategist sin arma, patron
"academico, no guerrero" a proposito). El hallazgo real no fue un hueco general,
fueron 2 colisiones literales entre Pivotes que nadie habia cruzado hasta ahora:

- **Torgan vs. Darro** (ambos Enano Duelist): los dos con "dos hachas cortas",
  identico. Ademas distinto del Enano Duelist del jugador (war pick & hammer, ya
  elegido para no chocar con Darro -- pero nunca se cruzo contra Torgan).
- **Lyris vs. Nyael** (ambas Elfa Duelist): los dos con dagas/cuchillos dobles
  cortos, mismo tipo de arma.

**Decisiones de Boris:**
- Torgan -> warhammer de guerra a una mano (4 menciones corregidas en su ficha:
  Esencia, epilogo x2, Diseño Visual Ratificado -- barrido completo, rule 8).
- Lyris -> propuesta mia, confirmada por Boris: par de bumeranes elficos de doble
  filo (vuelan en arco y vuelven a la mano) -- literal su epiteto "trazadora
  aerea", distinto tambien de los lanzadores de disco mecanicos de Maren (gadget
  tech, no hoja elfica arrojada a mano).
- Nyael y Bram: confirmados sin cambios (dagas delgadas / mazo de dos manos).
- Roen: arma fijada explicitamente como mandoble (greatsword), reemplaza la
  ambiguedad "mandoble/maza" de la reconciliacion anterior.

**Archivos actualizados:** [[Pivotes/Torgan-Ficha-Expandida-v1]] (4 menciones) ·
[[Pivotes/Lyris-Ficha-Expandida-v1]] · [[Roen-Ficha-Expandida-v1]] · [[Armamento
Base — Matriz Raza x Rol]] (nueva seccion §Colisiones con los Pivotes) ·
[[Current-State]] · [[00-Index]].

**Estado:** las 2 colisiones detectadas quedan cerradas. Bram/Roen (misma familia
de maza, Humano Vanguard x2) queda anotado como cercania menor, no colision --
el arma de Roen no se usa en pantalla hasta T3.

## [2026-08-07] design | Brief de re-roll de Lyris (bumeranes + limpieza de texto)

Tras cambiar el arma de Lyris (bumeranes elficos, cierre de la colision con Nyael),
Boris pregunto si hacia falta re-roll de su lamina. Verificacion: lyris-v1.png
muestra dos dagas curvas cortas claramente visibles en las caderas (arma vieja) +
texto superpuesto (titulo, "Front View"/"Side View") -- lamina previa a la regla
anti-texto de §0 y sin brief formal ratificado en Briefs de Concept Art.

**Nuevo brief §17, edicion sobre la imagen existente (no regeneracion completa):**
adjuntar lyris-v1.png, mantener pose/anatomia/arnes de cuerdas de traversal aereo
intactos, reemplazar las dagas por un par de bumeranes elficos cruzados a la
espalda baja, y sacar todo el texto superpuesto. Archivo destino: lyris-v2.png.

**Archivos actualizados:** [[Briefs de Concept Art]] §17 (nuevo) · [[Current-State]]
§Concept art pendiente · [[00-Index]].

**Estado:** brief escrito, sin correr en NB2 todavia.

## [2026-08-07] QA | Lyris v2 ratificada -- bumeranes elficos

Boris trajo lyris-v2.png (brief §17), corrida en NB2 con lyris-v1.png adjunta como
referencia. Evaluacion directa (sin subagente).

**Ratificada.** Pose, anatomia, arnes y cuerdas de traversal aereo intactos; texto
superpuesto eliminado por completo. Vista lateral muestra con claridad los dos
bumeranes curvos cruzados en la espalda baja, reemplazando las dagas viejas. Nota
menor no bloqueante: en la vista frontal el arma queda tapada por el arnes/capa --
la lateral resuelve la lectura sin ambiguedad.

**Archivos:** lamina copiada de Downloads a `90-Raw/concept/`. [[Briefs de Concept
Art]] §17 actualizado con QA + RATIFICADO en el header. [[Current-State]] y
[[00-Index]] actualizados.

**Estado:** con esto, las 2 colisiones de armamento detectadas contra los Pivotes
(Torgan/Darro, Lyris/Nyael) quedan cerradas tanto en canon de texto como en concept
art -- Torgan no tenia lamina propia que corregir.

## [2026-08-07] cierre de sesión | Compactación de Current-State + To Do de la próxima sesión

Sesión larga (2026-08-07): tutorial de Zephyr completo en concept art (3 skins +
emboscada + re-roll de Lyris, §15-17 de Briefs de Concept Art, 5/5 ratificadas) +
primer guion jugado del juego escrito (Guion/Encuentro con Roen, provisional) +
Armamento Base de las 12 celdas + barrido contra los 9 Pivotes (2 colisiones
cerradas: Torgan, Lyris) + fix de canon del parry + reconciliacion del escudo de
Roen. Detalle completo de cada paso en las entradas de arriba, todas fechadas
2026-08-07.

**Cierre:** Current-State.md compactado (estaba +823t sobre el techo tras la
sesion larga, bajo a +88t) -- el detalle ya vive completo en este LOG, Current-State
solo guarda resumen + pendientes. Bloque "Inmediato" reescrito con el To Do real de
la proxima sesion (reemplaza el bloque stale del 08-06).

**To Do de la proxima sesion:**
1. Guion: la caminata silenciosa hacia la ciudad natal donde alcanza Valen
   (Geografia y Ciudades §Beats Narrativos por Acto, punto 2) -- sigue directo de
   Guion/Encuentro con Roen.
2. Domingo pendiente: una sola ronda de subagentes de QA audita todo lo
   provisional acumulado (Los 3 Links de los Fijos + Guion/Encuentro con Roen).
   No antes de esa fecha.
3. Concept art listo para correr sin ejecutar (no bloquea): King Borran §9b-v3,
   key-art-poster §12.1/12.2.
4. Reglas de trafico sin cambios: linter antes de cada checkpoint, cualquier
   guion nuevo que toque un Link de los Fijos queda provisional hasta el domingo.

**Estado:** `check_canon.py` 0 criticos / 0 medium. `check_vault.py` verde
(~3,850 tokens de arranque). Sesion cerrada.

## [post-cierre] fix | King Borran ya estaba cerrado + hallazgo de key-art-poster-v2 sin evaluar

Boris senalo que King Borran v3 ya estaba hecho -- error mio: lo deje en el To Do
de cierre sin cruzarlo contra Briefs de Concept Art (que ya tenia "Evaluacion: ✅
GENERADO 2026-08-06, RATIFICADO por Boris" registrado) ni contra 90-Raw/concept
(donde king-borran-v3.png ya estaba copiado). Corregido en Current-State.

**Hallazgo adicional al verificar:** `marketing_key-art-poster-v2.png` (brief
§12.2) tambien existe -- sentado en Downloads desde 2026-07-28, coincide exacto
con el nombre de archivo destino del brief, pero nunca se evaluo ni se copio al
vault. Pendiente de QA la proxima vez que se retome concept art.

**Archivos actualizados:** [[Current-State]] (bloque Inmediato + Concept art
pendiente).

**Leccion de metodo:** antes de escribir un To Do de cierre con items de concept
art, cruzar contra `Briefs de Concept Art` (¿tiene Evaluacion ya?) y contra
`90-Raw/concept/` (¿el archivo ya existe?) -- no confiar en el estado previo de
Current-State sin verificar.

## [post-cierre 2] QA | key-art-poster V2 ratificado retroactivamente

Boris pidio evaluar marketing_key-art-poster-v2.png (brief §12.2), encontrado sin
evaluar en Downloads desde 2026-07-28. Evaluacion directa contra el brief completo.

**Ratificado.** Las 3 franjas de horizonte correctas (rio/Rivermeet izquierda,
Stillspire sobre el dosel de Gloomvault al centro, terreno volcanico con
resplandor de Ignis Reach a la derecha), sur ausente sin indicios de First Wound,
hueco de composicion donde estaba Speck, cielo con el gradiente exacto y espacio
limpio para el logo, perspectiva aerea correcta, sin armas desenvainadas ni poses
heroicas. Nota menor no bloqueante: mismo icono de destello de NB2 ya trackeado
desde el batch de Zephyr (§15.4).

**Archivos:** lamina copiada de Downloads a `90-Raw/concept/`. [[Briefs de Concept
Art]] §12.2 actualizado con QA + RATIFICADO en el header (insertado via awk por un
problema de encoding NBSP en la linea de negativos original -- Edit normal fallaba
por mismatch de espacios no-rompibles ocultos en el texto). [[Current-State]] y
[[00-Index]] actualizados.

**Estado:** con esto, los 2 hallazgos de concept art "generado pero olvidado sin
evaluar" (King Borran ya estaba cerrado, key-art-poster V2 recien se cerro) quedan
resueltos. §12.1 (V1) sigue siendo el unico brief de esta seccion sin correr.

## [2026-08-10] canon-qa | 17a ronda -- 13 criticos entre 2 subagentes, corregidos a la fuente

Ronda de QA sobre todo el canon `provisional` acumulado: [[Los 3 Links de los
Fijos]] + [[Guion/Encuentro con Roen]]. Linter primero (0 criticos, 28 INFO
preexistentes) -> 2 subagentes en frio (Opus, dramaturgia + congruencia
semantica), sin contexto entre si. Resultado: **13 criticos unicos** (fuerte
solapamiento entre ambos reportes, senal de que no era ruido).

**4 decisiones de diseno resueltas por Boris (AskUserQuestion):**
1. **Donde se suma Valen:** en una taberna dentro de la ciudad natal, tras la
   caminata a solas Roen+jugador (no en la "Frontera inmediata" que decia
   §Beats Narrativos -- [[Geografía y Ciudades]] se contradecia a si misma,
   punto 7 vs §Beats). Corregidos ambos + propagado a
   [[Guion/Encuentro con Roen]].
2. **Rol duplicado de Roen:** "doble ancla" (lo ya escrito en el guion) es
   canon, no "cadena de rescate" (lo que decia la fuente unica). Ademas
   bajado de T2 a T1 en [[Los 3 Links de los Fijos]] -- es estructural
   (character creation), no earned via bond, y se dispara en el primer
   encuentro a bond cero. Queda pendiente (❓) revisar si Valen/Darro tienen
   el mismo problema en sus propios casos de rol duplicado.
3. **Los 3 Hollowed de la emboscada:** excepcion de manada (solo 3, no la
   manada normal de 4-8) registrada en [[Villanos Menores]] §The Hollowed,
   con justificacion de habitat (filtracion aislada, no una manada asentada
   en zona sana).
4. **Ubicacion de "El Encuentro":** [[Roen-Ficha-Expandida-v1]] y
   [[Valen-Ficha-Expandida-v1]] (draft desde 2026-07-27) describian la
   escena en The Wilds, con ambos ya presentes -- desactualizado contra
   [[Geografía y Ciudades]]/[[Estructura Dramática]] (ratificadas) y el
   guion ya escrito. Reescritas ambas §Escena 1 a Zephyr: Roen rescata (no
   "ya presente"), Valen ausente (se suma despues, en la taberna). Resuelve
   tambien el beat duplicado de "primera bestia" (Valen ya no lo tiene --
   no estaba ahi).

**5 fixes directos** (sin decision nueva -- restauraban decisiones ya
tomadas o corregian texto obsoleto):
- Escudo/"shield arm" de Roen en el guion quemaba T3 "Nothing Borrowed" --
  reescrito a mano limpia.
- Remate de las 3 celdas Strategist restaurado a "accion a distancia", no
  melee -- la distincion por rol (Duelist=melee, Strategist=distancia) que
  Boris ya habia aprobado el 2026-08-07 (ver entrada de esa fecha) se habia
  perdido en un borrador intermedio de [[Armamento Base — Matriz Raza x
  Rol]]. Corregido ahi y en el guion.
- "Los fijos no alteran tu identidad de combate" ([[Los 3 Links de los
  Fijos]]) contradecia [[Acoplamientos]] (ratificado) para el jugador
  Duelist -- matizado.
- 4 menciones de "Roen recogio el escudo al inicio del juego" (residuo
  previo a la reconciliacion del 2026-08-07) corregidas a la version
  vigente (regalo anonimo, anios antes del juego).
- La lamina §16 (`zephyr-ambush-roen-arrival-v1.png`, ratificada) prometia
  un rescate que el guion no entrega en la Variante A -- aclarado en el
  guion que §16 es el instante de la llegada de Roen, no el catch en si
  (eso es §14.1).

**Metodo:** todos los fixes fueron a la fuente (regla 8 del repo), no a la
linea reportada. Re-grep + linter en 0 criticos / 0 medium tras los fixes
(28 INFO preexistentes sin cambios).

**Pendiente:** re-corrida de los 2 subagentes antes de pasar
[[Los 3 Links de los Fijos]] y [[Guion/Encuentro con Roen]] a `ratificado`
(criterio de cierre del sprint: 0 criticos en ambos). Queda tambien la
pregunta abierta sobre tier de Valen/Darro (punto 2 arriba).

## [2026-08-10, 2a pasada] canon-qa | re-corrida -- 3 nuevos criticos por subagente (uno mio), corregidos

Re-corri los 2 subagentes (mismo alcance, en frio otra vez) para verificar los
fixes de la entrada anterior. **No cerro.** 6 criticos entre ambos (fuerte
solapamiento -- 2 eran el mismo hallazgo desde los dos angulos).

**Bug propio detectado:** el fix de la ronda anterior (bajar el rol duplicado
de Roen de T2 a T1) dejo a Roen sin ningun T2 -- unico de los 3 fijos sin tier
medio, contradiciendo [[The Tether]] §B ("T1->T2->T3", sin excepcion) y el
gate del Final 4 (>=2 companieros en T2+). Peor: mi propio texto agregado a
[[Roen-Ficha-Expandida-v1]] ("todavia no lo conoce en persona") contradecia
una seccion YA EXISTENTE de esa misma ficha (18 variantes de encuentro, se
conocen hace 1-2 anios) que no habia leido con cuidado antes de escribir.

**Fixes de esta pasada:**
1. **T2 de Roen restaurado:** el contenido original "cadena de rescate" (que
   la pasada anterior habia reasignado a la variante T1 "doble ancla") se
   reasigna de nuevo, esta vez como **T2 generico** para los 3 roles, earned
   por bond -- no exclusivo de rol duplicado. [[Los 3 Links de los Fijos]]
   ahora: T1 base + T1-variante (doble ancla, solo combate compartido
   Vanguard) + T2 (cadena) + T3 (Nothing Borrowed). Aclarado tambien que
   "doble ancla" NO reemplaza el traversal base del link fuera de combate
   compartido -- ambiguedad que el subagente de dramaturgia marco como
   critico (perdida de la unica herramienta de traversal del jugador Vanguard
   en Acto 1).
2. **Corregido mi error:** Roen y el jugador YA se conocian (1-2 anios,
   [[Roen-Ficha-Expandida-v1]] §Conexion con el jugador). Zephyr es la
   primera vez que trabajan juntos en este contrato, no la primera vez que se
   ven. Ajustado tambien el guion (la linea "not the kind you give a
   stranger" ya era compatible, no necesito tocarla).
3. **Linea "Contract said you could handle yourself" reescrita** a "Told
   myself you could handle yourself before I took this job. Wasn't wrong." --
   la version anterior confundia 3 lecturas de "contrato" (el Contrato de
   Conquistador del Triune Council que firma el jugador vs. la contratacion
   personal de Roen, mercenario). [[Geografía y Ciudades]] tambien ajustada
   para distinguir ambos.
4. **Remate Strategist: de "no melee" a "no dano directo" de verdad.** El fix
   anterior solo saco el boton de melee pero el hand cannon (Enano) y la
   hanger (Humano) seguian siendo golpes de muerte en la prosa -- violaba
   [[Acoplamientos]] ("Strategist no dana") pese a citarlo. Reescrito en
   [[Armamento Base — Matriz Raza x Rol]] y el guion: las 3 celdas
   Strategist ahora neutralizan/marcan (Elfo: Tether Arcano: Enano: ronda de
   marcaje del hand cannon, no bala letal; Humano: Signal Horn detona la
   trampa, no la hanger) -- el Hollowed cae igual, pero no por el golpe del
   Strategist.
5. **[[Geografía y Ciudades]] ya no ofrece el sabor "atrapa a media caida"**
   para esta escena puntual (seguia listado como opcion viva pese a que el
   guion ya lo habia descartado explicitamente).

**Metodo:** de nuevo, todos los fixes a la fuente. Linter en 0 criticos / 0
medium tras esta pasada. Lanzando 3a re-corrida de los 2 subagentes.

## [2026-08-10, 3a pasada] canon-qa | 3a re-corrida -- 4 criticos mas, mas profundos, corregidos

3a re-corrida (2 subagentes, mismo alcance, en frio). **Buena noticia:** los 3
temas que la 2a pasada habia arreglado (contrato personal vs. Contrato de
Conquistador, "ya se conocian", cantidad/habitat de Hollowed) salieron
**verificados limpios** en los 2 reportes -- primera vez que un barrido
sobrevive intacto a una re-corrida completa en esta ronda.

**4 criticos nuevos, mas sistemicos que los anteriores:**
1. **T1 de los 3 links asumia "golpe del jugador"** en la fuente unica
   ([[Los 3 Links de los Fijos]]) -- rompia para las 3 celdas Strategist
   (violaba [[Acoplamientos]], "Strategist no dana") pese a que el guion y
   Armamento Base ya tenian el split de rol correcto. Era literalmente el
   fallo de la regla 8: se habia arreglado la linea reportada (el guion) dos
   veces sin tocar la fuente que originaba el problema. Corregido en la
   fuente para Roen (ventana de remate), Valen (Marked Variable ya no exige
   "golpe" del jugador) y Darro (T1 con rama de control para Strategist).
   Agregada tambien una nota de co-dependencia: el "expuesto" que genera
   Roen al lanzar un enemigo funciona como equivalente de marca de
   Strategist para el Duelist, solo en esa ventana puntual -- fuera de ella,
   sin Strategist en el grupo, el Duelist no tiene dano pleno.
2. **Darro sin T2 general** (solo tenia el caso de rol duplicado, a
   diferencia de Roen y Valen). Agregado "Doble Quiebre", T2 generico
   disponible para los 3 roles.
3. **"Objeto firma en T3" (afirmado en [[The Bound Five]], ratificado) era
   falso para Valen y Darro** -- solo Roen tiene uno (el escudo). Corregido
   en la fuente que originaba la promesa; queda como pendiente de diseño
   abierto en [[Los 3 Links de los Fijos]], no como hecho ya resuelto.
4. **El bookend ratificado ([[Guion/Apertura — Roen Viejo]] y [[Voz
   Narrativa]]) seguia diciendo "The Wilds"** como ambiente del handoff de
   control, pese a que la estructura ratificada (2026-08-07) arranca en Los
   Desfiladeros de Zephyr. El barrido de esta clase (rondas 1a y 2a) nunca
   habia llegado a estos 2 archivos ratificados -- se corrigieron ahi.

**Fixes menores en la misma pasada:** T2 "Cadena" de Roen no tenia sentido
para el jugador Vanguard (T1 no incluye agarres para ese rol) -- agregada
variante "Ancla Movil"; T3 de Roen aclarado a "solo el escudo" (mandoble y
espada siguen dormidos con o sin T3), propagado a Roen-Ficha y Armamento
Base, que tenian redaccion ambigua sobre "las tres piezas".

**Metodo:** linter en 0 criticos tras esta pasada (un critical propio de
cita rota en el primer intento, corregido de inmediato).

**Sesion cortada aca por Boris (2026-08-10):** la 4a re-corrida no se
lanzo. Primer paso de la proxima sesion: lanzarla (2 subagentes, mismo
alcance) antes de cualquier otra cosa -- criterio de cierre sigue siendo
0 criticos en ambos. Tres rondas seguidas encontraron problemas reales
(nunca ruido, siempre solapamiento fuerte entre los 2 subagentes), asi
que no asumir que esta vez cierra limpio solo porque van 3 pasadas.

## [2026-08-10] research | gauntlet-loop investigado + brief para el consejo

Boris pidio empezar a preparar el terreno para los 2 pendientes grandes
ingestados fuera de sesion: (1) revisar gauntlet-loop como tercer metodo de
desarrollo, (2) llevar al consejo la decision de motor/fases con su premisa
de vertical slice.

**Gauntlet-loop, How I Prompt Fable, y Workbench fetcheados y leidos.**
Conclusion: gauntlet-loop **no es una tercera via de motor** -- es un metodo
de produccion (constructor + critico independiente, loop sin limite de
rondas contra un estandar de calidad medible), ortogonal a Godot/Unity, no
un reemplazo. Ya disponible parcialmente en esta sesion via skill `/loop`;
lo que falta es disciplina de prompt, no tooling nuevo. Candidato natural de
"estandar medible" para Aether Bound: [[Benchmark Biomecánico]] (ya mide
frame a frame contra Sable/Sifu/HZD). Workbench (coordinacion multi-agente
via markdown compartido) no tiene caso de uso claro mientras el equipo sea
Boris + 1 agente. Todo el analisis completo agregado a [[ADR-003 Reset de
desarrollo y motor]] §Tercera via.

**Brief para el consejo escrito:** [[Brief para el Consejo — Motor y Fases
de Desarrollo]] compila la premisa de fases que Boris escribio (vertical
slice = creacion de personaje x18 + prologo + tutorial + titulo + Encuentro
con Roen, sin limite de tiempo para el desarrollo completo) + los insumos ya
resueltos (Godot vs Unity de ADR-002/003, gauntlet-loop de arriba).
**Tension detectada:** el candidato de slice de ADR-003 ([[Slice of Bond]],
4 escenas narrativas, Humano Duelist x Dagna) no es el mismo alcance que
pide la premisa de Boris (slice de onboarding/produccion, no de profundidad
narrativa) -- marcado explicitamente en el brief para que el consejo no lo
pise por error.

**Estado:** ambos pendientes tienen el terreno preparado. Falta que Boris
confirme si corre `/llm-council` con el brief ahora o prefiere ajustar la
premisa primero -- la sesion de decision de ADR-003 sigue siendo no
delegable, este brief la hace mas eficiente, no la reemplaza.

## [2026-08-10] design | consejo corrido + ADR-003 CERRADO + hard reset ejecutado

Boris confirmo correr `/llm-council` con el brief tal cual. 5 asesores (Contrarian,
First Principles, Expansionist, Outsider, Executor) -> revision cruzada anonima ->
sintesis del chairman. Transcript completo en
`90-Raw/council-2026-08-10-motor-y-fases.md`.

**Veredicto del consejo (resumen):** el bloqueo de 6 semanas no era tecnico, era
de firma -- el ADR daba permiso para seguir haciendo lo comodo (worldbuilding,
QA) en vez de lo que podia fallar (codigo). El Candidato B (creacion de
personaje x18 + prologo + tutorial + titulo + Encuentro con Roen) no tiene
condicion de muerte -- no es un vertical slice, es produccion de assets.
Candidato A ([[Slice of Bond]]) si tiene criterio de falla explicito ("si la
coda no duele, el slice falla"). Motor: Godot, evidencia medida vence a
argumentos de catalogo. El chairman discrepo de la unanimidad de los 5
revisores en un punto: la premisa de Boris ("game feel y biomecanica
correctos") no era vanidad de arte -- es la afirmacion de que la biomecanica
es el canal por el que viaja la perdida, y eso se conservo en el recorte.

**Error del consejo, detectado al aterrizarlo:** propuso resolver "Dagna o
Roen" para el slice con 30 min de lectura. Pregunta malformada -- **Roen es un
fijo, los fijos no traicionan**, no puede sostener la coda del Bond vacio.
Dagna gana por defecto. Se verifico ademas con evidencia del vault (sin
necesitar los 30 min): `Seismic Springboard` es el UNICO de los 9 links del
Pivote con los 3 tiers completamente escritos y el molde de referencia
explicito para los otros 8 -- Dagna se confirma con margen.

**Cierre escrito en [[ADR-003 Reset de desarrollo y motor]] §Cierre**
(borrador -> Boris registro los 3 playtesters -- Diego, Santiago, Delmer,
gamers sin exposicion previa al lore -- y agrego el protocolo de sesion: NO
ponerlos al corriente del lore antes de jugar (su ignorancia es el
instrumento, no un obstaculo) + orden obligatorio de preguntas post-sesion
(abiertas -> comprension -> emocional, porque el arbol de fallas §A solo
discrimina ejecucion vs diseno si la comprension se mide antes que la
emocion).

**Boris confirmo "Master, y hazlo"** -- ejecucion del hard reset:
1. `feat/c6-anatomy-rework` mergeado a `master` primero (master estaba 189
   commits atras de origin, y sin el trabajo de esta sesion completa --
   se sincronizo y mergeo sin conflictos antes de tocar codigo).
2. `git tag archive/prototipo` sobre el HEAD pre-reset -- snapshot recuperable
   para siempre.
3. `godot/` eliminado del arbol de trabajo (codigo versionado + cache local
   `.godot/` no versionada, 242MB).
4. Lanzadores muertos (`Start-Godot.bat`, `Start-GoldenScene.bat`,
   `Start-Playtest-Duelist.bat`, `Start-Playtest-Greybox.bat`) eliminados --
   apuntaban al proyecto borrado.
5. `CLAUDE.md` regla 5, `README.md`, y [[Task-Board]] §Frente C actualizados
   para reflejar el reset (Task-Board queda como registro historico, no se
   reescribe tarea por tarea).
6. [[ADR-002 Motor diferido]] vuelve a plena vigencia -- deja de estar "en
   revision".
7. [[ADR-003 Reset de desarrollo y motor]] cerrado y ratificado.

**Estado:** frente C del Task-Board descongelado. Proximo codigo de
produccion: el vertical slice (3 escenas, Dagna, Godot) segun el cierre de
ADR-003. Pendiente sin bloquear: VoBo explicito de Boris al recorte exacto de
3 escenas si quiere ajustar tiempos/beats.
