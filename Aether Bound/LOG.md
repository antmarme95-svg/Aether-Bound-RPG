# LOG — bitácora append-only del Vault

> **Rotado el 2026-09-11** (VAULT-STARTER §4.1). El archivo había llegado a
> **189,939 tokens** en 356 entradas y dejó de poder leerse de una pasada, que
> es justo la función por la que existe. Los tramos cerrados viven en
> `LOG-Archivo/`, **verbatim y sin resumir** — archivar no es comprimir.
>
> | Tramo | Entradas | Peso | Rango |
> |---|---|---|---|
> | [[2026-07]] | 262 | ~113,241 t | 2026-07-04 → 2026-07-31 |
> | [[2026-08]] | 94 | ~76,687 t | 2026-08-02 → 2026-08-24 |
>
> Este archivo conserva el **periodo en curso** (2026-09). Al cerrar un mes,
> su tramo se mueve a `LOG-Archivo/<AAAA-MM>.md` y se registra arriba.
>
> Nota de la rotación: el LOG original **no estaba estrictamente ordenado** —
> un tramo de agosto (entradas del 02 al 10) vivía por debajo de julio. La
> rotación por periodo lo corrige de paso, sin tocar el texto de ninguna
> entrada.

## [2026-09-21] código | Pasada 5: los pectorales estaban tragados — se recuperaron, y el disco sobrevivio

Tercer intento sobre el pecho de frente. **Resultado mixto y hay que decirlo
asi: el fix funciono para lo que midio, y el defecto grande sigue ahi.**

### Lo que cambio el metodo

Los dos intentos anteriores (Pasada 3, deltoides) fallaron por tantear. Este
arranco **midiendo la geometria en vez de mirarla**, y la medicion contradijo
la hipotesis con la que iba a entrar.

**Hipotesis descartada ANTES de escribir codigo.** Iba a aplanar `chest_mass`.
El barrido de la familia de parametros mostro que el intercambio
protrusion↔arista es **monotono**: la arista solo se suaviza cuando la masa
deja de sobresalir, y la protrusion es justo lo que compra el perfil contra
"tabla plana". No es que el fix sea caro — es que **no existe** dentro de esa
familia. Numeros: arista actual 23.7° en y=+0.0079; alargar la masa hacia abajo
la empeora (27.9° → 75.2°) porque el cilindro se angosta al bajar y la masa
tiene que clavarse mas para volver a entrar.

**Segunda hipotesis descartada por ratificacion previa.** El hallazgo **B2** del
libro pide "abdomen como masa propia" y encajaba perfecto: una masa abajo
enterraria la arista. Pero el propio archivo (`character_rig.gd`, bloque
ABDOMEN) tiene una prohibicion explicita — `abs_plate` fallo en **tres
magnitudes distintas** y Boris ratifico "SIN masa elevada" el 2026-07-14,
porque **la lamina no tiene nada que sobresalga ahi**. Es el limite de fuente
que la cabecera de [[Principios de Anatomia 3D]] ya advierte: el libro describe
anatomia real, el proyecto dibuja un estilo. **Gano la lamina.**

### Lo que si encontro la medicion

`pec.scale.z = 0.32` dejaba el frente del pectoral en z=0.1510 y la superficie
de `chest_mass` bajo el en z=0.1507: **0.3 mm de relieve**. El comentario del
propio archivo declara la intencion *"~3mm proud sobre chest_mass"*. O sea que
los pectorales estaban **tragados por la masa de pecho** y el torso no tenia
pectorales encima — solo el disco liso.

Fix: `scale.z` 0.32 → **0.38**, que devuelve los 3.3 mm exactos de la intencion.

**Por que `scale.z` y no `position.z`** (que es lo que el Sprint A6 habia
bajado): en el borde de una elipsoide la contribucion del semieje z es **cero**,
asi que el PERIMETRO no se mueve — solo bombea el centro. El filo superior se
queda clavado en z=0.135 y la "streak crema" que A6 combatio **no se puede
reabrir por construccion**, no por cuidado. Verificado en el render de perfil:
identico, sin "hombrera de futbol".

### Resultado en las tres razas

| | Antes | Despues |
|---|---|---|
| **Valen** (elfo) | pecho liso, una sola masa | **la mejora mas clara** — dos lobulos y el valle esternal |
| **Darro** (enano) | sin definicion | el borde del pectoral ya lee |
| **Roen** (humano) | lobulos apenas insinuados | lobulos separados, valle mas hondo |

Sin regresiones. Perfil intacto en los tres.

### Y lo que NO arreglo

**El defecto grande sigue completo.** El pecho sigue leyendo como **tapa de
barril sobresaliendo del torso**, con un filo duro por debajo que cruza de lado
a lado. Mas visible en Darro que en nadie.

**Pero la medicion acoto de donde NO sale.** `chest_mass` tiene semieje x
0.1485 contra un radio de cilindro de 0.1476 a esa altura: **estan a ras**. La
masa de pecho **no desborda lateralmente**, y como es hija de `torso` escala
junto con el, eso vale en cualquier build. **El voladizo de la silueta no es
`chest_mass`: son los deltoides.** Que es territorio con aviso propio
(`SHOULDER_X`, "dos rondas esculpieron el deltoide correcto sobre el pivote
equivocado").

### Estado del frente

Tres hipotesis quemadas en esta zona. **Se para de esculpir el pecho** y la
cuarta no se arranca sin decision del director: la evidencia apunta a los
hombros, y ahi hay una leccion cara pagada de antemano.

## [2026-09-21] lint | La rotacion del LOG rompio 37 criticos de canon — y 34 eran del linter, no del vault

Primera corrida de `check_canon.py` despues de la rotacion del 2026-09-11:
**37 criticos**, cuando el sprint habia cerrado en 0. Ninguno venia de haber
escrito canon nuevo — el vault no se toco en tres semanas. Los produjo la
rotacion misma, y en dos clases distintas que conviene no confundir.

**Clase 1 — 3 punteros muertos en archivos vivos.** [[00-Index]], [[Fenotipos y
Creacion de Personaje]] y [[Current-State]] citaban `[[LOG]] §2026-08-13`,
`§2026-08-24` y `§2026-08-21`. Las entradas existen y estan intactas, pero
ahora viven en `LOG-Archivo/2026-08.md`, asi que `[[LOG]]` ya no las contiene.
Deuda real: apuntaban a lo mas reciente que hicimos. Repuntadas a `[[2026-08]]`.

**Clase 2 — 34 falsos positivos del propio `LOG-Archivo/`.** El linter empezo
a barrer los tramos archivados como si fueran canon vivo. No lo son: la
cabecera de la rotacion dice **"verbatim y sin resumir — archivar no es
comprimir"**, y un tramo cerrado cita secciones que existian cuando se escribio.
Sus enlaces envejecen **por diseno**.

**El fix fue a la fuente, y la fuente ya tenia la respuesta escrita.** El linter
ya distinguia esta naturaleza: `APPEND_ONLY` (`LOG.md`,
`Current-State-Historico.md`) degrada sus hallazgos a INFO, con el comentario
*"sus enlaces rotos son esperables"*. La rotacion creo archivos de esa misma
naturaleza sin inscribirlos ahi. Se agrego `APPEND_ONLY_DIRS = ("LOG-Archivo/",)`
**por carpeta, no por nombre** — a proposito: cada mes que se cierre suma un
archivo, y una lista de basenames habria vuelto a romperse en octubre sin que
nadie lo notara hasta la siguiente corrida.

**La leccion de metodo:** una tarea de higiene que no toca ni una linea de canon
puede romper canon igual, porque **las citas son acoplamiento**. Mover un archivo
es cambiar la fuente de todo lo que lo cita. Rotar el LOG es barato; re-apuntar
lo que lo citaba es la otra mitad de la tarea, y quedo sin hacer.

**Queda abierto, sin bloquear:** `[[VAULT-STARTER]]` (LOG.md:23) no resuelve
porque `VAULT-STARTER.md` vive en la **raiz del repo**, fuera del vault que el
linter indexa. Es INFO. No lo toque: editarlo es reescribir una entrada del LOG,
y esa decision es del director, no de la higiene.

Cierre: **0 criticos / 0 medios**, 30 INFO, todos de archivos append-only.

## [2026-09-11] lint | LOG rotado y `check_vault.py` v4 instalado como herramienta única del repo

Cierra los dos pendientes que dejó la auditoría de [[VAULT-STARTER]] v4 contra
este vault.

### Rotación del LOG

189,939 tokens era el hallazgo §4.1 de v4: un LOG que ya no se puede abrir
entero deja de cumplir su función en silencio, y no lo denuncia ningún
semáforo porque no se auto-carga. Se archivó por mes a `LOG-Archivo/`.

**El corte mensual no alcanzó con un solo mes.** Agosto solo pesa 76,687 t,
casi el doble del techo de 40,000. Así que se archivaron **los dos meses
cerrados** y este archivo queda con el periodo en curso, que es lo que manda
§4.1. El mes es la frontera: reproducible, mecánica, sin criterio.

**Verificación de cero pérdida.** Las 356 entradas originales aparecen
exactamente una vez entre los dos archivos, comparadas por hash SHA-256 como
multiconjunto (0 faltantes, 0 sobrantes), y el orden interno de cada periodo
se preservó byte a byte. La comparación *concatenada* falló al primer intento
y no era un error de la rotación: el LOG no estaba ordenado por fecha, tenía
agosto debajo de julio. Lección de la propia sesión — **cuando una
verificación falla, primero se cuestiona la verificación**, que era la
suposición barata, no el dato.

### `check_vault.py` v4

El hallazgo §9.1 de v4 era que el script traía las rutas incrustadas y por eso
cada eje terminaba con su propia copia. Había **dos**, una en
`Aether Bound/scripts/` y otra en `Boda/scripts/`, y ambas habían drifteado el
techo de `Current-State` de 2,500 a 3,000 — el hallazgo §7.1, presente por
duplicado.

Ahora hay **una sola** en `scripts/check_vault.py`, que descubre los tres ejes
sola y no necesita edición. Las dos copias se eliminaron.

- `scripts/hook_current_state.sh` se movió con ella y ahora deduce el eje de
  la ruta editada (`--eje`), para no reportar los tres vaults cuando se tocó
  uno. Probado contra Aether Bound y Boda.
- `.claude/settings.json` y `settings.local.json` apuntan a las rutas nuevas.

### Estado tras la corrida

| Eje | Arranque | Sobre techo |
|---|---|---|
| Aether Bound | 3,571 t 🟢 | Current-State +162 t |
| Boda | 4,123 t 🟢 | Current-State +714 t |
| Inversión | 5,488 t 🟢 | Current-State +2,079 t |

Los tres `Current-State.md` quedan sobre el techo de 2,500 t. **No se tocan en
esta operación**: recortarlos es trabajo del Lint Loop por eje, y dos de esos
ejes no son este. Queda anotado como pendiente.
