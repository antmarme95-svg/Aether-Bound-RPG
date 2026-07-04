> **🧊 v2.2 CONGELADO (2026-07-04).** Este documento es la fuente *raw*
> inmutable del reseteo creativo — no se edita más. **La verdad viva del
> diseño está en el Vault: `Aether Bound/` (empezar por `SCHEMA.md` y
> `20-State/Current-State.md`).**

# GDD v2.1 — AETHER BOUND ✅

*(Título canónico sellado 2026-07-03. "Vanguards & Voidcores" retirado con
honores; "Speck" reservado como rostro del marketing — tráiler/corto.)*

> **Documento maestro de diseño.** Reemplaza la dirección narrativa del slice
> "Vanguards & Voidcores" (README). Consolida el reseteo creativo iniciado en la
> conversación de dirección (2026-07) + todo lo rescatable del prototipo Godot.
>
> **Leyenda de estado:** ✅ decidido · 🔶 propuesto (pendiente de aprobación del
> director) · ❓ abierto (falta decidir).
>
> Fase actual: **diseño/producto**. Nada de este documento toca código todavía.

---

## 0. Visión en una frase

✅ Un Action RPG de mundo abierto donde **no eres el elegido**: eres un
mercenario leal a tu cultura que, a través de un grupo disfuncional de cinco y
una criatura que nadie quiere, **desaprende esa lealtad** — hasta que tu mano
derecha te traiciona por convicción, no por maldad.

### Pilares (los 4 filtros de toda decisión de diseño)

| # | Pilar | Qué significa en la práctica |
|---|---|---|
| 1 | ✅ **La desilusión del héroe** | La historia no es salvar el mundo; es descubrir que tu sociedad no es tan buena como creías. Toda misión empuja hacia esa fricción moral. |
| 2 | ✅ **El Fellowship es el gameplay** | Sin ultimates. La mecánica central son los **acoplamientos** (link-mechanics estilo It Takes Two): dos personajes que se necesitan para resolver combate y traversal. La traición debe doler *en los controles*. |
| 3 | ✅ **Asimetría por fisionomía** | Raza × Rol cambia cómo te mueves y peleas (matriz 3×3). Un Enano Duelist y un Elfo Duelist son juegos distintos. |
| 4 | ✅ **Mundo con temperamento** | Cada ciudad/cultura tiene personalidad legible en arquitectura, ritmo de NPCs y forma de resolver conflictos (eje Avatar: TLA). |

### Referencias de tono

✅ Melancólico y épico (BotW/TotK) **+** vibrante y caótico con ciudades vivas
(Arcane, Vox Machina). Madurez irreverente, no grimdark.

---

## 1. Historia

### 1.1 El mundo — "La Era del Gran Cisma Arcano" ✅

Hace ~100 años una guerra de dioses destruyó el orden antiguo. El mundo
civilizado sobrevive bajo una tregua frágil liderada por el **Consejo de los
Tres Reinos**. En **The Wilds** — la tierra de nadie que separa (y conecta) a
los tres reinos — la naturaleza reclama ruinas divinas, y los **God-Cores**
(núcleos corruptos de los dioses muertos) enloquecen a la fauna. *Nota de
diseño: esto es lo que el mundo CREE — la verdad está en §2.4 y es la
revelación central del juego.*

### 1.2 Estructura dramática ✅

**Acto 1 — Lealtad.** Firmas un **Contrato de Conquistador** en la oficina de
reclutamiento de tu ciudad natal. Crees en tu cultura. Tu misión: entrar a The
Wilds y purgar nidos/apagar God-Cores.

- **Incidente incitante (protagonista):** te ordenan purgar un nido de
  "Bestias del Aether" (plaga oficial). Al llegar descubres que no son
  animales: son guardianes de un God-Core que está *estabilizando* el
  ecosistema local. El juego real empieza cuando eliges **no matar al último
  espécimen — la Criatura**. Te vuelves prófugo.

**Acto 2 — Comunidad.** Se forma el quinteto disfuncional (§3). Encuentros con
"el otro" (las otras razas) revelan que **tu propia cultura es responsable de
la degradación del ecosistema**. El grupo aprende lealtad, solidaridad,
compañerismo — el arco Fellowship del Señor de los Anillos con la fricción de
Vox Machina.

**Nudo — El Fragmento de la Verdad.** El grupo recupera un artefacto que
revela que la Criatura es la **llave para resetear el Aether del mundo**:
salvaría el ecosistema, pero borraría la civilización actual. (Y peor: hay
evidencia de que la Criatura es *también* origen de degradación en otras
regiones — una verdad parcial, diseñada para dividir al grupo.)

**Clímax — La Traición por Convicción.** El **Compañero 3** (tu mano derecha,
quien te enseñó a ver el mundo) concluye: *"para que millones vivan, esto debe
morir"* — y actúa. No es malvado; es la versión de ti que eligió la lógica
sobre el vínculo. Debes elegir entre detenerlo (¿matarlo?) para salvar a la
Criatura, o dejar que rompa tu corazón.

- **Regla de oro:** la traición se siente **mecánicamente**. El Compañero 3 se
  lleva el Fragmento (que era un dispositivo de acoplamiento): tus habilidades
  combinadas desaparecen, el personaje se siente más pesado, más lento, más
  solo. **Orfandad mecánica.**

### 1.3 El gancho interno ✅

Conflicto permanente entre: **beneficio propio** (contrato, estatus) ↔
**nuevos valores** (los vínculos del quinteto y la Criatura) ↔ **desilusión**
(tu sociedad no era lo que creías). Cada decisión mayor del juego tensa al
menos dos de esos tres polos.

---

## 2. Universo y ambientación

### 2.1 Estética ✅

**Aetherpunk medieval**: magia cruda (Aether) usada como combustible
tecnológico (tuberías, motores de vapor) en naturaleza exuberante. Cel-shaded
BotW con atmósfera madura. (El pipeline visual ya existe en el build Godot:
toon ramp, inverted-hull outlines, aerial perspective, biome presets.)

### 2.2 Las tres razas y su temperamento ✅

| Raza | Arquetipo | Hábitat | Eje de personalidad (Avatar) |
|---|---|---|---|
| **Elfos** | Etéreos, soberbios, confiados; la vida es eternidad, minimizan lo efímero | Corazón de The Wilds, difícil acceso; arquitectura orgánica suspendida ("templo de cristal silencioso") | Intelectual / desapegada — lógica sobre emoción |
| **Enanos** | Toscos, burdos, extremadamente dignos y tercos; trabajo manual | Faldas del bosque, junto a volcán/gran montaña; arquitectura vertical excavada ("corazón de metal ruidoso") | Pasional / leal — la terquedad como preservación cultural |
| **Humanos** | La raza joven: imprudente, adaptable, destructiva del ecosistema | Tierras bajas fértiles junto al gran río (modelo Sena: ciudades que nacen del agua); "hormiguero de comercio y desperdicio" | Caótica / ambiciosa — motor de cambio y de problema |

- ✅ **Mapeo con el prototipo (resuelto vía §6.1):** **Aether-Born → Elfos**
  (rim teal, mana veins — encaja natural), **Iron-Blooded → Enanos** (forjas,
  chispas, armadura de hierro — encaja natural), y el kit **Mist-Stalker** se
  reinterpreta como **the Mistbound**: subcultura humana fronteriza (Driftfolk
  del Driftmarket). El reino humano (the Restless) recibe fenotipo propio;
  nada del prototipo se tira.

### 2.3 Geografía — The Wilds como Gran Conector ✅

The Wilds no es mapa de relleno: es **arteria y frontera** entre los tres
reinos, y el lugar donde el juego *exige* cooperación:

- **Río Aethelgard (eje humano):** cruces que requieren puentes del Tank o
  plataformas del Strategist; separarse = el río te arrastra (castigo mecánico
  legible).
- **Montaña de Hierro / Volcán Ignis (bastión enano):** pendientes donde el
  Strategist ancla al grupo mientras el Duelist limpia el camino.
- **Bosque Profundo (santuario elfo):** visibilidad nula; el Strategist lleva
  la luz/visión. *Si tu mano derecha es Strategist y te traiciona aquí, te
  quedas a oscuras en el lugar más peligroso del juego.*

### 2.3b Mapa macro — "La Rueda" ✅ (ratificado)

**Estructura: regiones conectadas alrededor de un centro abierto** (no mundo
abierto absoluto — decisión de pacing y de escala de producción). El mundo es
una **rueda**: The Wilds es el cubo abierto estilo BotW; los tres reinos son
el aro; tres **arterias** los conectan al centro, y cada arteria ES su
mecánica cooperativa (§2.3) — progresión metroidvania-lite por links, no por
llaves.

| Región | Qué es | Mecánica / beat que vive ahí |
|---|---|---|
| **The Wilds** (cubo) | El bosque inmenso, lúgubre, melancólico que une los reinos | Exploración libre; El Nido; campamentos (UI de bonds); cores/cadáveres |
| **Reino Humano** (aro) | Capital fluvial en el Aethelgard — hormiguero de comercio y desperdicio | Origen humano; Standing alto se gasta aquí; quests de Maren/Iven/Bram |
| **Bastión Enano** (aro) | Vertical, excavado a las faldas del Volcán Ignis | Origen enano; quests de Torgan/Dagna/Vekka |
| **Santuario Elfo** (aro) | Suspendido en el corazón del bosque, acceso difícil | Origen elfo; quests de Sereth/Lyris/Nyael |
| **The River Road** (arteria humana) | El Aethelgard navegable | Co-op: puentes del Tank / plataformas del Strategist; el río castiga separarse |
| **The Cinder Ascent** (arteria enana) | Paso de montaña empinado | Co-op: anclaje en pendientes; criaturas que caen de las rocas |
| **The Gloomvault** (arteria elfa) | Bosque profundo, visibilidad nula | Co-op: el Strategist lleva la luz — el peor lugar para perderlo |
| **The Driftmarket** | Ciudad flotante de barcos amarrados, mercado negro **neutral** (rescatado del lore previo "Nómadas de la Niebla") | Terreno franco para prófugos; recluta de C4 (el Bufón); momento de Speck "el enviado del Consejo"; donde Standing y Bond chocan de frente |
| **The Sunken Archive** | Bóveda de la civilización de los dioses, hundida bajo el corazón de The Wilds | Dungeon del **Fragmento de la Verdad**; la traición ocurre al salir |
| **The First Wound** | El cráter donde la Muda se rompió hace 100 años: un **cementerio de God-Cores** — el giro §2.4 hecho paisaje | Zona final: clímax y los 4 finales. El jugador camina entre lo que creía ruinas y ahora sabe que son cuerpos |

**Los Desfiladeros de Zephyr** (tutorial §3.3) = el primer tramo de *tu*
arteria de origen (un template de diseño, tres skins culturales — economía de
producción).

#### Beats sobre el mapa por acto ✅

- **Acto 1 (tu gajo de la rueda):** tu capital (creación + Contrato) → tu
  arteria/Desfiladeros (tutorial solo + encuentro con C1) → The Wilds: El
  Nido (incidente incitante, Speck) → te vuelves prófugo. C2 se une en la
  arteria (fricción inmediata); **C3 aparece al volverte prófugo — el único
  que elige ayudar a un fugitivo**; C4 se recluta en el Driftmarket.
- **Acto 2 (la rueda completa):** los otros dos reinos abren — el "encuentro
  con el otro" es literalmente viajar el aro. Ahí viven las quests
  personales (1 por compañero por acto), los ~7 momentos de Speck (bautizo en
  campamento, primer puente estadio 2, el enviado en el Driftmarket…), y la
  evidencia de que **tu** cultura degrada el ecosistema (cada reino tiene su
  pecado visible desde el reino vecino). Cierre: el Sunken Archive → Fragmento
  → **traición** → misión del Bond vacío en tu propia arteria (el camino que
  mejor conoces, ahora vacío).
- **Acto 3 (el centro del centro):** perseguir/entender a C3 → decisión de la
  rueda entera reaccionando (los tres reinos movilizan ejércitos hacia The
  Wilds) → **The First Wound**: clímax + finales.

❓ Pendiente: asentamientos secundarios por región; distancias/tiempos de
viaje; fast travel (¿diegético — barcazas del Driftmarket?).

### 2.4 La Criatura — "Speck" ✅

#### Naturaleza (la gran revelación del juego)

La Criatura es la última **Custodia**: la especie de constructos biológicos
que la civilización de los dioses creó para *cuidar el Aether del mundo*
(sabor Horizon Zero Dawn — arqueología viviente, no OVNIs).

**El secreto que reescribe todo el lore:** los **God-Cores no son núcleos de
dioses muertos — son los cadáveres calcificados de Custodios adultos**,
muertos a mitad de "la Muda del Mundo" (el gran reset del Aether) cuando la
guerra de dioses los masacró. La Muda quedó a medias: por eso los cores
supuran Aether corrupto y enloquecen a la fauna. Cada core que las facciones
mandan "apagar" — cada core que el jugador destrozó en el Acto 1 — **era un
cuerpo de su especie.** El incidente incitante gana una segunda lectura
retroactiva: las "bestias" no custodiaban un núcleo, custodiaban la crisálida
de la última cría.

**El giro Grogu ("no es tan bebé"):** emocionalmente es una cría — juega,
imita, se encariña — pero carga la **memoria de especie**: a veces dice o hace
algo con un conocimiento imposible de la era de los dioses. No es un bebé de
un animal; es la infancia de un dios menor de mantenimiento.

**El dilema del clímax (lo que revela el Fragmento):** si madura, **terminará
la Muda** que quedó inconclusa hace 100 años. Eso sanaría el ecosistema… y
podría borrar la civilización actual. C3 lee eso y concluye. El jugador
apuesta a la tercera lectura: una Muda completada *con vínculo* — guiada, no
salvaje — podría ser distinta. Nadie sabe quién tiene razón hasta el final.

#### Por qué nadie la quiere ✅

- **Elfos:** abominación mágica, burla a la naturaleza etérea.
- **Enanos:** tecnología que respira — un insulto "impuro" a la artesanía.
- **Humanos:** el botín definitivo, herramienta de poder.

Los cinco la protegen *y* cada uno la querría para un fin distinto (venderla /
estudiarla / liberarla).

#### Crecimiento visible en 3 estadios ✅ (decisión: crece rápido, se aprecia en una partida)

| Estadio | Acto | Aspecto | Gameplay |
|---|---|---|---|
| **1 — La Cría** | Acto 1 | Pequeña, luminosa, la cargas | Pasiva: reacciona al mundo (olfatea Aether, se eriza ante peligro = radar diegético) |
| **2 — El Vínculo** | Acto 2 | Adolescente, torpe, del tamaño de un lobo | **Fuente de acoplamientos nuevos**: su Aether "puentea" interfaces — habilita combos entre miembros que no acoplan entre sí, y links directos con el jugador. Se desbloquean por momentos de vínculo (jugar, alimentar, side quests), no por XP |
| **3 — El Espejo** | Nudo → Clímax | Sus patrones se cristalizan **idénticos a los God-Cores rojos** que destruiste | El jugador ve a su amiga; C3 ve el apocalipsis creciendo. Tras la traición, sus links amortiguan *parcialmente* la orfandad mecánica — nunca la reemplazan del todo (agridulce por diseño) |

#### El bautizo ✅

- ✅ **La nombra el comic relief del quinteto** (el slot C4, "la Chispa" — §3.1)
  y el equipo adopta el nombre. Escena de bautizo: la cría estornuda chispas y
  le quema las cejas/barba al Bufón, que sentencia: *"no es más que una mota
  con opiniones."*
- ✅ **Un solo nombre canónico, nueve escenas distintas:** aunque el Bufón
  varía según tu quinteto, todos convergen en el mismo nombre por chistes
  diferentes (identidad de marca + rejugabilidad de la escena).
- ✅ **Idioma primario del juego: inglés** (nombres canónicos en inglés).
- ✅ **Nombre canónico: "Speck."** Línea del bautizo: *"It's nothing but a
  speck with opinions."* Humilde, tierno, monosílabo gritable en combate; el
  ser que puede resetear el mundo se llama Speck — el contraste ES el chiste
  y ES el tema. En el endgame, el Consejo la llama por su nombre antiguo
  (**"the Warden"**) y el grupo insiste en "Speck": **el nombre es el
  vínculo.**

---

## 3. El Quinteto Disfuncional (sistema de compañeros)

### 3.1 Estructura ✅

| Slot | Función narrativa | Función mecánica |
|---|---|---|
| **Jugador** | Define raza + rol | Celda de la matriz 3×3 |
| **Compañero 1 — El Afín** | Misma cultura; comunicación fácil; te da confianza | Complementa tu rol (si eres Tank, es tu Support) |
| **Compañero 2 — El Opuesto** | Choque cultural total; fricción y crecimiento | Rol/estilo antagónico al tuyo |
| **Compañero 3 — El Pivote** | El mediador; quien te abre los ojos; tu mano derecha; **el futuro traidor** | El que mejor domina el acoplamiento contigo — su partida rompe tu forma de jugar |
| **Compañero 4 — La Chispa (comic relief)** | El bufón del grupo; alivia la fricción C2/C3; **bautiza a la Criatura** (§2.4) | Completa la matriz de roles del quinteto |
| *+1 — La Criatura ("Speck")* | El corazón del arco; no es "compañera", es la razón del grupo | Estadio 2+: fuente de acoplamientos nuevos y puente entre miembros (§2.4) |

- ✅ **El quinteto = 5 contando al jugador** (jugador + C1–C4; la Criatura es
  el +1 no-combatiente que se vuelve puente). La matriz de roles 1 Vanguard /
  2 Duelists / 2 Strategists se reparte entre los cinco *incluyéndote*. (Nota:
  versiones previas contaban 5 compañeros + jugador; queda corregido así.)

- ✅ **Matchmaking orgánico:** el juego lee tu origen/raza/clase y asigna el
  quinteto (dinámica Han Solo–Chewbacca: complemento táctico + choque
  cultural).
- ✅ **El Pivote es función del jugador, nunca fijo.** C3 no es "un Elfo
  Strategist": es siempre un personaje **contrastante** con tu elección
  inicial (raza distinta, rol co-dependiente del tuyo). Es tu antítesis y tu
  némesis final — el deuteragonista del juego.
- ✅ **9 Pivotes únicos (bespoke)** — uno por cada celda jugador (raza×rol).
  Las parejas raza-a-raza se eligen **caso por caso** por máximo drama (no hay
  ciclo forzado; se permiten repeticiones de raza).
- ✅ **Constantes de diseño del Pivote:**
  1. Nunca es de tu raza; su rol es co-dependiente del tuyo (su partida =
     orfandad mecánica específica y nombrable).
  2. Te enseña la virtud que tu cultura no tiene — y su traición usa
     exactamente esa virtud en tu contra.
  3. ✅ El *sabor* de la traición lo dicta su raza: **Humano** traiciona por
     pragmatismo de supervivencia · **Enano** por deber/dogma · **Elfo** por
     lógica utilitaria fría.

### 3.1b Matriz de Pivotes ✅ (v1 aprobada; nombres provisionales hasta pase de naming de personajes)

| Jugador | Pivote (C3) | Lo que te enseña | Sabor de su traición | Orfandad mecánica al perderlo |
|---|---|---|---|---|
| **Elfo Duelist** | **Maren** — Humana Strategist (gadgeteer fluvial) | Improvisación, calidez, reírse del desastre | Pragmatismo: descifra el Fragmento y vende el plan al Consejo para salvar su ciudad ribereña | Sin sus redes/marcas, tu precisión arcana pierde el 'setup': dañas a la mitad |
| **Elfo Strategist** | **Torgan** — Enano Duelist (misil humano) | La dignidad del trabajo, la palabra empeñada | Deber: su código concluye que la Criatura debe morir | Pierdes tu proyectil — la Balística Arcana; marcas que ya nadie golpea |
| **Elfo Vanguard** | **Iven** — Humano Duelist (acróbata) | Espontaneidad, apetito de vivir | Pragmatismo ambicioso: la Criatura es el botín que redime a los suyos | Rediriges y contienes… pero ya nadie remata: combate de desgaste eterno |
| **Enano Duelist** | **Sereth** — Elfo Strategist (manipulador) | Perspectiva, soltar la terquedad | Lógica fría: "millones contra uno" | Vuelves a ser ciego: sin marcas ni guía, tu carga es fuerza bruta sin blanco |
| **Enano Strategist** | **Bram** — Humano Vanguard (brawler) | Riesgo, humor, cuerpo por delante | Pragmatismo: se cansa de ser el escudo de guerras ajenas | Tus torretas quedan sin frontline que las proteja: eres cristal |
| **Enano Vanguard** | **Lyris** — Elfa Duelist (trazadora aérea) | Ligereza; el muro aprende a mirar el cielo | Lógica fría, dicha con serenidad insoportable | Nadie vuelve a usar tus plataformas: tu solidez se convierte en soledad |
| **Humano Duelist** | **Dagna** — Enana Vanguard (muralla) | Constancia, lealtad, raíces | Deber: desmonta el nido que juró proteger | Pierdes tu trampolín sísmico: se acabó la verticalidad, peleas a ras de suelo |
| **Humano Strategist** | **Nyael** — Elfa Duelist (hoja que atraviesa tus campos) | Paciencia, precisión, silencio | Lógica fría: ejecuta la conclusión antes de discutirla | Tiendes redes que ya nadie atraviesa: tu 'setup' no tiene 'execution' |
| **Humano Vanguard** | **Vekka** — Enana Strategist (ingeniera) | Oficio, dignidad del detalle | Deber/dogma del gremio | **Desmonta lo que construyó para ti**: pierdes armadura/mejoras — orfandad literal |

### 3.1c Fichas de Pivotes v0 ✅ (aprobadas v0 — revisión final antes del cierre del GDD)

Regla de escritura: las 9 traiciones son **reacciones distintas a la misma
verdad** (la Muda, §2.4) — ninguna repite el beat de otra. Cada ficha: concepto
· qué te enseña · su quiebre · línea de voz muestra (inglés).

**Maren** — Humana Strategist (jugador: Elfo Duelist). Ingeniera fluvial de
chatarra; ríe bajo presión, repara lo irreparable. Te enseña calidez e
improvisación. *Quiebre:* es quien descifra el Fragmento (la tinkerer del
grupo) y hace las cuentas: su ciudad ribereña no sobrevive una Muda salvaje —
le vende el plan al Consejo. — *"I can love her and still do the math."*

**Torgan** — Enano Duelist (jugador: Elfo Strategist). Tu misil humano; tosco,
de pocas palabras, deuda de honor. Te enseña la palabra empeñada. *Quiebre:*
un **Juramento de Forja** anterior al grupo lo obliga: lo que amenace a los
tres reinos debe ser destruido. No discute; cumple. — *"An oath doesn't care
how I feel about you."*

**Iven** — Humano Duelist (jugador: Elfo Vanguard). Acróbata callejero,
hambre de vivir; escribe su nombre en la espalda de los enemigos que tú
contienes. Te enseña espontaneidad. *Quiebre:* su asentamiento muere de
corrupción de core; el Consejo le ofrece la cura a cambio de Speck. Traiciona
por los suyos, no contra ti. — *"You'd trade her for strangers? I'm trading
her for everyone I've ever known."*

**Sereth** — Elfo Strategist (jugador: Enano Duelist). Sereno, arrogante que
se ablanda; tus ojos en el caos. Te enseña perspectiva, soltar la terquedad.
*Quiebre:* aritmética pura, dicha con afecto — lo que lo hace insoportable. —
*"Millions against one. You taught me stubbornness is love, friend. This is
me being stubborn about millions."*

**Bram** — Humano Vanguard (jugador: Enano Strategist). Mercenario de gran
corazón, cuerpo por delante de tus torretas. Te enseña riesgo y humor.
*Quiebre:* agotamiento — lleva veinte años sangrando por guerras ajenas; el
Consejo le ofrece la libertad de su compañía por Speck. — *"I've been
everybody's wall. Just once, let me be the door."*

**Lyris** — Elfa Duelist (jugador: Enano Vanguard). Trazadora aérea que usa
tu cuerpo anclado como plataforma; risa serena. Te enseña ligereza — el muro
aprende a mirar el cielo. *Quiebre:* lógica fría con una calma que hiere más
que un grito. — *"You were my stillness. Be still now."*

**Dagna** — Enana Vanguard (jugador: Humano Duelist). Tu trampolín sísmico;
raíces, constancia, memoria larga. Te enseña lealtad. *Quiebre:* la ley de su
clan — *lo que amenaza la montaña, se deshace* — pesa más que el nido que
juró proteger. Llora mientras lo hace. — *"The mountain doesn't forgive. And
I am the mountain's."*

**Nyael** — Elfa Duelist (jugador: Humano Strategist). La hoja silenciosa que
atraviesa tus campos; casi no habla. Te enseña paciencia y precisión.
*Quiebre:* **ejecuta la conclusión antes de discutirla** — una noche el
Fragmento no está, y ella tampoco. Su traición es una ausencia. — *(nota
encontrada)* *"You taught me to set the trap and wait. I could not wait."*

**Vekka** — Enana Strategist (jugador: Humano Vanguard). Ingeniera de gremio
que construye tu armadura pieza a pieza. Te enseña el oficio, la dignidad del
detalle. *Quiebre:* dogma del gremio — *"a flawed forging must be unmade by
its maker."* Desmonta tu equipo con sus propias manos antes de irse: la
orfandad mecánica literal. — *"I built you. Forgive me for finishing the
job."*

❓ Pendiente: biografías completas, arcos por acto, diseño visual, y las
tablas de C1/C2/C4 por celda.

### 3.2 Roles de co-dependencia (sin ultimates) ✅

- **Duelist (el filo):** daño pleno solo sobre marcas/debilidades aplicadas
  por un Strategist.
- **Strategist (el ojo):** no daña; manipula entorno (gravedad, tiempo,
  marcas, visión).
- **Vanguard/Tank (el ancla):** gestiona el espacio; genera "aura de
  seguridad" y terreno utilizable; el equipo se mueve con él.

### 3.3 Acoplamientos firmados (Fellowship Bonds) ✅

Las tres parejas fundadoras (hoy viven canónicamente como links de Pivote en
§3.4: Arcane Ballistics, Seismic Springboard, The Weaver's Net):

1. **Elfo Strategist + Enano Duelist — "Balística Arcana":** el Elfo marca un
   punto; el Enano se convierte en misil humano contra esa marca. El Enano es
   ciego sin guía; el Elfo, indefenso sin músculo.
2. **Humano Duelist + Enano Tank — "Trampolín Sísmico":** el golpe de suelo
   del Enano crea onda/fisura; el Humano usa esa inercia para saltos/impulsos
   imposibles en solitario.
3. **Humano Strategist + Elfo Duelist — "La Red del Tejedor":** el Humano
   tiende campos/redes de Aether; el Elfo los atraviesa con su dash y
   electrifica sus hojas (setup & execution).

- ✅ **Principio del tutorial geográfico:** el mundo enseña el acoplamiento
  antes que cualquier texto. Zona de referencia: **Los Desfiladeros de
  Zephyr** — Zona A (solo, movimiento básico) → Zona B (obstáculo imposible
  sin tu primer compañero: la roca que uno no puede romper y el vacío que el
  otro no puede saltar).

### 3.4 Los 9 acoplamientos del Pivote ✅ (lo que la traición te quita)

Cada link tiene **setup + execution**, sirve en combate *y* traversal, y su
pérdida es la orfandad mecánica de §3.1b. Nombres canónicos en inglés.

| Jugador + Pivote | Link | Cómo funciona | Al perderlo |
|---|---|---|---|
| Elfo Duelist + Maren | **Skipping Stone** | Maren lanza discos-boya flotantes (anclas aéreas); tú encadenas dashes y disparos rebotando entre ellos, cada disco redirige tu trayectoria. Traversal: cruzar ríos/abismos saltando sus boyas | Te quedas sin anclas: un arquero aéreo condenado al suelo |
| Elfo Strategist + Torgan | **Arcane Ballistics** ✅ | Tú marcas un punto; Torgan se convierte en misil humano contra la marca. Traversal: él rompe lo que tú señalas | Marcas que ya nadie golpea |
| Elfo Vanguard + Iven | **Riposte Runner** | Tu escudo cinético no absorbe — redirige; Iven "surfea" tus paradas: cada golpe que rediriges es su vector de lanzamiento al flanco. Traversal: lo catapultas | Tus paradas vuelven a ser solo defensa: combate de desgaste eterno |
| Enano Duelist + Sereth | **Guided Avalanche** | Tu carga es imparable pero no gira; Sereth dobla gravedad/terreno para *curvarla* — tú eres la avalancha, él la pendiente. Traversal: alarga tus saltos bajando tu gravedad | Fuerza bruta sin blanco: vuelves a ser ciego |
| Enano Strategist + Bram | **Mobile Foundry** | Bram carga tus desplegables encima (torreta al hombro, escudo-taller): él pelea, tu tecnología dispara desde su cuerpo; te compra el tiempo de construcción | Eres cristal: nadie protege tu setup |
| Enano Vanguard + Lyris | **Skyhook** | Tú te anclas; ella se ata a ti y describe arcos aéreos a tu alrededor (cinta en el poste), golpeando en el ápice; puedes tirar del tether para redirigirla. Traversal: ella sube la línea, tú la tensas de cabrestante | Nadie vuelve a usar tu firmeza: tu solidez es soledad |
| Humano Duelist + Dagna | **Seismic Springboard** ✅ | Su golpe de suelo crea onda/fisura; tú usas la inercia para triple salto o impulso imposible | Se acabó la verticalidad: peleas a ras de suelo |
| Humano Strategist + Nyael | **The Weaver's Net** ✅ | Tú tiendes redes/campos de Aether; ella los atraviesa con su dash y electrifica sus hojas (setup & execution) | Tiendes trampas que nadie atraviesa |
| Humano Vanguard + Vekka | **Warforging** | En pleno combate te atornilla módulos (guanteletes ígneos, placas de ariete): cada módulo cambia tu verbo de brawler. Traversal: te convierte en ariete/taladro | Ella los desmonta al irse: pierdes verbos del cuerpo |

- ✅ **Regla post-traición:** Speck (estadio 3) puede "puentear" una versión
  *degradada* del link perdido — funciona distinto, se siente distinto, y
  cada uso te lo recuerda. Nunca es igual de bueno. Agridulce por diseño.

### 3.5 Control de compañeros ✅ (ratificado)

**Sistémico + un solo botón de vínculo. Cero menús de órdenes.**

- Los compañeros combaten **autónomos según su rol** (el Vanguard ancla, los
  Duelists flanquean, los Strategists marcan/manipulan).
- El jugador tiene **un único input contextual — "Bond"**: cerca de una
  oportunidad de acoplamiento (el mundo la telegrafía: la roca marcable, el
  abismo, la horda densa), mantener Bond inicia el link con el compañero
  relevante. Sin pausas tácticas, sin ruedas de comando.
- Justificación: la memoria muscular del vínculo (§ pilar 2) solo se forma si
  el acoplamiento es un gesto físico repetido, no una orden de menú. Y la
  traición debe sentirse en el pulgar: aprietas Bond y no responde nadie.
- ❓ Abierto: ¿ping/marca manual opcional para dirigir foco? ¿Bond mapea a
  quién cuando hay dos links posibles?

#### 3.5b "El Bond vacío" — beat obligatorio post-traición ✅

La escena del **miembro fantasma**, ratificada como momento diseñado (no
emergente):

1. **Preparación invisible (todo el juego):** cada link exitoso con el Pivote
   dispara un micro-flourish — la **Link Cam** (barrido de cámara de ~1s que
   celebra el acoplamiento) + su sting musical propio. El jugador lo ve
   cientos de veces; se vuelve gramática.
2. **La trampa amorosa (primera misión post-traición):** el diseño de nivel
   coloca deliberadamente el obstáculo firma del link perdido — la roca
   marcable de Torgan, el abismo de boyas de Maren, la pared de Dagna. El
   prompt de Bond aparece por memoria muscular del propio juego.
3. **El silencio:** el jugador pica Bond. La **misma Link Cam** hace el mismo
   barrido… sobre el espacio vacío donde esa persona ya no está. El sting
   musical arranca y muere a las dos notas. Sin música de fondo. Los
   compañeros restantes te miran; nadie dice nada. Speck gimotea. La cámara
   vuelve al hombro sin corte.
4. **Regla de dirección:** el dramatismo sale de **reusar el lenguaje de la
   celebración sobre la ausencia** — no de una cutscene nueva. Cuanto más
   idéntico al flourish feliz, más duele.
5. **Eco final (estadio 3 de Speck):** la primera vez que Speck puentea la
   versión degradada del link, la Link Cam regresa — pero encuadra a Speck
   *imitando la postura* del Pivote perdido. Funciona. No es lo mismo. El
   sting suena en otra tonalidad.

---

## 4. Matriz Raza × Rol (temperamento mecánico) ✅

(Los arquetipos Marvel son orden de magnitud, no licencia.)

| Raza \ Rol | Duelist (daño/acción) | Vanguard/Tank (frontline/control) | Strategist (soporte/utility) |
|---|---|---|---|
| **Elfo** | *Precisión arcana* (~Hawkeye): movilidad aérea, largo alcance, ataques que dejan rastro | *Escudo cinético* (~Dr. Strange): no absorbe — **redirige** con campos de fuerza | *Manipulador psíquico*: altera posiciones de aliados/enemigos, controla el campo |
| **Enano** | *Tanque ofensivo* (~Punisher): arma pesada, poco movimiento, daño contundente constante | *Muralla móvil* (~Hulk): control de área físico, "tunea" el terreno, su cuerpo es obstáculo | *Ingeniero*: torretas, drones, buffs de armadura |
| **Humano** | *Híbrido ágil* (~Black Panther): combos, encadena acrobacias | *Brawler callejero*: usa el entorno, agarres, improvisación | *Gadgeteer* (~Peter Parker): hooks, redes, trampas experimentales |

- ✅ **Locomoción por fisionomía** (ya implementada y aceptada en Godot,
  PRD-005): perfiles 9-cell — masa, slide por momentum, air-control, crouch
  stealth. Heavy = proyectil imparable en bajadas; Light = maniobrabilidad
  aérea. **Esto se conserva íntegro.**
- 🔶 Los 9 sub-estilos con VFX ya implementados (Spell-Blade, Scrap-Slinger,
  Shadow-Stalker, Arcane Aegis, Juggernaut, Pack-Leader, Chrono-Weaver,
  Thermite, Blood-Shaman) se re-mapean a las celdas de esta tabla — renombrar
  donde el sabor ya no cuadre.

### 4.1 Sistema de locomoción — spec v1 ✅ (ratificada con el principio §4.3)

**Arquitectura: FSM de estado único** (ya implementada y validada en el
prototipo — PRD-003/005). Estados: `Idle · Walking(crouch) · Running ·
Sprinting · Sliding · Airborne · Landing` **+ nuevos:** `Mantling ·
Climbing_Idle · Climbing_Moving`. Entradas/salidas estrictas por estado
(ej.: `Sliding` solo desde `Sprinting` + input de agacharse — regla ya viva).

#### Ya construido y aceptado (NO se rehace — se conserva del prototipo)

| Mecánica | Estado |
|---|---|
| Sprint táctico con drenaje de stamina + cooldown de exhaustión | ✅ vivo (BotW-style, tuning aceptado) |
| Slide: impulso ∝ masa, decay por coeficiente de fricción, cápsula baja, heading recto del sprint | ✅ vivo (tuning aceptado en playtest) |
| **Momentum chaining / "supersalto"**: slide→jump transfiere 0.90 del vector de velocidad al estado aéreo | ✅ vivo (L2) |
| Interrupts ≤1 tick: atacar/ADS/soltar-forward cancelan sprint y slide | ✅ vivo (L3) — equivale al `bCanShoot=false` del spec visto del otro lado: sprint y arma son mutuamente excluyentes |
| Fisionomía 9-cell: masa, air-control, crouch-stealth, fricción por subclase | ✅ vivo (L0) |
| Crouch squat + crouch-jog | ✅ vivo (L6, aceptado) |

#### Nuevo — Mantling / Vaulting 🔶

- Detección por 2 raycasts horizontales paralelos (pecho + cabeza): pecho
  impacta y cabeza no ⇒ superficie trepable.
- Física OFF durante el mantle; interpolación (lerp) del personaje al punto
  superior, sincronizada con la animación; sale a `Running`.
- **Integración fisionomía:** Heavy mantlea más lento pero puede mantlear
  bordes más altos (fuerza); Light encadena mantle→salto sin pausa.

#### Nuevo — Escalada estilo BotW (superficies etiquetadas) 🔶

- **Decisión de diseño (anti-BotW deliberada): NO todo es escalable.** Solo
  superficies con capa/tag `Climbable` (enredaderas, roca rugosa, tuberías de
  Aether). Razón: la escalada libre total rompe el gating de La Rueda; la
  escalada zonificada lo *diseña* — **el acceso "difícil" al Stillwood (§2.3b)
  es literalmente un muro de enredaderas**: la ciudad elfa se gana escalando.
- Mecánica: alineación a la normal de la pared (`-Hit.Normal`); gravedad
  anulada; input proyectado al plano de la pared (vertical = world-up,
  lateral = cross(normal, up) — rodea curvas sin despegarse).
- **Stamina:** drenaje en movimiento, casi nulo en idle; **climb-jump** con
  costo fijo alto; a stamina 0 → caída forzada + bloqueo de reenganche hasta
  tocar suelo. (Reusa la economía de stamina ya tuneada del sprint.)
- **Integración fisionomía (9-cell):** Heavy drena más rápido y no tiene
  climb-jump (trepa como tanque: lento, seguro); Light drena menos y su
  climb-jump cubre el doble (el Mist/duelist "vuela" por la pared); Balanced
  al medio. **Elegir raza cambia qué montañas son tuyas.**
- **Integración links:** Skyhook (Lyris) y Seismic Springboard (Dagna) son
  atajos de escalada — el Vanguard que no puede trepar alto es *lanzado*;
  co-op como sustituto de stat, fiel al pilar 2.

#### Regla transversal ✅

**Conservación del impulso en TODA transición** (ya probado en slide→jump):
la velocidad nunca se resetea a cero al cambiar de estado — se lee el vector
actual y se transfiere (total o porcentual) al estado entrante. Mantle y
climb-jump heredan esta regla.

❓ Pendiente: valores iniciales de las variables nuevas (ClimbSpeed,
StaminaClimbDrain, StaminaJumpCost, alturas de mantle por masa) — se tunean
con el método montage+playtest ya establecido; superficie `Climbable` en el
lenguaje visual de la Art Bible (las enredaderas deben *leerse* — ej. acento
saturado sutil sobre el pastel).

### 4.2 Sistema de combate — spec v1 ✅ (ratificada con el principio §4.3)

#### A. Arquitectura adoptada ✅ (genérica, data-driven, agnóstica de motor)

Cuatro componentes modulares en TODO personaje (jugador, compañero, enemigo):
**CombatComponent** (combos, input buffer, ventanas por AnimNotify, cargados)
· **GuardComponent** (bloqueo, parry, barra de **Equilibrio**/postura) ·
**EnergyComponent** (recurso de habilidades = **Aether**) ·
**PushPullComponent** (impulsos y tracciones vectoriales). Datos externos:
`WeaponData` (hitbox, DamageProfile salud/equilibrio, combo set) y
`AbilityData` (costo, ExecutionType). Resolución de impacto por **HitPayload**
(Daño, DañoEquilibrio, VectorFuerza, Interrupción). Encaja con la filosofía
del prototipo (JSON/Resources + FSM).

#### B. Reglas canónicas de acople (donde la arquitectura toca el canon)

1. **Las marcas son datos:** la regla de co-dependencia (§3.2 — el Duelist
   solo daña pleno sobre marcas del Strategist) se implementa como campo
   `MarkMultiplier` del HitPayload. Sin marca ⇒ multiplicador reducido. La
   dependencia del Fellowship vive en la tubería de daño, no en scripts
   especiales.
2. **Los links SON PushPull:** Arcane Ballistics, Seismic Springboard,
   Skyhook, Riposte Runner… todos son casos del PushPullComponent (impulsos
   y tracciones sobre *aliados*). Un solo sistema físico para combate, links
   y traversal — coherencia técnica y de feel.
3. **El Equilibrio nace de la masa:** la barra de postura se deriva del
   perfil 9-cell ya existente (Heavy = torre de Equilibrio difícil de
   romper; Light = frágil de postura pero difícil de golpear). Fisionomía y
   combate comparten fuente de datos.
4. **Parry con sabor racial** (el time-slow global `TimeScale 0.2` + stun del
   atacante es transversal — primer canon *sensorial* del combate):
   - **Elfo — Redirige:** el parry desvía el golpe/proyectil (inversión de
     vector, cambio de facción). El proyectil enemigo se vuelve tuyo.
   - **Enano — Absorbe:** el parry no desvía: *planta*. Anula el empuje,
     roba el DañoEquilibrio del atacante (su postura se agrieta, la tuya se
     refuerza).
   - **Humano — Roba:** el parry improvisa: desarma, agarra el brazo, usa el
     impulso del rival en su contra (Push con el VectorFuerza del atacante).
5. **Sprint↔arma ya es ley** (§4.1 interrupts): atacar cancela sprint/slide
   el mismo tick; el combate y la locomoción comparten FSM.
6. **Speck estadio 2+:** sus puentes se expresan como `AbilityData`
   adicionales inyectados al kit — los links degradados post-traición son
   los mismos assets con parámetros reducidos (§3.4).

#### C. La matriz de combate 3×3 (verbos por celda)

| Celda | Verbos dominantes | Perfil técnico |
|---|---|---|
| **Elfo Duelist** | Combos aéreos + dash-attack como *blink* hacia la marca; cargado = disparo perforante | CombatComponent aéreo; propulsión hacia objetivo fijado |
| **Elfo Vanguard** | Parry-redirect como verbo central; su "bloqueo" es un campo que devuelve | GuardComponent maestro; parry de proyectiles canónico; alimenta Riposte Runner (la fuerza redirigida = vector de lanzamiento de Iven) |
| **Elfo Strategist** | Pull/Push de masas (gravedad), marcas, recolocación de aliados | PushPullComponent sobre enemigos Y aliados; casi cero DamageProfile |
| **Enano Duelist** | Cargados rompe-guardias, combo corto y demoledor, alto DañoEquilibrio | Charged attacks; DamageProfile volcado a Equilibrio |
| **Enano Vanguard** | Bloqueo-muralla, ground-pound (Push en cono — el mismo del Springboard), cuerpo-obstáculo | GuardComponent + PushPull de área; Equilibrio máximo del juego |
| **Enano Strategist** | Torretas (leen WeaponData propio), buffs de Equilibrio/armadura a aliados | EnergyComponent + despliegue; sus buffs suman postura, no daño |
| **Humano Duelist** | Las cadenas de combo más largas del juego; input buffer generoso; momentum de locomoción alimenta el daño | CombatComponent maestro; ventanas de conexión amplias; sinergia con slide/leap |
| **Humano Vanguard** | Agarres, empujones, armas improvisadas del entorno (WeaponData intercambiable en caliente) | PushPull cuerpo a cuerpo + pickup de props; brawler adaptativo |
| **Humano Strategist** | Redes/trampas de tracción (Pull zonal), campos que ralentizan, gadgets de Aether | PushPull desplegable + EnergyComponent; prepara la pista (Weaver's Net) |

#### D. Semillas sensoriales del combate (para §6.3)

- **Parry:** time-dilation global 0.2 + sting (variación del leitmotiv de dos
  notas — la gramática sonora del Bond invade el combate).
- Ya vivo en el prototipo y se conserva: FOV-kick de sprint, landing stutter,
  cam-thump de aterrizaje.
- ❓ Por definir: hit-stop por peso de arma (más ms para el martillo de
  Torgan que para las dagas de Nyael), screen-shake budget, y la cámara de
  combate (lock-on vs. libre — decisión pendiente).

❓ Pendiente: DamageProfiles iniciales por celda; diseño de enemigos contra
esta arquitectura (los enemigos usan LOS MISMOS 4 componentes — un enemigo
"parry-able" se lee por su animación); tuning por montage+playtest.

### 4.3 Principio rector: "Movilidad realista sobre gráfico perfecto" ✅

**Mandato del director (2026-07-03):** el cuerpo importa más que el pixel. Los
rangos de movimiento, grados de libertad y articulaciones deben ser
biomecánicamente creíbles — la estilización vive en el *render* (Art Bible),
nunca en el *esqueleto*.

#### Reglas del esqueleto (todas las razas)

- **Articulaciones anatómicas con límites reales (joint constraints):**
  hombro = rótula 3-DOF con rango humano; codo y rodilla = bisagra 1-DOF (no
  hiperextienden salvo raza que lo justifique); muñeca/tobillo = 2-DOF;
  columna segmentada (el torso rota por vértebras, no como bloque); cadera
  3-DOF. **Nada rota donde un cuerpo no rota.**
- **Transferencia de peso real:** todo golpe/salto/frenado nace en la cadera
  y se encadena (cadera→torso→hombro→brazo). Sin wind-ups imposibles.
- **IK como estándar:** pies que se plantan en el terreno inclinado, manos
  que agarran la enredadera/el borde real del mantle — no animaciones
  "flotadas" sobre el mundo.
- El prototipo ya sembró esto (gait procedural con rodillas/codos/tobillos
  articulados, squat con flexión real de cadera — L5/L6, aceptado): se
  profundiza a IK completo con constraints, no se reemplaza.

#### ROM (rango de movimiento) por raza — la fisionomía hecha esqueleto

| Raza | Biomecánica | Consecuencias visibles |
|---|---|---|
| **Enano** | Palancas cortas, hombros masivos con ROM limitado (el brazo NO pasa cómodo sobre la cabeza), centro de gravedad bajo, cadera potente, squat profundo natural | Ataques horizontales y de cadera (arcos bajos, giros de torso); trepa con pasos cortos y seguros; su cargado es rotación de cadera, no molinete; imposible de desequilibrar, incómodo en lo alto |
| **Elfo** | Hipermovilidad controlada: rangos amplios, sobre-extensión elegante, columna flexible, zancada larga, tobillos de bailarín | Patadas/cortes altos, aterrizajes absorbidos en silencio, esquives que doblan la cintura como junco; en escalada estira alcances que otros no tienen; frágil ante el agarre (palancas largas = palancas en su contra) |
| **Humano** | **El ROM humano estándar ES la referencia** del rig; transferencia de peso atlética, versátil en todos los planos | El movimiento "que se siente correcto" por familiaridad; ni los arcos bajos del enano ni los altos del elfo, pero encadena planos (agarre→giro→golpe) mejor que ambos |

#### Aplicación directa

- **Combate (§4.2):** los arcos de ataque y wind-ups DERIVAN de los límites
  articulares — el moveset de cada celda 3×3 se anima desde su esqueleto, no
  al revés. Las dagas de Nyael trabajan en rango muñeca-codo; el martillo de
  Torgan, en cadera-torso.
- **Locomoción (§4.1):** el alcance de brazo real dicta qué agarres de
  escalada existen para cada raza (Heavy alcanza menos, Light estira más);
  el mantle usa la cadena hombro-codo verdadera; el squat/crouch ya cumple.
- **Animación:** prioridad de producción = rig con constraints + IK >
  cantidad de animaciones. Un esqueleto correcto hace creíbles 20
  animaciones; uno falso arruina 200.

---

## 5. Progresión y estructura de mundo

- ✅ **El Contrato de Conquistador** deja de ser solo prólogo: es un sistema
  que *te persigue* (reputación, cazadores, cláusulas). Ser prófugo tiene
  mecánica.
- ✅ **Loop principal (borrador):** explorar The Wilds → encontrar
  acoplamientos/recursos → fortalecer vínculos del quinteto → misiones que
  tensan lealtad vs. valores → avanzar el arco hacia el Fragmento.
- ✅ Sistema de vínculos: resuelto — **"The Tether"** (§5.2). Rastrea bond por
  compañero y los "momentos de persona" de Speck que gatean el Final 4.
- ❓ Progresión de personaje (skills, equipo, crafting) — sin definir en v2.

### 5.1 Finales ✅ (los 4 ratificados) — "¿Quién carga con la verdad?"

Los tres finales principales son **los tres polos del gancho (§1.3) ganando**;
el cuarto es la síntesis ganada, no elegida. El clímax físico (detener o no a
C3) abre el abanico, pero el final lo determina **qué haces con Speck
después**. Regla de dirección transversal: cada final cierra con su propio
eco del lenguaje Bond/Link Cam (§3.5b) — el botón cuenta la historia.

**1. The Guided Molt** *(ganan los nuevos valores)* — Detienes a C3 y apuestas
a la tesis del jugador: una Muda **guiada con vínculo** no borra, transforma.
El quinteto (lo que quede de él) ancla a Speck durante la Muda. El mundo
cambia: el Aether sana, las civilizaciones pierden su combustible mágico y
deben reinventarse — renovación con costo, no final feliz gratis.
*Variante:* si perdonaste a C3 (no lo mataste), regresa en el anclaje — su
convicción invertida: *"Be stubborn about millions, then. I'll hold the
line."* — *Eco Bond:* el anclaje final es un **multi-link**: cada pulsación de
Bond en la secuencia llama a *todos* a la vez. El inverso exacto del Bond
vacío.

**2. The Long Winter** *(gana la desilusión)* — No detienes a C3 (o no llegas
a tiempo): Speck muere o es entregada al Consejo. La civilización se salva…
por ahora: los cores siguen supurando, el mundo sigue pudriéndose despacio.
Compraste tiempo, no futuro. El quinteto se disuelve; te conviertes en lo que
eras en el Acto 1 — alguien que dejó que las órdenes decidieran. *Eco Bond:*
epílogo años después, en un páramo que fue bosque: el prompt de Bond aparece
por costumbre. Lo picas. Nada. Créditos.

**3. The Conqueror's Clause** *(gana el beneficio propio — ruta villano)* —
Traicionas a todos mejor que C3: entregas o encadenas a Speck tú mismo y
cobras el poder — el Contrato de Conquistador cumplido hasta su última letra.
Te vuelves el nuevo poder del Consejo (o su dueño). Los compañeros te
abandonan uno a uno, cada uno con la despedida de su cultura. *Eco Bond:*
picas Bond por hábito en tu trono; el único icono que responde es Speck —
encadenada. El espejo oscuro del §3.5b.

**4. The Warden's Choice** *(la síntesis — final "verdadero", ganado)* —
Desbloqueado solo con bond alto y los "momentos de persona" de Speck
completos (§5 requisito). En el clímax rechazas la premisa de todos — elfos,
enanos, humanos y C3 querían *usarla o eliminarla*; tú eres el primero que
**le pregunta**. Speck, con su memoria de especie, elige: una Muda parcial —
se calcifica voluntariamente en un **God-Core vivo** que estabiliza el mundo
sin borrarlo… al precio de dejar de ser Speck. El Consejo bautiza al nuevo
núcleo "the Warden". El grupo talla **SPECK** en su base. *Eco Bond:* años
después, ante el núcleo: picas Bond… y responde un sting débil de dos notas —
**la melodía que murió en el Bond vacío, completada en otra tonalidad.**

- ✅ Nota de estructura: 1–3 se eligen; 4 se *gana* (la elección aparece solo
  si jugaste el vínculo). Rejugabilidad: el género emocional del clímax ya
  varía por Pivote (§3.1c); los finales varían por filosofía.
- ❓ Abierto: estado post-final jugable (free roam) por final; duración de
  epílogos; si C3 muerto/vivo modifica también 2 y 3.

### 5.2 Sistema de vínculos — "The Tether" ✅ (ratificado)

Dos medidores visibles en tensión + un contador oculto. El gancho (§1.3)
hecho maquinaria: beneficio propio y nuevos valores tiran de dials opuestos;
la desilusión emerge de ver cuál elegiste alimentar.

**A. Contract Standing (beneficio propio).** Tu posición ante tu reino y el
Consejo. Sube cumpliendo cláusulas (reportar cores, entregar especímenes,
purgar). Compra: equipo, salvoconductos, estatus legal (bajar tu nivel de
prófugo), acceso a ciudades. *UI diegética: el propio pergamino del Contrato,
con cláusulas selladas.* Muchas acciones que suben Standing **cuestan Bond**
(reportar un core = vender el cadáver de un pariente de Speck) — la tensión
es visible en el momento de la decisión.

**B. Bond por compañero (nuevos valores).** Regla anti-grind central: el bond
**no se compra con regalos ni diálogos farmeables** — crece por (1) **uso
real de los links** en combate/traversal, (2) escenas de campamento, (3) la
quest personal de cada compañero (1 por acto). Tope de bond por acto: las
relaciones necesitan tiempo de historia, no farmeo.

- **Tiers = profundidad mecánica.** T1: link básico → T2: variante avanzada
  del link → T3: link perfeccionado + escena firma. **La intimidad ES el
  árbol de habilidades.** Corolario brutal: si llevaste a C3 a T3, la
  traición te quita más — el juego te castiga por amar bien, que es el tema.
- *UI diegética: sin números.* El icono del botón Bond por compañero es un
  cordón trenzado que gana hebras (T2/T3) — **la UI es el botón** (§3.5b
  reúsa esto: el cordón de C3 aparece deshilachado tras la traición). En el
  campamento, la cercanía física de los personajes al fuego refleja los
  bonds (legible sin menús).
- La escena de traición lee el bond: con C3 en T3 hay duda en su ejecución
  (deja algo atrás — el objeto firma de su quest personal); en T1 es más
  fría. Variante de matiz, no branch.

**C. Momentos de Persona de Speck (oculto, sin medidor).** ~7 escenas fijas a
lo largo de los actos donde puedes tratarla como *herramienta, mascota o
persona* (alimentarla tú vs. delegarlo; preguntarle antes de usar su puente
vs. ordenárselo; defenderla del enviado del Consejo; el bautizo mismo).
**Deliberadamente sin UI:** la personitud no se cuantifica — regla temática.
Gate del Final 4: mayoría de elecciones "persona" + ≥2 compañeros vivos en
T2+ → en el clímax aparece la opción de **preguntarle**.

- ❓ Abierto: lista definitiva de los ~7 momentos; economía exacta de
  Standing (qué compra en cada acto); si el Standing alto habilita contenido
  exclusivo de la ruta Conqueror (final 3).

---

## 6. Look & Feel

> Las dos líneas de abajo (paleta por reino, ciudades con ritmo) siguen
> vigentes como *reglas de contenido*; la dirección visual formal vive en la
> **Art Bible §6.2**. Pendiente: **Game Feel Bible** (§6.3, por escribir) —
> cámara, peso, respuesta. La **decisión de motor (Godot vs. Unreal) sigue
> DIFERIDA** hasta tener ambas biblias + el vertical slice.

- ✅ Cel-shaded con paleta por reino: cristal/teal etéreo (elfos), hierro/ámbar
  volcánico (enanos), madera/piedra/mercado ribereño (humanos). Peligro = ROJO
  (lenguaje ya establecido con los God-Cores).
- ✅ Ciudades con ritmo propio: festivales ruidosos humanos, silencio
  meditativo elfo, percusión industrial enana. Los NPCs tienen rutinas
  culturales, no solo tiendas.
- ❓ Dirección de audio/música — sin empezar. (Semilla ya canónica: el sting
  de dos notas del Bond como leitmotiv del juego entero — §3.5b, §5.1.)

### 6.1 Identidad y nomenclatura ✅ (sellada)

**Título del juego: `AETHER BOUND`.** Ya vive en el BACKLOG del repo, y con el
GDD v2 gana triple lectura: *bound* = atado por el Aether (la Muda), atado por
el vínculo (the Tether/Bond), y rumbo a ("bound for") The Wilds. El botón se
llama Bond y el juego se llama Bound: la mecánica está en la portada.
*(Alternativas si se quiere re-abrir: Tetherbound · The First Wound · Speck.)*

| Cosa | Nombre canónico ✅ | Nota |
|---|---|---|
| Cultura élfica | **the Aether-Born** | Reuso del prototipo — encaja intacto |
| Cultura enana | **the Iron-Blooded** | Reuso del prototipo — encaja intacto |
| Cultura humana | **the Restless** | Cómo se llaman a sí mismos (orgullo de movimiento/ambición); los elfos los llaman *"the Brief"* (efímeros — el desdén hecho apodo) |
| Reino humano | **Aethelgard** | Nombrado por su río, como los reinos históricos fluviales |
| Capital humana | **Rivermeet** | Donde el río se trenza; el hormiguero |
| Reino enano | **the Ignis Reach** | Las faldas del volcán |
| Capital enana | **Emberdeep** | Vertical, excavada |
| Reino elfo | **the Stillwood** | El corazón silencioso del bosque |
| Capital elfa | **the Stillspire** | El templo-aguja de cristal (resuena con Lyris: *"you were my stillness"*) |
| El Consejo | **the Triune Council** | — |
| La especie de Speck | **the Wardens** | Ya canónico (§2.4) |
| El reset del Aether | **the World-Molt** ("the Molt") | En español del doc: la Muda |
| Subcultura fronteriza | **the Mistbound** | Reuso de Mist-Stalker: humanos fronterizos y Driftfolk del mercado flotante — resuelve el ❓ de §2.2 |

- ✅ Con esto, el ❓ del mapeo Mist-Stalker→Humanos (§2.2) se cierra así: el
  *reino* humano es Aethelgard/the Restless; el **kit visual Mist-Stalker**
  del prototipo pasa a ser la subcultura **Mistbound** (fronterizos del
  Driftmarket) — nada se tira, todo se re-usa.

### 6.2 Art Bible — "Melancolía Gráfica" ✅ (ratificada 2026-07-04, anti-referencias incluidas)

**Referencias canónicas:** Sable (silueta, línea, luz/sombra, atmósfera) ·
Breath of the Wild (color, saturación, perspectiva aérea) · Dungeons of
Hinterberg (energía urbana, semitonos, acentos saturados).

**La frase-norte:** *una novela gráfica pintada a mano en acuarela* — la
firmeza del dibujo lineal (ligne claire/Moebius) conviviendo con la
volatilidad de la luz natural (impresionismo BotW).

#### Los 5 ejes

| Eje | Regla | Referencia |
|---|---|---|
| **Silueta / proporción** | Estilizada, legible, sin realismo; el espacio vacío es protagonista — los personajes se leen como figuras de cómic contra paisajes inmensos | Sable |
| **Línea** | Tinta negra nítida en primer plano; **el grosor/opacidad lo controla la profundidad**: a media distancia la tinta se agrisa ("el pincel se queda sin tinta"), en el horizonte desaparece | Sable × BotW |
| **Luz / sombra** | Cel de **3–4 escalones fijos** con bordes *jitter* (temblor procedural) — sombras de pincel seco sobre papel, ni los 2 tonos duros de Sable ni el degradado sutil de BotW | Híbrido |
| **Color / saturación** | Base: saturación media-baja, tono "lavado" acuarela (el Hyrule melancólico); **cambios drásticos de paleta por hora del día** (ocres/rosas de día → azules neón/violetas al anochecer, herencia Sable) | BotW × Sable |
| **Atmósfera / post** | Perspectiva aérea: lo lejano pierde contornos internos y se vuelve **silueta plana azul pastel**; aire con peso físico (Rayleigh), glowing edges a contraluz; grano de papel en pantalla | BotW × Sable |

#### La regla espacial — el registro sigue a La Rueda 🔶

La dirección de arte tiene **función narrativa**: el mundo cambia de registro
gráfico según dónde estás (§2.3b):

- **The Wilds + arterias (el cubo):** registro **Sable×BotW** — melancolía
  pastel, inmensidad, línea que se desvanece, silencio visual. El bosque
  lúgubre y épico.
- **Ciudades del aro (Rivermeet, Emberdeep, Stillspire, Driftmarket):**
  registro **Hinterberg** — la línea se engrosa, entran **semitonos/tramas**
  (halftone), los acentos saturados explotan (el rojo del teleférico), más
  densidad de detalle por metro. La ciudad *grita* gráficamente igual que
  grita culturalmente (pilar 4: Arcane/vibrante).
- **Transición diegética:** al viajar arteria→ciudad, la trama de semitonos
  aparece gradualmente y la paleta gana saturación — el jugador *ve* que
  entra a la civilización sin ninguna UI.
- **Peligro = ROJO saturado** en ambos registros (única constante intocable:
  en el mundo pastel, el rojo del God-Core es lo más saturado del frame).

#### Pipeline técnico (4 capas de post-proceso, screen-space)

1. **Edge detection atenuado por profundidad** (Sobel screen-space, herencia
   Shedworks): línea fina y nítida de cerca; grisácea/ambiental a media
   distancia (controlada por depth buffer); ausente en el horizonte.
2. **Soft quantization cel:** 3–4 bandas de luz fijas con *jitter* sutil en
   los bordes de banda (pincel de cerdas secas).
3. **Iluminación volumétrica + tonemapping:** dispersión Rayleigh (el aire
   pesa), glowing edges alrededor de la tinta a contraluz; contraste suave
   que rescata sombras — el negro de la tinta nunca apaga los pasteles.
4. **Grano de papel + line boil:** textura screen-space de papel de acuarela
   casi imperceptible + distorsión mínima de contornos que cambia cada pocos
   frames (vibración de animación a mano).

- ✅ **Nota de viabilidad (informa la decisión de motor, no la toma):** las 4
  capas son post-proceso screen-space — implementables en Godot (compositor
  effects / shaders de pantalla completa) sin pelear contra el renderer; el
  trabajo es de shader-craft, no de motor. El prototipo actual ya tiene la
  capa 2 primitiva (toon ramp); las capas 1, 3 y 4 son nuevas.
- ✅ **Anti-referencias canónicas**: Genshin Impact (saturación
  caramelo uniforme — mata la melancolía), PBR realista (Witcher/Horizon — 
  mata la novela gráfica), y el look actual del prototipo (cel genérico sin
  línea ni atmósfera).
- ❓ Pendiente: concept art propio (3 keyframes: Wilds al amanecer / Rivermeet
  de día / God-Core de noche); prueba técnica de las 4 capas sobre una escena
  del prototipo ("golden scene" comparativa).

---

## 7. Qué se conserva del prototipo (inventario de rescate)

| Activo del slice actual | Destino en v2 |
|---|---|
| Pipeline visual Godot (toon ramp, outlines, biomas, grass, fog) | ✅ Se conserva tal cual |
| Locomoción PRD-005 (9-cell, slide, crouch, ADS) | ✅ Se conserva tal cual |
| Matriz 3×3 Origen×Clase + VFX de sub-estilos | ✅ Se conserva; re-skin a Elfo/Enano/Humano |
| Character creation (fenotipo, orígenes, clases) | ✅ Se conserva; fenotipos se ajustan a las razas |
| Contrato de Conquistador + oficina de reclutamiento | ✅ Se conserva y se profundiza (§5) |
| Flujo CREATION→OFFICE→CITY_EXIT→WILDS | ✅ Se conserva como esqueleto del Acto 1 |
| "Purga el nido y destruye el Core" como misión completa | ❌ Se reemplaza: ahora es el incidente incitante (descubres que las bestias son guardianes) |
| Choice A/B/C con buffs al final del slice | ❌ Se reemplaza por la decisión de la Criatura (no matar al último espécimen) |
| Roadmap "Vanguards & Voidcores" del README | 🔁 Superado por este documento |

---

## 8. Estado de cierre del GDD

### Cerrado ✅ (los 8 frentes estructurales)

1. **La Criatura** — Speck / the Wardens / la Muda inconclusa / 3 estadios /
   fuente de acoplamientos / bautizo del Bufón (§2.4).
2. **El quinteto y los Pivotes** — estructura C1–C4 + Speck; 9 Pivotes únicos
   con matriz y fichas v0 (§3.1–3.1c).
3. **Acoplamientos** — los 9 links del Pivote con nombre y orfandad (§3.4) +
   regla post-traición.
4. **Control de compañeros** — Bond único contextual + "El Bond vacío"
   (§3.5–3.5b).
5. **Mapa macro** — La Rueda con beats por acto (§2.3b).
6. **El Fragmento de la Verdad** — qué revela (la Muda, §2.4), su rol de
   dispositivo de acoplamiento robado (§1.2) y el post-traición (§3.5b, §3.4).
7. **Finales + vínculos** — 4 finales (§5.1) + The Tether (§5.2).
8. **Identidad** — AETHER BOUND + nomenclatura completa (§6.1).

### Backlog de preproducción (no bloquea el GDD; entra a la fase de planeación)

- Fichas completas de los 9 Pivotes (biografía, arco por acto, diseño visual)
  + pase de naming definitivo de personajes.
- Tablas de C1 (afín), C2 (opuesto) y C4 (bufón) por celda de jugador + sus
  links (y los links directos de Speck estadio 2).
- Lista definitiva de los ~7 Momentos de Persona de Speck; economía exacta de
  Contract Standing; contenido exclusivo ruta Conqueror.
- Desambiguación de Bond con dos links posibles; ¿ping opcional?
- Asentamientos secundarios por región; tiempos de viaje; fast travel
  diegético (barcazas del Driftmarket).
- Estado post-final jugable y duración de epílogos; variantes C3 vivo/muerto
  en finales 2–3.
- Progresión de personaje (skills/equipo/crafting) — hereda scaffolding del
  prototipo.
- Dirección de audio/música (semilla: el sting de dos notas como leitmotiv).
- Diseño visual de Speck (3 estadios) y re-naming de los 9 sub-estilos VFX
  del prototipo donde el sabor ya no cuadre.
- Renombrar el juego en repo/README/strings ("Vanguards & Voidcores" →
  AETHER BOUND) — tarea de la fase técnica.
- **Art Bible (§6.2)** desde referencias visuales del director — escrita,
  pendiente ratificar. **Game Feel Bible (§6.3)** — parcialmente cubierta por
  la spec de locomoción §4.1 (mecánicas); falta el lado *sensorial*: cámara,
  peso/impacto, respuesta, screen-shake/hit-stop.
- Implementación de Mantling + Escalada (§4.1) — nuevos sistemas sobre la FSM
  existente; tuning por montage+playtest.
- Implementación del combate §4.2 (4 componentes + HitPayload) sobre el
  prototipo; DamageProfiles por celda; diseño de enemigos con los mismos
  componentes; decisión de cámara de combate (lock-on vs. libre).
- **Rig biomecánico §4.3:** esqueleto con joint constraints + IK completo
  (pies/manos), 3 variantes de ROM por raza — evolución del rig paramétrico
  actual, prioridad sobre cantidad de animaciones.
- **Decisión de motor** (Godot vs. Unreal) — diferida; se evalúa contra las
  dos biblias y el vertical slice, no antes.

---

*Historial:*
*v2.0 (2026-07-03) — reseteo creativo; consolida la conversación de dirección
(doc Gemini truncado) + inventario del prototipo Godot.*
*v2.1 (2026-07-03) — cierre de contenido: Speck canónica, 9 Pivotes + links,
Bond/Bond vacío, La Rueda, 4 finales, The Tether, AETHER BOUND sellado;
barrido de coherencia; §8 convertido en estado de cierre + backlog de
preproducción.*
*v2.2 (2026-07-04) — **VERSIÓN FINAL BENDECIDA POR EL DIRECTOR.** Añadidos y
ratificados: Art Bible §6.2 "Melancolía Gráfica" (Sable × BotW × Hinterberg,
regla espacial de La Rueda, pipeline 4 capas), locomoción §4.1 (mantling +
escalada zonificada), combate §4.2 (4 componentes + HitPayload + parry
racial), principio §4.3 "movilidad realista sobre gráfico perfecto" (ROM por
raza). El GDD queda cerrado; el trabajo continúa en la fase de planeación de
producción.*
