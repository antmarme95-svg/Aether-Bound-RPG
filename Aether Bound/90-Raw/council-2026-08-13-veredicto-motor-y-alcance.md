---
status: raw
updated: 2026-08-13
---

# Consejo — 2026-08-13 | Veredicto de motor, alcance de v1 y el trío de Pivotes

> **Qué es esto.** Transcripción del `/llm-council` corrido sobre
> [[Veredicto de Motor y Lectura del Proyecto]], a pedido de Boris.
> 5 consejeros independientes → 3 revisiones por pares anónimas →
> síntesis del presidente. **Es material RAW: opinión, no canon.**
>
> **Nota de método:** la ronda de peer review se corrió con 3 revisores en
> vez de 5 (la primera tanda de 5 murió por límite de gasto). Se conserva
> el anonimato y la aleatorización de letras.

## Las 5 preguntas que se llevaron al consejo

1. ¿Se ratifica Godot sabiendo que la comparación técnica dio **empate** y
   que el argumento fuerte es instrumentabilidad y licencia, no capacidad?
2. ¿Se corta v1 a 3 Pivotes ahora, o se espera al contador de horas?
3. ¿Sobreviven el trío (Bram+Dagna+Vekka) y el desbloqueo de Bram, con
   2 builds en la primera partida?
4. ¿Playtest antes que guión, o al revés?
5. ¿Qué instrumento se construye para medir **diversión**?

---

## VEREDICTO DEL CONSEJO

### Donde el consejo coincide

- **Playtest antes que guión. 5 de 5, sin matices.** Ni una línea nueva de
  guión hasta que exista un prototipo jugable del pilar.
- **Godot se ratifica y se deja de discutir.** Nadie propuso cambiar. La
  regla operativa que salió: **cero re-evaluaciones de motor hasta que
  exista un slice jugable.**
- **El pilar es una hipótesis sin un solo dato.** Cinco consejeros
  independientes llegaron a la misma frase: nadie ha medido que la ausencia
  produzca **duelo** y no simplemente **molestia**.
- **3 Pivotes sigue siendo demasiado para el dato que existe.** Cuatro de
  cinco piden cortar más abajo o construir uno completo primero.
- **La métrica de diversión debe ser contable, no interpretable.** El
  candidato que emergió solo: **pulsaciones del botón de Bond muerto
  después de la pérdida**, y a los cuántos segundos el jugador deja de
  intentar.

### Donde el consejo choca

- **¿1 Pivote o 3?** El Ejecutor y el Contrarian dicen construir **Dagna
  sola**, cronometrada, y dejar que el número decida. El Expansionista dice
  que 3 ya es enfoque suficiente y que la escasez se vende, no se disculpa
  (*"Hades salió con un arma"*).
- **¿Qué se prueba primero, la posesión o la pérdida?** El Outsider fue el
  único en darlo vuelta: *"un poder que nunca fue divertido no duele cuando
  desaparece — se siente como que el juego se arregló"*. Primero hay que
  probar que **tener** a Dagna es adictivo.
- **¿Dónde vive el experimento?** Primeros Principios lo quiere en 2D con
  cubos (más barato, aísla la hipótesis). El Ejecutor lo quiere en Godot 3D
  con cápsulas. Un revisor marcó el límite: un cubo sin vínculo mide un
  **reflejo motor**, no el duelo por un compañero.
- **El desbloqueo de Bram.** Es el único punto donde el consejo se parte al
  medio, y va aparte abajo.

### Los puntos ciegos que atrapó la revisión por pares

1. **El acoplamiento 1:1 Pivote↔build raza×rol es la causa estructural** de
   que cortar cueste builds jugables. Los cinco lo dieron por dado.
   Desacoplarlo cambia toda la aritmética del trío.
2. **Nadie fijó criterio de muerte.** ¿Qué resultado del test te hace
   abandonar el pilar? Medir sin umbral pre-comprometido es confirmación
   disfrazada de método. **Acordar la interpretación del resultado negativo
   ANTES de correrlo.**
3. **El dato de la rampa es costo de curva de aprendizaje, no ritmo
   estable.** La extrapolación "33 años" del Contrarian es mala matemática.
4. **Marketing: el gancho es una ausencia y no se captura en un GIF.** Un
   indie que no se puede mostrar en 6 segundos tiene un problema de
   wishlists, no de diseño.
5. **Audio.** El golpe de la pérdida es 50% sonido, y ninguno de los cinco
   lo nombró. Tampoco el volumen de arte y animación, que es el cuello real
   de un ARPG 3D de un solo autor.
6. **Precedentes gratis:** Brothers, Ico y BT en Titanfall 2 ya validaron
   variantes del pilar. Evidencia sin escribir una línea.
7. **El eje humano.** Sin deadline no hay fecha de fracaso, pero sí burnout
   y crecimiento por default del vault. Y *"cero guión"* ignora que escribir
   es donde el director es rápido y donde se repone. **Cadencia mixta, no
   abstinencia.**

### El desbloqueo de Bram — el único punto partido

**A favor (Expansionista):** no es concesión, es un **verbo de metajuego**.
*"El juego te enseña que la pérdida es la puerta"* es de la familia de lo
que hace de Nier: Automata una obra citada y no un buen action-RPG.
Extensión propuesta: la segunda partida debería **recordar** a quién
perdiste, y el botón de Bond vacío responder distinto.

**En contra (Contrarian, Outsider, Ejecutor):** es la única ruta que **no
entrega el pilar que v1 existe para probar**, cuesta una celda de
producción, y bloquea una build. Y el argumento del Outsider es el más
duro: *"un jugador nuevo no sabe que hay tercera ruta, no conoce Smash Bros
como referencia de diseño; lo que percibe es menos contenido del prometido.
Nadie rejuega para NO perder algo."*

**Un revisor marcó el punto ciego del Expansionista:** elogió el desbloqueo
como diseño brillante **sin un solo playtest**, convirtiendo el síntoma en
virtud.

### La recomendación

**Godot: ratificado y congelado.** Sin más spikes de motor.

**Alcance: no se defiende el 3 como final.** Se construye **Dagna sola,
end-to-end, cronometrada** — un link de 1 tier, no 3 — y de ahí sale la
constante horas/Pivote. Ese número decide si v1 son 3, 2 o 1. El trío queda
en el papel como intención, no como compromiso de producción.

**Bram: la decisión se sostiene, pero por una razón distinta a la que se
tomó.** Como su ruta es la que se desbloquea, es **lo último que se
construye** — o sea que es cortable a costo cero hasta el final. Eso vuelve
la objeción del consejo administrable en vez de fatal: si el número de
horas aprieta, Bram sale y nadie tuvo que rehacer nada. La objeción del
Outsider (el jugador percibe menos contenido, no un misterio) queda como
**riesgo abierto a medir en el playtest**, no como argumento para revertir.

**Playtest antes que guión, con una corrección:** el consejo pide
abstinencia total de escritura; el presidente no. Escribir es donde el
director es rápido y donde recupera energía, y este proyecto no tiene fecha
de fracaso pero sí riesgo de abandono. **Cadencia mixta:** el guión sigue,
pero deja de ser el frente principal y se limita al material del slice.

**El instrumento de diversión** es una sola cosa contable, y se decide su
umbral **antes** de correrlo.

### Lo único que hay que hacer primero

**El test gris del Bond, en Godot, con el criterio de muerte escrito antes
de correrlo.**

Escena gris, cápsula, una cornisa. Dagna reducida a un botón que te lanza
hacia arriba. Diez minutos de juego: cinco con ella, cinco sin ella. Sin
arte, sin diálogo, sin historia. La telemetría cuenta **pulsaciones del
botón muerto frente a la cornisa** y los segundos hasta que el jugador deja
de intentar.

Y antes de dárselo a nadie, escrito en el vault: **qué número significa que
el pilar existe, y qué número significa que no.**

---

**Relacionado:** [[Veredicto de Motor y Lectura del Proyecto]] ·
[[ADR-003 Reset de desarrollo y motor]] · [[Slice of Bond]] ·
[[Benchmark Biomecánico]] · [[Current-State]]
