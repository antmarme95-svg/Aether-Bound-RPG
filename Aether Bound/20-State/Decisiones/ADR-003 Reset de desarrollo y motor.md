---
status: ABIERTO — BLOQUEANTE
updated: 2026-07-28
supersede_parcial: "ADR-002 Motor diferido"
---

# ADR-003 — Reset de desarrollo y revisión de motor 🔴 ABIERTO

> **BLOQUEANTE: no se toca una línea de código hasta que este ADR se cierre.**
> Planteado por el director el 2026-07-28.

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

## Pendiente

Agendar la sesión de decisión. Requiere al director; no es delegable a un agente.
Insumo listo para esa sesión: [[Brief para el Consejo — Motor y Fases de
Desarrollo]] (2026-08-10) — compila esta investigación, la premisa de fases
de Boris, y marca una tensión de alcance a resolver antes de correr el
consejo.
