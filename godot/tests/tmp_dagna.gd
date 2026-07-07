# tmp_dagna.gd — sonda temporal de presentación: Dagna (pivote B1) montada
# GRÁFICAMENTE como CharacterRig procedural desde su config de datos
# (data/characters.gd + character/character_signature.gd) y capturada
# frente / espalda / perfil contra la lámina canónica
# (Aether Bound/90-Raw/concept/dagna-v1.png). Prueba el pipeline
# lámina → config → Godot que se replicará con los demás pivotes.
# Boot: --autotest=res://tests/tmp_dagna.gd -- --origin=ironblooded --cls=warrior --skip=wilds
extends Node

const _GameDirector = preload("res://core/game_director.gd")
const _Characters   = preload("res://data/characters.gd")

var _director = null
var _ctl = null

func _ready() -> void:
	await get_tree().process_frame
	_run()

func _run() -> void:
	_director = _GameDirector.new()
	get_tree().current_scene.add_child(_director)
	_director.start()

	var elapsed := 0.0
	while elapsed < 10.0:
		if _director.controller != null and _director.hud != null and _director.hud.visible:
			break
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	var ctl = _director.controller
	if ctl == null:
		print("[TmpDagna] FAIL: sin controller")
		get_tree().quit(1)
		return
	_ctl = ctl
	var scene: Node3D = _director.scene
	var fwd := Vector3(sin(ctl.facing), 0.0, cos(ctl.facing))

	# ---- escenario limpio: UI fuera, jugador oculto, bestias lejos ----
	_director.hud.visible = false
	if _director.quest_ui != null:
		_director.quest_ui.visible = false
	if _director.minimap_ui != null:
		_director.minimap_ui.visible = false
	if ctl.rig != null:
		ctl.rig.visible = false
	_park_enemies()

	# ---- Dagna desde su config (pipeline lámina → config → rig) ----
	var holder := Node3D.new()
	holder.name = "dagna_holder"
	scene.add_child(holder)
	holder.position = ctl.position + fwd * 2.0
	if scene.has_method("get_height"):
		holder.position.y = scene.get_height(holder.position.x, holder.position.z)
	var rig = CharacterRig.new()
	holder.add_child(rig)
	_Characters.apply_to_rig(rig, "dagna")
	rig.set_motion(0.0, false)

	# La sonda toma el control TOTAL de la cámara: congelar el director
	# (que la re-sincroniza cada frame a la cabeza del jugador) y encuadrar
	# nivelado. El idle fuerza head.rotation.x=0, así que el "mira arriba"
	# previo era ENCUADRE, no pose — un retrato nivelado lo corrige.
	_director.set_process(false)
	var cam: Camera3D = ctl.cam
	var view := Vector3(sin(ctl.facing + PI), 0.0, cos(ctl.facing + PI))  # lado que Dagna encara de frente
	var base := holder.global_position

	# ---- capturas: cámara FIJA y nivelada al frente; se rota el MODELO ----
	_place(cam, base + Vector3(0.0, 0.9, 0.0), view, 3.1, 0.18)

	holder.rotation.y = ctl.facing + PI          # frente
	await _wait_sec(0.6)
	await Debug.screenshot("res://test_out/dagna_front.png")

	holder.rotation.y = ctl.facing               # espalda: martillo + trenza
	await _wait_sec(0.4)
	await Debug.screenshot("res://test_out/dagna_back.png")

	holder.rotation.y = ctl.facing - PI * 0.5    # perfil izquierdo: la cuña
	await _wait_sec(0.4)
	await Debug.screenshot("res://test_out/dagna_profile.png")

	# ---- detalle 3/4 cercano a la cabeza: cuña + tatuajes ----
	_place(cam, base + Vector3(0.0, 1.12, 0.0), view, 1.7, 0.05)
	holder.rotation.y = ctl.facing + PI - 0.5
	await _wait_sec(0.4)
	await Debug.screenshot("res://test_out/dagna_detail.png")

	print("[TmpDagna] DONE")
	get_tree().quit(0)

## Cámara nivelada: en el lado `dir` (al que mira el modelo en pose de frente),
## a `dist` del punto `center`, elevada apenas `lift` (mirada casi horizontal,
## sin picada ni contrapicada — el retrato lee de tú a tú).
func _place(cam: Camera3D, center: Vector3, dir: Vector3, dist: float, lift: float) -> void:
	cam.global_position = center + dir * dist + Vector3(0.0, lift, 0.0)
	cam.look_at(center)

## Bestias del boot fuera de cuadro (y de rango de aggro) durante toda la sonda.
func _park_enemies() -> void:
	if _ctl == null:
		return
	for e in _ctl.enemies:
		if is_instance_valid(e):
			e.visible = false
			e.position = _ctl.position + Vector3(400.0, 0.0, 400.0)

func _wait_sec(s: float) -> void:
	var t := 0.0
	while t < s:
		_park_enemies()
		await get_tree().process_frame
		t += get_process_delta_time()
