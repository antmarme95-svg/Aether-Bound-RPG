# weapon_data.gd — PRD-006 alcance 1: datos externos de armas (Combate §A,
# "Datos externos: WeaponData + AbilityData"). Mismo patrón JSON del
# prototipo (class_multipliers.json / locomotion.json).
#
# Cada arma define su cadena de combo como pasos con duración/daño/balance/
# fuerza — la FORMA del golpe (fases, ventanas) es del esqueleto
# (rig_biomech), nunca del arma (Movilidad Realista §4.3).
#
# Loaded via preload (never class_name — see Lecciones).
extends RefCounted

const _PATH := "res://data/weapons.json"

static var _cache: Dictionary = {}

static func _load() -> void:
	if not _cache.is_empty():
		return
	var f := FileAccess.open(_PATH, FileAccess.READ)
	if f == null:
		push_error("[weapon_data] cannot open %s" % _PATH)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[weapon_data] bad JSON in %s" % _PATH)
		return
	_cache = parsed

static func get_weapon(id: String) -> Dictionary:
	_load()
	if _cache.has(id):
		return _cache[id]
	push_warning("[weapon_data] unknown weapon '%s' — falling back to unarmed" % id)
	return _cache.get("unarmed", {})

static func combo_length(weapon: Dictionary) -> int:
	return (weapon.get("combo", []) as Array).size()

static func combo_step(weapon: Dictionary, index: int) -> Dictionary:
	var combo: Array = weapon.get("combo", [])
	if combo.is_empty():
		return {}
	return combo[clampi(index, 0, combo.size() - 1)]
