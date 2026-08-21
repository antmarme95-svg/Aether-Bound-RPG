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
