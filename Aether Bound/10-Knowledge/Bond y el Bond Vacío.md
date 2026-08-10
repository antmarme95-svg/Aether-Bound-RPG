---
status: ratificado
source: "GDD §3.5, §3.5b"
updated: 2026-07-04
---

# Bond y el Bond Vacío

## Control de compañeros

**Sistémico + un solo botón. Cero menús de órdenes.** Los compañeros combaten
autónomos según su rol ([[Acoplamientos]]). El jugador tiene **un único input
contextual — "Bond"**: cerca de una oportunidad telegrafiada por el mundo,
mantener Bond inicia el link con el compañero relevante. Sin pausas tácticas.

Justificación: la memoria muscular del vínculo solo se forma con un gesto
físico repetido. **La traición debe sentirse en el pulgar: aprietas Bond y no
responde nadie.**

## "El Bond vacío" — beat obligatorio post-traición

1. **Preparación (todo el juego):** cada link con el Pivote dispara la **Link
   Cam** (~1s de barrido celebratorio) + su sting musical. Se vuelve gramática.
2. **La trampa amorosa:** la primera misión post-traición coloca el obstáculo
   firma del link perdido ([[Los 9 Links del Pivote]]). El prompt de Bond
   aparece por memoria muscular.
3. **El silencio:** picas Bond. La misma Link Cam barre… el espacio vacío. El
   sting muere a las dos notas. Sin música. Nadie dice nada. [[Speck]]
   gimotea. La cámara vuelve al hombro sin corte.
4. **Regla de dirección:** el dramatismo sale de **reusar el lenguaje de la
   celebración sobre la ausencia** — cuanto más idéntico, más duele.
5. **Eco final:** cuando Speck puentea el link degradado, la Link Cam regresa
   encuadrándola *imitando la postura* del Pivote. El sting suena en otra
   tonalidad. Aplica a las 8 celdas con traición — **no a la celda de Bram**,
   ver excepción abajo.

## La excepción de Bram — el Bond que SÍ responde

**Celda Enano Strategist.** Bram es el único Pivote que **rehúsa traicionar** y se
queda con el jugador hasta el cráter ([[Pivotes/Bram-Ficha-Expandida-v1]]), así que
nunca pierde su link (**Mobile Foundry**) y el beat de arriba no tiene ruta. **No es
un hueco: es la única celda donde el beat se juega invertido.**

1. **Misma preparación, misma trampa.** La primera misión después del corredor del
   Archive coloca el obstáculo firma del Mobile Foundry, exactamente igual que en las
   otras ocho celdas. El jugador ya sabe lo que viene: el juego entero le enseñó que
   después de la traición, ahí es donde el Bond se muere.
2. **Y Bram responde.** Pica Bond esperando el vacío, y la Link Cam barre **y lo
   encuentra**: Bram ya está en posición, cargando los desplegables encima como
   siempre. El sting suena completo. Nadie lo comenta.
3. **Regla de dirección invertida:** el peso no sale de la ausencia sino de **la
   expectativa de ausencia que no se cumple.** El jugador aprieta el botón preparado
   para que le duela. La emoción es el desahogo — un beat que ninguna otra celda
   ofrece, y que en un juego de ocho traiciones (Bram es el único que no traiciona)
   vale precisamente porque es único.
4. **Lo que esto le paga a Bram.** Su superlativo es *"el único que rehúsa"*
   ([[Los 9 Pivotes]]), y hasta ahora eso vivía solo en diálogo. Acá se vuelve
   **mecánica**: la única celda donde el gesto de la pérdida devuelve presencia.
5. **El vacío igual llega, y llega en el cráter.** No hay celda sin pérdida: en la
   ruta Bram el ejecutor es **Torgan como segundo agente**, y lo que se rompe no es
   un link sino la certeza de que rehusar alcanza. Bram rehúsa **y el Council entrega
   igual, con otras manos.** Ese es su costo, y es peor que perder el link.

**Nota de diseño:** el sting completo de este beat **no debe mezclarse** con el sting
truncado de dos notas de las otras ocho celdas. Si el jugador rejuega y los confunde,
la inversión no lee. **Y en esta celda no hay Eco final** (arriba, ítem 5): no hay
link degradado que Speck pueda puentear, porque Bram nunca lo perdió.

El sting de dos notas es el leitmotiv del juego entero; cada final cierra con
su propio eco de este lenguaje ([[Los 5 Finales]]). El cordón trenzado del
botón es la UI de [[The Tether]].

## Resolución de Bond con más de un link posible (council 2026-08-05)

Con los 4 compañeros (3 fijos + Pivote, [[Los 3 Links de los Fijos]]) activos
en pantalla a la vez, el botón único necesita una regla para cuando hay más
de una oportunidad de link telegrafiada al mismo tiempo. Se corrió un council
de 5 perspectivas antes de decidir — la pregunta original ("¿qué opción de
las 3 elegimos?") resultó ser la pregunta equivocada.

**Regla de diseño primaria — va a la fuente, no al síntoma.** Un encuentro
**no debe** generar dos telegraphs de link igualmente válidos y simultáneos,
salvo que sea un dilema narrativo intencional (una escena que explícitamente
quiere que el jugador sienta "no puedo con los dos"). Esto es una restricción
de **encounter/level design** — spacing, timing, composición visual del
telegraph — no un problema que se resuelve en el input. Aplica a quien diseñe
encuentros cuando ADR-003 se destrabe y exista contenido jugable; hoy es
regla escrita, no auditable todavía (no hay vertical slice).

**Sistema de respaldo — solo para el residuo de casos, nunca el sistema
central:**
1. **Proximidad/contexto** dispara el link — el mundo desambigua, no el
   jugador ni una tabla memorizable.
2. **Desempate por urgencia real**, no por rol: si dos oportunidades
   compiten, gana la que tiene la ventana de telegrafía más corta.
3. **Feedback visual post-hoc** cuando el sistema resuelve a favor de uno:
   el jugador tiene que poder ver, después del gesto, que la otra
   oportunidad también estaba ahí — sin esto, cualquier regla se siente
   arbitraria la primera vez que "falla".

**Descartado — no implementar:**
- **Prioridad fija por rol:** memorizable ("el Vanguard siempre gana"), y
  rompe con cada compañero nuevo que se agregue.
- **Ping/marca manual:** un segundo input, aunque sea liviano, convierte el
  gesto en secuencia — viola que Bond sea UN botón y agrega titubeo en el
  instante donde el peso emocional depende de que apretar sea instantáneo.
- **"Caracterización emergente" (compañeros compitiendo por el link vía IA):**
  la idea más atractiva que salió del council y también la más peligrosa —
  si un compañero "se adelanta" o "le roba" el link a otro, el jugador deja
  de poder atribuir el resultado a su propia lectura del campo, y eso
  contamina exactamente el silencio que hace funcionar el beat de traición
  ("aprietas Bond y no responde nadie"). Prohibido para esta mecánica.

**Pendiente (❓):** auditar la frecuencia real de telegraphs simultáneos
ambiguos una vez exista contenido jugable — no ejecutable hoy, sin vertical
slice. → Task-Board.
