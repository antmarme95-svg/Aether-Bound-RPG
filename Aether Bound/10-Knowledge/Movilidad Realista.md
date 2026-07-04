---
status: ratificado
source: "GDD §4.3"
updated: 2026-07-04
---

# Movilidad realista sobre gráfico perfecto

**Mandato del director:** el cuerpo importa más que el pixel. La estilización
vive en el *render* ([[Art Bible]]), nunca en el *esqueleto*.

## Reglas del esqueleto

- **Joint constraints anatómicos:** hombro 3-DOF, codo/rodilla bisagra 1-DOF,
  muñeca/tobillo 2-DOF, columna segmentada, cadera 3-DOF. **Nada rota donde
  un cuerpo no rota.**
- **Transferencia de peso real:** todo golpe/salto nace en la cadera y se
  encadena. Sin wind-ups imposibles.
- **IK como estándar:** pies plantados en pendiente, manos al borde real del
  mantle. El gait procedural del prototipo (L5/L6) se profundiza a IK
  completo, no se reemplaza.

## ROM por raza

| Raza | Biomecánica | Consecuencia |
|---|---|---|
| **Enano** | Palancas cortas, hombro limitado (el brazo no pasa cómodo sobre la cabeza), centro bajo, squat natural | Arcos bajos y de cadera; trepa a pasos cortos; imposible de desequilibrar, incómodo en lo alto |
| **Elfo** | Hipermovilidad controlada, columna flexible, zancada larga | Cortes altos, aterrizajes silenciosos, esquives de junco; alcances de escalada únicos; frágil al agarre |
| **Humano** | **El ROM de referencia del rig**; transferencia atlética | El movimiento "correcto" por familiaridad; encadena planos mejor que ambos |

## Aplicación

Los movesets de [[Combate]] se animan **desde** su esqueleto (las dagas de
Nyael en rango muñeca-codo; el martillo de Torgan en cadera-torso); la
[[Locomoción]] hereda alcances reales de agarre. **Prioridad de producción:
rig con constraints + IK > cantidad de animaciones** — un esqueleto correcto
hace creíbles 20 animaciones; uno falso arruina 200. → Task-Board (rig
biomecánico).
