---
status: BORRADOR DE CIERRE — pendiente de firma del director
updated: 2026-08-10
supersede_parcial: "ADR-002 Motor diferido"
---

# ADR-003 — Reset de desarrollo y revisión de motor 🟡 BORRADOR DE CIERRE

> **BLOQUEANTE: no se toca una línea de código hasta que este ADR se cierre.**
> Planteado por el director el 2026-07-28.
> **Borrador de cierre escrito el 2026-08-10** tras el consejo — ver
> §Cierre al final. **La firma es del director; nada de lo de abajo está
> ratificado hasta que Boris lo confirme.**

## Contexto

El proyecto cambió de naturaleza. Nació como **prototipo técnico** (combate, locomoción, springboard, gates de autotest) y hoy es un **juego narrativo** con:

- 9 rutas de Pivote con fichas de 400-770 líneas cada una
- 5 finales con matriz de diferenciación por arquetipo
- 12 personajes de elenco con arcos completos + Speck
- Estructura política de 3 reinos, Elder Circle, Triune Council
- ~30 piezas de concept art ratificadas
- Sistema de Bond/Tether donde **la intimidad ES el árbol de habilidades**

El código actual fue arquitecturado para el proyecto viejo. El director plantea dos movimientos:

1. **Hard/full reset de código y renders**
2. **Revisar la decisión de motor** — intuición de que Unity encaja mejor que Godot

## Estado de la decisión previa (ADR-002)

`ADR-002` confirmó Godot el 2026-07-04 con evidencia real y sigue siendo **válido en lo que evaluó**: la golden scene corriendo a 430-530 fps (7-9× el presupuesto) con el look de la [[Art Bible]] aprobado en vivo contra los keyframes.

**Pero ADR-002 evaluó paisaje, no personajes animados.** Y el proyecto se movió hacia donde el riesgo es otro.

## Análisis

### Sobre el hard reset — recomendación: SÍ, con matiz

El código se construyó para un juego que ya no es este. La arquitectura no contempla 9 rutas ramificadas, 5 finales, ni un sistema de vínculos que es simultáneamente progresión mecánica y narrativa.

**Matiz crítico: reset del código, NO del conocimiento.** Lo que costó meses y no debe tirarse:
- [[Lecciones]] — anti-patrones técnicos ganados con dolor
- [[Benchmark Biomecánico]] — mediciones frame a frame contra Sable/Sifu/HZD
- [[Art Bible]] — las 4 capas y la regla espacial, validadas en la golden scene
- Los PRDs cerrados como registro de qué se probó y qué falló
- Todo `10-Knowledge/`

El código es la parte **barata** de reproducir. El conocimiento no.

### Sobre Unity vs Godot — argumentos nuevos que ADR-002 no evaluó

**A favor de revisar hacia Unity:**

1. **Animación de personajes.** El vault exige ROM por raza, foot IK tipo HZD, combos trifásicos tipo Sifu, proporciones blindadas (4.5 / 7.5 / 8 cabezas). Unity tiene Animation Rigging, Playables y ecosistema maduro de rigging procedural; Godot 4 mejoró pero sigue detrás. **No es casualidad que la deuda técnica abierta sea justamente pies sin IK y ROM por raza.**
2. **Consolas.** ADR-002 difirió esto a "producción tardía". Godot 4 necesita partner externo (W4 Games, Pineapple Works); Unity tiene pipeline oficial. Si el proyecto va en serio, la deuda vence antes de lo previsto.
3. **Precedente directo:** **Sable se hizo en Unity** — es la referencia visual #1 del proyecto. El camino técnico está pisado y documentado.
4. **Volumen narrativo.** 9 rutas × 5 finales necesita herramientas de diálogo/branching. Unity tiene integraciones maduras (Ink, Yarn Spinner); en Godot hay menos opciones probadas a esa escala.

**A favor de quedarse en Godot:**

1. Evidencia real de que el look funciona (golden scene, ADR-002)
2. Sin licencias ni runtime fees
3. Más ligero, itera más rápido
4. Ya existe `Lecciones.md` con anti-patrones específicos de Godot 4.6

**Nota sobre el costo de cambiar:** si el hard reset se ejecuta, el argumento "ya tenemos código en Godot" **desaparece**. El costo de migrar baja casi a cero, porque no hay nada que migrar. Eso hace que las dos decisiones se contaminen — por eso hay que resolverlas en orden (ver abajo).

### El riesgo que ningún motor resuelve

**El alcance narrativo creció más rápido que la capacidad de producción.**

9 Pivotes × 5 finales × 9 celdas de jugador es alcance de **estudio mediano**, no de proyecto individual. Ningún motor cambia esa aritmética.

La pregunta de mayor valor no es *"¿Unity o Godot?"* sino:

> **¿Cuál es el vertical slice mínimo que prueba que este juego funciona?**

Una celda de jugador, un Pivote, un final, a calidad final. Si eso funciona, el resto es replicación con contenido. Si no funciona, el motor era irrelevante.

## Criterios que deben resolverse antes de tocar código

En este orden — cada uno alimenta al siguiente:

### 1. Definición del vertical slice mínimo 🔴
Qué es lo mínimo jugable que prueba la tesis del juego. Candidato natural: [[Slice of Bond]] (Humano Duelist × Dagna, 4 escenas, 45-60 min) — ya está ratificado y es el arco de referencia canónico. Decidir si sigue siendo el slice correcto post-rework narrativo.

### 2. Target de plataforma 🔴
PC solamente / PC + consolas / consolas desde v1. **Define parcialmente el motor** — si consolas está en v1, el argumento Godot se debilita mucho.

### 3. Alcance de v1 vs post-lanzamiento 🔴
¿Los 9 Pivotes son v1, o v1 son 3 y los otros 6 son contenido posterior? ¿Los 5 finales son v1? Esta decisión tiene más impacto en la viabilidad que la del motor.

### 4. Motor definitivo — evaluado CONTRA el slice, no en abstracto 🔴
Con 1-3 resueltos, la evaluación deja de ser filosófica. Criterio propuesto: reconstruir **una escena del slice** en ambos motores y comparar tiempo real de implementación, no specs de marketing.

### 5. Qué se conserva y qué se tira 🔴
Inventario explícito: `10-Knowledge/` completo se conserva; `Lecciones` y `Benchmark Biomecánico` se conservan; `godot/` se archiva como referencia; `src/` (Three.js) ya está congelado. Decidir si los assets 3D existentes sobreviven o se rehacen.

## Recomendación de secuencia

**Definir slice → definir plataforma → definir alcance v1 → elegir motor contra el slice → resetear código.**

En ese orden, la decisión de motor casi se toma sola y con evidencia, igual que ADR-002 en su momento.

## Consecuencias mientras este ADR esté ABIERTO

- **No se escribe código de producción.** Ni en Godot ni en Unity.
- **Sí se puede seguir con:** worldbuilding, guión, concept art, mockups de UI, diseño de sistemas en papel. Todo el frente narrativo y de arte sigue vivo y desbloqueado.
- `ADR-002` queda **parcialmente superado**: su evidencia de rendering sigue siendo válida; su conclusión ("Godot es el motor") queda en revisión.
- El [[Task-Board]] frente C (técnico) queda congelado hasta el cierre.

## Tercera vía: Gauntlet Loop (agentes autónomos) — investigación 2026-08-10

Boris pidió evaluar la metodología [gauntlet-loop](https://somethingbig.ai/gauntlet-loop)
como alternativa a "Godot & Unity + Blender", con dos artículos de apoyo:
[How I Prompt Fable](https://shumer.dev/how-i-prompt-fable) (Matt Shumer) y
[Workbench](https://workbench.md/).

### Qué es, en una línea

Una técnica de **prompting/orquestación**, no un motor: un agente líder
descompone un objetivo ambicioso en piezas, y cada pieza tiene un
constructor (genera) y un crítico independiente (compara contra una
referencia de calidad concreta — ej. screenshots de Call of Duty) en
loop sin límite de rondas hasta satisfacer el estándar. El proyecto de
referencia (`Claude-of-Duty`, Matt Shumer) generó ~55.000 líneas de
código, texturas, meshes, animaciones y sonido desde un único prompt,
corriendo sobre Claude Code/Codex.

### Por qué NO es una tercera vía comparable a Godot/Unity

**Es ortogonal al motor, no un reemplazo.** Gauntlet Loop es un método de
*producción* (cómo se genera y verifica el trabajo), no un *runtime* de
juego. El proyecto de referencia corre sobre stack web (no Godot, no
Unity) — no hay evidencia de que la técnica esté probada contra un motor
con requisitos como los nuestros: rigging humanoide por raza, ROM,
combos tipo Sifu, cámara libre, gates de autotest. Comparar "Gauntlet
Loop vs. Godot vs. Unity" mezcla dos ejes distintos: **motor** (dónde
corre el juego) y **método de producción** (cómo se genera el
contenido/código dentro de ese motor). El método podría aplicarse
*sobre* cualquiera de los dos motores ya evaluados, no en su lugar.

### Lo que sí es directamente aplicable, ya, sin decisión de motor

Esta sesión de Claude Code **ya tiene una implementación parcial del
patrón** vía la skill `/loop` (self-pacing) — construir, autoevaluar,
iterar. Lo que falta para aplicar el patrón completo de Gauntlet Loop no
es tooling nuevo, es **disciplina de prompt**, según "How I Prompt
Fable": (1) objetivo grande y sub-especificado en vez de pasos
prescriptos, (2) "house rules" inmutables en el prompt de sistema en vez
de permisos caso por caso, (3) un estándar de calidad **medible**, no un
adjetivo — para nosotros, candidatos ya existen: el [[Benchmark
Biomecánico]] (mediciones frame a frame contra Sable/Sifu/HZD) es
exactamente el tipo de "barra real" que la técnica pide, y ya lo
tenemos, (4) verificación por un crítico independiente que **nunca**
puede ser el mismo agente que construyó.

**Workbench** resuelve coordinación multi-agente vía un doc markdown
compartido con permisos granulares — útil si en algún momento se corren
varios agentes en paralelo sobre distintas piezas del vertical slice
(ej. un agente en assets, otro en combate, otro en UI), pero no
resuelve nada que el vault + `Task-Board` no estén ya resolviendo a
menor escala para un director trabajando con un solo agente a la vez.
No hay caso de uso claro para adoptarlo mientras el equipo sea
Boris + 1 agente.

### Recomendación para la sesión de decisión

No tratar Gauntlet Loop como punto 4 del ADR (motor). Tratarlo como
**método de producción a aplicar dentro de la decisión de motor que se
tome** — la pregunta correcta no es "¿Godot, Unity o Gauntlet Loop?"
sino "una vez que el vertical slice y el motor estén definidos, ¿lo
construimos con este patrón de constructor/crítico contra el Benchmark
Biomecánico como estándar medible, en vez de a mano?". Es compatible con
cualquiera de los dos motores evaluados.

---

# Cierre (BORRADOR, 2026-08-10) — pendiente de firma

> Insumos: [[Brief para el Consejo — Motor y Fases de Desarrollo]] +
> el transcript del consejo en `90-Raw/council-2026-08-10-motor-y-fases.md`
> (5 asesores + revisión cruzada + síntesis).

## Las 5 decisiones

### 1. Hard reset — SÍ ✅

Se ejecuta. `godot/` se archiva con `git tag archive/prototipo` y se
borra del árbol de trabajo. **Se conserva el conocimiento, no el código:**
[[Lecciones]], [[Benchmark Biomecánico]], [[Art Bible]], los PRDs
cerrados como registro histórico, y todo `10-Knowledge/`.

### 2. Motor — GODOT, y no se reabre hasta que el slice dé veredicto ✅

[[ADR-002 Motor diferido]] **deja de estar en revisión y vuelve a estar
plenamente vigente.** Razones, en orden de peso:

- La evidencia medida (golden scene, 430-530 fps, look aprobado en vivo)
  vence a los argumentos de catálogo de Unity.
- Ninguna ventaja de Unity está en el camino crítico de lo que el slice
  debe responder. **En un greybox, foot IK y ROM por raza no existen** —
  se estaría eligiendo motor contra los requisitos de un juego que
  todavía no se probó que funcione.
- [[Lecciones]] es capital pagado con dolor, específico de Godot 4.6.
  Una migración lo incinera y compra el derecho de volver a pagarlo.
- Consolas en un proyecto sin fecha es planear la gira antes de escribir
  la canción.

**Al argumento de Unity se le concede el hecho y se le niega la
conclusión:** es cierto que post-reset hoy es el día más barato de la
historia del proyecto para migrar. Barato no es lo mismo que necesario.
**Condición de reapertura:** si el slice pasa y la producción de
animación de personajes resulta ser el cuello de botella medido (no
supuesto), se reabre con datos reales.

### 3. Vertical slice — [[Slice of Bond]] recortado a 3 escenas ✅

**Compañero: Dagna.** El consejo propuso resolver "Dagna o Roen" con
lectura de canon; la pregunta está malformada y se resuelve sin ella:
**Roen es un fijo y los fijos no traicionan.** El slice entero se apoya
en la coda del Bond vacío — Roen no se va nunca, estructuralmente no
puede sostenerla. Dagna gana por defecto, no por empate.

*Corolario que sí sobrevive:* `Slice of Bond` se ratificó el 2026-07-05,
**antes** del rework de los 9 Pivotes. La pregunta legítima no es "¿Dagna
o Roen?" sino "¿sigue siendo Dagna el mejor de los **9 Pivotes** para
esto?". Se responde en 30 minutos de lectura con una regla única: *cuál
vínculo tiene la traición mejor escrita hoy y el link de traversal más
limpio*. Si empata, gana Dagna — su link ya está diseñado y no hay que
inventarlo. **→ pendiente de Boris antes de arrancar.**

**Recorte de 4 escenas a 3** (propuesta, pendiente de ratificar):

| # | Escena | Duración | Qué prueba |
|---|---|---|---|
| 1 | **Cold open comprimido** — la purga, la crisálida, eliges no matar, ella te abre paso | ~5 min | Establece el vínculo. Mínimo indispensable: sin esto la coda no tiene de qué doler |
| 2 | **El Ascenso con Dagna** — el link ES la progresión, camp scene a mitad, T1→T3 comprimido, **termina en la traición** | ~20 min | La tesis: ¿el Bond como árbol de habilidades se siente? |
| 3 | **Coda — Bond vacío** — el mismo tramo sin ella, sin verticalidad | ~10 min | El criterio de muerte: ¿duele? |

**Se corta:** el mini-dungeon del Sunken Archive y **todo el combate** —
la traición se juega, no se pelea.

**Se corta de la premisa B, completo y sin negociación:** las 18
combinaciones raza×rol×género, marcas/tatuajes/warpaint, pelo, vello
facial, secuencia de título, tutorial y prólogo. Eso es producción, no
aprendizaje, y no vuelve a discutirse hasta que el slice pase.

**Pero se conserva el eje de B que sí carga peso — y esto es una
corrección al consejo, no una concesión:** greybox de **entorno**, sí;
greybox de **cuerpo**, no. Un rig, con biomecánica y game feel correctos,
y Dagna con voz. La premisa del director nunca dijo "quiero sliders de
barba" — dijo *"low poly aceptable pero game feel y biomecánica
correctos"*, y eso es una afirmación de diseño: **si el slice es escalar
con ella y escalar sin ella, el dolor de la coda pasa por el cuerpo.** Un
rig cápsula mudo puede matar la prueba por razones que no tienen nada que
ver con Dagna. La biomecánica no es contenido de arte acá; es el canal
por el que viaja la pérdida.

### 4. Target de plataforma — PC únicamente ✅

Para el slice y hasta nuevo aviso. Consolas queda **fuera de v1** y deja
de ser argumento en cualquier discusión de motor hasta que exista un
juego que exportar.

### 5. Alcance de v1 — DIFERIDO deliberadamente, con regla de decisión 🟡

No se decide ahora, y no por evasión: **el dato que lo decide todavía no
existe.** El slice sale con un número —cuántas horas costó Dagna de
punta a punta— y ese número decide si el juego tiene 9 Pivotes, 5 o 3.
Decidir el alcance antes de tener esa medición es adivinar.

---

## Las 3 piezas que se escriben ANTES de la primera línea de código

El consejo fue explícito: sin estas tres, el ADR no está cerrado, solo
cambió de excusa.

### A. Árbol de "¿y si no duele?"

Un resultado de "no dolió" es inútil sin desambiguar la causa. **El eje
discriminador es comprensión vs. emoción:**

| Rama | Evidencia que la identifica | Qué se hace |
|---|---|---|
| **Falla el INSTRUMENTO** | Los 3 playtesters **divergen** entre sí, o quien no sintió nada tampoco supo explicar qué hacía Dagna en el ascenso | No concluir nada. El test no midió. Re-testear con más gente o mejor guion de sesión |
| **Falla la EJECUCIÓN** | Los 3 **coinciden** en que no dolió, **pero** sus comentarios son de legibilidad o feel: "no me quedó claro que ella abría las rutas", "el movimiento se sentía raro", "no noté que el terreno había cambiado" | Iterar el slice. **No se toca el diseño.** El problema es el canal, no el mensaje |
| **Falla el DISEÑO** | Los 3 **coinciden**, entendieron perfectamente la mecánica y la pérdida — supieron decir qué perdieron y por qué — **y aun así no les importó** | La tesis del Bond como árbol de habilidades no funciona. **Replantear el juego antes de escalar a 9 Pivotes.** Este es el resultado caro y es el que el slice existe para detectar |

**Regla anti-autoengaño:** la rama se elige con la evidencia **antes** de
leer el resultado emocional, no después. Comprensión alta + indiferencia
= diseño. No hay tercera lectura.

### B. Contador de horas

Log de horas por escena y por sistema, desde la primera línea. No es
métrica de productividad — es **el insumo del criterio 5**: el costo real
de un Pivote completo, que multiplicado por 9 dice si ese juego existe.

### C. Los 3 playtesters ✅ (definidos por Boris, 2026-08-10)

| # | Nombre | Exposición previa al proyecto | Disponibilidad |
|---|---|---|---|
| 1 | **Diego** | Ninguna significativa — no conoce el lore ni el proyecto | Confirmada |
| 2 | **Santiago** | Ninguna significativa — íd. | Confirmada |
| 3 | **Delmer** | Ninguna significativa — íd. | Confirmada |

Los tres son **jugadores experimentados** ("gamers natos"). Fecha exacta
a fijar cuando el slice tenga fecha de entrega; la disponibilidad ya está
confirmada por Boris.

#### 🔴 Regla de oro: NO ponerlos al corriente

**Su ignorancia del proyecto es el instrumento, no un obstáculo a
resolver.** El impulso natural es explicarles quién es Dagna y de qué va
el mundo antes de que jueguen. Hacerlo **destruye la medición**: el slice
existe para probar si la escena construye el vínculo *por sí sola*, en
~35 minutos, sin ayuda externa. Un jugador que llega sabiendo que Dagna
importa va a sentir que importa, y eso no prueba nada sobre el juego.

**Se les puede decir:**
- Los controles (moverse, usar el link) — eso es tutorial, no lore.
- Que es un prototipo temprano sin arte: cubos grises, sin texturas.
  Evita que reporten "se ve feo" como si fuera un hallazgo.
- Encuadre mínimo de género: *"es un RPG de acción; vas a subir una
  montaña con una compañera."* Nada más.

**No se les puede decir, bajo ninguna circunstancia:**
- Quién es Dagna más allá de lo que la escena muestre.
- **Que va a traicionarte.** Mata el experimento completo.
- Que el objetivo del test es medir si duele. Si saben que se espera
  tristeza, la actúan.
- Nada del mundo más amplio: los 9 Pivotes, los 5 finales, las razas, la
  política de los 3 reinos, que el Bond es el árbol de habilidades.

#### Orden de las preguntas post-sesión (no negociable)

El árbol de fallas §A **solo funciona si la comprensión se mide antes que
la emoción.** Al revés, la pregunta emocional contamina el recuerdo y ya
no se puede distinguir "no entendió" de "entendió y no le importó".

1. **Abiertas primero.** *"Contame qué pasó."* / *"¿Cómo estuvo?"* Sin
   dirigir. Se anota lo que mencionan **espontáneamente** — si la pérdida
   aparece sola acá, es la señal más fuerte que el test puede dar.
2. **Comprensión después.** *"¿Qué podías hacer en la primera subida que
   no pudiste en la segunda?"* / *"¿Por qué cambió?"* Esto mide si el
   canal funcionó, y es lo que separa la rama EJECUCIÓN de la rama
   DISEÑO.
3. **Emocional al final, y nunca dirigida.** *"¿Cómo te sentiste en el
   último tramo?"* — **no** *"¿te dio tristeza que se fuera?"*.

**Ventaja y riesgo de que sean jugadores experimentados:** a favor,
articulan bien "el movimiento se siente raro" vs. "no me importó el
personaje", que es justo lo que el árbol necesita para discriminar. En
contra, tienden a **rellenar huecos con convención de género** — pueden
dar por sentado que la compañera traiciona porque así funcionan estos
juegos, y reportar comprensión que la escena no construyó. Contramedida:
en el paso 2, preguntar *cómo lo supieron* — si la respuesta es "porque
siempre pasa", eso no cuenta como que la escena lo comunicó.

**Plan B si se caen:** autograbación de sesión + revisión diferida a las
2 semanas, más una pasada previa de agente imparcial **como filtro, no
como juez** — una IA no siente una pérdida, pero sí detecta si la escena
ni siquiera *comunica* que perdiste algo.

---

## Método de producción

**Gauntlet-loop (constructor + crítico independiente en loop) sobre el
traversal únicamente**, con [[Benchmark Biomecánico]] como estándar
medible. **Verificación previa obligatoria:** el Benchmark está calibrado
contra Sable/Sifu/HZD — combate y fauna. Antes de usarlo hay que
confirmar que mide algo útil en una escena de escalada sin combate; si no
aplica, hay que definir el estándar de esta escena o el loop no tiene
contra qué medir.

**Sobre la narrativa el crítico es humano.** No hay benchmark para "duele".

**Orden:** el loop se construye **sobre** esta escena, no antes de ella.
Una máquina de calidad sin nada que medir es otra semana de no-código con
mejor vestuario.

---

## Consecuencias del cierre

- Se levanta el bloqueo. El frente C (técnico) del [[Task-Board]] se
  descongela.
- [[ADR-002 Motor diferido]] vuelve a `ratificado` pleno; deja de estar
  parcialmente superado.
- El worldbuilding y el guión siguen vivos, pero **dejan de ser el frente
  principal**: la 4ª re-corrida de QA de canon y los demás pendientes
  inmediatos de [[Current-State]] siguen en la cola, no bloquean el slice.

## Firma

**Pendiente del director.** Nada de este cierre está ratificado hasta que
Boris lo confirme, ítem por ítem si hace falta. Los dos puntos que más
piden su ojo: el recorte a 3 escenas (§3) y la revisión de 30 minutos
sobre si Dagna sigue siendo el Pivote correcto post-rework.
