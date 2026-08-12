---
status: provisional
source: "[[Geografía y Ciudades]] §El Encuentro con Roen (estructura ratificada 2026-08-07) + [[Los 3 Links de los Fijos]] §Roen (Second Catch, provisional — pendiente de QA del domingo) + [[Roen-Ficha-Expandida-v1]] §Escena 1. Regla de tráfico de [[Current-State]]: todo guión que toque un Link de los Fijos se trata como provisional hasta la ronda del domingo."
updated: 2026-08-07
---
# Encuentro con Roen (Acto 1, cierre del tutorial de Los Desfiladeros de Zephyr)

> Primer guión jugado del juego (no bookend — ver [[Guion/Apertura — Roen Viejo]]
> para eso). Continúa directo del tramo solo post-title-card
> ([[Geografía y Ciudades]] §Los Desfiladeros de Zephyr). Diálogo en
> inglés (regla 9 del repo); el resto del archivo en español. Concept
> art de referencia: [[Briefs de Concept Art]] §15.1-15.3 (entorno) y
> §16 (`zephyr-ambush-roen-arrival-v1.png`, ya ratificado — el staging
> de la emboscada de abajo calca esa lámina: los 3 Hollowed, el terreno,
> Roen entrando en cuadro. La lámina congela el instante previo al
> contacto ("the catch hasn't happened yet") — es el keyframe de la
> **llegada** de Roen, no del remate en sí; el momento exacto del
> catch/lanzamiento es [[Briefs de Concept Art]] §14.1,
> `roen-second-catch-v1.png`, referencia visual del link en general).

## Puesta en escena

Sigue directo del tramo solo tras el title card "AETHER BOUND" — el
jugador se acerca al punto ya acordado con Roen (la contratación es un
hecho previo, ver [[Roen-Ficha-Expandida-v1]] §Escena 1). El terreno varía por
raza (árido en Aethelgard, volcánico en Ignis Reach, boscoso en
Stillwood — §15.1/15.2/15.3), pero el blocking de la escena es idéntico
en las 3: los 3 Hollowed cierran el paso, Roen entra en cuadro justo
cuando lo hicieron. Roen no es visible hasta su entrada.

## Guión

```
[Player continues alone along the trail — same solo movement as before
the title card. No dialogue, no music cue change yet.]

The trail narrows. [Environment beat varies by race — arid canyon bend /
volcanic switchback / root-choked slope, matching §15.1-15.3.]

A low growl. Not wind. Not an animal either — off.

Three HOLLOWED break cover, closing in from three different angles,
cutting off retreat. [Staging matches zephyr-ambush-roen-arrival-v1.png.]

[GAMEPLAY: combat begins. Player fights the 3 Hollowed alone. The
encounter is tuned to feel unwinnable solo — no dialogue during this
stretch, system-driven.]

[TRIGGER: player's HP/stagger threshold reached, or a scripted timer —
whichever the systems team locks. At that exact moment:]

FOOTSTEPS — fast, heavy, from the trail behind.

ROEN enters, already moving.

--- ROLE VARIANT A: DUELIST / STRATEGIST (modo estándar) ---

Roen closes the distance in two strides, grabs the nearest Hollowed by
the collar of its rags, and swings it bodily into the player's line of
attack — off-balance, exposed, close enough to finish.

ROEN
Yours.

[GAMEPLAY: a short input window opens. **Duelist:** the player presses
the melee button to land the finisher with the race's base weapon
([[Armamento Base — Matriz Raza x Rol]]: double-bladed sword for Elfo,
war pick & hammer for Enano, scimitar + parrying dagger for Humano) —
this one deals the killing blow, bonus damage/impact from the link.
**Strategist:** no killing blow — the celda's control action lands on
the thrown Hollowed instead and neutralizes it (Elfo: Tether Arcano
marks it, yanked off-balance and out of the fight; Enano: hand cannon's
marking round staggers and tags it for the rest of the group to finish;
Humano: signal horn detonates the trap underfoot, net pins it down).
The Hollowed still goes down
in the same beat, just not from the Strategist's own hit — coherente
con [[Acoplamientos]] (ratificado): el Strategist no inflige daño
directo, controla. Remate a nivel de rol, no una sola coreografía para
las 6 celdas Duelist+Strategist (decisión de Boris, 2026-08-07, ver
[[LOG]]:7876-7881). Second Catch T1, thrown-enemy flavor. If the window
is missed, this is NOT a fail state — the Hollowed falls back into the
normal fight, the player just doesn't get the link's bonus effect
([[Los 3 Links de los Fijos]] §Roen, "Ventana de remate"). Roen turns to
the other two Hollowed without waiting to see the finish land — he
already knows it will.]

--- ROLE VARIANT B: VANGUARD (rol duplicado) ---

Roen doesn't grab the player and doesn't grab an enemy — he plants
himself back-to-back with them, off-hand coming up in a bare-knuckle
guard, like he already knew where they'd be standing. No shield: he
still fights this bare-handed, same as every fight until T3 ([[Los 3
Links de los Fijos]] §Roen, T3 "Nothing Borrowed").

ROEN
Hold here. I've got what's behind you.

[GAMEPLAY: "doble ancla" — both anchor the same ground, fighting outward
in opposite arcs, matching stance. Neither retreats.]

--- END VARIANTS ---

[GAMEPLAY: the remaining Hollowed fall — whichever combination the role
variant left standing.]

The last one drops. Silence, except for both of them breathing hard.

Roen looks the player over once — not checking for wounds, checking
whether they're still standing on their own. They are.

He doesn't smile. No hand offered if they're already up. Just a short
nod — the kind you give someone who did the job, not the kind you give
a stranger.

ROEN
Told myself you could handle yourself before I took this job. Wasn't
wrong.

(beat)

That's the last easy stretch of this road. Figured you should know now,
not later.

He's already turning to walk on before finishing the sentence — not
rude, just a man who's said his piece.

ROEN (CONT'D)
Come on. Long way to [Rivermeet / Emberdeep / Stillspire — swap by
race].

[Player falls into step beside him. No further dialogue — the walk
toward the home city continues in silence, the tutorial's established
rhythm.]
```

**Modo estándar único para Duelist y Strategist, sabor "lanza a un
enemigo" (decisión de Boris, 2026-08-07, 2ª pasada).** **La acción de
Roen** no cambia por rol — solo Vanguard tiene un modo distinto ("rol
duplicado"). **Lo que sí se divide por rol es la respuesta del jugador:**
la ventana de remate ([[Los 3 Links de los Fijos]] §Roen).
Duelist conecta un golpe, Strategist resuelve con su acción de control, y
Vanguard no tiene ventana en T1. Precisado 2026-08-11: este párrafo
decía "el link no cambia por rol" y la fuente dice "split por rol",
hablando de cosas distintas con formulaciones opuestas. Tal
como ya fijaba [[Geografía y Ciudades]] §El Encuentro con Roen, punto 5
de la lista. Dos correcciones sobre el primer borrador de este archivo:
(1) el split Duelist/Strategist que inventaba dos coreografías de Roen
distintas no tenía base en canon — corregido, ambos roles reciben la
misma acción de Roen; (2) el sabor elegido cambió de "atrapa a media
caída" a **"lanza a un enemigo para que el jugador remate"** — más
simple de producir: una sola coreografía de Roen, y lo único que varía
por celda es la animación del remate (ver nota siguiente), en vez de
necesitar coreografías completas de rescate distintas por raza×rol. El
sabor "atrapa a media caída" (con lámina ya ratificada,
`roen-second-catch-v1.png`, §14.1) sigue vigente como referencia visual
del link *Second Catch* en general — no se descarta, solo no es el que
usa esta escena puntual.

**✅ Verbos de remate por raza×rol — resuelto y ratificado (2026-08-07,
mismo día).** [[Armamento Base — Matriz Raza x Rol]] (`status:
ratificado`) fija arma, verbo y mecánica clave para las 9 celdas, más la
regla transversal de la ventana de input (whiff = se pierde el bonus
del link, no el combate — ya incorporada arriba y en [[Los 3 Links de
los Fijos]] §Roen). **El remate de esta escena puntual sigue escrito a
nivel de rol, no de celda** (Duelist = melee, Strategist = acción a
distancia de su propia celda) — restaura la decisión original de Boris
(2026-08-07, [[LOG]]:7876-7881), perdida en un borrador intermedio que
generalizaba "melee" a las 6 celdas Duelist+Strategist. Coherente con
[[Acoplamientos]] (ratificado): el Strategist no inflige daño directo.

**Jugador sin línea de diálogo hablada.** Ninguna fuente fija
explícitamente "protagonista silencioso", pero [[Bond y el Bond Vacío]]
establece el silencio como el beat más fuerte del juego, y la viñeta
muda del jugador en [[Guion/Apertura — Roen Viejo]] ya usa el mismo
recurso. Este guión sigue ese patrón por consistencia — **asunción de
diseño, no regla escrita, a confirmar con Boris antes de generalizarla
al resto del guión de actos.**

**"Told myself... wasn't wrong" — corregido 2026-08-10 (2ª pasada).**
La versión anterior ("Contract said you could handle yourself") usaba
"Contract" de forma ambigua con el Contrato de Conquistador del Triune
Council (que firma el jugador, [[Guion/Apertura — Roen Viejo]]) — tres
lecturas distintas convivían en el vault (ver [[LOG]]). Reescrita para
que sea inequívocamente el juicio personal de Roen, no una cita de
documento: confirma en pantalla que ya se conocían y que Roen aceptó el
trabajo confiando en eso ([[Roen-Ficha-Expandida-v1]] §Escena 1,
§Conexión con el jugador) — no la contratación en sí, que sigue sin
mostrarse.

**Tono de la primera línea de Roen — verificado.** "Competente sin
fanfarria, asiente, no aplaude" ([[Roen-Ficha-Expandida-v1]] §Escena 1,
citado también en [[Geografía y Ciudades]] §El Encuentro con Roen, punto
6 de la lista). El nudo de la escena post-combate (ni sonrisa, ni mano ofrecida, un
solo gesto de reconocimiento) es la dramatización directa de esa nota.

## Pendiente

- **`status: provisional`** hasta la ronda de QA del domingo — toca
  *Second Catch*, que sigue provisional en [[Los 3 Links de los Fijos]].
- No escrito todavía: el tramo de caminata silenciosa hacia la ciudad
  natal, y la escena en la taberna donde se suma Valen
  ([[Geografía y Ciudades]] §Beats Narrativos por Acto, locación 1;
  decisión de Boris, 2026-08-10) — es la escena siguiente, fuera de
  alcance de este archivo.
