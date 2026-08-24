# Named-character visual configs — pipeline lámina → config → CharacterRig.
# Cada personaje canónico (pivotes B1..B9, etc.) se describe como
# origin + clase + fenotipo + piezas firma; apply_to_rig() lo monta completo
# sobre un CharacterRig ya instanciado. Para replicar con otro personaje:
# agregar su entrada al dict y (si trae piezas nuevas) su builder en
# character/character_signature.gd.
#
# Referencia de fidelidad de Dagna:
#   Aether Bound/90-Raw/concept/dagna-v1.png (lámina canónica, 2026-07-04)
#   Ficha: Aether Bound/10-Knowledge/Dagna.md (§ Diseño visual)
class_name CharactersData extends RefCounted

const _Signature = preload("res://character/character_signature.gd")

const CHARACTERS: Dictionary = {
	"dagna": {
		"display_name": "Dagna Piedrahonda",
		"origin": "ironblooded",
		"class": "warrior",
		# Fenotipo base: cuerpo enano robusto — mismo par weight/height que el
		# perfil heavy de enemy_humanoid.gd, que ya valida la proporción enana.
		"phenotype": {
			"weight": 1.0, "height": 0.10,
			"jaw": 0.72, "cheek": 0.45, "eyeTilt": 0.62, "eyeShape": 0.10,
			"hair": 1,        # Norse Braids: trenzas de sien + trenza trasera (lámina)
			"beard": 0,
			"hairColor": 2,   # ember copper de paleta (afinado abajo con hair_tint)
			"skinTone": 1,    # sun-kissed
			"warpaint": 0,    # cara limpia — el tatuaje de gremio va en ANTEBRAZOS
			"paintColor": 2,
			"arcaneMod": 0.0, # sin goggles/venas/prótesis: guardiana práctica
		},
		# Cobrizo OSCURO exacto de la lámina; la paleta solo trae ember copper
		# (muy naranja) o chestnut (muy café) — se ajusta el albedo tras aplicar.
		"hair_tint": "#7a3c1d",
		"signature": {
			"guardian_tunic": true,        # camisa olivo + correa + botonadura (el torso base es piel)
			"gate_pauldrons": true,        # placas de compuerta en AMBOS hombros, a escala del cuerpo real
			"shin_plates": true,           # espinilleras de compuerta (las greaves base quedan dentro)
			"braid_wedge": true,           # anillas de forja + CUÑA miniatura, trenza IZQUIERDA (ficha: garantizarla)
			"forearm_guild_tattoos": true, # motivo de la Puerta (arco + cuña), ambos antebrazos
			"gate_hammer": true,           # martillo-maza de cabezal plano (ariete) a la espalda
			"tool_belt": true,             # cinturón de guardiana: bolsas + martillito + cuña de repuesto
			"waist_skirt": true,           # faldón de cuero a la rodilla (silueta de la lámina)
		},
	},
	# --- Pasada 1 (2026-08-23): Roen, Darro, Valen SIN piezas firma todavía.
	# Solo fenotipo + origen + clase, para renderizar el rig TAL COMO ESTÁ hoy
	# y ver si los defectos de Dagna (torso-bola, sin cuello, hombreras
	# flotantes) son sistémicos en las 3 razas o propios de ella. El vestuario
	# (capa de Roen, hachas de Darro, grabados de Valen) es Pasada 2, después
	# de que el rig tenga algo digno de vestir.
	#
	# Valores de fenotipo: primera pasada de calibración a ojo contra
	# roen-v3.png / darro-v1.png / valen-v4.png en 90-Raw/concept/ y las
	# fichas expandidas — NO medidos en píxeles todavía (a diferencia de la
	# escultura del cuerpo, la cara no tiene el mismo instrumento de
	# medición). Revisar cuando haya QA visual.
	"roen": {
		"display_name": "Roen",
		"origin": "miststalker",  # raza "the Restless"; el origin YA es la Frontera Mistbound de su ficha
		"class": "warrior",       # Vanguard
		"phenotype": {
			"weight": 0.5, "height": 0.55,
			"jaw": 0.65, "cheek": 0.5, "eyeTilt": 0.5, "eyeShape": 0.5,
			"hair": 8,          # Shorn Scout: corte corto militar (roen-v3.png)
			"beard": 1,         # Stubble
			"beardDensity": 0.6,  # barba corta pareja, no solo sombra de 3 días (más llena que el default 0.35)
			"hairColor": 4,     # chestnut — castaño oscuro (roen-v3.png)
			"skinTone": 1,      # sun-kissed
			"warpaint": 6,      # Scout Marks — coherente con su cultura Mistbound de frontera
			"paintColor": 4,    # wyld green desaturado — el warpaint verde geométrico de Mistbound (ficha línea 71)
			"arcaneMod": 0.0,   # humano sin modificación arcana
		},
		"signature": {},  # Pasada 2: capa, escudo (retirado en v2/v3 de concept, revisar si vuelve), espada
	},
	"darro": {
		"display_name": "Darro",
		"origin": "ironblooded",
		"class": "thief",  # Duelist
		"phenotype": {
			# Más liviano que Dagna a propósito (canon: "build más liviano que
			# Dagna o Torgan, hachas cortas" — Briefs de Concept Art §14).
			"weight": 0.6, "height": 0.35,
			"jaw": 0.75, "cheek": 0.4, "eyeTilt": 0.5, "eyeShape": 0.55,
			"hair": 2,          # Elven Topknot — el moño/coleta corta de darro-v1.png (el nombre no ata la raza)
			"beard": 2,         # Braided Jarl
			"beardDensity": 0.7,
			"hairColor": 2,     # ember copper — mismo tono que Dagna, coherente entre enanos
			"skinTone": 2,      # bronze
			"warpaint": 0,      # None — sus marcas ámbar van en los ANTEBRAZOS (pieza firma, Pasada 2), no en la cara
			"paintColor": 0,
			"arcaneMod": 0.0,
		},
		"signature": {},  # Pasada 2: bandas ámbar de antebrazo, hacha corta, dagas del cinturón
	},
	"valen": {
		"display_name": "Valen",
		"origin": "aetherborn",
		"class": "mage",  # Strategist
		"phenotype": {
			"weight": 0.15, "height": 0.8,  # esbelto, alto dentro del rango aetherborn
			"jaw": 0.25, "cheek": 0.6, "eyeTilt": 0.75, "eyeShape": 0.3,  # mandíbula fina, pómulos altos, ojos almendrados de inclinación alta
			"hair": 5,          # Curtain Long — pelo negro largo liso (valen-v4.png)
			"beard": 0,         # Clean
			"hairColor": 0,     # void black
			"skinTone": 6,      # pale lavender (aether-marked) — "cold pale tones, faint lavender undertone" (Briefs de Concept Art §1)
			"warpaint": 0,      # None — sin pintura facial
			"paintColor": 0,
			# >0.06 hace visibles las venas: son los grabados aether teal de
			# garganta/pecho de la lámina. El color sale del accent de
			# `aetherborn` (#46e6ff aether cyan) vía apply_phenotype, así que
			# no hace falta hair_tint ni paintColor para el teal.
			"arcaneMod": 0.3,
		},
		"signature": {},  # Pasada 2: si hay pieza de vestuario específica (hoy la lámina lo muestra sin ropa de torso)
	},
}

static func get_character(id: String) -> Dictionary:
	return CHARACTERS.get(id, {})

## Monta un personaje nombrado completo sobre un CharacterRig ya en escena:
## fenotipo → arquetipo → tinte de pelo exacto → piezas firma.
static func apply_to_rig(rig, id: String) -> void:
	var c: Dictionary = get_character(id)
	if c.is_empty():
		return
	var origin: Dictionary = OriginsData.get_origin(String(c["origin"]))
	rig.apply_phenotype(c["phenotype"], origin)
	rig.apply_archetype(String(c.get("class", "")))
	if c.has("hair_tint"):
		rig.hair_mat.set_shader_parameter("albedo_color", Color(String(c["hair_tint"])))
	_Signature.attach(rig, c.get("signature", {}))
