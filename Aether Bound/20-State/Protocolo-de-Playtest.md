---
status: vivo
updated: 2026-08-13
source: "Encargo de la sesión técnica, 2026-08-13. Fuentes: `90-Raw/council-2026-08-13-veredicto-motor-y-alcance.md` (consejo que partió el playtest en dos etapas) + [[ADR-003 Reset de desarrollo y motor]] §A (árbol de fallos) y §C (los 3 playtesters) + [[Slice of Bond]]."
---

# Protocolo de Playtest — A (test gris del Bond) y B (slice completo)

> **Documento operativo, en español**, para Boris y para quien facilite la
> sesión. Las preguntas que se le leen al tester también van en español.
> Solo el contenido in-game va en inglés (regla 9 de `CLAUDE.md`).
>
> **Son dos protocolos con costos muy distintos y se corren en orden.**
> **A** es barato y va primero: una cápsula gris y una cornisa. **B** es el
> slice completo con Dagna. El resultado de A decide si B se corre como
> está diseñado.

---

# 🔴 §0 — CRITERIO DE MUERTE (se firma ANTES de correr nada)

**Esta sección va primero porque es la única que pierde todo su valor si se
escribe después.** El consejo del 2026-08-13 fue explícito: *medir sin
umbral pre-comprometido es confirmación disfrazada de método.* Los números
de abajo son **propuesta**; Boris los ajusta y firma. Lo que no es
negociable es que estén firmados antes de que un tester toque el build.

## 0.1 — Qué mide el Protocolo A, exactamente

Dos números por tester, ambos contables y ninguno interpretable:

| Símbolo | Qué es | Cómo se obtiene |
|---|---|---|
| **P** | Pulsaciones del botón de Bond **muerto**, estando **dentro de la zona de la cornisa** | Telemetría (§4.1) |
| **T** | Segundos entre la primera y la última pulsación muerta en esa zona | Telemetría |
| **U** | Pulsaciones por minuto del botón **vivo**, durante la fase CON | Telemetría |

**Definición operativa de "frente a la cornisa":** el jugador está dentro
del volumen de disparo delante de la cornisa. Sin esa definición el conteo
es barro — la implementación está en §4.1.

## 0.2 — Condición de validez (se evalúa ANTES que el resultado)

> **Si el test no pasa esta condición, no tiene resultado.** No "resultado
> negativo": **no tiene resultado**, y no se interpreta.

**U ≥ 2 pulsaciones/minuto durante la fase CON.**

Es la objeción del Outsider convertida en gate: *"un poder que nunca fue
divertido no duele cuando desaparece — se siente como que el juego se
arregló."* Si el tester apenas usó la habilidad cuando la tenía, la fase
SIN no mide pérdida: mide indiferencia previa. **Primero hay que probar que
tener el botón es adictivo.** Con U < 2, el hallazgo es *"la habilidad no
enganchó"* — que es un hallazgo real y barato, pero es sobre la fase CON, y
la fase SIN se descarta.

## 0.3 — Umbrales (propuesta para tu firma)

Sobre los **3 testers** (Diego, Santiago, Delmer — [[ADR-003 Reset de
desarrollo y motor]] §C):

| Resultado | Umbral | Lectura |
|---|---|---|
| 🟢 **El reflejo existe** | **P ≥ 3 y T ≥ 20 s** en **2 de 3** testers | La ausencia produce insistencia, no solo un error de dedo. Se procede al Protocolo B. |
| 🟡 **No concluye** | P = 2 en la mayoría, **o** los 3 divergen entre sí | Rama **INSTRUMENTO** del árbol de ADR-003. No se concluye nada, se re-testea con mejor guion de sesión o más gente. |
| 🔴 **El reflejo no aparece** | **P ≤ 1** en **2 de 3** | La mitad mecánica de la pérdida no es legible. **Ver §0.4 — esto NO mata el pilar.** |

**Por qué 3 pulsaciones y no 1.** Una pulsación es error de dedo o memoria
muscular. Dos es comprobar. **Tres es negarse a aceptarlo** — y eso es lo
único que este test barato puede llegar a ver. Los 20 segundos son el
mismo criterio en el otro eje: insistir veinte segundos contra un botón que
no responde no es un reflejo, es una discusión con el juego.

## 0.4 — 🔴 Cómo se lee un resultado negativo (regla anti-suicidio)

**Escrito antes de correr el test, y es la parte del documento que más
importa.**

**El Protocolo A NO PUEDE FALSEAR EL PILAR.** Un revisor del consejo marcó
el límite con precisión: *un cubo sin vínculo mide un reflejo motor, no el
duelo por un compañero.* En el test gris no hay personaje, no hay
fidelidad, no hay 35 minutos de convivencia, no hay voz y no hay audio. Lo
único que puede medir es si **la ausencia de una capacidad se nota y
molesta**.

Por lo tanto:

- Un 🔴 en A significa **"la mitad mecánica no es legible o no engancha"**.
  Es un hallazgo de **ejecución**, barato y accionable: se itera el feel del
  link, la legibilidad de la cornisa o el diseño del espacio, y se vuelve a
  correr.
- Un 🔴 en A **no habilita** ninguna conclusión sobre el diseño del Bond,
  ni sobre el proyecto. **La rama DISEÑO del árbol de ADR-003 solo se puede
  alcanzar desde el Protocolo B**, y ni siquiera desde B si falta el audio
  (§9.3).
- **Prohibido explícitamente:** usar un 🔴 de A como argumento para
  replantear el juego, recortar alcance o abandonar el pilar. Si eso pasa,
  el test hizo daño neto y habría sido mejor no correrlo.

**Y al revés, la trampa simétrica:** un 🟢 en A **tampoco prueba el pilar**.
Prueba que el reflejo existe, que es la condición mínima necesaria para que
el duelo sea posible. Es permiso para gastar en B, nada más.

## 0.5 — Firma

| Campo | Valor |
|---|---|
| Umbrales de §0.3 | ✅ **firmados por Boris el 2026-08-13** |
| Condición de validez §0.2 | ✅ **firmada el 2026-08-13** |
| Regla de lectura negativa §0.4 | ✅ **firmada el 2026-08-13** |
| Build congelado (hash) | ⬜ pendiente — la escena gris ya existe (`godot/scenes/gray_test.tscn`); falta congelar y hashear |

**Ningún tester toca el build hasta que las tres casillas estén marcadas.**
Las tres lo están. Lo que falta ahora es el build, no el criterio — y por
diseño ese orden es el correcto: **el criterio se firmó antes de que
existiera nada que medir**, que es la única forma de que no lo contamine el
resultado.

> **Lo que la firma cierra, textual, para que no haya relectura después:**
>
> - **🟢 verde** = P ≥ 3 **y** T ≥ 20 s, en **2 de 3** testers.
> - **🟡 amarillo** = P = 2 en la mayoría, o los 3 divergen. Rama
>   INSTRUMENTO. No se concluye nada.
> - **🔴 rojo** = P ≤ 1 en **2 de 3**. Rama EJECUCIÓN mecánica.
> - **Validez previa:** con **U < 2 pulsaciones/min** en la fase CON, la
>   sesión **no tiene resultado** y la fase SIN no se interpreta.
> - **Un 🔴 no falsea el pilar** y está prohibido usarlo para replantear el
>   juego, recortar alcance o abandonar. Un 🟢 tampoco lo prueba: es permiso
>   para gastar en B.
>
> A partir de acá, mover cualquiera de estos números **es un commit con
> fecha y autor**, y el impulso de moverlos se anota en el [[LOG]] aunque
> no se ejecute (§6). Están replicados como constantes en
> `godot/tools/telemetry_analysis.gd`.

---

# PROTOCOLO A — Test gris del Bond

**Costo:** una escena gris, una cápsula, una cornisa, un botón.
**Duración por tester:** ~30 min (10 de juego + 15 de preguntas + margen).
**Objetivo:** saber si la desaparición de una capacidad **se nota y se
insiste**, antes de gastar un peso en arte, diálogo o historia.

## 1. Qué hay en el build

- Escena gris: geometría de caja, sin texturas, sin iluminación de autor.
- El jugador es una cápsula.
- **Un botón de Bond** que lanza hacia arriba. Nada más — no hay combate,
  no hay enemigos, no hay objetivos escritos, no hay UI de misión.
- **Una cornisa** alcanzable **solo** con el botón, colocada en una ruta
  que el jugador va a recorrer varias veces.
- Minuto 5: **el botón deja de funcionar.** Sin aviso, sin animación de
  fallo, sin sonido, sin mensaje. Simplemente no pasa nada.

> **Sin personaje.** En el Protocolo A el botón **no es Dagna**, no se le
> pone nombre y no se lo presenta como compañera. Meter media ficción a
> mitad de camino contamina el test sin comprarle fidelidad. Esa es
> exactamente la razón por la que A no puede falsear el pilar (§0.4).

## 2. Guión minuto a minuto

| Tramo | Qué pasa |
|---|---|
| **−5:00 → 0:00** | Preparación **sin el tester en la sala**: build congelado corriendo, telemetría verificada con una pulsación de prueba, hoja de registro impresa, cronómetro listo. |
| **0:00 → 0:03** | Recepción y encuadre. Se lee el texto de §3.1 **literal**. |
| **0:03 → 0:05** | Controles. Se muestran moverse y el botón. Se le deja probar el botón 2-3 veces en suelo plano. **No se menciona la cornisa.** |
| **0:05 → 0:10** | **FASE CON.** 5 minutos. El facilitador se calla (§3.3) y registra. |
| **0:10** | **Corte.** El botón muere. El facilitador **no dice nada, no mira al tester, no cambia de postura.** |
| **0:10 → 0:15** | **FASE SIN.** 5 minutos. Silencio total. Acá se juega el test. |
| **0:15** | *"Listo, gracias."* Se corta el build. |
| **0:15 → 0:30** | Preguntas post-sesión (§3.4), en orden y con la redacción exacta. |

## 3. Guion del facilitador

### 3.1 — Lo que se le dice al tester (texto literal)

> *"Es un prototipo muy temprano, sin arte: cubos y cápsulas grises. No
> está feo, está sin hacer — eso no lo evalúes.*
>
> *Vas a jugar diez minutos. Tienes dos cosas: moverte, y un botón que te
> impulsa hacia arriba. No hay objetivo escrito ni forma de perder.
> Explora y sube lo que puedas.*
>
> *Mientras juegas yo no voy a hablar. Si me preguntas algo te voy a
> contestar siempre lo mismo, así que no te preocupes si sueno raro.
> Después te hago unas preguntas."*

### 3.2 — 🔴 Lo que NO se le puede decir

- **Que el botón va a dejar de funcionar.** Mata el experimento entero.
- Que hay dos fases, o que el test dura "cinco y cinco".
- Que la cornisa es importante, o señalarla de cualquier manera.
- Que el botón representa a un personaje, o que el juego trata de una
  compañera. En A no existe tal cosa.
- Nada del proyecto, el lore o Dagna — regla de oro de [[ADR-003 Reset de
  desarrollo y motor]] §C: **su ignorancia es el instrumento.**
- Después del minuto 10: **cualquier cosa**. Ni "sigue", ni "tranquilo".

### 3.3 — Disciplina de observación silenciosa

**El facilitador está prohibido de hablar entre 0:05 y 0:15**, con dos
excepciones y ninguna más:

1. **Fallo técnico** del build (cuelgue, caída del framerate que impide
   jugar). Se corta, se anota la hora y la sesión **se descarta**.
2. **Incomodidad física** del tester (mareo, molestia). Se corta.

**Si el tester pregunta algo** —"¿se rompió?", "¿tengo que hacer algo?",
"¿está bien así?"— la respuesta es **siempre la misma frase, con el mismo
tono plano**:

> *"Sigue como te parezca."*

Nada más. No se amplía, no se sonríe, no se asiente, no se niega. **Cada
pregunta del tester después del minuto 10 se anota con su hora exacta** —
es dato: preguntar "¿se rompió?" es una forma de insistir.

**Qué mira el facilitador** (a ojo, sin interrumpir):
- Cuántas veces vuelve a la cornisa **físicamente**, no solo con el botón.
- Si busca rutas alternativas (rodear, saltar desde otro lado, apilar).
- **El cuerpo:** si se acerca a la pantalla, si suspira, si se ríe, si
  suelta el mando.
- Si verbaliza solo (*"¿qué?"*, *"a ver"*, puteadas). **Se transcribe
  literal**, no se resume.

### 3.4 — Preguntas post-sesión (orden exacto, redacción exacta)

> **El orden contamina.** Va de lo más abierto a lo más cerrado, y ninguna
> pregunta puede adelantar información de las siguientes. **No se saltea
> ninguna aunque el tester ya la haya contestado sin que se la hagan** —
> en ese caso se anota "ya contestada espontáneamente", que es dato fuerte.

| # | Pregunta (literal) | Por qué está |
|---|---|---|
| 1 | *"Cuéntame qué pasó."* | Máxima apertura. Lo que menciona primero es lo que le importó. |
| 2 | *"¿Hubo algún momento en que quisieras hacer algo y no pudieras?"* | Primera oportunidad de que aparezca la pérdida **sin nombrarla**. Si aparece acá, es la señal más fuerte del test. |
| 3 | *"¿Notaste algún cambio durante los diez minutos?"* | Si **no** menciona el botón, es dato: la pérdida no fue legible. |
| 4 | *"¿Qué hacía el botón?"* | Comprensión mecánica. Es el eje discriminador del árbol de fallos: no entender ≠ no importarle. |
| 5 | *"Cuando dejó de funcionar, ¿qué pensaste?"* | Primera que revela explícitamente que dejó de funcionar. **No puede ir antes.** |
| 6 | *"¿Cuántas veces dirías que lo intentaste después?"* | Se compara con **P** real. La brecha entre lo que recuerda y lo que hizo es dato en sí misma. |
| 7 | *"¿Te dio coraje, te dio igual, o ni lo pensaste?"* | Cerrada, tres opciones, la más contaminante. Va última. |

## 4. Dependencias técnicas — **no se resuelven acá, se especifican**

### 4.1 — Hook de telemetría (para la sesión técnica)

Es código y va en el build. **Sin esto el Protocolo A no tiene métrica
primaria y no se corre.**

> ### ✅ Implementado y verificado (2026-08-13)
>
> | Archivo | Qué es |
> |---|---|
> | `godot/scripts/telemetry.gd` | El grabador. Un CSV por sesión, **flush por línea** |
> | `godot/scripts/ledge_zone.gd` | El volumen de la cornisa (`Area3D`) |
> | `godot/scripts/bond_driver.gd` | El botón y el corte del minuto 5, **en silencio** |
> | `godot/tools/telemetry_analysis.gd` | Deriva P, T, U y clasifica |
> | `godot/tools/telemetry_report.gd` | Imprime el informe y el veredicto |
> | `godot/tools/test_telemetry.gd` | 50 verificaciones, `ALL_PASS` |
>
> ```
> godot --headless --path godot --script res://tools/test_telemetry.gd
> godot --headless --path godot --script res://tools/telemetry_report.gd -- --dir=user://telemetry
> ```
>
> **Tres decisiones que tomó el código y conviene que estén acá:**
>
> 1. **El hook no filtra nada.** Registra *cada* pulsación —viva o muerta,
>    dentro o fuera de la zona— y el filtrado lo hace el derivador. Si el
>    hook filtrara, el dato se perdería y no habría cómo recuperarlo después
>    de la sesión.
> 2. **Flush por línea, no al cerrar.** Una sesión de playtest no se puede
>    repetir: si el build se cuelga en el minuto 9, los 9 minutos tienen que
>    estar en disco.
> 3. **Los umbrales no se pueden pasar por línea de comandos.** Están como
>    constantes en `telemetry_analysis.gd`. Cambiarlos es un commit, con
>    fecha y autor — que es lo que §6 pide.
>
> **Y una que el código NO tomó:** el derivador levanta una bandera cuando
> la fase CON duró mucho menos de 5 minutos (la sesión se cortó y nadie la
> marcó como fallo técnico), pero **no reclasifica**. Avisa y nada más. Un
> umbral que no firmaste no puede mover un resultado.

**Eventos a registrar**, uno por línea, a CSV por sesión:

| Evento | Cuándo se dispara | Campos |
|---|---|---|
| `session_start` | Al cargar la escena | `session_id`, `tester_id`, `build_hash`, `timestamp_ms` |
| `phase_change` | Al minuto 5 exacto | `session_id`, `phase` (`con` \| `sin`), `timestamp_ms` |
| `ledge_zone_enter` / `ledge_zone_exit` | Al entrar/salir del volumen de disparo de la cornisa | `session_id`, `ledge_id`, `timestamp_ms` |
| `bond_press` | **Cada** pulsación del botón, viva o muerta | `session_id`, `timestamp_ms`, `phase`, `button_alive` (bool), `in_ledge_zone` (bool), `ledge_id` (o vacío), `player_pos` (x,y,z), `ms_since_phase_start`, `press_index` |
| `session_end` | Al minuto 10 o al corte | `session_id`, `reason` (`completa` \| `fallo_tecnico` \| `abortada`), `timestamp_ms` |

**Definición del volumen de disparo:** caja delante de la cornisa, del
ancho de la cornisa y ~3 m de profundidad, a la altura del suelo desde el
que se saltaría. `in_ledge_zone` es simplemente "el jugador está adentro".
**No se filtra por orientación de cámara** — filtrar agrega criterio
interpretable justo donde el documento promete conteo.

**Derivados que salen del CSV, sin trabajo manual:** `P` = pulsaciones con
`button_alive=false` e `in_ledge_zone=true` · `T` = última menos primera de
esas pulsaciones · `U` = pulsaciones con `button_alive=true` / 5 min.

### 4.2 — Otras dependencias anotadas

- **Reloj único:** la telemetría y el cronómetro del facilitador tienen que
  poder cruzarse. Basta con anotar la hora de `session_start` a mano.
- **Build congelado y hasheado** antes del primer tester; los 3 juegan
  exactamente el mismo build.

## 5. Hoja de registro — Protocolo A

```
TESTER: ________________   FECHA: __________  BUILD: ____________
FACILITADOR: ___________   HORA session_start: __________

VALIDEZ
  U (pulsaciones/min en fase CON): ______      ¿U ≥ 2?  SÍ / NO
  Si NO → la fase SIN no se interpreta. Anotar y parar.

MÉTRICA PRIMARIA
  P (pulsaciones muertas en zona de cornisa): ______
  T (segundos entre la primera y la última):  ______
  Autoinforme de la pregunta 6:               ______   (brecha: ______)

CONDUCTA OBSERVADA (fase SIN)
  Regresos físicos a la cornisa: ______
  ¿Buscó rutas alternativas?  SÍ / NO   ¿Cuáles? ______________________
  Preguntas al facilitador (hora + literal):
    ____________________________________________________________
  Verbalizaciones espontáneas (literal, sin resumir):
    ____________________________________________________________
  Cuerpo (se acerca / suspira / se ríe / suelta el mando / otro):
    ____________________________________________________________

RESPUESTAS (literal, sin parafrasear)
  1 ______________________________________________________________
  2 ______________________________________________________________
  3 ______________________________________________________________
  4 ______________________________________________________________
  5 ______________________________________________________________
  6 ______________________________________________________________
  7  coraje / igual / ni lo pensé

INCIDENTES: ______________________________________________________
```

## 6. Lectura del conjunto y decisión

Se agregan los 3 testers y se compara contra §0.3 **sin tocar los
umbrales**. Si aparece la tentación de moverlos, ese impulso se anota en el
LOG y **no se ejecuta**.

| Resultado | Qué se hace |
|---|---|
| 🟢 | Se procede al **Protocolo B**. |
| 🟡 | Rama INSTRUMENTO. Se rehace el guion de sesión o se suma gente. **No** se toca el diseño ni el alcance. |
| 🔴 | Rama EJECUCIÓN mecánica. Se itera feel/legibilidad/espacio y se vuelve a correr A. **No** se replantea el pilar (§0.4). |

---

# PROTOCOLO B — Sesión completa del slice

**Costo:** el slice de 3 escenas con Dagna.
**Duración por tester:** ~90 min (45-60 de juego + 30 de preguntas).
**Objetivo:** el criterio de éxito de [[Slice of Bond]] — que un playtester
ajeno al proyecto **sienta la pérdida dos veces**, mecánica y emocional.
**Se corre solo con 🟢 en el Protocolo A.**

> **Dos discrepancias de alcance que este protocolo NO resuelve** y que hay
> que cerrar antes de construir: [[Slice of Bond]] describe **4 escenas** y
> [[ADR-003 Reset de desarrollo y motor]] lo recorta a **3**; y el slice
> pide **T1→T3** mientras el consejo del 08-13 pide **un link de 1 tier**.
> El protocolo de abajo funciona con cualquiera de las dos versiones —
> pero la hoja de registro del eje gameplay cambia si hay un solo tier.

## 7. Guión minuto a minuto

| Tramo | Qué pasa |
|---|---|
| **−10:00** | Preparación sin el tester: build congelado, telemetría verificada, 3 hojas de registro (una por eje), cronómetro. |
| **0:00 → 0:04** | Encuadre (§8.1, literal). Incluye el permiso de grabar audio si se graba. |
| **0:04 → 0:07** | Controles, en seco. Se enseñan movimiento, ataque y el botón de Bond. **Nada sobre Dagna.** |
| **0:07 → ~1:05** | **Sesión.** Silencio (§8.2). El facilitador registra por eje en columnas separadas. |
| *(dentro)* | **Marcas de tiempo obligatorias:** primer uso voluntario del link · primera vez que usa a Dagna sin que la escena lo obligue · momento de la traición · **primera pulsación del Bond muerto en la coda**. |
| **Fin del slice** | *"Listo, gracias."* No se comenta nada de lo que pasó. |
| **+0:00 → +0:30** | Preguntas post (§8.3), en orden. |
| **+7 días** | Test de recuerdo (§10). |

## 8. Guion del facilitador

### 8.1 — Encuadre (texto literal)

> *"Es un prototipo temprano. Hay cosas sin arte y cosas sin sonido — eso
> no lo evalúes, todavía no está hecho.*
>
> *Es un RPG de acción. Vas a subir una montaña con una compañera. Dura
> como una hora.*
>
> *Mientras juegas no voy a hablar; si me preguntas algo te voy a contestar
> siempre lo mismo. Después platicamos."*

Es el encuadre mínimo autorizado por [[ADR-003 Reset de desarrollo y
motor]] §C, palabra por palabra: género, la montaña, la compañera. **Nada
más.**

### 8.2 — 🔴 Prohibiciones y disciplina

**No se puede decir, bajo ninguna circunstancia:**
- Quién es Dagna más allá de lo que la escena muestre.
- **Que va a traicionarte.** Mata el experimento completo.
- Que hay más Pivotes, otras rutas, o que existe una tercera ruta que se
  desbloquea. (La pregunta 12 lo toca **después**, y con redacción
  controlada.)
- Cualquier cosa sobre el lore, el mundo o los 5 finales.

**Silencio durante toda la sesión**, con las mismas dos excepciones del
Protocolo A (fallo técnico, incomodidad física) más una tercera:

3. **Bloqueo duro de progresión** por bug —no por dificultad— por más de
   2 minutos. Se anota la hora, se destraba con la mínima intervención
   posible, y **el tramo queda marcado como contaminado** en las 3 hojas.

**Frase única de deflexión**, igual que en A: *"Sigue como te parezca."*

**Excepción de la traición:** si el tester se detiene después de la
traición y pregunta algo, **la deflexión se aplica igual**. La tentación de
consolar o de explicar acá es la más fuerte de toda la sesión y es la que
más daño hace.

### 8.3 — Preguntas post-sesión (orden exacto, con mapeo al árbol de fallos)

> **Cada pregunta mapea a una rama del árbol de [[ADR-003 Reset de
> desarrollo y motor]] §A** (INSTRUMENTO / EJECUCIÓN / DISEÑO) o a un
> riesgo declarado del consejo. **Si alguna pregunta futura no mapea a un
> fallo posible, sobra y se saca.**

**Bloque 1 — Abierto (antes de nombrar nada)**

| # | Pregunta (literal) | Mapea a |
|---|---|---|
| 1 | *"Cuéntame qué pasó."* | Todo. Lo que menciona primero ordena el resto. |
| 2 | *"¿Qué fue lo más divertido?"* | **Riesgo 4** (¿tener a Dagna era adictivo?). Va **antes** de cualquier mención de la pérdida, o se contamina. |
| 3 | *"¿Hubo algo que quisieras hacer y no pudieras?"* | EJECUCIÓN vs DISEÑO — pérdida mecánica sin nombrarla. |

**Bloque 2 — Eje gameplay**

| # | Pregunta | Mapea a |
|---|---|---|
| 4 | *"¿Qué hacía tu compañera?"* | **INSTRUMENTO.** Si no lo sabe explicar, el test no midió (regla explícita del árbol). |
| 5 | *"¿Cambió algo en cómo jugabas después de la mitad?"* | EJECUCIÓN: legibilidad del cambio de terreno y de rutas. |
| 6 | *"El botón que la llamaba, ¿lo apretaste después? ¿Qué esperabas que pasara?"* | Instrumento **botón en la cornisa**. Se cruza con telemetría. |

**Bloque 3 — Eje narrativa**

| # | Pregunta | Mapea a |
|---|---|---|
| 7 | *"¿Qué pasó al final?"* | Comprensión del hecho, separada de la emoción. |
| 8 | *"¿Por qué lo hizo?"* | **INSTRUMENTO vs DISEÑO.** Entender el motivo y aun así no importarle es la rama cara. |
| 9 | *"¿Cómo te sentiste?"* | La medición emocional. Va después de las dos de comprensión, nunca antes. |
| 10 | *"¿Qué escuchaste en esa parte?"* | **Riesgo 2 (audio).** Registra el hueco declarado (§9.3). |

**Bloque 4 — Eje visual**

| # | Pregunta | Mapea a |
|---|---|---|
| 11 | *"¿Qué viste que te haya quedado grabado?"* | EJECUCIÓN visual. Sin sugerir qué debería haber visto. |

**Bloque 5 — Riesgos de producto (van al final, son los más contaminantes)**

| # | Pregunta | Mapea a |
|---|---|---|
| 12 | *"El juego terminado tendría dos personajes distintos con los que se puede empezar, y un tercero que aparece después. ¿Cómo te suena?"* | **Riesgo 3** (objeción del Outsider). Redacción **neutra a propósito**: no dice "se desbloquea al perder" ni vende el misterio. Se codifica: más de lo que esperaba / lo esperable / **menos de lo que esperaba**. |
| 13 | *"Si le tuvieras que contar este juego a un amigo en una frase, ¿qué le dirías?"* | Instrumento **frase al amigo** + **Riesgo 1**. Se transcribe **literal**. |
| 14 | *"Si tuvieras que mostrarle seis segundos de video para que quiera jugarlo, ¿qué le mostrarías?"* | **Riesgo 1** (el gancho es una ausencia y no entra en un GIF). Es la pregunta que mide el problema de wishlists. |
| 15 | *"¿Jugarías de nuevo? ¿Por qué?"* | Cierra. Cruza con 12. |

## 9. Los cuatro instrumentos acordados

### 9.1 — El botón en la cornisa
Mismo hook de telemetría de §4.1, mismo `bond_press` con `button_alive` e
`in_ledge_zone`, aplicado a **la cornisa de la coda** de [[Slice of Bond]]
(*"la cornisa que sabías que alcanzabas con ella"*). Se reporta **P** y
**T** igual que en A, y se cruza con la pregunta 6.

### 9.2 — Inputs por minuto
Pulsaciones del botón de Bond por minuto a lo largo de toda la sesión,
partido en tres tramos: **antes de T2** · **entre T2 y la traición** ·
**coda**. Sirve para dos cosas: ver si el uso **creció** (la habilidad
enganchó — Riesgo 4) y ver la caída después de la traición.
**Dependencia:** el mismo evento `bond_press` ya lo cubre; solo hay que
agregar `scene_id` al payload.

### 9.3 — 🔴 Regla del audio (Riesgo 2)
El consejo marcó que **el golpe de la pérdida es 50% sonido** y ningún
instrumento lo toca. Mientras el build no tenga pasada de audio:

> **No se puede concluir la rama DISEÑO del árbol de fallos.** Con la mitad
> del canal ausente, "entendieron todo y no les importó" es indistinguible
> de "faltaba la mitad del golpe". Un resultado negativo de B en build mudo
> **solo puede leerse como EJECUCIÓN**.

La pregunta 10 existe para dejar registro del hueco, no para taparlo.

### 9.4 — El recuerdo a 7 días
Protocolo aparte, §10.

## 10. Test de recuerdo a los 7 días

**A quién:** a los 3 testers, por separado, **sin que sepan que iba a
haber una segunda instancia** (no se anuncia en la sesión).

**Cuándo:** entre 6 y 8 días después. No antes.

**Cómo:** mensaje escrito, no llamada — la llamada empuja a rellenar el
silencio. **Un solo mensaje, con esta redacción exacta:**

> *"Hola, sin volver a mirar nada ni pensarlo mucho: ¿qué recuerdas del
> prototipo que jugaste?"*

**Prohibido:** nombrar a Dagna, la montaña, la traición o el final. Si el
tester pide pistas, se contesta *"lo que te venga"* y nada más.

**Solo si contesta**, y sin insistir, una única repregunta:

> *"¿Y qué sentiste al final?"*

**Qué se hace con la respuesta.** Se codifica la mención **espontánea** de
tres cosas, en la primera respuesta:

| Código | Qué cuenta |
|---|---|
| **C** — compañera | La menciona como alguien, no como mecánica |
| **P** — pérdida | Menciona que se fue / lo traicionó / la perdió |
| **M** — mecánica | Menciona el salto, la verticalidad, el botón |

**Lectura:**
- **P presente en 2 de 3** → el momento pega y sobrevive una semana. Es la
  evidencia más fuerte que el slice puede producir.
- **M sin P** → la mecánica quedó, el vínculo no. Rama **EJECUCIÓN**: el
  canal emocional no llegó.
- **Ni C ni P ni M en 2 de 3** → nada quedó. **No es rama DISEÑO
  automáticamente** — se cruza con las respuestas del día 0 antes de
  clasificar, y con la regla del audio (§9.3).

## 11. Hojas de registro — Protocolo B (una por eje)

```
=== HOJA 1 — EJE GAMEPLAY ===
TESTER: __________  FECHA: ________  BUILD: __________

Marcas de tiempo
  Primer uso voluntario del link:            ______
  Primer uso NO obligado por la escena:      ______
  Momento de la traición:                    ______
  Primera pulsación del Bond muerto (coda):  ______

Inputs por minuto
  Antes de T2: ____   Entre T2 y traición: ____   Coda: ____
  ¿El uso creció?  SÍ / NO      (Riesgo 4)

Coda
  P (pulsaciones muertas en la cornisa): ____   T (seg): ____
  Regresos físicos a la cornisa: ____
  ¿Buscó ruta alternativa? SÍ / NO  ¿Cuál? ______________________

Fricción / bugs (hora + descripción, marcar si contaminó el tramo):
  ______________________________________________________________
Respuestas 3, 4, 5, 6 (literal):
  ______________________________________________________________

=== HOJA 2 — EJE NARRATIVA ===
TESTER: __________  FECHA: ________

Conducta en la traición
  ¿Se detuvo?  SÍ / NO      ¿Cuánto? ______
  ¿Preguntó algo? (hora + literal): _____________________________
  Cuerpo / verbalizaciones (literal): ___________________________

Respuestas 7, 8, 9, 10 (literal, sin parafrasear):
  7 ____________________________________________________________
  8 ____________________________________________________________
  9 ____________________________________________________________
  10 ___________________________________________________________

Clasificación preliminar (NO se completa hasta tener las 3 sesiones):
  ¿Entendió QUÉ pasó?   SÍ / NO
  ¿Entendió POR QUÉ?    SÍ / NO
  ¿Le importó?          SÍ / NO
  → Comprensión alta + indiferencia = rama DISEÑO
    (⚠️ bloqueada si el build está mudo — §9.3)

=== HOJA 3 — EJE VISUAL ===
TESTER: __________  FECHA: ________

Respuesta 11 (literal): ________________________________________
Comentarios espontáneos sobre lo visual (hora + literal):
  ______________________________________________________________
Reportes de "se ve feo" / placeholder — se anotan y NO se cuentan
como hallazgo (el encuadre ya los declaró fuera):
  ______________________________________________________________

=== HOJA 4 — RIESGOS DE PRODUCTO ===
Respuesta 12: ____________________________________________________
  Codificación:  más de lo que esperaba / lo esperable / MENOS
Respuesta 13 (frase al amigo, LITERAL): __________________________
Respuesta 14 (los 6 segundos): ___________________________________
  ¿Lo que mostraría es una ausencia?  SÍ / NO   (Riesgo 1)
Respuesta 15: ____________________________________________________

=== DÍA 7 ===
Fecha de contacto: ______  Respuesta literal: ____________________
Códigos presentes:  C ☐   P ☐   M ☐
```

## 12. Regla anti-autoengaño (vale para A y para B)

De [[ADR-003 Reset de desarrollo y motor]] §A, y se repite acá porque es
donde se va a violar: **la rama del árbol se elige con la evidencia de
comprensión ANTES de leer el resultado emocional, no después.** Comprensión
alta + indiferencia = DISEÑO. No hay tercera lectura, y no se busca una.

---

## Pendiente

- **Firmar §0** (umbrales, condición de validez, regla de lectura
  negativa). **Bloquea correr el Protocolo A.**
- ~~**Implementar el hook de telemetría de §4.1**~~ ✅ **hecho 2026-08-13**,
  con test propio (50 verificaciones). Detalle en §4.1.
- ~~**Construir la escena gris**~~ ✅ **hecha 2026-08-13** →
  `godot/scenes/gray_test.tscn`, generada por `tools/build_gray_scene.gd`,
  con `tools/test_gray_scene.gd` (18 verificaciones) probando **con física
  real** que la mesa no se sube caminando desde ninguna de 8 direcciones.
  Se corre con `godot --path godot -- --tester=Diego`.
- **Congelar el build y anotar su hash en §0.5.** Es la única casilla de §0
  que sigue abierta.
- **Pasada de feel del jugador con Boris en la máquina.** Velocidad,
  sensibilidad de cámara y altura del salto están puestas por número, no
  probadas a mano. Si el control se siente mal, un 🔴 sería de ejecución y
  el test habría costado tres sesiones para decir eso.
- **Fijar fecha con Diego, Santiago y Delmer.** Disponibilidad ya
  confirmada ([[ADR-003 Reset de desarrollo y motor]] §C); falta fecha,
  que depende de la entrega del build.
- **Cerrar las 2 discrepancias de alcance del Protocolo B** (3 vs 4
  escenas; 1 tier vs T1→T3). No las resuelve este documento.
- **Decidir si se graba audio o video de las sesiones.** El protocolo
  funciona sin grabación —todo se anota literal— pero la transcripción
  literal a mano es la parte más frágil. Si se graba, hay que pedir
  permiso en el encuadre.
- **Pasada de audio del slice** antes de que cualquier resultado negativo
  de B pueda leerse como rama DISEÑO (§9.3).
