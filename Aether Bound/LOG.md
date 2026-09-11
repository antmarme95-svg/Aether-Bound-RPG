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
