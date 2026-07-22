# Origin factions — direct port of src/data/origins.js.
class_name OriginsData extends RefCounted

const ORIGINS: Array[Dictionary] = [
	{
		"id": "aetherborn",
		"name": "Aether-Born",
		"tag": "High-Tech Elven Mage Lineage",
		"lore": "Heirs of the sky-archives. Their blood runs hot with raw mana and unpaid library fines.",
		"defaultName": "Vessari",
		"passive": {
			"id": "manaOverload",
			"name": "Mana-Overload",
			"desc": "Hold Q to overclock casting speed at the cost of draining stamina. +50 permanent Magicka.",
			"attributeMods": {"magicka": 50},
			"hint": "Q — OVERCLOCK",
		},
		"city": {
			"name": "Zephyr-Academica",
			"desc": "A levitating skyland city held aloft by blue crystal pipelines, floating lecture halls, and sheer institutional stubbornness.",
		},
		"recruiter": {"name": "Provost Ilyra Venn", "title": "Office of Profitable Curiosity"},
		"rival": "The Iron Tribunal of the Craters",
		"heightRange": [0.97, 1.13],
		# C6b (2026-07-21): esqueleto FIJO por raza ([[Fenotipos y Creación
		# de Personaje]] — "palancas largas, hombros estrechos caídos,
		# cuello largo"). Multiplicadores sobre el rig humano (1.0 =
		# comportamiento humano, ver `character_rig.gd _apply_build`).
		# Punto de partida medido contra la lámina (`fenotipo-elfo-*.png`,
		# "8 heads tall"); afinar con el banco de anatomía antes de VoBo.
		"proportions": {
			# Ronda 1 (medido en banco 2026-07-21): 8.78 cabezas con
			# 1.15/0.90 — objetivo 8.0, un poco menos extremo.
			"limb_len": 1.08,
			"shoulder_x": 0.82,
			"neck_len": 1.35,
			"head_scale": 0.94,
			"hand_scale": 1.08,
		},
		"theme": {
			"accent": "#46e6ff",
			"sky": "#7fd4ff",
			"ambient": "#bfe8ff",
			"fog": "#9fd0e8",
			"pipeGlow": "#46e6ff",
			"floor": "#cfd8e6",
			"wall": "#8fa6c4",
			"trim": "#e8eef8",
			"propSet": "skyland",
		},
	},
	{
		"id": "ironblooded",
		"name": "Iron-Blooded",
		"tag": "Steam & Arcane Forge Warriors",
		"lore": "Volcano-born smith-soldiers. They settle philosophical disputes with hammers, and most other disputes with bigger hammers.",
		"defaultName": "Brunhylde",
		"passive": {
			"id": "colossusStance",
			"name": "Colossus Stance",
			"desc": "Immune to stagger. Heavy swings land faster, and you shrug off 25% of all physical damage.",
			"attributeMods": {},
			"hint": "PASSIVE — ALWAYS FORGED ON",
		},
		"city": {
			"name": "The Smelting Craters",
			"desc": "An industrial fortress city bolted into a live volcano — iron gears the size of houses, rivers of molten aether, doors that mean it.",
		},
		"recruiter": {"name": "Forge-Sergeant Brakka Húldottir", "title": "Conscription & Quenching Division"},
		"rival": "The Archlectors of Zephyr-Academica",
		"heightRange": [0.92, 1.08],
		# C6b (2026-07-21): "palancas cortas, trapecio masivo, cuello
		# hundido, manos enormes, centro bajo" ([[Fenotipos y Creación de
		# Personaje]]). Punto de partida medido contra la lámina
		# (`fenotipo-enano-varon-v1.png`, "4.5 heads tall"); afinar con el
		# banco de anatomía antes de VoBo.
		"proportions": {
			# Ronda 3 (medido en banco 2026-07-21): r1 5.34 cabezas (0.62/1.12),
			# r2 4.22 cabezas (0.45/1.30) — se pasó un poco del objetivo 4.5.
			"limb_len": 0.48,
			"shoulder_x": 1.60,
			"neck_len": 0.45,
			"head_scale": 1.24,
			"hand_scale": 1.40,
		},
		"theme": {
			"accent": "#ff9d4d",
			"sky": "#3a2420",
			"ambient": "#ffb37a",
			"fog": "#52281c",
			"pipeGlow": "#ff6a2b",
			"floor": "#4a3a32",
			"wall": "#5e4438",
			"trim": "#2e2018",
			"propSet": "forge",
		},
	},
	{
		# Human origin (the Restless). Kept id "miststalker" internally — renaming
		# it would touch ~10 test files that key origins by string id — but the
		# race is 100% human: this entry represents the Mistbound, the frontier
		# Driftfolk subculture of the Restless (Aether Bound/10-Knowledge/Las Tres
		# Razas.md, Fenotipos y Creación de Personaje.md — decisión 2026-07-04).
		"id": "miststalker",
		"name": "Mistbound",
		"tag": "Driftmarket Frontier Outlaws",
		"lore": "Canal-running smugglers of the fog, Driftmarket-born and beholden to no crown. If you can see them, they are either being polite or you are already robbed.",
		"defaultName": "Ryx",
		"passive": {
			"id": "feralInstinct",
			"name": "Frontier Instinct",
			"desc": "Move faster through high grass, toggle fog-sight with N, and enemies notice you far later.",
			"attributeMods": {},
			"hint": "N — FOG-SIGHT",
		},
		"city": {
			"name": "The Titan's Docks",
			"desc": "A foggy multi-level canal sprawl built inside the ribcage of a fallen colossus. Run by smugglers, tolerated by gods.",
		},
		"recruiter": {"name": "Quillane “Quill” Marrow", "title": "Acquisitions (Don't Ask) Desk"},
		"rival": "The Gilded Concord of Free Captains",
		"heightRange": [0.9, 1.15],
		"theme": {
			"accent": "#4dff9d",
			"sky": "#2c4a44",
			"ambient": "#9fd8c5",
			"fog": "#56766e",
			"pipeGlow": "#4dff9d",
			"floor": "#3c4a44",
			"wall": "#51635c",
			"trim": "#27332e",
			"propSet": "docks",
		},
	},
]

static func get_origin(id: String) -> Dictionary:
	for o in ORIGINS:
		if o["id"] == id:
			return o
	return {}
