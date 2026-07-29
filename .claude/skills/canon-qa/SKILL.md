---
name: canon-qa
description: Auditar y cerrar la consistencia del canon del vault de Aether Bound. Usar cuando Boris pida una re-corrida de QA, cerrar un sprint de canon, verificar contradicciones entre fichas, o cuando se acabe de escribir/cambiar canon y haya que propagarlo. También al pedir "barrido", "re-corrida", "críticos" o "¿cerró el sprint?".
---

# QA de Canon — Aether Bound

Cierra contradicciones de hechos y de dramaturgia en `Aether Bound/10-Knowledge/`.

## Por qué existe esta skill

Cuatro rondas de QA con subagentes LLM fallaron en la **misma** clase de errores.
El diagnóstico, con evidencia de la 4ª ronda: **10 de 18 críticos eran
mecánicos** — citas rotas, aritmética que no cerraba, clases barridas a dos
tercios, reglas de fuente única re-enunciadas. Se estaba usando un LLM
(~234k tokens, 14 min, no reproducible) para el trabajo de un linter.

**Regla de oro: el linter barre lo mecánico, los subagentes barren lo que exige
juicio.** Nunca al revés, nunca en paralelo.

## Fase 0 — Linter primero, siempre

```bash
python "Aether Bound/scripts/check_canon.py"
```

Clases que cubre: wikilinks rotos, citas `§` a secciones inexistentes,
violaciones de fuente única, `hace N años` imposible contra la edad declarada,
encabezados `(edades A-B)` que no encierran sus datos, longevidad contra
`Las Tres Razas`, epítetos con género incorrecto, reinos usados como ciudades
caminables, POIs con cuadrantes divergentes, y cifras dentro de diálogo (INFO —
verificar a mano, son las más caras de equivocar).

Exit code 1 si hay CRITICAL. **No spawnees ningún subagente hasta que dé 0.**
Cada crítico que el linter encuentra es un crítico que no hay que pagarle a un
LLM para que encuentre — y que no se va a olvidar de la mitad de la clase.

Si aparece una regla de fuente única nueva, agregá su fila a `FUENTES_UNICAS`
en el script. Si aparece una clase de error recurrente que sea determinista,
**agregá un chequeo nuevo antes de delegarla a un subagente.** El linter es el
artefacto que crece; los subagentes son desechables.

## Fase 1 — Subagentes en frío, solo para juicio

Dos `Agent` (`general-purpose`, modelo Opus), **en paralelo**, **sin contexto de
los fixes** — la imparcialidad depende de que no hayan visto el trabajo hacerse.
Si validan su propio trabajo, el "0 críticos" no vale nada.

- **QA de dramaturgia:** gates de los 5 finales (¿inequívocos? ¿comparten
  verbo?), sabor declarado contra los 60 epílogos (12 fichas × 5 finales),
  reglas de tono (F2b prohíbe todo beat de "aprendimos algo"), los 3 grados de
  agencia de Speck (le preguntan / acepta / se la arrebatan), arcos que su
  epílogo contradice, beats sembrados que no se pagan.
- **QA de congruencia semántica:** lo que el linter no puede ver — dos archivos
  que describen la misma escena distinto, roles/títulos incompatibles,
  duplicación de fichas, causalidad de una muerte, cargos y facciones.

En **los dos** prompts, este contrato es obligatorio:

> Cuando encuentres un dato erróneo, NO reportes solo la línea. Debés:
> (1) grep del dato en TODO el vault, (2) identificar qué archivo lo enuncia
> como canon primario, (3) reportar la CLASE COMPLETA de menciones con
> archivo:línea. Un hallazgo que reporte 1 línea habiendo 6 menciones cuenta
> como hallazgo incompleto.

Y cerrá con: *"Sé severo: el criterio de cierre es 0 críticos, así que un falso
'todo bien' es peor que un falso positivo."*

## Fase 2 — Fixes: a la fuente, no a la línea

Por cada crítico, en este orden:

1. **Buscá la fuente.** Grep del dato en todo el vault y identificá qué archivo
   lo enuncia como canon primario. Arreglar la línea reportada sin arreglar la
   fuente reintroduce el crítico en la siguiente ficha.
2. **Arreglá ahí primero**, después propagá.
3. **Re-grep** para confirmar 0 residuos.

**No adivines decisiones de diseño.** Si el fix implica elegir entre dos canons
posibles (cuánto cuesta un final, qué gatea una rama, si se archiva una ficha),
es decisión de Boris: usá `AskUserQuestion` con las consecuencias de cada opción
explicadas — cuánto trabajo implica y qué se rompe. Mientras esperás, hacé todo
lo que no dependa de la respuesta.

Cuando el fix produzca prosa nueva, escribila **en la voz del vault**: canon
afirmativo, negrita para lo no negociable, y cuando corrijas un dato falso que
un personaje cree, no lo borres — **marcalo como error heredado** y usalo como
beat (ver `Valen:58`, los ancianos y sus "cuatro Mudas").

## Fase 3 — Cierre

1. `check_canon.py` en 0 críticos y `check_vault.py` en 🟢.
2. Actualizá `00-Index.md`, `LOG.md` y `20-State/Current-State.md` (regla 4 del
   CLAUDE.md — ningún loop cierra sin esto).
3. Commit + push. **Nunca dejes el trabajo sin commitear**: en una sesión el
   clasificador se cayó a mitad de camino y todo quedó en disco, mezclado con
   los cambios previos.
4. **Re-corrida.** El criterio de cierre es 0 críticos de ambos subagentes.
   Cuatro rondas de historia dicen que va a haber otra: no declares cerrado un
   sprint por cansancio.

## Anti-objetivos

- No delegar a un subagente lo que el linter puede decidir.
- No dejar que el subagente implemente los fixes: diagnostica, no ejecuta.
- No re-invocar al mismo subagente para verificar sus propios fixes.
- No editar archivos derivados a mano (`Briefs de Mapa del Mundo` §cuadrantes se
  **regenera** desde `Geografía y Ciudades`).
- No tocar `docs/GDD.md` ni `BACKLOG.md` — congelados.
