---
status: ratificado
source: "GDD §7"
updated: 2026-07-04
---

# Inventario del Prototipo (qué se conserva)

El prototipo Godot 4.6.3 (`godot/` en el repo; `src/` Three.js es referencia
congelada) es la base material del juego.

| Activo | Destino |
|---|---|
| Pipeline visual (toon ramp, outlines, biomas, grass, fog) | ✅ Se conserva; evoluciona hacia las 4 capas de la [[Art Bible]] |
| Locomoción PRD-005 (9-cell, slide, crouch, ADS) | ✅ Se conserva tal cual ([[Locomoción]]) |
| Matriz 3×3 + VFX de sub-estilos | ✅ Se conserva; re-skin a Elfo/Enano/Humano ([[Matriz Raza x Rol]], [[Las Tres Razas]]) |
| Character creation | ✅ Se conserva; fenotipos ajustados a razas |
| Contrato de Conquistador + oficina | ✅ Se conserva y profundiza ([[Progresión y Contrato]]) |
| Flujo CREATION→OFFICE→CITY_EXIT→WILDS | ✅ Esqueleto del Acto 1 |
| "Purga el nido y destruye el Core" | ❌ Reemplazado: ahora es el incidente incitante ([[Estructura Dramática]]) |
| Choice A/B/C con buffs | ❌ Reemplazado por la decisión de la Criatura |
| Roadmap "Vanguards & Voidcores" del README | 🔁 Superado ([[Nomenclatura]]) |

Detalles técnicos operativos (rutas, gates QA, lecciones): `20-State/Lecciones`.
