---
status: raw
updated: 2026-08-10
---

# Consejo — Motor y Fases de Desarrollo (2026-08-10)

> Transcript del `/llm-council` corrido sobre
> [[Brief para el Consejo — Motor y Fases de Desarrollo]].
> 5 asesores independientes → revisión cruzada anónima → síntesis del
> chairman. **Archivo raw: no se edita.** Las decisiones que salieron de
> acá viven en [[ADR-003 Reset de desarrollo y motor]].

## Pregunta enmarcada

¿Qué vertical slice se construye primero, con qué motor, y bajo qué método
de producción — para probar que el juego funciona antes de comprometer
meses de desarrollo? Tensión central: `Slice of Bond` (1 celda × 1 Pivote,
tesis narrativa/emocional, criterio "si la coda no duele, falla") vs. la
premisa del director (creación de personaje ×18 + prólogo + tutorial +
título + Encuentro con Roen, tesis de producción/onboarding).

---

## Respuestas de los asesores (resumen)

**El Contrarian.** El problema no es cuál slice — son 6 semanas eligiendo
no decidir, con el ADR dando permiso escrito. El trabajo narrativo es la
zona de confort: ninguna ronda de QA puede reprobar, un slice sí. El
debate de motor es un señuelo: ningún criterio de éxito depende del motor.
Godot y punto. El Candidato B es una trampa disfrazada de producción. Y la
pregunta evitada: ¿quién es el playtester ajeno? Sin esa persona nombrada,
A tampoco es falsable.

**El First Principles Thinker.** La pregunta está mal planteada. ¿Por qué
6 semanas sin decidir algo que no tiene consecuencias? El ADR no protege
nada — se usa como permiso para hacer lo cómodo. El criterio de A no
requiere motor: es una hipótesis narrativa falsable con cubos grises este
fin de semana. El elefante: 9×5×9 no es un juego que exista; el slice
honesto no prueba "si el juego funciona", prueba **si el diseño sobrevive
al recorte**.

**El Expansionist.** El activo que nadie cuenta es el gauntlet-loop + el
Benchmark Biomecánico: una máquina de calidad reutilizable con estándar
numérico. Los 9 Pivotes no son riesgo de alcance, son motor de discurso
("¿a quién te traicionó?") — constrúyelos modulares para que el Pivote 10
cueste días. Voto: B con la coda de A pegada. Motor: Unity, porque
post-reset migrar cuesta casi nada y compras animación de personajes,
consolas e Ink/Yarn. Oportunidad adyacente: publica el proceso.

**El Outsider.** Tres cosas suenan raras en frío: (1) 6 semanas de "no se
escribe código" mientras se escriben miles de líneas de worldbuilding no
es un ADR pendiente, es una función; (2) nadie se enamoró de un juego por
el slider de vello facial — B es la parte más cara y la que menos
incertidumbre resuelve; (3) nadie resolvió quién es el playtester. Sobre
el motor: evidencia medida vs. argumentos de folleto — gana la evidencia.
Pregunta incómoda: 9 Pivotes × 5 finales asume gente que rejuega nueve
veces, ¿existe?

**El Executor.** Ninguno de los dos candidatos es ejecutable como está.
Elige A recortado: greybox total, sin combate, dos verbos
(escalar-con-ella / escalar-sin-ella), 6-8 semanas hasta manos de un
playtester. B no tiene criterio de falla — un slice sin condición de
muerte no es prueba, es desarrollo con otro nombre. Motor: Godot, cierra
hoy. Método: gauntlet-loop solo sobre traversal; en narrativa el crítico
es humano. Lunes, 3 horas: cierra el ADR, `git tag archive/prototipo`,
crea la escena.

## Revisión cruzada — resultado

**Unanimidad de los 5 revisores:** el Executor es la respuesta más fuerte
(única que resuelve slice + motor + método con criterios operativos y
acción concreta). El Expansionist es el mayor punto ciego (recomienda
hacer ambos candidatos — exactamente el no-recorte que el ADR lleva 6
semanas fallando en hacer — y migra de motor contra la evidencia).

**Hallazgos que solo emergieron en la revisión cruzada:**
1. Nadie escribió **qué pasa si la coda NO duele** — ¿falla el diseño, la
   ejecución, o el instrumento? Sin ese árbol escrito antes, el criterio
   de muerte es retórico.
2. Nadie escribió **qué pasa si SÍ duele** — validar 1 Pivote no valida el
   patrón de producción para 9. El slice debe salir con un número de horas.
3. El **playtester ajeno no existe** en ningún documento.
4. Nadie propuso el **puente barato**: un agente imparcial como filtro
   previo (no juez) de "duele/no duele".
5. **Migrar no cuesta cero** — se incinera `Lecciones.md`.
6. El **Benchmark Biomecánico puede no medir este slice** (calibrado
   contra combate/fauna, no contra escalada).
7. **La semana siete** — el bloqueo creció durante el propio consejo.

## Veredicto del chairman (resumen)

- **Slice:** A recortado a 3 escenas. Greybox de entorno **pero no greybox
  de cuerpo** — un rig con biomecánica y game feel correctos, y el
  compañero con voz. Ese es el punto de la premisa del director que 4
  asesores tiraron junto con los tatuajes: *la biomecánica es el canal por
  el que viaja la pérdida*, no decoración.
- **Se corta de B:** las 18 combinaciones, marcas, pelo, vello facial,
  secuencia de título, tutorial y prólogo.
- **Motor:** Godot, cerrado hoy, sin reabrir hasta que el slice dé
  veredicto. Al Expansionist se le concede el hecho (hoy es el día más
  barato para migrar) y se le niega la conclusión (barato ≠ necesario).
- **Método:** gauntlet-loop solo sobre traversal, previa verificación de
  que el Benchmark aplica a una escena sin combate. Se construye *sobre*
  la escena, no antes.
- **Antes de la primera línea de código:** árbol de "si no duele",
  contador de horas, y 3 playtesters con nombre y fecha.

**El chairman discrepó de la unanimidad** en un punto: los 5 revisores
enterraron 3 cosas legítimas del Expansionist, dos de ellas del propio
director — la lectura sin caridad de la premisa B (que dice "game feel y
biomecánica correctos", no "quiero sliders"), el hecho de que `Slice of
Bond` se ratificó **antes** del rework de los 9 Pivotes, y la modularidad
como única respuesta seria al problema de alcance.

---

## ⚠️ Error del consejo, detectado al aterrizarlo (2026-08-10)

El chairman propuso resolver "**Dagna o Roen**" con 30 minutos de lectura
de canon. **La pregunta está malformada y no requiere esos 30 minutos:**

**Roen es un fijo. Los fijos no traicionan.** Solo los 9 Pivotes
traicionan ([[The Bound Five]], [[Los 9 Pivotes]]; cf.
[[Geografía y Ciudades]] §960 — *"Valen es fijo, no traicionará"*; la
única excepción del lado Pivote es Bram, que tampoco traiciona). El slice
completo se apoya en la coda del **Bond vacío**: recorrer el mismo terreno
sin ella. Roen no se va nunca — estructuralmente no puede sostener esa
coda.

El consejo no podía saberlo: el brief describía el "Encuentro con Roen"
como parte de la premisa B (onboarding/tutorial) sin explicitar que Roen
pertenece al elenco fijo. **Dagna gana por defecto**, no por empate.

Corolario que sí sobrevive del planteo del chairman: la observación de que
`Slice of Bond` se ratificó antes del rework narrativo sigue siendo
válida — pero la pregunta correcta no es "¿Dagna o Roen?" sino
"¿sigue siendo Dagna el mejor de los **9 Pivotes** para el slice?".
