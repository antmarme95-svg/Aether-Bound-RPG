# Character Head/Bust Review v0.3 — humano base, ronda 3 (M9/M10)

> **Fuente RAW del director (Boris), 2026-07-10.** Depositado verbatim (sobre
> capturas de M9-r2). No se edita. Checklist vivo: [[Task-Board]] §C6.

## Evaluación General

Ronda dos muestra correcciones reales: color de pelo al castaño aprobado,
ojos fuera del registro de caricatura (esclerótica reducida, iris con color,
cejas más bajas y rectas), y apareció una marca facial verde. Sin embargo: la
silueta del pelo deriva a "moño/top knot" inexistente en el concepto, la
cabeza se sobre-corrigió a ovoide demasiado ancha, las marcas faciales están
incompletas y mal posicionadas, y la nariz-bloque y orejas-disco introducen
problemas nuevos. El vestuario sigue ausente y el cuello sigue largo.
**Veredicto: Needs Revision** — progreso claro, cabeza aún no on-model.

## Críticos

1. **Silueta del pelo off-model (top knot).** El concepto: quiff corto
   barrido arriba-atrás, laterales cortos, textura. Implementación: casquete
   liso con protuberancia superior que lee como moño (arquetipo
   monje/samurái = cambio de identidad). Fix: eliminar protuberancia;
   construir el quiff con 2-3 volúmenes ANGULARES (masa frontal elevada con
   barrido hacia atrás, laterales pegados).

2. **Marcas faciales incompletas y mal ubicadas.** Concepto: (1) diagonal
   verde en frente/ceja DERECHA del personaje, (2) diagonal en mejilla
   IZQUIERDA del personaje. Implementación: una sola marca pequeña en la
   mejilla, del lado contrario, con forma de triángulo compacto. Espejar o
   dejar parcial es peor que omitir (se propaga a marketing/íconos/retratos).
   Fix: dos marcas con proporción de FRANJA alargada; verificar lateralidad
   contra el concepto antes del commit.

## Alta prioridad

3. **Proporción craneal sobre-corregida** (de larga/angosta a ancha/ovoide;
   mejillas más allá de la línea de mandíbula). Fix: ancho máximo a la
   altura de mejillas −10-15%, marcar quiebre del pómulo, ensanchar/cuadrar
   mandíbula inferior. Objetivo: trapecio invertido suave, no elipse.

4. **Vestuario sigue ausente** (segunda ronda). Si el torso desnudo es
   base-body intencional para sistema modular, documentarlo en el PR y queda
   CERRADO. Si no, bloquear cowl antes de la siguiente ronda; la corrección
   del cuello depende de esto.

## Media prioridad

5. **Nariz-bloque rectangular de valor más oscuro**, sin transición con la
   frente ni punta/alas. En cel-shading los quiebres de valor son
   declaraciones de forma. Fix: igualar valor al tono de piel, sesgar el
   bloque (base más ancha que puente, leve proyección de punta).

6. **Orejas-disco** (leen como audífonos/botones). Fix: primitivo
   semi-elíptico con eje mayor vertical, banda ceja-nariz, leve inclinación
   hacia atrás.

7. **Cuello sigue largo y cilíndrico.** Fix: acortar y ensanchar la base con
   transición al trapecio; re-evaluar junto con el cowl.

## Baja prioridad

8. **Boca**: sonrisa cerrada mínima vs sonrisa amplia con dientes del
   concepto. Ensanchar levemente la boca base (prevé el rango del rig
   facial).

9. **Parches rectangulares de valor en mentón/cuello** (seams de blockout).
   Confirmar que no haya geometría duplicada.

## Hallazgos positivos

- Color de pelo corregido al castaño ✓ (cierre del crítico #1 de ronda 1).
- Ojos re-construidos correctamente — on-model, **no tocar más**.
- Tono de piel des-saturado hacia el concepto ✓.
- Prop retirado del build de revisión ✓.
- Integración Godot con iluminación de escena, workflow correcto ✓.

## Riesgo de producción

- Rig facial: cráneo ovoide + boca angosta congelados → re-skinning.
- Equipamiento modular: interfaz cuello-torso sin contrato tras dos rondas.
- Legibilidad: el top knot cambia el arquetipo a distancia.
- Pipeline: marcas espejadas se propagan a íconos/retratos/marketing.
- **Cobertura: próxima entrega DEBE incluir turnaround completo (frente,
  perfil, ¾, espalda).**

## Puntuación

- Concept Fidelity: **5.5 / 10** · Production Readiness: **5 / 10** ·
  Technical Execution: **6.5 / 10** · **Overall: 5.5 / 10.**
- Bloqueantes: silueta del quiff, estructura mandibular, marcas correctas y
  bilaterales, blockout del cowl (o cierre documentado). Próxima entrega con
  turnaround completo.
