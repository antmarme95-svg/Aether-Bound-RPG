---
status: opinión
updated: 2026-08-12
---

# Veredicto de Motor y Lectura del Proyecto

> **Qué es esto.** Lo pidió el director el 2026-08-12, para llevarlo al
> consejo: el veredicto de motor con todo lo medido, más una lectura
> honesta de la solidez probable del proyecto y su techo, sin timeline.
>
> **Qué NO es.** No es canon ni decisión. Es la opinión del asistente,
> con las fuentes marcadas para que el consejo pueda discutirla pieza por
> pieza. Donde es juicio, dice juicio.
>
> **Lo que leí y lo que no**, porque cambia cuánto vale cada párrafo:
> leí el vault de estado (`Current-State`, `LOG`, `Lecciones`), el
> [[Benchmark Biomecánico]] entero, [[Slice of Bond]], los ADR, y corrí el
> spike técnico completo. **No** leí en profundidad las 12 fichas de
> personaje, no vi el concept art, y el guión está apenas empezado —
> **no puedo juzgar la calidad de la prosa ni del arte**. Tampoco sé
> cuántas horas por semana tiene el director.

---

## 1. Veredicto de motor: **GODOT**, y el spike no lo movió

**Ratifico Godot.** No porque haya ganado la comparación técnica —
en lo que se midió, **empataron** — sino porque lo que el spike sí
movió fue un eje que no estaba en la mesa cuando se decidió.

### Lo que se midió, y dio empate

| Métrica (foot IK contra el terreno) | Godot | Unity |
|---|---|---|
| Penetración, plano | −0.004 m | +0.005 m |
| Penetración, rampa 21.8° | +0.005 m | +0.031 m |
| Plano → rampa | +0.009 m | +0.027 m |

Los dos cumplen el estándar del [[Benchmark Biomecánico]] (fila de HZD:
*pies creíbles en terreno*). La diferencia de 26 mm en pendiente es real
pero **sin explicar** — puede ser script, clips o motor. El retargeting
stock funcionó en los dos.

### El eje que sí movió el spike, y es el argumento fuerte

**Godot se deja medir desde afuera; Unity mucho menos.** Todo el spike
—construir la escena, importar, correr, capturar, medir huesos, medir
píxeles— se hizo con `--headless --script`, en segundos por corrida. El
equivalente en Unity exigió entrar a play mode en batchmode sobreviviendo
el domain reload con `SessionState`, pelear el culling del Animator, y
esperar minutos por corrida.

Eso importa **en este proyecto en particular** más que en otro: acá el
código lo escribe un asistente que necesita **verificar su propio trabajo
sin que el director mire cada frame**. Un motor que se deja instrumentar
barato multiplica al equipo; uno que no, convierte cada verificación en
una sesión de a dos.

Sumado a lo que ya estaba: licencia MIT sin riesgo contractual, escenas en
texto diffeable, iteración de segundos, y evidencia propia previa (golden
scene, 430–530 fps).

### El costo real de Godot, medido y no negociado

**El foot IK de fábrica no funciona.** `SkeletonIK3D` está deprecado y
`TwoBoneIK3D` **no produce salida** en 4.7.1 — probado en escena mínima
aislada, 9 variantes de configuración, 0 píxeles en las 9, contra un
control que sí mueve el render. Hubo que **escribir el solver** (~130
líneas). Una vez escrito, cumple el estándar.

Eso es el patrón a esperar de Godot en 3D: **las piezas de alto nivel a
veces no están, o están y no andan.** El framework sí funciona; las clases
concretas, a veces no. Presupuestar eso como constante, no como sorpresa.

### Lo que el spike NO probó, y conviene que el consejo lo tenga presente

Nada de rendimiento comparado, combate, IA, UI, audio, guardado,
build/export, ni look final. **La decisión de motor se sostiene sobre
licencia, iteración e instrumentabilidad — no sobre una comparación
técnica integral, que no se hizo.**

---

## 2. Lo que este proyecto tiene de genuinamente fuerte

Digo esto primero porque lo que viene después es duro, y sería deshonesto
que pareciera un balance negativo.

**1. El pilar es una idea real, no un reskin de género.** El Bond vacío
—una mecánica cuya *ausencia* es la carga emocional— se explica en una
frase y se siente jugando: *la cornisa que sabías que alcanzabas con ella;
picás Bond; nadie golpea el suelo*. Los juegos que pegan fuerte suelen
tener exactamente una de estas. Esta es buena, y es **legible**, que es
más raro todavía.

**2. La disciplina de coherencia es inusual y está instrumentada.** Un
linter de canon con 22 clases, 17+ rondas de QA, bloques de propagación,
la regla de "corregir a la fuente y no a la línea". La mayoría de los
proyectos de una persona mueren de incoherencia narrativa. **Este no va a
morir de eso.**

**3. El director corrige al asistente, y tiene razón.** Hoy, tres veces
seguidas, reportó un problema que mis mediciones decían que no existía; y
las tres veces tenía razón. Eso es un dato sobre el proyecto: **hay
alguien con criterio mirando el resultado**, no solo el reporte. Vale más
de lo que parece.

**4. Ya existen instrumentos para medir lo que importa.** El
[[Benchmark Biomecánico]] no es una lista de deseos: son timings medidos
frame a frame de Sifu, Sable y Fortnite, contra los que se comparó la
propia build. Saber qué es "bueno" con números es una ventaja que la
mayoría no tiene.

---

## 3. El riesgo real, y no es el que suele preocupar

**No es la escritura. No es el motor. Es la asimetría entre los dos.**

- **97.154 palabras** de conocimiento de diseño en `10-Knowledge`, más
  57.770 de estado. Un vault de ~200.000 palabras.
- **Cero líneas de código de producción.** El prototipo fue reseteado
  (ADR-003) y lo que hay hoy es un spike de rampa.

La narrativa está entre cinco y diez años-persona por delante de la
realidad técnica. **Eso no es un defecto de la escritura** — la escritura
es el activo. Es un dato sobre **dónde está el cuello de botella**, y
sobre cuánto de lo escrito va a esperar mucho tiempo antes de ser jugable.

### El dato duro de velocidad, que es el más incómodo del día

Hoy, con el asistente a full y el director disponible, **lo que se logró
fue que un personaje camine por una rampa con los pies apoyados.** Un día
entero. Con seis vueltas atrás, tres conclusiones dadas vuelta, y un
solver escrito a mano porque el del motor no andaba.

Eso **no** es un juicio sobre nadie: es el costo real del 3D. Pero es la
unidad de medida honesta. Y contra eso hay que leer el alcance del
[[Slice of Bond]]: ~55 minutos de juego con 4 escenas, combate con 4
componentes, 2 tipos de enemigo, un link de 3 tiers, camp scene,
mini-dungeon y una coda emocional a medida.

**El slice no es un fin de semana. Es el proyecto de un buen rato.** Y el
slice es el 2% del v1 escrito.

Por eso el instrumento que ADR-003 puso —**medir el costo real en horas de
UN Pivote antes de decidir el alcance de v1**— es, en mi opinión, la
decisión más inteligente que hay en todo el vault. **No la salteen.**

---

## 4. Solidez probable y techo

### Solidez: alta en lo narrativo, sin evidencia en lo jugable

La coherencia del mundo y la fuerza del pilar están fuera de discusión a
esta altura. Lo que **no tiene ni una sola medición todavía** es si el
juego es **divertido**. Hay instrumentos para el canon y ahora para la
biomecánica; **no hay ninguno para el fun**. Los 3 playtesters
(Diego/Santiago/Delmer) con protocolo de sesión son el plan correcto, y
**no se han corrido**.

Mi lectura: el riesgo mayor no es que el juego sea incoherente ni feo. Es
que sea **respetable y aburrido** — que el Bond vacío funcione en el papel
y en la coda, y que las 20 horas entre medio sean un action RPG del
montón. Eso solo lo dice un playtest.

### Techo, sin timeline

**Steam: realista.** Hay público probado para action-RPG narrativo 3D
estilizado con un gancho emocional fuerte y un solo autor detrás. Ese
público premia exactamente lo que este proyecto tiene: identidad,
coherencia, una idea que se cuenta en una frase. **Es el techo correcto
para apuntar.**

**Consola: posible, pero no como objetivo de v1 — y no por el motor.**
Godot exige un partner de porteo, que es dinero o publisher; y ese partner
aparece **después** de una tracción demostrada en PC, no antes. El camino
realista es Steam → números → publisher → port. Diseñar para consola desde
ahora agrega restricciones (certificación, input, memoria, TRC) a un
proyecto que todavía no probó que es divertido. **Es una consecuencia del
éxito, no una vía hacia él.**

**Lo que puede bajar el techo por debajo de "viable en Steam":** no la
escritura ni el motor, sino **el volumen de producción 3D**. Nueve Pivotes
con arcos, epílogos y escenas firma, más mundo abierto, más 5 finales
cinemáticos. Ahí es donde los proyectos de una persona se rompen — no por
falta de talento, por aritmética.

---

## 5. ¿Le veo potencial? Sí, con una condición

**Sí, y no es por cortesía.** El pilar es bueno, la coherencia es real, y
hay criterio en la cabina. La mayoría de los proyectos que veo fallan en
alguna de esas tres; este tiene las tres.

**La condición es de alcance, y es la recomendación más incómoda que
tengo:**

> **v1 con 3 Pivotes, no con 9.**

El vault ya tiene las 9 fichas escritas, así que **no se tira nada** —
las otras 6 son banco para secuela, DLC o v2. Pero producir 9 arcos
completos con sus links, escenas firma, rupturas y epílogos multiplica por
tres el trabajo 3D más caro del proyecto para agregar **variación**, no
**profundidad**. El Bond vacío no pega más fuerte porque haya nueve
maneras de perderlo. Pega fuerte porque perdiste **esa**.

Tres Pivotes bien producidos con rutas que se sienten distintas superan a
nueve a medio hacer, y **la diferencia en meses es enorme**.

Segunda recomendación, más chica: **medir el fun antes que seguir
escribiendo.** El siguiente frente del vault es "guión y diálogos por
actos". Mi opinión: el guión puede esperar; el playtest del slice, no.
Cada palabra escrita antes del primer playtest es una apuesta a que el
diseño no va a cambiar.

---

## 6. Lo que le diría al consejo que discuta

1. ¿Se ratifica Godot sabiendo que **la comparación técnica dio empate** y
   que el argumento fuerte es de instrumentabilidad y licencia, no de
   capacidad?
2. ¿Se corta v1 a **3 Pivotes** ahora, o se espera al contador de horas de
   ADR-003? (Mi opinión: el contador va a decir 3; adelantarlo ahorra
   meses de producción mal dirigida.)
3. ¿**Playtest antes que guión**, o guión antes que playtest?
4. ¿Consola se saca explícitamente del alcance de v1, o se deja como
   ambición declarada? (Mi opinión: sacarla, y volver a mirarla con
   números de Steam en la mano.)
5. ¿Qué instrumento se construye para medir **diversión**, que hoy es el
   único eje sin métrica?

---

**Relacionado:** [[ADR-002 Motor diferido]] · [[ADR-003 Reset de
desarrollo y motor]] · [[Comparativa de Motores — Godot vs Unity]] ·
[[Benchmark Biomecánico]] · [[Slice of Bond]] · [[Current-State]]
