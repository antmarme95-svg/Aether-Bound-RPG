---
status: vivo
updated: 2026-08-12
---

# Comparativa de Motores — Godot vs Unity

> **Qué es esto y qué no.** Es el insumo pedido por el director el
> 2026-08-12: pros/contras y FODA de cada motor, apoyado en lo que el
> spike de [[ADR-003 Reset de desarrollo y motor]] **midió de verdad** más
> hechos verificables de cada plataforma.
>
> **No reabre la decisión.** El motor es **Godot** ([[ADR-002 Motor
> diferido]], re-confirmado en el cierre de ADR-003). Este documento
> existe para que esa decisión se sostenga con los ojos abiertos, y para
> que el veredicto final del spike —cuando se dé— compare lo mismo de los
> dos lados.
>
> **Marcado de origen, deliberado:** 🔬 = medido en este proyecto ·
> 📋 = hecho verificable de la plataforma · ⚖️ = juicio, discutible.

---

## 1. Lo que el spike midió (y lo que no)

El spike puso la **misma** Dagna, el **mismo** rig y la **misma** rampa en
los dos motores, con foot IK **stock** de cada uno.

**Lo que quedó probado:**

- ⚠️ **CORREGIDO (2026-08-12, medición contra el Benchmark).** Esta línea
  decía que "el foot IK stock alcanza en los dos". **Es falso del lado de
  Godot.** Medido: con `SkeletonIK3D` corriendo (`is_running() == true`,
  target resuelto) el pie se mueve **1.4 mm** respecto de tenerlo apagado
  — es un **no-op**, mientras el dedo queda **20 cm por debajo** de la
  superficie de la rampa. El grounding que se veía en las capturas venía
  del cuerpo apoyado por física, no del IK. Detalle abajo, §5.
- 🔬 **El retargeting stock alcanza en los dos.** Mecanim en Unity;
  `BoneMap` + `SkeletonProfileHumanoid` en Godot. En Godot hubo que armar
  el `BoneMap` a mano (el rig de Dagna es Rigify, no Mixamo), pero es una
  tarea de 45 minutos y queda versionada como recurso.
- 🔬 **La diferencia visual grande de la lámina comparativa NO es de
  motor: es de clip.** La zancada de Starter Assets recorre 1.12 m; la de
  DoubleL, 0.825 m. Peras y manzanas si no se dice.

**Lo que NO probó, y conviene no fingir que sí:**

- Nada de rendimiento comparado (no se midió fps en condiciones iguales).
- Nada de combate, IA, UI, audio, guardado, ni build/export.
- Nada del look final: los dos corren greybox plano.
- El jugador sigue idle en los dos.

### Medición contra el Benchmark (2026-08-12)

El [[Benchmark Biomecánico]] (§v2) pide, en la fila de HZD, **"foot IK
contra el terreno cada frame — pies creíbles en terreno"**, y en el canon
de Sable, **raíz continua**. Traducido a tres métricas y corrido en Godot
(`godot/tools/footik_benchmark.gd`):

| Métrica | Godot medido | Estándar |
|---|---|---|
| Raíz continua | ✅ avance 0.0249 m/frame, desvío 7.7% | Sable: raíz continua, cero pop |
| Penetración del dedo, piso plano | ❌ **−0.132 m** (media en apoyo) | ~0 |
| Penetración del dedo, rampa 21.8° | ❌ **−0.205 m** (peor: −0.247 m) | ~0 |
| Adaptación de la planta a la pendiente | ❌ **10.9°** de 21.8° | ≈ el ángulo del terreno |
| **Aporte del IK** (IK on vs IK off) | ❌ **1.4 mm** | — |

**La fila que importa es la última.** Con el foot IK apagado los números
son idénticos hasta el cuarto decimal (−0.1323 contra −0.1320 en plano;
−0.2051 contra −0.2048 en rampa). `SkeletonIK3D` **no está haciendo
nada**, aunque reporte `is_running() == true` y su `target_node` resuelva
bien. Es coherente con que esté **marcado como deprecado** en 4.x: el
camino vigente es `SkeletonModifier3D`.

**Lo que esto significa para el veredicto:** la pregunta "¿alcanza el foot
IK stock de Godot?" **todavía no tiene respuesta**, porque lo que se probó
no era foot IK — era animación cruda con el cuerpo apoyado por física.
Comparar este número contra Unity daría un resultado engañoso a favor de
Unity por una razón que no es del motor. **Primero hay que hacer funcionar
el IK del lado Godot; recién después la comparación significa algo.**

---

## 2. Pros y contras

### GODOT

**A favor**

- 📋 **MIT. Cero regalías, cero fee por instalación, cero cambio
  retroactivo de licencia.** Para un proyecto de un solo autor con
  horizonte largo, esto elimina una clase entera de riesgo.
- 📋 **El motor es un binario de ~180 MB y abre en segundos.** El ciclo
  editar→correr es cortísimo.
- 🔬 **Se automatiza muy bien desde línea de comandos.** Todo el spike
  —construir la escena, importar, correr, capturar, medir huesos— se hizo
  con `--headless --script`. Eso importa mucho en este proyecto: es lo que
  permite que el asistente verifique su propio trabajo sin pedirte que
  mires.
- 🔬 **La escena es texto legible y diffeable.** `spike_slope.tscn` se lee
  en el commit; los bugs de estructura se ven en el diff.
- 📋 **El árbol de nodos + señales es un modelo mental chico.** Menos
  conceptos que aprender que en Unity moderno (GameObject + prefabs +
  ScriptableObjects + packages + assemblies + tres pipelines de render).
- ⚖️ **Ya hay evidencia propia a favor**: la golden scene de ADR-002 corrió
  las 4 capas de la [[Art Bible]] a 430–530 fps.

**En contra**

- 🔬 **El importador de FBX tiene trampas caras, y son silenciosas.** Hoy
  aparecieron cuatro en una sola sesión: escala ×100 escondida dentro de
  una pista de animación; el árbol duplicado al re-apropiar una instancia;
  el frente del modelo en +Z contra la convención −Z del motor; y
  `SkeletonIK3D` como `SkeletonModifier3D` sin el equivalente de
  `Animator.GetIKPosition()`. Ninguna dio un mensaje de error: todas se
  manifestaron como "se ve raro". Están inventariadas en [[Lecciones]]
  §Godot 4.7.
- 🔬 **El foot IK stock NO FUNCIONA, y hubo que escribirlo (medido
  2026-08-12).** `SkeletonIK3D` está deprecado, y su reemplazo vigente
  **`TwoBoneIK3D` no produce salida en 4.7.1**: escena mínima aislada, 9
  variantes de configuración, 0 píxeles en las 9, contra un control que sí
  mueve el render. **Costo real: un solver de dos huesos escrito a mano**
  (`scripts/two_bone_ik.gd`, ~130 líneas con comentarios) — mientras que
  del lado Unity `OnAnimatorIK` funciona de fábrica.
  **Matiz importante, y va a favor de Godot:** una vez escrito, el
  resultado **cumple el estándar del [[Benchmark Biomecánico]]** — el pie
  queda a ±6 mm del suelo y se apoya igual de bien en pendiente que en
  plano. O sea: no es una limitación del motor, es una **deuda de una
  tarde**. Y el framework de `SkeletonModifier3D` en sí funciona bien; lo
  que falla es una clase concreta.
- 🔬 **El foot IK stock es más pobre que el de Unity.** En la lámina, el
  pie de Godot apunta la punta hacia abajo y penetra la superficie;
  `SkeletonIK3D` coloca el tobillo y rota al normal, pero no ajusta la
  pelvis ni el dedo. Unity lo resuelve más limpio con la misma cantidad de
  código. **Y `SkeletonIK3D` está marcado como deprecado** — el camino
  vigente es `SkeletonModifier3D`, que hay que escribir.
- 📋 **La biblioteca de assets es mucho más chica.** Y —lo más concreto
  para vos— **tus 55 paquetes comprados son del Asset Store de Unity**.
  Sirven en Godot, pero pasando por conversión y retargeting cada vez.
- ⚖️ **Menos gente resolvió tu problema antes.** Cuando algo se rompe, hay
  menos hilos, menos videos y menos respuestas de Stack Overflow.
- 📋 **Consolas requieren un partner externo** (ya anotado como riesgo de
  producción tardía en ADR-002). Irrelevante para v1, que es PC.

### UNITY

**A favor**

- 📋 **Ecosistema de assets enorme**, y vos ya invertiste en él: 55
  paquetes, ~2.3 GB, listos para usar sin conversión.
- 🔬 **Las herramientas de animación humanoide son más maduras.** El
  sistema Humanoid con avatar, el retargeting automático entre rigs
  compatibles, los blend trees, y un foot IK que da mejor resultado con el
  mismo esfuerzo.
- 📋 **C#** con un ecosistema de herramientas y depuración muy completo.
- 📋 **Volumen de documentación, cursos y respuestas** sin comparación.
- 📋 **Exportación a consolas** por caminos ya trillados.

**En contra**

- 📋 **Licencia con historial de cambios unilaterales.** El episodio del
  Runtime Fee (2023) se revirtió, pero demostró que los términos pueden
  moverse bajo los pies de un proyecto ya empezado. Para un desarrollo de
  varios años hecho por una persona, ese riesgo es asimétrico.
- 🔬 **Automatizarlo desde afuera es notablemente más caro.** Para hacer el
  equivalente del capturador de Godot hubo que: abrir el editor en
  batchmode, entrar a play mode sobreviviendo el domain reload con
  `SessionState`, y descubrir que el culling del Animator deja de escribir
  los `Transform` de los huesos cuando la cámara mira a otro lado. Cada
  corrida tarda minutos contra segundos.
- 🔬 **Los tiempos de arranque e importación son de otro orden.**
- 📋 **Las escenas son YAML gigante, en la práctica no diffeable.**
- ⚖️ **Más superficie de decisión**: tres pipelines de render, dos sistemas
  de input, paquetes que se pisan. Más cosas que elegir mal.

---

## 3. FODA

### FODA — GODOT (el motor elegido)

|  | **Ayudan** | **Estorban** |
|---|---|---|
| **Internas** | **FORTALEZAS**<br>· Licencia MIT, sin riesgo contractual<br>· Ciclo de iteración cortísimo<br>· 🔬 Se automatiza y se autoverifica desde CLI — encaja con cómo trabajás con el asistente<br>· Escenas en texto, versionables y revisables<br>· Evidencia propia previa (golden scene, 430–530 fps) | **DEBILIDADES**<br>· 🔬 Importador de FBX con trampas silenciosas<br>· 🔬 Foot IK stock más pobre, y `SkeletonIK3D` deprecado<br>· Herramientas de animación humanoide menos maduras<br>· Biblioteca de assets chica frente a la que ya comprate |
| **Externas** | **OPORTUNIDADES**<br>· El motor mejora rápido en 3D (4.x)<br>· El pipeline de retargeting ya quedó resuelto y versionado: el costo se paga una vez<br>· Nada obliga a modelar todo a mano — los assets de Unity se convierten | **AMENAZAS**<br>· Cada asset nuevo del Asset Store es una conversión más, con su propio riesgo de trampa silenciosa<br>· Si el slice necesita IK/animación de calidad alta, hay que escribir `SkeletonModifier3D` propio<br>· Consolas exigen partner (post-v1) |

### FODA — UNITY (la alternativa)

|  | **Ayudan** | **Estorban** |
|---|---|---|
| **Internas** | **FORTALEZAS**<br>· Tus 55 paquetes funcionan sin convertir<br>· 🔬 Animación humanoide y foot IK más maduros<br>· C# y su ecosistema de depuración<br>· Documentación y comunidad enormes | **DEBILIDADES**<br>· 🔬 Automatización externa cara y frágil (batchmode + play mode + culling del Animator)<br>· Arranque e importación lentos<br>· Escenas no diffeables<br>· Superficie de decisión grande (3 pipelines, 2 inputs) |
| **Externas** | **OPORTUNIDADES**<br>· Camino a consolas ya trillado<br>· Mercado laboral y de contratación mucho más grande, si algún día sumás gente | **AMENAZAS**<br>· ⚠️ **Riesgo de licencia**: precedente de cambio unilateral de términos a mitad de proyecto<br>· Dependés de una empresa con presión financiera<br>· Cambios de rumbo de plataforma fuera de tu control |

---

## 4. Lectura honesta

**El eje que más pesa no es técnico, es de método.** Los dos motores
resuelven el problema del spike. La diferencia real que apareció hoy es
que **Godot se deja automatizar y verificar desde afuera, y Unity mucho
menos** — y este proyecto se construye con un asistente que necesita
poder medir su propio trabajo sin que vos mires cada frame. Ese es un
argumento a favor de Godot que no estaba en la mesa cuando se decidió, y
que el spike hizo visible.

**El contraargumento más fuerte para Unity es el que ya pagaste:** 55
paquetes de assets. Pero el spike también mostró que la conversión
funciona, y que el pipeline se arma una vez.

**Esa pregunta ya se corrió (2026-08-12) y tiene respuesta:** el foot IK
de Godot **sí alcanza el estándar del [[Benchmark Biomecánico]]**, pero
**hay que escribirlo** — el `TwoBoneIK3D` de fábrica no produce salida.
Con el solver propio, el pie queda a ±6 mm del suelo y se apoya igual de
bien en pendiente que en plano. El costo fue una tarde, y es
**no recurrente**.

### El foot IK, medido de los dos lados (2026-08-12)

Mismo protocolo en los dos motores (`godot/tools/footik_benchmark.gd` ·
`unity/Assets/_Spike/Editor/SpikeFootIKBenchmark.cs`): cámara ortográfica
con su "arriba" en la normal del terreno, silueta contra la línea del
suelo, 16 muestras por terreno, apoyo = el 40% de muestras más bajas.
**Y los dos calibrados con el mismo criterio** — barriendo el offset del
tobillo hasta minimizar la penetración en plano.

| Métrica | **Godot** (solver propio) | **Unity** (`Animator IK`) | Estándar |
|---|---|---|---|
| Penetración, plano | **−0.004 m** | **+0.005 m** | ~0 |
| Penetración, rampa 21.8° | **+0.006 m** | **+0.031 m** | ~0 |
| Plano → rampa (consistencia) | **+0.010 m** | **+0.027 m** | 0 |
| Offset calibrado | 0.045 | 0.21 | — |

**Los dos cumplen el estándar en plano** (±5 mm). En pendiente, el pie de
Godot queda más pegado a la superficie (+6 mm contra +31 mm), y su
consistencia plano→rampa es casi el triple de buena.

**Se probó explicar la diferencia por un error de coseno, y la medición lo
rechazó.** La hipótesis era que el `SpikeFootIK.cs` de Unity desplaza el
objetivo **verticalmente** (`hit.point + Vector3.up * offset`) mientras el
de Godot lo desplaza **a lo largo de la normal**. Se aplicó el cambio a
Unity y la rampa **empeoró**: +0.031 → +0.055 m. Se revirtió.

**Por qué el argumento del coseno no aplica acá:** el `footOffsetY`
calibrado de Unity da **0.21 m**, y un tobillo real está a 0.08-0.10. O sea
que ese número **no es una altura de tobillo**: es un factor que absorbe la
geometría tobillo→punta de la bota, que es lo que marca el píxel más bajo
de la silueta. Un factor de corrección así **no tiene una dirección física
que respetar**, y girarlo con la pendiente solo lo desalinea. El coseno
vale para una altura real; no vale para un fudge.

**Entonces la diferencia en pendiente queda SIN explicar.** Puede ser el
script, pueden ser los clips (el de Starter Assets tiene un despegue de
punta más marcado que el de DoubleL, y el punto más bajo de la silueta
depende de eso), o puede ser el motor. **No hay evidencia para atribuirlo a
ninguno de los tres**, y en particular no alcanza para decir "Godot planta
mejor el pie".

**Lo que sí es diferencia de motor** sigue siendo lo de antes: en Unity el
foot IK **viene funcionando**; en Godot **hay que escribirlo**, porque el
`TwoBoneIK3D` de fábrica no produce salida.

**Métrica no comparable — raíz continua.** Godot da 0.0249 m/frame con
7.8% de desvío; Unity da 0.0003 m/frame con 600%. **El número de Unity no
sirve para comparar**: el driver mueve en `Update()` y en batchmode corre a
miles de fps, así que el desplazamiento por frame es minúsculo y el desvío
relativo se dispara. No es que la raíz de Unity sea peor — es que la
métrica está atada al timestep de cada motor. Los dos mueven la raíz por
código sin stepping, así que **los dos cumplen el criterio de Sable por
construcción**; el número no aporta nada y se deja anotado como no
comparable en vez de publicarlo como si dijera algo.

**Instrumento validado de los dos lados.** El de Unity tiene un CONTROL
que hunde al personaje 10 cm y verifica que la penetración medida cambie
~10 cm: da **0.0995 m**. La primera corrida del control dio 0.0205 y marcó
"SOSPECHOSO" — no era el instrumento, era el **foot IK volviendo a plantar
el pie**. Se corrigió corriendo el control con el IK apagado. Es el mismo
tipo de trampa que del lado Godot costó medio día.

---

**Relacionado:** [[ADR-002 Motor diferido]] · [[ADR-003 Reset de
desarrollo y motor]] · [[Lecciones]] · [[Benchmark Biomecánico]] ·
[[Current-State]]
