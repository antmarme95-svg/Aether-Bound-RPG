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

- 🔬 **El foot IK stock alcanza en los dos.** `Animator IK`
  (`OnAnimatorIK`) en Unity y `SkeletonIK3D` en Godot plantan el pie en la
  pendiente sin escribir un solver. El problema original —"no pasaba ni el
  ojo ni el feel"— era de construir todo a mano, no del motor.
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

**Lo que sigue sin estar probado, y es lo que debería decidir el
veredicto:** si el foot IK y la animación de Godot alcanzan para el
estándar del [[Benchmark Biomecánico]] —que es el pilar del que depende
[[Slice of Bond]]— o si hay que escribir un `SkeletonModifier3D` propio.
Eso es una pregunta con respuesta empírica, y todavía no se corrió.

---

**Relacionado:** [[ADR-002 Motor diferido]] · [[ADR-003 Reset de
desarrollo y motor]] · [[Lecciones]] · [[Benchmark Biomecánico]] ·
[[Current-State]]
