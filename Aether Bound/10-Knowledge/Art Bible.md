---
status: ratificado
source: "GDD §6, §6.2"
updated: 2026-07-04
---

# Art Bible — "Melancolía Gráfica"

**Referencias canónicas:** Sable (silueta, línea, luz, atmósfera) · BotW
(color, saturación, perspectiva aérea) · Dungeons of Hinterberg (energía
urbana, semitonos). **Frase-norte:** *una novela gráfica pintada a mano en
acuarela.*

## Los 5 ejes

| Eje | Regla |
|---|---|
| **Silueta** | Estilizada, legible; el espacio vacío es protagonista (Sable) |
| **Línea** | Tinta negra nítida en primer plano; el grosor lo controla la profundidad — a media distancia se agrisa, en el horizonte desaparece |
| **Luz/sombra** | Cel de 3–4 escalones fijos con bordes *jitter* (pincel seco) |
| **Color** | Saturación media-baja "lavada" acuarela; cambios drásticos de paleta por hora del día |
| **Atmósfera** | Perspectiva aérea (silueta plana azul pastel al fondo), Rayleigh, glowing edges, grano de papel |

## La regla espacial — el registro sigue a [[La Rueda]]

- **Wilds + arterias:** registro **Sable×BotW** — melancolía pastel, silencio
  visual.
- **Ciudades del aro:** registro **Hinterberg** — línea gruesa, semitonos,
  acentos saturados; la ciudad *grita* gráficamente (pilar 4).
- **Transición diegética** al viajar arteria→ciudad, sin UI.
- **Peligro = ROJO saturado** en ambos registros (constante intocable).
- **Regla nocturna (ratificada 2026-07-04):** de noche/atardecer, los glowing
  edges ganan color aether — filos neón teal en crestas y contornos a
  contraluz (herencia Sable nocturna). Referencia canónica:
  `90-Raw/concept/keyframe-wilds-dusk-v1.png`.

## Keyframes canónicos (criterio de aceptación de la golden scene)

`keyframe-wilds-dawn-v1.png` + `keyframe-wilds-dusk-v1.png` (ratificados
2026-07-04): la golden scene Godot se acepta comparándola lado a lado contra
este par a las dos horas del día. La escena persigue la imagen, nunca al
revés.

## Pipeline técnico (4 capas screen-space)

1. Edge detection Sobel atenuado por profundidad; 2. soft quantization cel
con jitter; 3. volumétrica Rayleigh + glowing edges + tonemapping suave;
4. grano de papel + line boil. Viable en Godot (la capa 2 primitiva ya existe
— [[Inventario del Prototipo]]); informa la decisión de motor sin tomarla
(→ ADR-002).

**Anti-referencias:** Genshin (saturación caramelo), PBR realista
(Witcher/Horizon), y el look actual del prototipo (cel genérico).

**Reglas de contenido vigentes:** paleta por reino (teal elfo / ámbar enano /
madera-río humano); ciudades con ritmo cultural propio; el esqueleto nunca se
estiliza ([[Movilidad Realista]]).

**Pendiente (❓):** concept art (3 keyframes); prueba técnica de las 4 capas
sobre una "golden scene" del prototipo; dirección de audio (semilla: el sting
de dos notas, [[Bond y el Bond Vacío]]); Game Feel Bible. → Task-Board.
