---
status: ratificado
updated: 2026-07-29
---

# QA de Canon Loop

Cierra contradicciones de **hechos y dramaturgia** en el canon textual del
vault. Hermano del [[QA Loop]], que hace lo mismo para **assets visuales**
contra una lámina.

> **El método ejecutable vive en la skill `canon-qa`** (`.claude/skills/canon-qa/`).
> Este documento registra el *por qué* y el contrato; la skill tiene los pasos.
> Deliberadamente **no** se duplica el procedimiento acá: dos copias de una regla
> es la clase de error que este loop existe para cazar.

- **Objetivo:** 0 críticos de consistencia, verificable y reproducible.
- **Entrada:** canon recién escrito o cambiado, o un sprint que Boris quiera cerrar.
- **Orden no negociable:**
  1. **Linter** (`scripts/check_canon.py`) hasta 0 críticos.
  2. **Subagentes en frío** (Opus, en paralelo, sin contexto de los fixes) solo
     para lo que exige juicio: dramaturgia y congruencia semántica.
  3. **Fixes a la fuente**, nunca a la línea reportada, con re-grep de la clase.
  4. **Checkpoint + commit** y re-corrida hasta que ambos subagentes den 0.
- **Validación:** `check_canon.py` exit 0 **y** `check_vault.py` en 🟢.
- **Artefactos:** [[00-Index]], [[LOG]], [[Current-State]], y **chequeos nuevos en
  el linter** cuando aparezca una clase determinista recurrente.
- **Salida:** sprint de canon cerrado con criterio medible, no con cansancio.

## Por qué el orden importa (evidencia, 2026-07-29)

Cuatro rondas de QA fallaron en la misma clase de errores. En la 4ª ronda, **10
de 18 críticos eran mecánicos**: citas rotas, aritmética que no cerraba, clases
de menciones barridas a dos tercios, y reglas de fuente única re-enunciadas por
otros archivos. Se estaba pagando ~234k tokens y 14 minutos de subagente para
encontrar lo que un script encuentra en dos segundos — y encima el subagente
olvidaba parte de la clase: la longevidad humana quedó en 2/3, y la aritmética
de Lyris pasó **dos rondas reportada** sin cerrarse, con una cifra en diálogo.

En su primera corrida, el linter encontró **3 violaciones de fuente única que
ningún subagente había reportado.**

**La regla que sale de eso:** el linter es el artefacto que crece — cada clase
determinista nueva se codifica ahí antes de volver a delegarla. Los subagentes
son desechables y se reservan para el juicio.

## Anti-objetivos

- Delegar a un subagente lo que el linter puede decidir.
- Dejar que el subagente implemente los fixes (diagnostica, no ejecuta).
- Re-invocar al mismo subagente para verificar sus propios fixes.
- Declarar un sprint cerrado sin re-corrida.
