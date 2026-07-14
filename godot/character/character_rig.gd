## CharacterRig — cuerpo humanoide paramétrico.
## C6a (2026-07-10, rework anatómico): las proporciones ya NO son el puerto
## del prototipo (anime ~6.4 cabezas) — siguen el canon de las láminas de
## fenotipo (`90-Raw/concept/fenotipo-*.png`): humano ATLETA de 7.5 cabezas
## (ver PROPORTIONS abajo). La jerarquía de pivotes es intacta (biomecánica
## conservada: hip-first, columna lumbar+torácica, constraints de ROM).
## Línea: el rig NO fabrica outline (decisión del director 2026-07-10) — la
## tinta la pone el Sobel del post Melancolía (Art Bible, eje Línea); los
## materiales son toon_opaque (pase opaco, visibles al depth del post).
## Pivots: body > hips/spine > head > sub-meshes, arms, legs.
class_name CharacterRig extends Node3D

# ----------------------------------------------------------------
# PROPORTIONS — canon anatómico humano (lámina fenotipo-humano-v1: atleta
# de 7.5 cabezas). Alturas en metros a escala 1.0; el total queda ~1.92 m
# con la coronilla y el mentón cerrando una cabeza de ~0.255 m.
# Landmarks (mundo, de pie): coronilla 1.92 · mentón 1.67 · hombros 1.55 ·
# codo/ombligo 1.23 · muñeca/entrepierna ~0.95 · rodilla 0.50 · suelo 0.
# Los fenotipos enano (4.5 cabezas, trapezoide) y elfo (8, esbelto) derivan
# de esta tabla en C6b.
# ----------------------------------------------------------------
# r4 = Character Blockout Review v0.1 del director (90-Raw/reviews/):
# CRITICAL 1 silueta atlética (hombros +12%, cintura menos, pecho más),
# CRITICAL 2 cabeza menor, CRITICAL 3 cuello largo + hombros más bajos.
const HEAD_SCALE: float = 0.84       # cráneo del puerto ×0.84 (review: menos cabezón)
# Fase C (Benchmark-Musculatura-Torso.md / debate orquestador↔QA
# 2026-07-13): CUELLO +15% — la caída mentón→hombro se leía corta (la
# barbilla casi rozaba la línea de hombros en 3/4). HEAD_Y y NECK_Y suben
# el mismo delta que el cilindro del cuello crece (ver _build, +0.015 de
# alto) para que la cabeza no se hunda ni se separe del cuello.
const HEAD_Y: float = 0.520          # v0.4 H3 0.505 + 15% de cuello (Fase C)
const NECK_Y: float = 0.3595  # v0.4 H3 0.352 + 15% de cuello (Fase C)
# QA dirigido 2026-07-13 (hombros que no convencían al director): el
# "+12%" de la review v0.1 CONTRADECÍA la lámina (fenotipo-humano-v1 dice
# "narrow sloped shoulders", biacromial ~2.05 cabezas ≈ 0.52 m) y quedó
# fosilizado — el render medía 0.67 m (+30%). Dos rondas esculpieron el
# deltoide correcto sobre el pivote equivocado. La lámina es el canon:
# pivote ADENTRO y ABAJO; la silueta cuello→muñeca solo DESCIENDE.
const SHOULDER_X: float = 0.21       # media distancia entre hombros (lámina, ex-0.262)
const SHOULDER_Y: float = 0.26       # línea de hombros (lámina: caída real, ex-0.29)
const UPPER_SPINE_Y: float = 0.24    # bisagra torácica sobre la lumbar
# PRD Rework Fenotipo pt.13 (2026-07-14, riesgo alto): curva dorsal estática
# — perfil "en tabla" del QA de cuerpo completo. Subido de -0.05 (propuesta
# técnica inicial) a -0.09 por objeción directa de Fable (imperceptible con
# el torso construido en placas separadas). Se suma como OFFSET al target
# del settle de `upper_spine.rotation.x` (línea ~2900, el "follow del
# torácico fuera del strike") en vez de asignarse una sola vez en _build():
# ese lerp corre TODO frame que no sea strike y converge hacia
# `spine.rotation.x * 0.30` — una asignación directa en _build() se borra
# sola en <150ms de idle (mismo mecanismo que el "settle satura el clamp"
# de Lecciones). Sumar el offset al target la hace parte del reposo real.
const DORSAL_CURVE_X: float = -0.09
# V-taper del tronco (multiplicadores base sobre el build de peso/clase):
# pecho con VOLUMEN (review CRITICAL 1) y cintura recogida marcando el
# cambio tórax→pelvis.
const CHEST_X: float = 1.16
const CHEST_Z: float = 0.92
const WAIST_XZ: float = 0.90

# ---- lerp helper ----
static func _lerp(a: float, b: float, t: float) -> float:
	return a + (b - a) * t

# ---- capsule helper ----
static func _capsule_mesh(r: float, len: float, mat: Material) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = CapsuleMesh.new()
	mesh.radius = r
	mesh.height = len + r * 2.0
	mi.mesh = mesh
	mi.material_override = mat
	return mi

# ---- box helper ----
static func _box_mesh(w: float, h: float, d: float, mat: Material) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(w, h, d)
	mi.mesh = mesh
	mi.material_override = mat
	return mi

# ---- sphere helper ----
static func _sphere_mesh(r: float, mat: Material) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = r
	mesh.height = r * 2.0
	mi.mesh = mesh
	mi.material_override = mat
	return mi

# ---- cylinder helper ----
static func _cylinder_mesh(top_r: float, bot_r: float, height: float, mat: Material) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = top_r
	mesh.bottom_radius = bot_r
	mesh.height = height
	mi.mesh = mesh
	mi.material_override = mat
	return mi

# ---- disc (circle) helper (for iris/pupil — flat cylinder) ----
static func _disc_mesh(r: float, mat: Material) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = r
	mesh.bottom_radius = r
	mesh.height = 0.002
	mi.mesh = mesh
	mi.material_override = mat
	return mi

# ----------------------------------------------------------------
# Scene nodes (mirrors JS property names where possible)
# ----------------------------------------------------------------
var body: Node3D
var hips: Node3D
var spine: Node3D        # segmento LUMBAR (raíz del tronco)
var upper_spine: Node3D  # segmento TORÁCICO (ronda articulación #3) — carga brazos/cuello/cabeza
var head: Node3D
var hair_slot: Node3D
var beard_slot: Node3D
var feature_slot: Node3D
var tail_slot: Node3D

var pelvis: MeshInstance3D
var torso: MeshInstance3D
var waist: MeshInstance3D  # cintura/lumbar — cierra el hueco torso->pelvis (ver _build)
# jerkin/strap MIGRARON a character_outfit.gd (Fase Migración de Ropa,
# debate orquestador↔QA 2026-07-13, GO del director) — el cuerpo base ya no
# fabrica ropa fosilizada; build_frontier() la cuelga como outfit aditivo.
var goggles: Node3D
var skull: MeshInstance3D
var jaw_mesh: MeshInstance3D  # renamed from "jaw" to avoid shadowing Node3D.get_name
var cheeks: Array = []
var eyes: Array = []
var brows: Array = []
var legs: Array = []
var arms: Array = []
var prosthetic: Node3D
var veins: Array = []

# ---- materials (per-rig so colors are independent) ----
var skin_mat: ShaderMaterial
var lip_mat: ShaderMaterial
var lip_mat_lower: ShaderMaterial
var mouth_seam_mat: ShaderMaterial
var head_mat: ShaderMaterial
var hair_mat: ShaderMaterial
var leather_mat: ShaderMaterial
var dark_leather_mat: ShaderMaterial
var metal_mat: ShaderMaterial
var accent_glow_mat: StandardMaterial3D
var vein_mat: StandardMaterial3D
var eye_white_mat: StandardMaterial3D
var iris_mat: StandardMaterial3D
var pupil_mat: StandardMaterial3D

var accent: Color = Color("#46e6ff")

# Per-origin visual state
var _spark_particles: GPUParticles3D = null   # ironblooded sparks node
var _fur_slot: Node3D = null                  # miststalker fake-fur node
var _iron_armor: Array = []                   # ironblooded armor pieces: [{node, base}]

# Motion / animation state
var _t: float = 0.0
var _phase: float = 0.0
var _motion_speed: float = 0.0
var _motion_crouch: bool = false
var _motion_slide: bool = false        # true while sliding — uses a dedicated low pose
var _hip_crouch: float = 0.0           # smoothed 0..1 crouch amount for hip back+down offset
var _attack_timer: float = 0.0
var _attack_style: String = "melee"

# ---- PRD-006 alcance 0: biomech strike + joint constraints ----
const _Biomech = preload("res://character/rig_biomech.gd")
var _strike_t: float = 0.0             # remaining strike time (seconds); <=0 = inactive
var _strike_dur: float = 0.0           # total duration of the current strike
var _constraint_report: Dictionary = {}  # per-joint attempted-violation stats

# ---- Benchmark Biomecánico: pose stepping "on 2s" (Sable/Xrd) ----
# The VISIBLE pose is sampled at ~12 Hz and held (comic-book rhythm);
# gameplay stays continuous — strike timers/phases advance every frame at
# 60 fps, so combat windows and hitboxes never step. Toggle for A/B review.
var animation_on_twos: bool = true
const POSE_STEP: float = 1.0 / 12.0
var _pose_clock: float = 0.0

# Body pop (A/B 2026-07-06, director): el MESH visible también holdea su
# offset de mundo entre ticks de pose — el personaje entero popea (Sable),
# no solo las extremidades. La raíz/gameplay sigue continua; el hold vive
# en X/Z + yaw del nodo body (body.position.y pertenece a crouch/slide).
# Ronda 2 (director: "se siente con lag"): MOVING HOLD — el offset del
# hold se capea, así el cuerpo acompaña a la raíz con un retraso acotado
# y el pop queda como textura de chop constante, no como trailing.
# VEREDICTO A/B (director, 2026-07-06, 3 rondas): el pop de cuerpo NO
# paga su costo — ni completo (lag), ni con moving hold, ni a 24 Hz.
# CANON: stepping en 2s SOLO en extremidades; el cuerpo (raíz+mesh) corre
# suave a 60. El mecanismo queda implementado tras este toggle (default
# OFF) por si el alcance 1 (poses extremas) reabre la pregunta.
var body_pop_on_twos: bool = false
const BODY_POP_STEP: float = 1.0 / 24.0  # cuerpo en "1s y medio": 24 Hz
const BODY_POP_SNAP: float = 1.5    # saltos de raíz mayores re-anclan sin pop
const BODY_POP_MAX: float = 0.15    # tope de trailing (m) — red anti-lag
const BODY_POP_MAX_YAW: float = 0.2 # tope de hold de giro (rad, ~11°)
var _body_pop_clock: float = 0.0
var _held_root_pos: Vector3 = Vector3.INF
var _held_root_yaw: float = 0.0

# Cache keys to avoid redundant texture/hair rebuilds
var _head_tex_key: String = ""
var _hair_key: String = ""
var _beard_key: String = ""
var _origin_id: String = ""

# M9-r2 (review v0.2 CRITICAL 2): banda de pintura en el brazo — acompaña
# al warpaint facial (identidad del concept: marca en el bíceps izquierdo).
var _arm_stripe: MeshInstance3D = null
# M9-r3: franja de FRENTE como geometría (el v del atlas se comprime no
# lineal en esa banda — irresoluble por textura; ver warpaint_atlas §6).
var _face_mark: MeshInstance3D = null

# ---- archetype silhouette state ----
var _archetype_class: String = ""        # "warrior" / "mage" / "thief" / ""
var _last_p: Dictionary = {}             # last phenotype applied
var _last_origin: Dictionary = {}        # last origin applied
var _focus_orb: MeshInstance3D = null    # Strategist-only floating orb

# ---- Vanguard VFX nodes (warrior only, per-origin) ----
var _aegis_shield: MeshInstance3D = null    # aetherborn warrior: teal emissive shield
var _thruster_l: GPUParticles3D = null      # ironblooded warrior: left steam jet
var _thruster_r: GPUParticles3D = null      # ironblooded warrior: right steam jet
var _pack_wisp: MeshInstance3D = null       # miststalker warrior: spectral wisp orb
var _stealth_decal: MeshInstance3D = null   # miststalker warrior: stealth zone ring
var _wisp_angle: float = 0.0               # orbit angle for wisp

# ---- Strategist VFX nodes (mage only, per-origin) ----
const _CHRONO_SHADER = preload("res://rendering/chrono_field.gdshader")
var _chrono_field: MeshInstance3D = null    # aetherborn mage: temporal refraction dome
var _chrono_decal: MeshInstance3D = null    # aetherborn mage: teal ground AoE ring
var _thermite_embers: GPUParticles3D = null # ironblooded mage: orange ember particles
var _thermite_decal: MeshInstance3D = null  # ironblooded mage: orange ground ring decal
var _shaman_decal: MeshInstance3D = null    # miststalker mage: green-red siphon ring
var _shaman_aura: GPUParticles3D = null     # miststalker mage: green heal particles

# ----------------------------------------------------------------
func _ready() -> void:
	_init_materials()
	_build()
	# C6: sin outline de casco invertido — la línea la pone el Sobel del post.

func _init_materials() -> void:
	skin_mat = ToonMaterials.toon_mat_opaque(Color("#f2b186"))
	# FASE C paso 5: tono de labio propio (rosa cálido, más profundo que la
	# piel) — la boca deja de ser una línea pintada y necesita distinguirse
	# como masa de piel distinta bajo el cel-shading, no un trazo de color.
	# AJUSTE FINO post-QA Ronda 3: 3 rondas moviendo solo posición/escala no
	# lograron que labio sup/inf lean como DOS masas (bloque -> agujero ->
	# bloque otra vez) — el QA sugirió variar TONO además de geometría, para
	# que el toon shading marque la separación y no dependa solo del Sobel.
	# Superior más oscuro/en sombra (el labio superior normalmente recibe
	# menos luz frontal), inferior más claro/rosado (recibe más luz, además
	# de ser el más carnoso).
	lip_mat = ToonMaterials.toon_mat_opaque(Color("#a85f47"))
	lip_mat_lower = ToonMaterials.toon_mat_opaque(Color("#e0947a"))
	# PRD Rework Fenotipo pt.8: la comisura usaba pupil_mat (negro plano,
	# leía "hueco/prótesis") — tono de labio oscurecido, coherente con el
	# resto de la boca en vez de un agujero sin relación de color.
	mouth_seam_mat = ToonMaterials.toon_mat_opaque(Color("#a85f47").darkened(0.55))
	head_mat = ToonMaterials.toon_mat_opaque(Color("#ffffff"))
	hair_mat = ToonMaterials.toon_mat_opaque(Color("#b8451f"))
	leather_mat = ToonMaterials.toon_mat_opaque(Color("#5b4632"))
	dark_leather_mat = ToonMaterials.toon_mat_opaque(Color("#3a2d22"))
	metal_mat = ToonMaterials.toon_mat_opaque(Color("#6f7a88"))
	accent_glow_mat = ToonMaterials.glow_mat(accent, 1.2)
	vein_mat = ToonMaterials.glow_mat(accent, 0.8)

	eye_white_mat = StandardMaterial3D.new()
	eye_white_mat.albedo_color = Color("#f8f6f2")
	eye_white_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	iris_mat = StandardMaterial3D.new()
	iris_mat.albedo_color = accent
	iris_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	pupil_mat = StandardMaterial3D.new()
	pupil_mat.albedo_color = Color("#10131a")
	pupil_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

# ----------------------------------------------------------------
func _build() -> void:
	body = Node3D.new()
	body.name = "body"
	add_child(body)

	# ---------- legs ----------
	hips = Node3D.new()
	hips.name = "hips"
	hips.position.y = 0.95
	body.add_child(hips)

	# r4 (review CRITICAL 1): pelvis un punto más ancha que la cintura — el
	# cambio tórax→cintura→pelvis se LEE en la silueta.
	pelvis = _box_mesh(0.27, 0.16, 0.16, dark_leather_mat)
	pelvis.name = "pelvis"
	pelvis.position.y = -0.01
	hips.add_child(pelvis)
	_add_outline_pass(pelvis, Color("#3a2d22"))

	# belt/buckle_glow MIGRARON a character_outfit.gd (Fase Migración de
	# Ropa) — el cuerpo base ya no fabrica cinturón fosilizado; lo cuelga
	# CharacterOutfit.build_frontier() como pieza aditiva del outfit.

	for side in [-1, 1]:
		var leg = Node3D.new()
		leg.name = "leg_" + ("l" if side == -1 else "r")
		leg.position = Vector3(side * 0.09, 0.0, 0.0)
		hips.add_child(leg)

		# C6a-r2 (feedback del director: "que dejen de ser puros círculos"):
		# la pierna es un volumen que ESTRECHA como en la lámina — muslo
		# masivo arriba → rodilla, pantorrilla → tobillo. Cilindros cónicos,
		# no cápsulas-globo; la rodilla es la única bola (articulación).
		# r4 (review HIGH 5): la pierna tiene TRES volúmenes diferenciados —
		# cuádriceps arriba, rodilla, GEMELO atrás — no un tubo continuo.
		# FASE B (fusión de uniones, QA "maniquí articulado"): el muslo
		# terminaba en radio 0.058 a solo 0.03 del centro de la rodilla
		# (r0.054) — el cono era MÁS GRUESO que la esfera de articulación en
		# ese corte transversal (0.058 > sqrt(0.054²-0.03²)=0.045), así que
		# el muslo asomaba MÁS ANCHO que la rodilla → costura dura (valle de
		# profundidad que el Sobel entinta). Fix: el cono termina más
		# delgado (0.050, "ligeramente menor que la esfera") y penetra
		# HONDO (0.02 más allá del centro de la rodilla, no tangente) —
		# se alarga el cilindro para no mover el extremo de cadera. La
		# rodilla crece a 0.066 ("apenas mayor que ambos conos") para
		# envolver la transición con curvatura convexa continua.
		var thigh = _cylinder_mesh(0.090, 0.050, 0.45, dark_leather_mat)
		thigh.position.y = -0.245
		leg.add_child(thigh)
		_add_outline_pass(thigh, Color("#3a2d22"))

		var knee = Node3D.new()
		knee.name = "knee"
		knee.position.y = -0.45
		leg.add_child(knee)

		var knee_cap = _sphere_mesh(0.066, dark_leather_mat)
		knee_cap.position.y = 0.0
		knee.add_child(knee_cap)
		_add_outline_pass(knee_cap, Color("#3a2d22"))

		# La espinilla también penetra 0.02 más allá del centro de la
		# rodilla (arriba) — mismo criterio que el muslo — Y se alarga
		# hacia ABAJO para cerrar el HUECO real con la bota (el tope de la
		# espinilla quedaba en y=-0.39 mientras la bota empieza en
		# y=-0.405: 1.5 cm de aire/piel visible entre caña y bota).
		# bottom_r sube un poco (0.036→0.040) para fundir mejor con el
		# ancho de la caña.
		var shin = _cylinder_mesh(0.052, 0.040, 0.44, dark_leather_mat)
		shin.position.y = -0.20
		knee.add_child(shin)
		_add_outline_pass(shin, Color("#3a2d22"))

		# GEMELO: masa trasera alta de la pantorrilla (perfil de atleta)
		var calf = _sphere_mesh(0.048, dark_leather_mat)
		calf.scale = Vector3(0.75, 1.6, 0.85)
		calf.position = Vector3(0.0, -0.10, -0.028)
		knee.add_child(calf)
		_add_outline_pass(calf, Color("#3a2d22"))

		# Bota: caña + puntera (review HIGH 7: pies MAYORES — estabilidad
		# visual, contacto con el suelo, lectura en animación)
		var boot = _box_mesh(0.11, 0.09, 0.21, leather_mat)
		boot.position = Vector3(0.0, -0.45, 0.03)
		knee.add_child(boot)
		_add_outline_pass(boot, Color("#5b4632"))
		var toe = _box_mesh(0.10, 0.055, 0.085, leather_mat)
		toe.position = Vector3(0.0, -0.4675, 0.14)
		knee.add_child(toe)
		_add_outline_pass(toe, Color("#5b4632"))

		# Store sub-nodes in metadata (mirrors JS leg.userData)
		leg.set_meta("knee", knee)
		leg.set_meta("thigh", thigh)
		leg.set_meta("shin", shin)
		legs.append(leg)

	# ---------- torso ----------
	# Ronda articulación #3 (2026-07-06): la columna deja de ser monobloque.
	# `spine` es el segmento LUMBAR; `upper_spine` (torácico, a +0.22) carga
	# torso/strap/brazos/cuello/cabeza — el jerkin queda abajo, la bisagra
	# visual vive en el borde jerkin/torso. Posiciones mundiales intactas.
	spine = Node3D.new()
	spine.name = "spine"
	spine.position.y = 1.0
	# PRD Rework Fenotipo pt.13: leve avance de la lumbar (perfil "en tabla"
	# del QA) — posición pura, sin lerp que la sobrescriba (a diferencia de
	# upper_spine.rotation.x, ver DORSAL_CURVE_X arriba).
	spine.position.z = 0.01
	body.add_child(spine)

	upper_spine = Node3D.new()
	upper_spine.name = "upper_spine"
	upper_spine.position.y = UPPER_SPINE_Y
	spine.add_child(upper_spine)

	# C6a-r2: el tronco es UN taper continuo como en la lámina — pecho ancho
	# arriba (hombros cuadrados, no globo) que estrecha hacia la cintura; la
	# cintura (jerkin) retoma el MISMO radio y asienta sobre la pelvis. El
	# V-taper elíptico (CHEST_X/Z) lo aplica _apply_build sobre peso/clase.
	torso = _cylinder_mesh(0.16, 0.11, 0.34, skin_mat)
	torso.position.y = 0.12
	upper_spine.add_child(torso)
	_add_outline_pass(torso, Color("#f2b186"))

	# Fase C (Benchmark-Musculatura-Torso.md): las cajas-peto (pec_plate/
	# clavicle) SE ELIMINAN — leían como armadura de placas, no como
	# músculo (QA d2 ya lo diagnosticaba). Reemplazo: PECTORALES =
	# elipsoides SEMI-HUNDIDAS en el cilindro del torso, mismo patrón
	# gemelo que brazos/piernas (esfera escalada + intersección real con
	# el volumen anfitrión → el Sobel entinta la curva de intersección,
	# no un rectángulo). Receta del debate orquestador↔QA: r 0.05, escala
	# (1.4, 0.9, 0.5), centros x=±0.055 / y=0.21 / z=0.115. Verificado
	# contra el radio real del cilindro en y=0.21 (interpolado top 0.16 /
	# bot 0.11 sobre height 0.34): r_cyl≈0.148 → el borde del pec
	# (z=0.115+0.025=0.140) queda LIGERAMENTE hundido (~0.008), no proud;
	# el valle esternal lo dibuja la curva de intersección entre ambos
	# elipsoides (se solapan ~3 cm en el centro — mismo mecanismo de
	# "anillo" que el gemelo, aquí en par para el valle).
	for pside in [-1, 1]:
		var pec = _sphere_mesh(0.05, skin_mat)
		pec.scale = Vector3(1.4, 0.9, 0.5)
		pec.position = Vector3(float(pside) * 0.055, 0.21, 0.115)
		upper_spine.add_child(pec)
		_add_outline_pass(pec, Color("#f2b186"))

	# CLAVÍCULA: cápsula finísima por lado (r 0.012), del esternón al
	# hombro, con leve V (ángulo asimétrico) — sugiere el hueso sin
	# fabricar una costura dura. Semi-hundida sobre la línea de los pecs.
	for cside in [-1, 1]:
		var clavicle = _capsule_mesh(0.012, 0.075, skin_mat)
		clavicle.rotation.z = PI / 2.0 - float(cside) * 0.14   # V hacia el esternón
		clavicle.position = Vector3(float(cside) * 0.075, 0.282, 0.116)
		upper_spine.add_child(clavicle)
		_add_outline_pass(clavicle, Color("#f2b186"))

	# PLACA ABDOMINAL: 1 elipsoide aplastada única — plano tenso de
	# abdomen enjuto, SIN six-pack ni ombligo (tabla SÍ/NO de la rúbrica).
	# r 0.055, escala (1.1, 1.6, 0.4), y=0.02 (bajo el pecho), z=0.105.
	# En y=0.02 el radio del cilindro interpola a ≈0.120; el borde del
	# abdomen (z=0.105+0.022=0.127) protruye ~0.007 (≈12% de su propio
	# radio, dentro del tope ≤30%) — plano-tenso, no cóncavo ni barril.
	# NOTA (Migración de Ropa, 2026-07-13): el jerkin fosilizado que tapaba
	# esta masa MIGRÓ a character_outfit.gd (faja envuelta con margen real
	# sobre z=0.127 — ver _attach_waist_wrap) — la anatomía queda desnuda
	# aquí a propósito (banco tmp_anatomy.gd no llama outfit).
	# PRD Rework Fenotipo pt.12 (2026-07-14): QA de cuerpo completo la leyó
	# "óvalo sin correspondencia" — scale.z (protrusión) recortada 0.4→0.30
	# y scale.x (ancho) subida 1.1→1.25 para un borde más gradual contra el
	# cilindro del torso. Si sigue leyendo "óvalo", bajar a ~0.22 (no
	# insistir en 0.30 per nota del QA).
	var abs_plate = _sphere_mesh(0.055, skin_mat)
	abs_plate.scale = Vector3(1.25, 1.6, 0.30)
	abs_plate.position = Vector3(0.0, 0.02, 0.105)
	upper_spine.add_child(abs_plate)
	_add_outline_pass(abs_plate, Color("#f2b186"))

	# CINTURA (lumbar): cierra el HUECO real entre el borde del abdomen
	# (abs_plate, mundo y≈1.172 al fondo) y el tope de la pelvis (mundo
	# y≈1.02) — auditoría 2026-07-13 (faja/jerkin migrado a outfit dejaba
	# la anatomía DESNUDA con 15 cm de vacío ahí; con outfits sin playera
	# se veía fondo a través del torso). Cilindro de piel, hijo de `spine`
	# (frame lumbar, coincide con el mundo de `hips`/`upper_spine`):
	# top_radius=0.11 = MISMO radio base que el fondo del cilindro del
	# torso (línea torso arriba) — al copiarle exactamente torso.scale.x/z
	# en _apply_build, el borde superior queda IDÉNTICO en cualquier build
	# (mismo factor elíptico CHEST_X/Z), costura cero. bottom_radius=0.085
	# funde con el ancho de la pelvis (half x≈0.144, half z≈0.08 en build
	# neutro) sin que sobresalga. Altura 0.22, y=0.08 (spine-local): borde
	# superior en spine-y=0.19 (mundo 1.19, = fondo del torso) y borde
	# inferior en spine-y=-0.03 (mundo 0.97), 5 cm HONDO dentro de la
	# pelvis (tope en mundo 1.02) — overlap real, no tangente, mismo
	# criterio que las uniones de pierna/brazo (evita costura por huecos
	# de precisión flotante).
	waist = _cylinder_mesh(0.11, 0.085, 0.22, skin_mat)
	waist.position = Vector3(0.0, 0.08, 0.0)
	spine.add_child(waist)
	_add_outline_pass(waist, Color("#f2b186"))

	# r3: TRAPECIOS — la línea del hombro BAJA del cuello al deltoide (lámina:
	# sloped shoulders); mata la repisa cuadrada de la tapa del cilindro.
	# QA 2026-07-13 (b/extra): caída 0.27→0.40 rad (~23°, la de la lámina),
	# centro afuera para que la punta ATERRICE sobre el tope del deltoide
	# (una sola línea cuello→brazo, sin remontar).
	# PRD Rework Fenotipo pt.3 (2026-07-14): la CAJA sobre el cilindro del
	# torso siempre deja arista visible (caras planas intersectando una
	# superficie curva) — reemplazada por esfera escalada semi-hundida,
	# mismo patrón que `pec`/`deltoid` arriba (masa de silueta, no plano).
	# PRD Rework Fenotipo pt.4 (2026-07-14): ángulo 0.40→0.28 rad (~16°) —
	# el QA de cuerpo completo leyó los hombros angostos; primer paso de
	# menor riesgo antes de tocar SHOULDER_X (decisión de Boris si no basta).
	for tside in [-1, 1]:
		var trap = _sphere_mesh(0.10, skin_mat)
		trap.scale = Vector3(1.6, 0.6, 0.7)
		trap.position = Vector3(float(tside) * 0.115, 0.315, 0.0)
		trap.rotation.z = -float(tside) * 0.28
		upper_spine.add_child(trap)
		_add_outline_pass(trap, Color("#f2b186"))

	# jerkin/strap MIGRARON a character_outfit.gd (Fase Migración de Ropa,
	# debate orquestador↔QA 2026-07-13, GO del director): el cilindro de
	# cuero en la cintura (spine y=0.16) y la bandolera diagonal (upper_spine)
	# ya no viven fosilizados en el cuerpo base — CharacterOutfit.
	# build_frontier(rig) los reemplaza por la FAJA ENVUELTA + cinturón
	# diagonal fiel a fenotipo-humano-v1.png. El torso queda desnudo aquí
	# a propósito (banco de anatomía tests/tmp_anatomy.gd NO llama outfit).

	# Pauldron is built AFTER arms loop so arm_r (arms[1], side==1) exists.
	# It will be added to arm_r after that loop runs — placeholder here.

	# ---------- arms ----------
	for side in [-1, 1]:
		var arm = Node3D.new()
		arm.name = "arm_" + ("l" if side == -1 else "r")
		# Hombros del canon: en la línea 1.55 (SHOULDER_Y sobre el torácico)
		# y abiertos a ±SHOULDER_X — el deltoide NACE del pecho, sin hueco lego.
		arm.position = Vector3(side * SHOULDER_X, SHOULDER_Y, 0.0)
		upper_spine.add_child(arm)

		# C6a-r2: brazo que ESTRECHA — deltoide (bola de hombro) → codo →
		# muñeca fina → mano de MITÓN (caja, no esfera). Como la lámina.
		# r4 (review CRITICAL 4): masa de ATLETA, no de personaje delgado —
		# bíceps/antebrazo suben sin llegar a heroico; el deltoide crece y
		# funde la transición hombro-brazo (LOW 15).
		# FASE B (fusión de uniones, QA "maniquí articulado"): igual que la
		# pierna, hombro/codo solo TOCABAN el centro de su esfera (embed=0,
		# tangencia pura) → el Sobel entinta el anillo de tangencia. Peor
		# aún, el antebrazo (top_r 0.054) era MÁS GRUESO que la esfera del
		# codo (r 0.045) en su propio corte transversal — asomaba por fuera
		# del codo. Fix uniforme: cada esfera de articulación crece "apenas
		# mayor que ambos conos" y cada cono PENETRA 0.02 más allá del
		# centro de su esfera (no tangente) — se alargan los cilindros para
		# no mover el extremo libre (hombro/mano) ya aprobado.
		# FASE B r2 (feedback director: "hombros abultados, muñecas
		# inexistentes, músculos poco marcados"): el deltoide de r1 (r0.076,
		# esfera pura) leía como hombrera/globo. Encoge a r0.066 y lo
		# ACHATA con escala no-uniforme (0.95, 1.15, 0.9) — gota que
		# ENVUELVE el hombro (más alto que ancho, más angosto que profundo)
		# en vez de bola. Centro sube apenas (y −0.01→−0.006) y se sesga
		# afuera+adelante (x=side*0.010, z=0.008) para leer músculo
		# deltoides real, no repisa. Costura con "upper" INTACTA: el cono
		# sigue tocando en y=0.01 (arm-local), que ahora queda 0.016 por
		# encima del centro del deltoide (antes 0.02) — MÁS margen de
		# solape que r1, no menos, porque el radio efectivo en Z/X de la
		# elipsoide en ese corte (~0.057-0.060) sigue por encima del
		# top_r del cono (0.056) — no hay asomo, no se reabre el anillo.
		# QA 2026-07-13 (b/c): el tope del deltoide subía SOBRE la línea del
		# trapecio → la silueta bajaba y REMONTABA (charretera). Estirado
		# vertical fuera (1.15→1.0) y centro más abajo (−0.006→−0.02): el
		# deltoide vive SIEMPRE bajo la línea descendente cuello→brazo. Con
		# el pivote nuevo (0.21) su borde interior queda DENTRO del cilindro
		# del pecho → solape real, muere la costura pecho-hombro.
		var deltoid = _sphere_mesh(0.066, skin_mat)
		deltoid.scale = Vector3(0.95, 1.0, 0.9)
		deltoid.position = Vector3(side * 0.010, -0.02, 0.008)
		arm.add_child(deltoid)
		_add_outline_pass(deltoid, Color("#f2b186"))

		var upper = _cylinder_mesh(0.056, 0.040, 0.35, skin_mat)
		upper.position.y = -0.165
		arm.add_child(upper)
		_add_outline_pass(upper, Color("#f2b186"))

		# FASE B r2: BÍCEPS (masa frontal) y TRÍCEPS (masa trasera) del
		# brazo superior — mismo patrón que el GEMELO de la pierna (~L331):
		# esfera escalada, semi-hundida, el escalón del cel lee el volumen.
		# r2b (ronda visual del orquestador): la v1 desplazaba SOLO en Z →
		# de FRENTE la silueta del brazo no cambiaba nada y el músculo no
		# se leía (el banco captura de frente). El bulto se lee por el
		# ensanchamiento LATERAL: componente X hacia afuera (side*) además
		# del sesgo Z, y masas un punto más grandes.
		# r2c: 0.014 de X seguía invisible a distancia de banco (verificado
		# por hash de capturas — el cambio cargaba, solo era chico). El
		# gemelo protruye ~30% de su radio; estas masas apuntan a lo mismo.
		# r2d (feedback director: "baja el tamaño pero APLÁSTALOS, no los
		# encojas — que mantengan su ubicación"): posiciones y largo (eje Y)
		# INTACTOS; solo se aplastan los ejes radiales X/Z ~20-25% — el
		# músculo sigue naciendo/muriendo donde debe, pero protruye menos.
		var bicep = _sphere_mesh(0.046, skin_mat)
		bicep.scale = Vector3(0.72, 1.45, 0.72)
		bicep.position = Vector3(side * 0.020, -0.125, 0.034)   # afuera + frente
		arm.add_child(bicep)
		_add_outline_pass(bicep, Color("#f2b186"))

		var tricep = _sphere_mesh(0.043, skin_mat)
		tricep.scale = Vector3(0.68, 1.35, 0.72)
		tricep.position = Vector3(side * 0.016, -0.175, -0.034)  # afuera + espalda
		arm.add_child(tricep)
		_add_outline_pass(tricep, Color("#f2b186"))

		var elbow = Node3D.new()
		elbow.name = "elbow"
		elbow.position.y = -0.32   # codo en la línea del ombligo (1.23)
		arm.add_child(elbow)

		var elbow_cap = _sphere_mesh(0.058, skin_mat)
		elbow_cap.position.y = 0.0
		elbow.add_child(elbow_cap)
		_add_outline_pass(elbow_cap, Color("#f2b186"))

		# FASE B r2 (feedback director: "muñecas inexistentes" — el
		# antebrazo terminaba en bot_r=0.036, casi el mismo grosor que la
		# mano, así que no había estrechamiento visible). bot_r baja a
		# 0.026 (rango pedido 0.024-0.028) — la muñeca vuelve a ser el
		# punto MÁS DELGADO del brazo. top_r/height/position INTACTOS: la
		# punta del cono (elbow-local y=-0.285) no se mueve, así que la
		# mano tampoco pierde su solape con ella (mismo criterio de
		# penetración que ya tenía, solo que ahora es un cono AFILADO, no
		# grueso).
		var fore = _cylinder_mesh(0.048, 0.026, 0.305, skin_mat)
		fore.position.y = -0.1325
		elbow.add_child(fore)
		_add_outline_pass(fore, Color("#f2b186"))

		# FASE B r2: masa del ANTEBRAZO (brachioradialis) — bulto superior
		# cerca del codo que adelgaza hacia la muñeca, mismo patrón GEMELO.
		# Semi-hundida en "fore" (cono ya con top_r=0.048 ahí cerca), sesgo
		# frontal (+Z) que se funde con el bíceps por encima del codo.
		# r2b: mismo fix que bíceps/tríceps — componente X hacia afuera
		# (la masa del antebrazo/brachioradialis se lee del lado del pulgar)
		# y un punto más grande para que el cel la agarre de frente.
		# r2d: mismo aplastado que bíceps/tríceps (posición intacta).
		var forearm_mass = _sphere_mesh(0.042, skin_mat)
		forearm_mass.scale = Vector3(0.72, 1.4, 0.68)
		forearm_mass.position = Vector3(side * 0.018, -0.075, 0.026)
		elbow.add_child(forearm_mass)
		_add_outline_pass(forearm_mass, Color("#f2b186"))

		# FASE B r2: MUÑECA — esferita escalada que funde la punta afilada
		# del antebrazo (r0.026) con la mano, sin mover la mano (meta de
		# montaje de arma intacta). "Apenas mayor" que bot_r del cono,
		# achatada (scale) para no engordar la lectura de "punto más fino".
		var wrist_cap = _sphere_mesh(0.030, skin_mat)
		wrist_cap.scale = Vector3(0.9, 0.8, 0.95)
		wrist_cap.position = Vector3(0.0, -0.285, 0.0)   # punta del cono "fore"
		elbow.add_child(wrist_cap)
		_add_outline_pass(wrist_cap, Color("#f2b186"))

		# r4 (review HIGH 6): mano con PRESENCIA — llega a media pierna.
		# r5b (feedback del director: "hay tres masas — pulgar más dos"):
		# la mano lee como MANO, no como garra — palma + CUATRO dedos
		# individuales delgados (ranura ~3 mm entre cada uno: el Sobel
		# entinta las separaciones en close-up y a distancia se funden en
		# una masa) con largos naturales (medio > índice ≈ anular > meñique)
		# + PULGAR hacia el cuerpo. La línea hace el trabajo.
		var hand = _box_mesh(0.064, 0.062, 0.066, skin_mat)
		hand.position.y = -0.30
		hand.rotation.x = -0.12   # curl relajado de la lámina
		elbow.add_child(hand)
		_add_outline_pass(hand, Color("#f2b186"))

		# offsets del índice→meñique (x local); el índice queda del lado
		# del pulgar (interior). Largos por dedo, medio el más largo
		# (r5c, director: +20% de largo en los cuatro).
		# PRD Rework Fenotipo pt.6 (2026-07-14): gap efectivo era ~0.38mm
		# (prácticamente fundido pese a que el comentario histórico decía
		# "~3mm") — offsets separados a gap ~1.4mm limpio + nudillo (esfera
		# chica semi-hundida en la base de cada dedo, mismo patrón de
		# overlap real que codo/rodilla) para que el Sobel entinte tanto la
		# ranura entre dedos como el quiebre nudillo→falange.
		var f_off: Array = [0.025, 0.010, -0.010, -0.025]
		var f_len: Array = [0.067, 0.076, 0.070, 0.055]
		for fi in range(4):
			var f_l: float = f_len[fi]
			var f_x: float = -float(side) * float(f_off[fi])
			# r5e (director): dedos 10% más delgados (sección 0.0108×0.038)
			var finger = _box_mesh(0.0108, f_l, 0.038, skin_mat)
			finger.position = Vector3(f_x, -0.027 - f_l * 0.5, 0.006)
			finger.rotation.x = -0.22   # los dedos doblan más que la palma
			hand.add_child(finger)
			_add_outline_pass(finger, Color("#f2b186"))

			var knuckle = _sphere_mesh(0.007, skin_mat)
			knuckle.scale = Vector3(1.0, 0.75, 1.0)
			knuckle.position = Vector3(f_x, -0.027, 0.008)
			hand.add_child(knuckle)
			_add_outline_pass(knuckle, Color("#f2b186"))

		# r5c (director): el pulgar APUNTA en la misma dirección que los
		# dedos (cuelga hacia abajo), abierto 30° respecto a ellos hacia
		# el interior — ya no cruza horizontal.
		# r5d (director, ref. anatómica Cleveland Clinic): el pulgar NACE
		# de la eminencia tenar — a media palma, cerca de la muñeca — no
		# del borde inferior; nacimiento 50% más adentro de la mano.
		# PRD Rework Fenotipo pt.6: de caja de sección uniforme (leía
		# "ranura paralela" a los dedos) a cápsula — extremos redondeados
		# lo distinguen de los dedos-caja sin cambiar largo/ángulo.
		var thumb = _capsule_mesh(0.014, 0.05, skin_mat)
		thumb.position = Vector3(-float(side) * 0.038, -0.022, 0.010)
		thumb.rotation.z = -float(side) * 0.5236   # 30° de apertura
		thumb.rotation.x = -0.25
		hand.add_child(thumb)
		_add_outline_pass(thumb, Color("#f2b186"))

		arm.set_meta("elbow", elbow)
		arm.set_meta("upper", upper)
		arm.set_meta("fore", fore)
		arm.set_meta("hand", hand)
		arm.set_meta("side", side)
		arms.append(arm)

	# ---------- pauldron (right shoulder armor) ----------
	# Parent to arm_r (arms[1], side==1) so it sits on the shoulder joint and follows arm swing.
	# Local position (0, 0.03, 0) = just above the arm root = top of shoulder cap.
	var arm_r: Node3D = arms[1]
	var pauldron = Node3D.new()
	# C6a-r2: asentado SOBRE el deltoide nuevo (r 0.062) — antes flotaba al
	# nivel de la oreja, dimensionado para el hombro-globo del puerto.
	pauldron.position = Vector3(0.0, 0.015, 0.0)
	pauldron.rotation.z = -0.12
	var plate_a = _box_mesh(0.115, 0.032, 0.125, metal_mat)
	_add_outline_pass(plate_a, Color("#6f7a88"))
	var plate_b = _box_mesh(0.088, 0.028, 0.098, metal_mat)
	plate_b.position.y = 0.036
	_add_outline_pass(plate_b, Color("#6f7a88"))
	var stud = _box_mesh(0.03, 0.018, 0.03, accent_glow_mat)
	stud.position.y = 0.058
	pauldron.add_child(plate_a)
	pauldron.add_child(plate_b)
	pauldron.add_child(stud)  # stud = glow, no outline
	arm_r.add_child(pauldron)

	# Prosthetic aether forearm (left arm [0], shown at high arcaneMod)
	var left_elbow: Node3D = arms[0].get_meta("elbow")
	prosthetic = Node3D.new()
	prosthetic.name = "prosthetic"

	var proseg = _box_mesh(0.075, 0.2, 0.075, metal_mat)
	proseg.position.y = -0.12
	_add_outline_pass(proseg, Color("#6f7a88"))

	var seam1 = _box_mesh(0.012, 0.18, 0.078, vein_mat)
	seam1.position = Vector3(0.034, -0.12, 0.0)
	# seam1 = glow, no outline

	var fist = _box_mesh(0.085, 0.07, 0.08, metal_mat)
	fist.position.y = -0.29
	_add_outline_pass(fist, Color("#6f7a88"))

	var knuckle = _box_mesh(0.087, 0.018, 0.082, vein_mat)
	knuckle.position.y = -0.265
	# knuckle = glow, no outline

	prosthetic.add_child(proseg)
	prosthetic.add_child(seam1)
	prosthetic.add_child(fist)
	prosthetic.add_child(knuckle)
	prosthetic.visible = false
	left_elbow.add_child(prosthetic)

	# ---------- head ---------- (colgada del torácico)
	# Cuello con taper — v0.1 pedía que EXISTIERA; v0.2/v0.3/v0.4 lo fueron
	# acortando. v0.4 H3 (PROMOVIDO, 3ª ronda): −30% → 0.10 de largo, base
	# 0.075 fundida al trapecio; la cabeza baja con él (HEAD_Y 0.505).
	# Fase C (debate orquestador↔QA 2026-07-13): +15% de largo — 0.10→0.115
	# (criterio: caída barbilla→hombro ~0.55 cabezas, la barbilla no roza la
	# línea de hombros en 3/4). NECK_Y/HEAD_Y suben el mismo delta arriba.
	var neck = _cylinder_mesh(0.050, 0.075, 0.115, skin_mat)
	neck.position.y = NECK_Y
	upper_spine.add_child(neck)
	_add_outline_pass(neck, Color("#f2b186"))

	head = Node3D.new()
	head.name = "head"
	head.position.y = HEAD_Y
	# C6a: el pivote entero de la cabeza escala ×0.84 — cráneo, cara, pelo,
	# barba y goggles bajan JUNTOS a la cabeza de 7.5; sus layouts internos
	# (hair_library, warpaint) no se tocan. La cara en sí es C6c.
	head.scale = Vector3.ONE * HEAD_SCALE
	upper_spine.add_child(head)

	# C6c (comparación contra la lámina): el cráneo tiene FORMA — más angosto
	# que alto, nuca redondeada; ya no es la pelota chibi.
	# M9-r3 (review v0.3 HIGH 3): fuera el ovoide — cráneo compacto; el
	# ancho lo domina la MANDÍBULA (trapecio invertido), no las mejillas.
	skull = _sphere_mesh(0.15, head_mat)
	skull.name = "skull"
	skull.scale = Vector3(0.82, 1.02, 0.95)
	# Godot SphereMesh: seam at -Z, so u=0.5 (face strip) faces +Z by default.
	skull.rotation.y = 0.0
	head.add_child(skull)
	_add_outline_pass(skull, Color("#f2b186"))

	# M9-r2 (review v0.2 HIGH 4): mandíbula más ANCHA y cuadrada — la
	# estructura del concept es amable y curtida, no fina y joven. El
	# mentón se funde en la mandíbula (fuera la costura vertical dura).
	# (jaw/cheeks en skin_mat — M9-r2b: sus UVs de caja/esfera muestrean el
	# atlas SIN control y embarran el warpaint; la textura vive en el cráneo)
	# r3 (review v0.3): la mandíbula DOMINA el ancho bajo. M9-r6 (director):
	# TRAPECIO, no rectángulo — ancha en la línea de las orejas, estrechando
	# hacia el mentón (afila las facciones). Prisma de 4 caras con taper
	# (cilindro de 4 segmentos girado 45°, mismo truco que la nariz); la
	# relación ancho/profundidad la pone el slider de jaw en apply_phenotype.
	# FASE C paso 1 (luz verde del director 2026-07-13, propuesta por masas):
	# la mandibula ya NO es un prisma de 4 caras + caja de menton apilados
	# (esos eran los dos ofensores de costura del r5). Ahora es UNA masa
	# redondeada (esfera escalada) que PENETRA dentro del craneo (overlap
	# real, no tangente — misma leccion que las uniones de pierna/brazo): el
	# borde superior queda ~2 cm DENTRO del craneo, asi el cel-step lee un
	# craneo->mandibula continuo y el Sobel entinta solo el contorno externo,
	# sin anillo de costura. Mas angosta que el craneo en X (mandibula fina,
	# lamina: "fine narrow jaw continuing the line of the skull") y el borde
	# inferior forma el menton suave (fuera la caja dura). El menton se funde
	# aqui (ya no hay nodo `chin` aparte). skin_mat: el atlas de warpaint solo
	# vive en el craneo (M9-r2b), la mandibula va en piel plana.
	jaw_mesh = _sphere_mesh(0.12, skin_mat)
	jaw_mesh.name = "jaw"
	# X0.78 (angosta) · Y0.84 (largo craneo->menton) · Z0.94 (plano facial)
	jaw_mesh.scale = Vector3(0.78, 0.84, 0.94)
	# y=-0.048: tope en y=+0.053 (bien dentro del craneo), menton en y=-0.149
	# — calibrado para 7.5 cabezas canon (alto menton->coronilla 0.253 m; el
	# -0.085 inicial colgaba el menton a 6.67 cabezas, cara larga). z=0.026:
	# frente de la mandibula en z=0.139, al ras del plano facial del craneo
	# (0.1425), con el menton bajo la nariz.
	jaw_mesh.position = Vector3(0.0, -0.048, 0.026)
	head.add_child(jaw_mesh)
	_add_outline_pass(jaw_mesh, Color("#f2b186"))

	# ÁNGULO GONÍACO — AJUSTE FINO post-QA (2026-07-14, veredicto del
	# director: "totalmente alejada" de la lámina). La esfera única de
	# `jaw_mesh` tiene curvatura uniforme en todo su perímetro -> ningún
	# punto del contorno lee como quiebre óseo, la cara entera se ve
	# "óvalo/blob" en vez de "por masas". Se agrega una masa chica en la
	# zona donde la mandíbula gira de vertical (rama, junto a la oreja) a
	# horizontal (cuerpo) — MISMO truco de overlap real (hundida en
	# jaw_mesh, sin costura), pero rompe la curvatura continua con un
	# segundo radio distinto, dando el ángulo que el Sobel puede entintar.
	for gside in [-1, 1]:
		var jaw_angle = _sphere_mesh(0.050, skin_mat)
		jaw_angle.scale = Vector3(0.55, 0.35, 0.85)
		jaw_angle.position = Vector3(gside * 0.095, 0.00, 0.050)
		head.add_child(jaw_angle)
		_add_outline_pass(jaw_angle, Color("#f2b186"))

	# MENTÓN CENTRAL — AJUSTE FINO post-QA Ronda 2 (PRD punto 8): el ángulo
	# goníaco de arriba solo cubre la zona junto a la oreja; el mentón en
	# sí (x=0, cerca de la punta y=-0.149 de `jaw_mesh`) seguía redondo/
	# blando. Cerca del polo de la elipsoide la proyección Z se achica
	# mucho (jaw solo llega a z≈0.072 ahí) — un bulto chico ahí, con más
	# proyección Z propia, da la punta de mentón que la lámina pide, sin
	# invadir la boca (labios en y=-0.069/-0.087, este bulto vive más abajo).
	# AJUSTE FINO post-QA Ronda 3: la esfera (`chin_boss` v1) atenuó la
	# redondez pero una esfera NUNCA da un borde recto — el QA señaló que
	# la lámina tiene mentón cuadrado/definido, no una bola. Cambiado a
	# CAJA (borde inferior recto real), mismo hundimiento por overlap.
	# AJUSTE FINO Ronda 4: el QA notó un canto/borde flotante — protrusión
	# ~2cm más allá de la superficie del jaw en ese punto, demasiado poco
	# hundimiento para una caja (una caja plana sobre una superficie curva
	# SIEMPRE deja un escalón visible donde no es tangente; necesita más
	# overlap que una esfera para integrarse). Recesado 0.086→0.080
	# (protrusión ahora ~1.3cm en vez de ~2cm).
	# AJUSTE FINO Ronda 6: ensanchado (0.052→0.058) para un mentón cuadrado
	# más definido, siguiendo la lámina.
	# AJUSTE FINO post-QA (barba quitada, mentón por fin visible sin tapar):
	# la cara frontal quedaba en z≈0.098 — ~4.7cm DETRÁS de la cara frontal
	# de `lip_lower` (z≈0.145). El mentón nunca competía visualmente con el
	# labio inferior: el punto más adelantado de esa zona era la boca, no
	# la mandíbula, al revés de la lámina (mentón marcado, el rasgo más
	# anguloso de la cara). Profundidad y posición subidas para que la cara
	# frontal iguale/supere levemente al labio (z≈0.148).
	# Primer intento (z=0.109, prof. 0.078, front≈0.148) se pasó de rosca —
	# leía como mandíbula protuberante/bulldog, no mentón marcado. Bajado a
	# un punto intermedio (front≈0.125, entre el 0.098 original y el 0.148
	# exagerado).
	var chin_boss = _box_mesh(0.058, 0.032, 0.055, skin_mat)
	chin_boss.position = Vector3(0.0, -0.134, 0.0975)
	head.add_child(chin_boss)
	_add_outline_pass(chin_boss, Color("#f2b186"))

	# NARIZ — FASE C paso 4 (luz verde director): cuña INTEGRADA. Antes era
	# un prisma de 4 caras con cap plano flotando SOBRE la piel (sin overlap)
	# -> costura visible en la base, "pegado" al cráneo en vez de nacer de él.
	# Mismo truco de fusión que mandíbula/pómulo: la RAÍZ (puente, arriba)
	# se encoge casi a un punto (top_r≈0) y se HUNDE ~1.6 cm dentro del
	# cráneo (overlap real) — sin cap visible, el cel-step lee cráneo->nariz
	# continuo. La PUNTA (abajo) es el extremo ancho (bot_r) que sí proyecta
	# fuera del cráneo (~8-9 mm), como pide la lámina (cuña que abre hacia
	# la base). Arista al frente (PI/4) conserva el facetado de prisma.
	# AJUSTE FINO post-QA (Ronda 6): "se aplana en vista frontal" — con
	# bot_r 0.017 la cuña era angosta y su facetado apenas contrastaba de
	# frente (la arista al frente reparte la luz simétrico entre 2 caras
	# chicas). Base ensanchada (0.017→0.021) y protrusión subida (z 0.136→
	# 0.139) para más volumen visible desde cámara frontal, sin perder el
	# facetado de prisma (M9-r3) ni la raíz hundida.
	# AJUSTE FINO Ronda 8 — PRUEBA DE DIAGNÓSTICO (misma técnica que resolvió
	# la boca): la arista-al-frente (rotation.y=PI/4) reparte la luz
	# simétrica entre 2 caras chicas iguales -> poco contraste frontal, sin
	# importar cuánto se agrande la base (ya se probó en Ronda 6-7). Prueba
	# exagerada: CARA plana al frente (rotation.y=0, no arista) — una cara
	# put a la cámara + dos caras laterales en sombra debería dar un
	# quiebre de tono real (puente iluminado, lados oscuros), y bot_r subido
	# fuerte (0.021→0.030) para confirmar el umbral de visibilidad.
	# La prueba (bot_r 0.030, cara plana) SÍ resolvió el frontal — el
	# quiebre de tono cara-iluminada/lados-en-sombra lee mucho mejor que la
	# arista simétrica. Calibrado hacia abajo desde el extremo de la prueba.
	# PRD Rework Fenotipo pt.9 (2026-07-14): "prisma muy ancho/duro en
	# frontal" — bot_r angostado 0.026→0.019. NO se tocan radial_segments
	# (el PRD proponía 4→6-8): con N=4 y rotation.y=0 hay una CARA plana
	# exactamente al frente (el fix de Ronda 8, documentado arriba, que
	# resolvió 3 rondas de facetado ilegible); con N par >4 ningún múltiplo
	# de rotation.y deja una cara centrada en +Z, así que subir segmentos
	# reintroduce el problema que Ronda 8 cerró. Ángulo de facetas sin
	# tocar; solo se angosta la base.
	var nose = _cylinder_mesh(0.0015, 0.019, 0.062, skin_mat)
	(nose.mesh as CylinderMesh).radial_segments = 4
	nose.position = Vector3(0.0, -0.010, 0.139)
	nose.rotation.x = -0.34   # raíz hundida arriba, punta proyecta frente-abajo
	nose.rotation.y = 0.0     # cara plana al frente (fix Ronda 8, no arista)
	head.add_child(nose)
	_add_outline_pass(nose, Color("#f2b186"))

	# ALAS de la nariz: el M9-r3 pedía que la cuña "abriera a base/alas" y
	# nunca se construyó — sin ellas la punta terminaba en el aire, sin
	# conexión lateral a mejilla/mandíbula. Bulto chico semi-hundido a cada
	# lado de la punta (overlap real con nariz Y mandíbula) que rellena esa
	# transición — funde la base de la cuña con el plano facial.
	for aside in [-1, 1]:
		var ala = _sphere_mesh(0.011, skin_mat)
		ala.scale = Vector3(0.8, 0.6, 0.6)
		ala.position = Vector3(aside * 0.014, -0.043, 0.132)
		head.add_child(ala)
		_add_outline_pass(ala, Color("#f2b186"))

	# BOCA — FASE C paso 5 (luz verde director): boca por GEOMETRÍA, no línea
	# pintada. Antes eran 3 cajas planas en pupil_mat (negro) simulando un
	# trazo de tinta sin volumen — el "cel-shading debe describir la forma
	# correcta" (M9-r3) pedía labios reales, no un dibujo. Ahora: labio
	# SUPERIOR + INFERIOR (masas cilíndricas en lip_mat, el inferior más
	# grueso/carnoso — asimetría natural) que se HUNDEN en la mandíbula
	# (overlap real, mismo truco que nariz/mandíbula/pómulo) y protruyen un
	# poco al frente del plano facial; la línea oscura queda SOLO como la
	# comisura interior (sombra de la boca entreabierta, ya no dibuja la
	# boca entera) — mantiene la sonrisa franca de M9-r2 con las comisuras
	# como bultos chicos subidos en las puntas.
	# AJUSTE FINO post-QA: labio sup/inf estaban casi tangentes en Y (gap
	# 0.013) y a la misma Z -> sin escalón de profundidad, el Sobel no
	# distinguía las dos masas y el conjunto leía como un solo bloque. Ahora:
	# gap Y casi al doble + escalón Z real (superior protruye más/bermellón,
	# inferior se hunde) -> discontinuidad detectable = línea de comisura.
	# AJUSTE FINO post-QA Ronda 2 (2026-07-14): el gap Y (0.066→0.090=0.024,
	# casi el doble del valor pre-ajuste 0.013) + escalón Z (0.140/0.132)
	# SOBRE-corrigió — el QA lo leyó como boca abierta tipo "O"/grito.
	# AJUSTE FINO Ronda 3: gap Y recortado a 0.018 (mató el efecto "O") pero
	# el escalón Z (0.004) quedó MAL calibrado — con radios distintos
	# (0.007 vs 0.011) las caras FRONTALES de ambos labios terminaban
	# exactamente al mismo Z (0.145 los dos), sin ningún escalón visible
	# desde cámara frontal — de ahí que Ronda 4 (variar solo el TONO) no
	# generara ningún cambio perceptible: no había geometría con la que el
	# tono pudiera interactuar. AJUSTE FINO Ronda 5 (recomendación directa
	# del QA — "más separación Z con hueco de sombra real" + "línea de
	# contorno forzada, no depender del Sobel automático"): el escalón
	# ahora se calcula sobre la cara FRONTAL de cada labio, no el centro
	# (inferior protruye ~8mm más que superior); `mouth_seam` se hunde en
	# ese valle real entre las dos caras Y se OSCURECE/agranda para actuar
	# como línea de comisura forzada, visible sin depender del toon step.
	# AJUSTE FINO Ronda 6 — PRUEBA DE DIAGNÓSTICO (recomendación directa del
	# QA): 5 rondas corrigiendo la geometría en pasos de milímetros sin
	# cambio perceptible → el QA sugirió un escalón EXAGERADO (3-4x) para
	# encontrar el umbral real de visibilidad antes de seguir ajustando a
	# ciegas. Escalón subido a ~3.6cm entre caras frontales (antes 0.8cm) —
	# valor deliberadamente grande, a recalibrar hacia abajo si esto SÍ se
	# lee (o a investigar la vía material/shader si ni así se nota).
	# La prueba con escalón exagerado (3.6cm entre caras) SÍ se hizo visible
	# en el banco (confirma: el techo era de MAGNITUD, no de técnica) — se
	# calibra hacia abajo a ~2.6cm, todavía pronunciado pero sin leer como
	# jeta/protuberancia en perfil.
	var lip_upper = _cylinder_mesh(0.007, 0.007, 0.054, lip_mat)
	lip_upper.rotation.z = PI / 2.0
	lip_upper.position = Vector3(0.0, -0.069, 0.122)
	head.add_child(lip_upper)
	_add_outline_pass(lip_upper, Color("#f2b186"))

	# AJUSTE FINO post-QA Ronda 8 (desempate): radio 57% más grueso que el
	# superior + 2.2cm más de protrusión hacía que el inferior se viera
	# como un parche aislado/pegado, no integrado. Radio bajado (0.011→
	# 0.009) y protrusión recortada (z 0.144→0.136, escalón ahora ~1.6cm
	# en vez de 2.6cm) — sigue leyendo más carnoso que el superior sin
	# desproporcionarse.
	var lip_lower = _cylinder_mesh(0.009, 0.009, 0.056, lip_mat_lower)
	lip_lower.rotation.z = PI / 2.0
	lip_lower.position = Vector3(0.0, -0.087, 0.136)
	head.add_child(lip_lower)
	_add_outline_pass(lip_lower, Color("#f2b186"))

	# línea de comisura FORZADA: agrandada/oscurecida más — actúa como
	# línea explícita de boca, no depende del Sobel detectando el escalón.
	var mouth_seam = _box_mesh(0.044, 0.010, 0.014, mouth_seam_mat)
	mouth_seam.position = Vector3(0.0, -0.078, 0.137)
	head.add_child(mouth_seam)

	for mside in [-1, 1]:
		# comisuras: bulto chico SUBIDO (sonrisa franca de M9-r2), fusiona
		# labio superior/inferior en la punta.
		var corner = _sphere_mesh(0.008, lip_mat)
		corner.scale = Vector3(0.6, 0.6, 0.6)
		corner.position = Vector3(float(mside) * 0.0275, -0.078, 0.137)
		head.add_child(corner)
		_add_outline_pass(corner, Color("#f2b186"))

	# M9-r1: MEJILLAS ALTAS — pómulos bajo el ojo, no cachetes bajos.
	# r3: más ADENTRO y chicos (review: no expandir más allá de la línea de
	# mandíbula) — el pómulo es un QUIEBRE, no un globo lateral.
	# FASE C paso 2 (luz verde director): PÓMULOS ALTOS como PLANO MALAR, no
	# esferita redonda (la r0.023 al ras no leia nada -> cara plana del r5).
	# Masa elongada y semi-hundida BAJO el ojo, con el eje largo DIAGONAL
	# (outer-arriba -> inner-abajo, la eminencia malar); poco Z para leer
	# como PLANO (no bola). Semi-hundido en el plano facial: el cel-step lee
	# el escalon del pomulo, el Sobel entinta solo el borde. La forma
	# (rotacion + escala no uniforme) se fija aqui; apply_phenotype modula
	# alto/tamano alrededor de esta base sin romper el eje diagonal.
	# Fix (feedback director 2026-07-13: "los pusiste a un lado de los ojos"):
	# el ojo vive en y=0.022 — con el pomulo casi a esa misma altura (y~0.016)
	# y solo un poco mas afuera en X, leia LATERAL al ojo, no bajo el ojo.
	# Bajado a y=-0.012 (claramente por debajo) y recogido en X (0.067->0.060,
	# mas cerca de la nariz que del borde de la mandibula) para que el plano
	# quede BAJO el angulo externo del ojo, como pide la lamina.
	# AJUSTE FINO post-QA Ronda 1: Z=0.46 aplastaba el pómulo tanto que no
	# generaba discontinuidad de profundidad detectable por el Sobel ("no
	# lee desde ningún ángulo"). Subido a 0.64 — Ronda 2 confirmó que
	# "prácticamente no cambió nada". AJUSTE FINO Ronda 2 (PRD punto 7a):
	# la magnitud seguía siendo insuficiente (protrusión efectiva ~2cm
	# contra un cráneo de 15cm de radio). Radio base 0.030→0.032 y posición
	# más adelante (0.114→0.116); el multiplicador de escala Z sube de
	# 0.64 a 0.75 en `apply_phenotype`.
	# AJUSTE FINO Ronda 3: Ronda 2 con radio 0.032/Z-mult 0.75 dio "mejora
	# leve, insuficiente". El QA pidió descartar la hipótesis (a) magnitud
	# antes de investigar (b) causa externa — se sube otro escalón: radio
	# 0.032→0.036, posición 0.116→0.122, Z-mult 0.75→0.95 en apply_phenotype.
	# AJUSTE FINO Ronda 4 (mismo día): 0.036/0.122/Z-mult 0.95 SÍ se hizo
	# visible, pero se pasó de rosca — lee "cachete gordo", no plano malar
	# alto (más radio en una ESFERA siempre lee más gordo, nunca más
	# anguloso). AJUSTE FINO Ronda 5 (recomendación directa del QA — mismo
	# truco que ya resolvió el mentón): CAJA achatada en vez de esfera. Una
	# caja tiene caras PLANAS — lee como plano óseo anguloso en vez de bulto
	# redondo, sin importar cuánto se escale.
	# r_cheek-box-v2: 0.068 (el "diámetro" equivalente de la esfera 0.034)
	# resultó ENORME como caja — las caras planas con arista dura leen
	# mucho más grandes que una esfera de igual bounding box (el Sobel
	# entinta el borde recto entero, no un highlight suave). Base bajada a
	# ~60%.
	cheeks = []
	for side in [-1, 1]:
		var cheek = _box_mesh(0.040, 0.040, 0.040, skin_mat)
		cheek.rotation.z = -float(side) * 0.5   # eje largo diagonal
		cheek.position = Vector3(side * 0.060, -0.012, 0.112)
		head.add_child(cheek)
		_add_outline_pass(cheek, Color("#f2b186"))
		cheeks.append(cheek)

	# Ojos a escala HUMANA (el ojazo anime era la mitad del read chibi).
	eyes = []
	brows = []
	for side in [-1, 1]:
		var eye_group = Node3D.new()
		eye_group.name = "eye_" + ("l" if side == -1 else "r")
		# v0.5 C3: CONFORMADO a la superficie — a 0.130 la esclerótica
		# sobresalía del plano facial y se veía desde atrás en perfil.
		# AJUSTE FINO post-QA (feedback directo de Boris): a x=0.052 con
		# radio 0.015 el hueco entre esquinas internas (0.074) era ~2.4x el
		# ancho de un ojo (0.030) — muy separados, leían como botones
		# flotando lejos de la nariz. Regla humana estándar: el hueco entre
		# ojos ≈ el ancho de un ojo. Recogido a x=0.036 (con el radio nuevo
		# de 0.017 abajo, el hueco entre esquinas internas queda en ~0.038,
		# cerca de 1 ancho de ojo).
		eye_group.position = Vector3(side * 0.036, 0.022, 0.126)

		# M9-r2 (review v0.2 HIGH 5): ojo más CHICO y entrecerrado — menos
		# esclerótica visible, apertura angosta (fuera el ojo-platillo
		# caricatura; registro grounded-fantasy).
		# FASE C paso 3 (luz verde director): seguía leyendo "platillo" — la
		# esclerótica (white) era GRANDE relativo al iris (r0.018 vs r0.011,
		# el iris cubría ~60%) y la ceja no llegaba a tocarla (gap real de
		# ~1 cm) -> ojo redondo flotando en blanco, sin párpado. Dos cambios:
		# (a) white más CHICA y más aplastada (menos área visible total);
		# (b) iris/pupila CRECEN para llenar casi todo el alto del ojo
		# (margen de blanco fino arriba/abajo = almendra, no aro ancho).
		# AJUSTE FINO post-QA Ronda 8 (desempate, confirmado por Boris contra
		# refs. de Link/Zelda BotW/TotK): el iris (disco r0.0135, diámetro
		# 0.027) era MÁS ALTO que la esclerótica entera (white Y-semi
		# 0.015*0.58=0.0087, alto total 0.0174) — el iris literalmente
		# desbordaba el blanco por todos lados, margen NEGATIVO. El
		# comentario de p3 decía "margen de blanco fino" pero en los
		# números reales el margen no existía. White agrandada en Y
		# (0.58→0.85) e iris/pupila achicadas — ahora el margen es real y
		# perceptible (~3.7mm), sin volver al ojo-platillo del r5 (el iris
		# sigue llenando la mayoría del alto).
		# Radio subido 0.015→0.017 (mismo ajuste de Boris de arriba): los
		# ojos eran chicos Y separados a la vez, se veían como botones. Se
		# agrandan un poco (manteniendo la proporción esclerótica/iris ya
		# corregida) para que aporten estructura real a la cara, no solo un
		# punto decorativo perdido en un óvalo grande.
		var white = _sphere_mesh(0.017, eye_white_mat)
		white.scale = Vector3(1.0, 0.85, 0.36)
		eye_group.add_child(white)

		var iris = _disc_mesh(0.0102, iris_mat)
		iris.rotation.x = PI / 2.0
		iris.position.z = 0.0100
		eye_group.add_child(iris)

		var pupil = _disc_mesh(0.0048, pupil_mat)
		pupil.rotation.x = PI / 2.0
		pupil.position.z = 0.0110
		eye_group.add_child(pupil)

		var glint = _disc_mesh(0.0022, eye_white_mat)
		glint.rotation.x = PI / 2.0
		glint.position = Vector3(0.003, 0.003, 0.0115)
		eye_group.add_child(glint)

		eye_group.set_meta("side", side)
		head.add_child(eye_group)
		eyes.append(eye_group)

		# Ceja BAJA y cercana al ojo (lámina: brow line marcada, no flotante).
		# M9-r1: fina y CAFÉ CÁLIDO. M9-r2: más baja y RECTA (review v0.2:
		# el arco alto empuja a caricatura).
		var brow_mat := StandardMaterial3D.new()
		brow_mat.albedo_color = Color("#3a2418")
		brow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		# (v0.5 C3: pegada a la superficie — a 0.140 flotaba 10 mm y se
		# asomaba por encima del cráneo desde atrás)
		# FASE C paso 3: PÁRPADO — la ceja crece un poco y baja para que su
		# borde inferior SOLAPE de verdad el tope del ojo (overlap real, no
		# tangente, misma lección que las uniones del cuerpo): tapa el borde
		# superior de la esclerótica → lee entrecerrado/con párpado, no un
		# óvalo blanco completo flotando bajo una ceja separada.
		# AJUSTE FINO post-QA: el solape de párpado (bueno para matar el
		# ojo-platillo) apilaba una segunda línea de tinta muy cerca de la
		# del pómulo (paso de arriba) -> lectura de "arrugas". Se afina un
		# poco (menos invasión + menos alto) sin perder el párpado real.
		# x recogido junto con el ojo (0.052→0.036) para seguir centrada
		# sobre el ojo movido.
		# PRD Rework Fenotipo pt.10 (2026-07-14): primer paso de bajo riesgo
		# (mismo mesh, solo dimensiones) — Fable señala que esto NO da arco
		# real; si sigue leyendo recta, segunda pasada = cadena de 2-3
		# cápsulas/esferas decrecientes (patrón `_braid`).
		var brow = _box_mesh(0.040, 0.006, 0.010, brow_mat)
		brow.position = Vector3(side * 0.036, 0.038, 0.133)
		head.add_child(brow)
		brows.append(brow)

	# Technomagic goggles (visible at mid arcaneMod > 0.38)
	goggles = Node3D.new()
	goggles.name = "goggles"
	var band = _box_mesh(0.31, 0.03, 0.03, dark_leather_mat)
	band.position = Vector3(0.0, 0.095, 0.0)
	_add_outline_pass(band, Color("#3a2d22"))
	goggles.add_child(band)

	var lens_l = _cylinder_mesh(0.035, 0.035, 0.03, metal_mat)
	lens_l.rotation.x = PI / 2.0
	lens_l.position = Vector3(-0.055, 0.095, 0.125)
	_add_outline_pass(lens_l, Color("#6f7a88"))
	goggles.add_child(lens_l)

	var lens_r = _cylinder_mesh(0.035, 0.035, 0.03, metal_mat)
	lens_r.rotation.x = PI / 2.0
	lens_r.position = Vector3(0.055, 0.095, 0.125)
	_add_outline_pass(lens_r, Color("#6f7a88"))
	goggles.add_child(lens_r)

	var lens_glow_l = _disc_mesh(0.026, accent_glow_mat)
	lens_glow_l.rotation.x = PI / 2.0
	lens_glow_l.position = Vector3(-0.055, 0.095, 0.142)
	goggles.add_child(lens_glow_l)

	var lens_glow_r = _disc_mesh(0.026, accent_glow_mat)
	lens_glow_r.rotation.x = PI / 2.0
	lens_glow_r.position = Vector3(0.055, 0.095, 0.142)
	goggles.add_child(lens_glow_r)

	goggles.visible = false
	head.add_child(goggles)

	# Hair / beard slots
	# M10 (review v0.2): el hack de aplastar el slot se REVIERTE — cada
	# estilo se autora a su cráneo (el flatten distorsionaba TODOS los
	# estilos, incluidas las trenzas aprobadas de Dagna). El canon humano
	# usa el estilo 10 "frontier crop" (corto, barrido arriba-atrás).
	hair_slot = Node3D.new()
	hair_slot.name = "hair_slot"
	beard_slot = Node3D.new()
	beard_slot.name = "beard_slot"
	head.add_child(hair_slot)
	head.add_child(beard_slot)

	# Origin feature slot (ears, etc.) attached to head; tail to hips
	feature_slot = Node3D.new()
	feature_slot.name = "feature_slot"
	head.add_child(feature_slot)

	tail_slot = Node3D.new()
	tail_slot.name = "tail_slot"
	hips.add_child(tail_slot)

	# Glowing mana veins (visible when arcaneMod > 0.06)
	# JS veinDefs: [parent, x, y, z, w, h]
	var vein_defs: Array = [
		[arms[1],                                    0.045,  -0.1,   0.02,  0.012, 0.16],  # right upper arm
		[arms[1].get_meta("elbow"),                  0.04,   -0.1,   0.015, 0.01,  0.13],  # right forearm
		[spine,                                      0.1,     0.32,  0.145, 0.014, 0.2 ],  # chest line
		[spine,                                     -0.06,    0.5,   0.12,  0.01,  0.09],  # neck side
		[legs[0].get_meta("knee"),                  -0.04,  -0.16,   0.045, 0.01,  0.14],  # left shin
	]
	veins = []
	for def in vein_defs:
		var parent_node: Node3D = def[0]
		var vein = _box_mesh(def[4], def[5], def[4], vein_mat)
		vein.position = Vector3(def[1], def[2], def[3])
		vein.rotation.z = 0.18
		vein.visible = false
		parent_node.add_child(vein)
		veins.append(vein)

# ---- outline helpers: NO-OP desde C6 (2026-07-10) ----
# La línea de tinta del rig la dibuja el Sobel del post Melancolía (Art Bible:
# nítida cerca / grisácea media / ausente lejos). El casco invertido era el
# look del prototipo (grosor uniforme a toda distancia = anti-referencia) y
# además mentía sobre los volúmenes al juzgar anatomía. Los call sites se
# conservan (documentan dónde iba la línea) pero no generan pases.
func _add_outline_pass(_mi: MeshInstance3D, _base_color: Color, _thickness: float = 0.02) -> void:
	pass

func _apply_outline_to_children(_node: Node, _base_color: Color, _thickness: float) -> void:
	pass

# ================================================================
# _apply_build — internal helper that combines phenotype weight + archetype multiplier.
# Called by both apply_phenotype and apply_archetype so order never matters.
# Archetype multipliers are applied on top of the weight-based scale (X/Z only).
# ================================================================
func _apply_build() -> void:
	if _last_p.is_empty():
		return
	var w: float = _last_p.get("weight", 0.5)
	var limb: float = _lerp(0.82, 1.42, w)

	# Archetype multiplier for X/Z (breadth/depth); 1.0 = neutral
	var arch_xz: float = 1.0
	match _archetype_class:
		"warrior":
			arch_xz = 1.30  # Vanguard — clearly bulky tank
		"thief":
			arch_xz = 0.80  # Duelist — clearly lean/agile

	# C6a: V-taper base — el pecho es ancho/plano y la cintura recogida ANTES
	# de aplicar peso/clase (el frijol del puerto era pecho=cintura).
	torso.scale  = Vector3(_lerp(0.84, 1.34, w) * arch_xz * CHEST_X, 1.0, _lerp(0.86, 1.26, w) * arch_xz * CHEST_Z)
	# jerkin.scale (WAIST_XZ) migró — ahora lo lee CharacterOutfit.
	# build_frontier() en vivo desde torso.scale/pelvis.scale (ver ahí).
	pelvis.scale = Vector3(_lerp(0.88, 1.25, w) * arch_xz, 1.0, 1.0)
	# waist copia EXACTO el x/z de torso: su top_radius (0.11) es el mismo
	# radio base del fondo del cilindro del torso, así que igualando el
	# factor elíptico la costura queda idéntica en cualquier build/peso
	# (ver comentario en _build). Y se deja en 1.0 (no respira con torso).
	waist.scale = Vector3(torso.scale.x, 1.0, torso.scale.z)

	var limb_xz: float = limb * arch_xz
	for arm in arms:
		var upper: MeshInstance3D = arm.get_meta("upper")
		var fore: MeshInstance3D = arm.get_meta("fore")
		upper.scale = Vector3(limb_xz, 1.0, limb_xz)
		fore.scale  = Vector3(limb_xz, 1.0, limb_xz)

	for leg in legs:
		var thigh: MeshInstance3D = leg.get_meta("thigh")
		var shin:  MeshInstance3D = leg.get_meta("shin")
		thigh.scale = Vector3(limb_xz, 1.0, limb_xz)
		shin.scale  = Vector3(limb_xz, 1.0, limb_xz)

	# Vanguard: larger pauldron to read as tank
	var pauldron: Node3D = arms[1].get_child(arms[1].get_child_count() - 1)
	if pauldron != null:
		if _archetype_class == "warrior":
			pauldron.scale = Vector3(1.3, 1.2, 1.3)
		else:
			pauldron.scale = Vector3.ONE

	# Ironblooded armor pieces: scale X/Z by arch_xz so armor is bulky on
	# Vanguard (1.30), lean on Duelist (0.80), neutral on Strategist (1.0).
	# Y is kept at base so piece height doesn't stretch with body width.
	# Safe no-op when _iron_armor is empty (non-ironblooded origins).
	for entry in _iron_armor:
		var n = entry.get("node")
		if is_instance_valid(n):
			var b: Vector3 = entry.get("base", Vector3.ONE)
			n.scale = Vector3(b.x * arch_xz, b.y, b.z * arch_xz)

	# Strategist: floating focus orb (only for mage; remove for all others)
	_update_focus_orb()
	# Vanguard: per-origin presence VFX (only for warrior; remove for all others)
	_update_vanguard_vfx()
	# Strategist: per-origin presence VFX (only for mage; remove for all others)
	_update_strategist_vfx()

# ================================================================
# _update_focus_orb — manages the Strategist emissive focus orb.
# Creates it if class is "mage" and not yet present; removes it otherwise.
# Parented above the right shoulder so it floats when the rig is viewed.
# ================================================================
func _update_focus_orb() -> void:
	if _archetype_class == "mage":
		if _focus_orb == null:
			# Build a small emissive sphere parented to the right arm root.
			# Material is set to accent color so each origin gets a distinctive orb
			# (teal for aetherborn, orange for ironblooded, green for miststalker).
			var orb_mat := StandardMaterial3D.new()
			# Use a moderate emission multiplier (1.0) so the accent hue stays readable
			# at camera distance rather than blooming to white. The albedo already
			# provides a bright saturated base; emission adds a glow ring.
			orb_mat.albedo_color               = accent
			orb_mat.emission_enabled           = true
			orb_mat.emission                   = accent
			orb_mat.emission_energy_multiplier = 1.0
			orb_mat.shading_mode               = BaseMaterial3D.SHADING_MODE_UNSHADED
			_focus_orb = _sphere_mesh(0.055, orb_mat)
			_focus_orb.name = "focus_orb"
			# Position: float above right shoulder (arm_r local space)
			_focus_orb.position = Vector3(0.18, 0.25, 0.0)
			arms[1].add_child(_focus_orb)
		else:
			# Orb already exists — refresh its material to the current accent color
			# so origin switches (e.g. staying mage but changing origin) take effect.
			var orb_mat := _focus_orb.material_override as StandardMaterial3D
			if orb_mat != null:
				orb_mat.albedo_color               = accent
				orb_mat.emission                   = accent
	else:
		if _focus_orb != null:
			_focus_orb.queue_free()
			_focus_orb = null

# ================================================================
# _update_vanguard_vfx — manages Vanguard (warrior) per-Origin presence VFX.
# Creates the appropriate VFX only when _archetype_class == "warrior", branched
# by _origin_id, and frees all nodes otherwise or on origin switch.
# Mirrors the _update_focus_orb lifecycle exactly.
# ================================================================
func _update_vanguard_vfx() -> void:
	# Always free every cell's nodes first (clean state before branch)
	if _aegis_shield != null:
		_aegis_shield.queue_free()
		_aegis_shield = null
	if _thruster_l != null:
		_thruster_l.queue_free()
		_thruster_l = null
	if _thruster_r != null:
		_thruster_r.queue_free()
		_thruster_r = null
	if _pack_wisp != null:
		_pack_wisp.queue_free()
		_pack_wisp = null
	if _stealth_decal != null:
		_stealth_decal.queue_free()
		_stealth_decal = null

	if _archetype_class != "warrior":
		return

	match _origin_id:
		"aetherborn":
			# ---- Arcane Aegis: single translucent teal emissive shield surface ----
			# A rounded quad (BoxMesh, flat on Z) in front of the left arm — one modest
			# transparent surface (overdraw budget: 1 surface).
			var shield_mat := StandardMaterial3D.new()
			shield_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			shield_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			shield_mat.blend_mode   = BaseMaterial3D.BLEND_MODE_ADD
			shield_mat.cull_mode    = BaseMaterial3D.CULL_DISABLED
			shield_mat.albedo_color = Color(0.15, 0.85, 0.95, 0.38)
			shield_mat.emission_enabled = true
			shield_mat.emission         = Color(0.0, 0.65, 0.90) * 1.4
			shield_mat.emission_energy_multiplier = 1.6
			# Rim/fresnel-look: use grow+front-face trick (second mesh pass if desired later;
			# for now the additive blend already creates a limb-glow Fresnel read).

			var shield_mesh := BoxMesh.new()
			shield_mesh.size = Vector3(0.22, 0.30, 0.018)  # flat shield plate

			_aegis_shield = MeshInstance3D.new()
			_aegis_shield.name = "aegis_shield"
			_aegis_shield.mesh = shield_mesh
			_aegis_shield.material_override = shield_mat
			# Parent to left arm (arms[0]), positioned outward/forward at forearm level
			_aegis_shield.position = Vector3(-0.04, -0.28, 0.08)
			arms[0].add_child(_aegis_shield)

		"ironblooded":
			# ---- Juggernaut: steam-exhaust GPUParticles3D jets at both shoulders ----
			# Two jets (left + right), modest amount (~22 each) so total stays ~44.
			for side_idx in range(2):
				var side_sign: float = -1.0 if side_idx == 0 else 1.0
				var arm_node: Node3D = arms[side_idx]

				var jet := GPUParticles3D.new()
				jet.name = "steam_jet_" + ("l" if side_idx == 0 else "r")
				jet.amount = 22
				jet.lifetime = 0.90
				jet.explosiveness = 0.0   # continuous
				jet.fixed_fps = 0
				jet.visibility_aabb = AABB(Vector3(-0.5, -0.1, -0.5), Vector3(1.0, 1.2, 1.0))

				var proc := ParticleProcessMaterial.new()
				proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
				proc.emission_sphere_radius = 0.04
				proc.lifetime_randomness = 0.4
				# Exhaust vents upward and backward from shoulder
				proc.direction = Vector3(side_sign * 0.2, 1.0, -0.4)
				proc.spread = 40.0
				proc.gravity = Vector3(0.0, -1.0, 0.0)   # light — steam drifts
				proc.initial_velocity_min = 0.25
				proc.initial_velocity_max = 0.65
				proc.scale_min = 0.05
				proc.scale_max = 0.12

				# Steam colour: grey-white with a tiny orange-ember core
				var steam_grad := GradientTexture1D.new()
				var grad := Gradient.new()
				grad.colors = PackedColorArray([
					Color(1.0, 0.62, 0.28, 0.85),  # faint orange-hot at source
					Color(0.88, 0.88, 0.88, 0.60),  # light grey steam
					Color(0.75, 0.75, 0.75, 0.0),   # dissipate
				])
				grad.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
				steam_grad.gradient = grad
				proc.color_ramp = steam_grad

				jet.process_material = proc

				# Draw mesh: low-poly sphere (reads as steam puff)
				var puff_mesh := SphereMesh.new()
				puff_mesh.radius = 0.045
				puff_mesh.height = 0.09
				puff_mesh.radial_segments = 5
				puff_mesh.rings = 3
				var puff_mat := StandardMaterial3D.new()
				puff_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				puff_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				puff_mat.blend_mode   = BaseMaterial3D.BLEND_MODE_MIX
				puff_mat.albedo_color = Color(0.85, 0.85, 0.85, 0.55)
				puff_mesh.material = puff_mat
				jet.draw_pass_1 = puff_mesh

				# Position: at the shoulder top, slightly behind
				jet.position = Vector3(0.0, 0.1, -0.06)
				arm_node.add_child(jet)

				if side_idx == 0:
					_thruster_l = jet
				else:
					_thruster_r = jet

		"miststalker":
			# ---- Pack-Leader: spectral wisp orb + stealth-zone ground decal ----

			# 1) Spectral wisp: translucent green blob that orbits the head
			var wisp_mat := StandardMaterial3D.new()
			wisp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			wisp_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			wisp_mat.blend_mode   = BaseMaterial3D.BLEND_MODE_ADD
			wisp_mat.albedo_color = Color(0.18, 0.95, 0.35, 0.70)
			wisp_mat.emission_enabled = true
			wisp_mat.emission         = Color(0.10, 0.80, 0.25) * 1.8
			wisp_mat.emission_energy_multiplier = 1.8

			var wisp_mesh := SphereMesh.new()
			wisp_mesh.radius = 0.065
			wisp_mesh.height = 0.13
			wisp_mesh.radial_segments = 8
			wisp_mesh.rings = 5

			_pack_wisp = MeshInstance3D.new()
			_pack_wisp.name = "pack_wisp"
			_pack_wisp.mesh = wisp_mesh
			_pack_wisp.material_override = wisp_mat
			# Initial position: will be updated in _process orbit
			_pack_wisp.position = Vector3(0.22, 0.12, 0.0)
			# Parent to head so it orbits around the head pivot
			head.add_child(_pack_wisp)
			_wisp_angle = 0.0

			# 2) Stealth-zone ground decal: flat translucent green ring under feet
			# A flat torus-like ring = outer cylinder minus inner (use two concentric
			# flat cylinders in a Node3D; simpler: one thin CylinderMesh with inner_radius).
			# Godot CylinderMesh has no inner_radius, so use a flat TorusMesh.
			var ring_mat := StandardMaterial3D.new()
			ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			ring_mat.blend_mode   = BaseMaterial3D.BLEND_MODE_ADD
			ring_mat.cull_mode    = BaseMaterial3D.CULL_DISABLED
			ring_mat.albedo_color = Color(0.05, 0.70, 0.15, 0.22)
			ring_mat.emission_enabled = true
			ring_mat.emission         = Color(0.04, 0.55, 0.12) * 0.9
			ring_mat.emission_energy_multiplier = 0.9

			var ring_torus := TorusMesh.new()
			ring_torus.inner_radius = 0.35
			ring_torus.outer_radius = 0.50
			ring_torus.rings = 24
			ring_torus.ring_segments = 12

			_stealth_decal = MeshInstance3D.new()
			_stealth_decal.name = "stealth_ring"
			_stealth_decal.mesh = ring_torus
			_stealth_decal.material_override = ring_mat
			# Place at ground level; rig root is at origin, feet at ~y=-0.95 in world,
			# but in body-local space hips are at 0.95. Place ring at body.position_y = 0
			# so it's at character's feet in rig-local space (world y=0).
			_stealth_decal.position = Vector3(0.0, -0.98, 0.0)
			add_child(_stealth_decal)

# ================================================================
# _update_strategist_vfx — manages Strategist (mage) per-Origin presence VFX.
# Creates the appropriate VFX only when _archetype_class == "mage", branched
# by _origin_id, and frees all nodes otherwise or on origin switch.
# Mirrors the _update_vanguard_vfx lifecycle exactly.
# ================================================================
func _update_strategist_vfx() -> void:
	# Always free every cell's nodes first (clean state before branch)
	if _chrono_field != null:
		_chrono_field.queue_free()
		_chrono_field = null
	if _chrono_decal != null:
		_chrono_decal.queue_free()
		_chrono_decal = null
	if _thermite_embers != null:
		_thermite_embers.queue_free()
		_thermite_embers = null
	if _thermite_decal != null:
		_thermite_decal.queue_free()
		_thermite_decal = null
	if _shaman_decal != null:
		_shaman_decal.queue_free()
		_shaman_decal = null
	if _shaman_aura != null:
		_shaman_aura.queue_free()
		_shaman_aura = null

	if _archetype_class != "mage":
		return

	match _origin_id:
		"aetherborn":
			# ---- Chrono-Weaver: screen-space refraction dome + teal ground ring ----

			# 1) Translucent refraction dome around the character (SphereMesh + chrono shader)
			var dome_mat := ShaderMaterial.new()
			dome_mat.shader = _CHRONO_SHADER
			dome_mat.set_shader_parameter("tint_color",         Color(0.15, 0.85, 0.90, 1.0))
			dome_mat.set_shader_parameter("distortion_amount",  0.008)
			dome_mat.set_shader_parameter("dome_alpha",         0.30)
			dome_mat.set_shader_parameter("wobble_freq",        2.2)

			var dome_mesh := SphereMesh.new()
			dome_mesh.radius          = 0.88   # modest — keeps overdraw low
			dome_mesh.height          = 1.76
			dome_mesh.radial_segments = 16
			dome_mesh.rings           = 10

			_chrono_field = MeshInstance3D.new()
			_chrono_field.name              = "chrono_dome"
			_chrono_field.mesh              = dome_mesh
			_chrono_field.material_override = dome_mat
			# Centre at torso height (~1.05 above rig root = spine base 1.0 + a bit)
			_chrono_field.position = Vector3(0.0, 1.05, 0.0)
			add_child(_chrono_field)

			# 2) Faint teal ground AoE ring decal
			var ring_mat := StandardMaterial3D.new()
			ring_mat.shading_mode    = BaseMaterial3D.SHADING_MODE_UNSHADED
			ring_mat.transparency    = BaseMaterial3D.TRANSPARENCY_ALPHA
			ring_mat.blend_mode      = BaseMaterial3D.BLEND_MODE_ADD
			ring_mat.cull_mode       = BaseMaterial3D.CULL_DISABLED
			ring_mat.albedo_color    = Color(0.10, 0.75, 0.85, 0.28)
			ring_mat.emission_enabled = true
			ring_mat.emission        = Color(0.04, 0.60, 0.80) * 0.8
			ring_mat.emission_energy_multiplier = 0.8

			var ring_torus := TorusMesh.new()
			ring_torus.inner_radius  = 0.65
			ring_torus.outer_radius  = 0.88
			ring_torus.rings         = 24
			ring_torus.ring_segments = 12

			_chrono_decal = MeshInstance3D.new()
			_chrono_decal.name              = "chrono_ring"
			_chrono_decal.mesh              = ring_torus
			_chrono_decal.material_override = ring_mat
			_chrono_decal.position          = Vector3(0.0, -0.98, 0.0)
			add_child(_chrono_decal)

		"ironblooded":
			# ---- Thermite-Sage: orange ember GPUParticles3D + orange ground ring ----

			# 1) Orange ember particles rising around the character
			_thermite_embers = GPUParticles3D.new()
			_thermite_embers.name           = "thermite_embers"
			_thermite_embers.amount         = 22
			_thermite_embers.lifetime       = 1.20
			_thermite_embers.explosiveness  = 0.0   # continuous
			_thermite_embers.fixed_fps      = 0
			_thermite_embers.visibility_aabb = AABB(Vector3(-0.6, -0.1, -0.6), Vector3(1.2, 2.0, 1.2))

			var ember_proc := ParticleProcessMaterial.new()
			ember_proc.emission_shape        = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
			ember_proc.emission_sphere_radius = 0.35   # spawn in a ring around body
			ember_proc.lifetime_randomness   = 0.45
			ember_proc.direction             = Vector3(0.0, 1.0, 0.0)
			ember_proc.spread                = 50.0
			ember_proc.gravity               = Vector3(0.0, 0.5, 0.0)   # embers drift up
			ember_proc.initial_velocity_min  = 0.20
			ember_proc.initial_velocity_max  = 0.60
			ember_proc.scale_min             = 0.025
			ember_proc.scale_max             = 0.06

			# Orange-to-transparent ember colour ramp
			var ember_grad := GradientTexture1D.new()
			var eg := Gradient.new()
			eg.colors  = PackedColorArray([
				Color(1.00, 0.70, 0.10, 1.0),  # bright orange-yellow core
				Color(1.00, 0.40, 0.05, 0.80),  # deeper orange
				Color(0.80, 0.20, 0.02, 0.0),   # fade to transparent
			])
			eg.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
			ember_grad.gradient = eg
			ember_proc.color_ramp = ember_grad

			_thermite_embers.process_material = ember_proc

			# Tiny sphere draw pass — reads as glowing ember dot
			var ember_sphere := SphereMesh.new()
			ember_sphere.radius          = 0.018
			ember_sphere.height          = 0.036
			ember_sphere.radial_segments = 4
			ember_sphere.rings           = 2
			var ember_draw_mat := StandardMaterial3D.new()
			ember_draw_mat.shading_mode      = BaseMaterial3D.SHADING_MODE_UNSHADED
			ember_draw_mat.emission_enabled  = true
			ember_draw_mat.emission          = Color(1.0, 0.55, 0.08)
			ember_draw_mat.albedo_color      = Color(1.0, 0.55, 0.08)
			ember_draw_mat.transparency      = BaseMaterial3D.TRANSPARENCY_ALPHA
			ember_draw_mat.blend_mode        = BaseMaterial3D.BLEND_MODE_ADD
			ember_sphere.material            = ember_draw_mat
			_thermite_embers.draw_pass_1     = ember_sphere

			# Parented to rig root, centred — emitters spread outward via sphere emission
			_thermite_embers.position = Vector3(0.0, 1.0, 0.0)
			add_child(_thermite_embers)

			# 2) Orange napalm ground ring decal
			var therm_ring_mat := StandardMaterial3D.new()
			therm_ring_mat.shading_mode    = BaseMaterial3D.SHADING_MODE_UNSHADED
			therm_ring_mat.transparency    = BaseMaterial3D.TRANSPARENCY_ALPHA
			therm_ring_mat.blend_mode      = BaseMaterial3D.BLEND_MODE_ADD
			therm_ring_mat.cull_mode       = BaseMaterial3D.CULL_DISABLED
			therm_ring_mat.albedo_color    = Color(0.90, 0.38, 0.05, 0.30)
			therm_ring_mat.emission_enabled = true
			therm_ring_mat.emission        = Color(0.80, 0.30, 0.02) * 1.2
			therm_ring_mat.emission_energy_multiplier = 1.2

			var therm_torus := TorusMesh.new()
			therm_torus.inner_radius  = 0.28
			therm_torus.outer_radius  = 0.50
			therm_torus.rings         = 24
			therm_torus.ring_segments = 12

			_thermite_decal = MeshInstance3D.new()
			_thermite_decal.name              = "thermite_ring"
			_thermite_decal.mesh              = therm_torus
			_thermite_decal.material_override = therm_ring_mat
			_thermite_decal.position          = Vector3(0.0, -0.98, 0.0)
			add_child(_thermite_decal)

		"miststalker":
			# ---- Blood-Shaman: green-red siphon ring + green heal-aura particles ----

			# 1) Green→red translucent siphon ground ring (brighter + larger for legibility)
			var siphon_mat := StandardMaterial3D.new()
			siphon_mat.shading_mode    = BaseMaterial3D.SHADING_MODE_UNSHADED
			siphon_mat.transparency    = BaseMaterial3D.TRANSPARENCY_ALPHA
			siphon_mat.blend_mode      = BaseMaterial3D.BLEND_MODE_ADD
			siphon_mat.cull_mode       = BaseMaterial3D.CULL_DISABLED
			# Bumped alpha 0.26→0.42 and brighter emission for clear readability at distance
			siphon_mat.albedo_color    = Color(0.30, 0.70, 0.15, 0.42)
			siphon_mat.emission_enabled = true
			siphon_mat.emission        = Color(0.20, 0.65, 0.10) * 1.5
			siphon_mat.emission_energy_multiplier = 1.5

			# Slightly larger torus (inner 0.32→0.30, outer 0.55→0.62) for visibility
			var siphon_torus := TorusMesh.new()
			siphon_torus.inner_radius  = 0.30
			siphon_torus.outer_radius  = 0.62
			siphon_torus.rings         = 28
			siphon_torus.ring_segments = 14

			_shaman_decal = MeshInstance3D.new()
			_shaman_decal.name              = "siphon_ring"
			_shaman_decal.mesh              = siphon_torus
			_shaman_decal.material_override = siphon_mat
			_shaman_decal.position          = Vector3(0.0, -0.98, 0.0)
			add_child(_shaman_decal)

			# Outer red drain ring — brighter than before for the drain edge read
			var drain_mat := StandardMaterial3D.new()
			drain_mat.shading_mode    = BaseMaterial3D.SHADING_MODE_UNSHADED
			drain_mat.transparency    = BaseMaterial3D.TRANSPARENCY_ALPHA
			drain_mat.blend_mode      = BaseMaterial3D.BLEND_MODE_ADD
			drain_mat.cull_mode       = BaseMaterial3D.CULL_DISABLED
			drain_mat.albedo_color    = Color(0.85, 0.12, 0.12, 0.32)
			drain_mat.emission_enabled = true
			drain_mat.emission        = Color(0.75, 0.08, 0.08) * 1.2
			drain_mat.emission_energy_multiplier = 1.2

			var drain_torus := TorusMesh.new()
			drain_torus.inner_radius  = 0.58
			drain_torus.outer_radius  = 0.72
			drain_torus.rings         = 24
			drain_torus.ring_segments = 10

			var drain_ring := MeshInstance3D.new()
			drain_ring.name              = "drain_ring"
			drain_ring.mesh              = drain_torus
			drain_ring.material_override = drain_mat
			drain_ring.position          = Vector3(0.0, -0.98, 0.0)
			add_child(drain_ring)

			# 1b) Green siphon wisps — 3 short vertical rising columns (one-surface each)
			# Very thin capsules rising from just above the ring, bright green additive.
			var wisp_mat := StandardMaterial3D.new()
			wisp_mat.shading_mode    = BaseMaterial3D.SHADING_MODE_UNSHADED
			wisp_mat.transparency    = BaseMaterial3D.TRANSPARENCY_ALPHA
			wisp_mat.blend_mode      = BaseMaterial3D.BLEND_MODE_ADD
			wisp_mat.cull_mode       = BaseMaterial3D.CULL_DISABLED
			wisp_mat.albedo_color    = Color(0.15, 0.90, 0.25, 0.55)
			wisp_mat.emission_enabled = true
			wisp_mat.emission        = Color(0.10, 0.80, 0.20) * 1.6
			wisp_mat.emission_energy_multiplier = 1.6
			# 3 wisps at equal angles around the ring
			var wisp_angles: PackedFloat32Array = PackedFloat32Array([0.0, 2.094, 4.189])  # 0, 120, 240 deg
			for wa in wisp_angles:
				var wx: float = sin(wa) * 0.46
				var wz: float = cos(wa) * 0.46
				var wisp_cap := CapsuleMesh.new()
				wisp_cap.radius = 0.028
				wisp_cap.height = 0.22
				var wisp_mi := MeshInstance3D.new()
				wisp_mi.mesh = wisp_cap
				wisp_mi.material_override = wisp_mat
				wisp_mi.position = Vector3(wx, -0.78, wz)   # slightly above ground ring
				add_child(wisp_mi)

			# 2) Green heal-aura GPUParticles3D drifting upward (~18 particles)
			_shaman_aura = GPUParticles3D.new()
			_shaman_aura.name            = "shaman_aura"
			_shaman_aura.amount          = 18
			_shaman_aura.lifetime        = 1.60
			_shaman_aura.explosiveness   = 0.0
			_shaman_aura.fixed_fps       = 0
			_shaman_aura.visibility_aabb = AABB(Vector3(-0.6, 0.0, -0.6), Vector3(1.2, 2.2, 1.2))

			var aura_proc := ParticleProcessMaterial.new()
			aura_proc.emission_shape        = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
			aura_proc.emission_sphere_radius = 0.30
			aura_proc.lifetime_randomness   = 0.40
			aura_proc.direction             = Vector3(0.0, 1.0, 0.0)
			aura_proc.spread                = 35.0
			aura_proc.gravity               = Vector3(0.0, 0.35, 0.0)   # gentle upward drift
			aura_proc.initial_velocity_min  = 0.15
			aura_proc.initial_velocity_max  = 0.45
			aura_proc.scale_min             = 0.022
			aura_proc.scale_max             = 0.052

			var aura_grad := GradientTexture1D.new()
			var ag := Gradient.new()
			ag.colors  = PackedColorArray([
				Color(0.35, 1.00, 0.35, 1.0),  # bright heal green
				Color(0.15, 0.85, 0.25, 0.60),  # mid green
				Color(0.05, 0.60, 0.15, 0.0),   # fade out
			])
			ag.offsets = PackedFloat32Array([0.0, 0.50, 1.0])
			aura_grad.gradient = ag
			aura_proc.color_ramp = aura_grad

			_shaman_aura.process_material = aura_proc

			var aura_sphere := SphereMesh.new()
			aura_sphere.radius          = 0.016
			aura_sphere.height          = 0.032
			aura_sphere.radial_segments = 4
			aura_sphere.rings           = 2
			var aura_draw_mat := StandardMaterial3D.new()
			aura_draw_mat.shading_mode      = BaseMaterial3D.SHADING_MODE_UNSHADED
			aura_draw_mat.emission_enabled  = true
			aura_draw_mat.emission          = Color(0.20, 1.00, 0.35)
			aura_draw_mat.albedo_color      = Color(0.20, 1.00, 0.35)
			aura_draw_mat.transparency      = BaseMaterial3D.TRANSPARENCY_ALPHA
			aura_draw_mat.blend_mode        = BaseMaterial3D.BLEND_MODE_ADD
			aura_sphere.material            = aura_draw_mat
			_shaman_aura.draw_pass_1        = aura_sphere

			_shaman_aura.position = Vector3(0.0, 0.05, 0.0)
			add_child(_shaman_aura)

# ================================================================
# apply_archetype — set the combat archetype and re-apply proportions.
# Call after apply_phenotype (or at any time; idempotent on repeated calls).
# class_id: "warrior" | "mage" | "thief"  (empty string = reset to neutral)
# ================================================================
func apply_archetype(class_id: String) -> void:
	_archetype_class = class_id
	_apply_build()

# ================================================================
# apply_phenotype — live-update all sliders. Mirrors JS applyPhenotype exactly.
# p: Dictionary with same keys as PhenotypeData.default_phenotype()
# origin: Dictionary from OriginsData.get_origin(id)
# ================================================================
func apply_phenotype(p: Dictionary, origin: Dictionary) -> void:
	# Cache for re-application by apply_archetype
	_last_p = p
	_last_origin = origin
	_apply_build()

	# Height: uniform root scale within origin heightRange
	var range_arr: Array = origin.get("heightRange", [0.94, 1.1])
	scale = Vector3.ONE * _lerp(float(range_arr[0]), float(range_arr[1]), p.get("height", 0.5))

	# ---- origin features (ears, tail, accent) ----
	# NOTE: must run BEFORE the vein color calc below — vein_mat.albedo_color
	# reads `accent`, and on the first apply_phenotype call `accent` is still
	# the class default (#46e6ff cyan) until this block updates it per-origin.
	var origin_id: String = origin.get("id", "")
	if origin_id != _origin_id:
		_origin_id = origin_id
		var theme: Dictionary = origin.get("theme", {})
		var accent_hex: String = theme.get("accent", "#46e6ff")
		accent = Color(accent_hex)
		iris_mat.albedo_color = accent
		accent_glow_mat.albedo_color = accent * 1.2
		accent_glow_mat.emission = accent * 1.2
		_build_origin_features(origin)

	# Arcane modification thresholds (JS: >0.06, >0.38, >0.68)
	var mod: float = p.get("arcaneMod", 0.0)
	for vein in veins:
		vein.visible = mod > 0.06
	# Vein color: JS: veinMat.color.copy(accent).multiplyScalar(0.35 + mod * 1.8)
	var vein_brightness: float = 0.35 + mod * 1.8
	vein_mat.albedo_color = accent * vein_brightness
	vein_mat.emission = accent * vein_brightness

	goggles.visible = mod > 0.38

	var prosthetic_on: bool = mod > 0.68
	prosthetic.visible = prosthetic_on
	var left_fore: MeshInstance3D = arms[0].get_meta("fore")
	var left_hand: MeshInstance3D = arms[0].get_meta("hand")
	left_fore.visible = not prosthetic_on
	left_hand.visible = not prosthetic_on

	# ---- face structure ----
	# FASE C paso 1: la mandibula es ahora la esfera fundida (base
	# 0.78/0.84/0.94 en _build). El slider modula ANCHO y profundidad
	# alrededor de esa base SIN tocar el largo (Y), que fija el menton al
	# ras de la nariz. jaw bajo = mandibula fina (lamina); jaw alto = amplia.
	var jaw_v: float = p.get("jaw", 0.5)
	jaw_mesh.scale = Vector3(
		0.78 * _lerp(0.86, 1.16, jaw_v),
		0.84,
		0.94 * _lerp(0.92, 1.08, jaw_v)
	)

	# M9-r1: rango del slider subido — el pómulo ALTO es la base (review:
	# mejillas altas); el extremo bajo ya no baja a cachete.
	# FASE C paso 2: el pomulo es el PLANO MALAR elongado (base en _build).
	# Escala NO uniforme: ancho X y alto Y del plano, poco Z (semi-hundido).
	# cheek alto = base (lamina: high cheekbones); el slider sube el pomulo y
	# lo agranda un poco, sin volverlo bola (Z se queda corto).
	# Fix (feedback director: pomulo lateral al ojo, no bajo el ojo): rango
	# bajado 0.004..0.028 -> -0.024..0.000 — el ojo vive en y=0.022, el tope
	# del rango (0.0) queda 2.2 cm por debajo, nunca cruza la altura del ojo.
	# AJUSTE FINO post-QA: el "escalón" del pómulo (Z) se subió en _build a
	# 0.64 (antes 0.46, demasiado aplastado para leer). Acá dos fixes más:
	# (a) rango Y bajado otros 0.008 (-0.024..0.000 -> -0.032..-0.008) — el
	# pómulo vivía a solo ~3.4 cm del ojo (y=0.022), tan cerca que el Sobel
	# apilaba su borde + el de la ceja como "arrugas/patas de gallo" en vez
	# de una sola línea de párpado limpia; (b) Z de escala sube con él.
	var cheek_v: float = p.get("cheek", 0.5)
	for cheek in cheeks:
		cheek.position.y = _lerp(-0.032, -0.008, cheek_v)
		var cs: float = _lerp(0.9, 1.16, cheek_v)
		# r_cheek-box-v2: base bajada a 0.040 (de 0.068) — multiplicadores
		# recalibrados para la caja chica (antes tuneados para radio de
		# esfera 0.034, quedaban gigantes sobre la base nueva).
		cheek.scale = Vector3(1.3 * cs, 0.55 * cs, 0.55 * cs)

	# JS eyes: rotation.z = side * lerp(-0.32, 0.26, eyeTilt), scale.y = lerp(0.5, 1.3, eyeShape)
	# M9-r2: rango de tilt de CEJA acotado (review v0.2: cejas RECTAS —
	# el arco alto era caricatura); el ojo conserva su rango.
	var eye_tilt: float = p.get("eyeTilt", 0.5)
	var eye_shape: float = p.get("eyeShape", 0.5)
	for i in range(eyes.size()):
		var eye = eyes[i]
		var side: int = eye.get_meta("side")
		eye.rotation.z = float(side) * _lerp(-0.32, 0.26, eye_tilt)
		eye.scale.y = _lerp(0.5, 1.3, eye_shape)
		brows[i].rotation.z = float(side) * _lerp(-0.20, 0.09, eye_tilt)

	# ---- colors ----
	var skin_tones: Array = PaletteData.SKIN_TONES
	var hair_colors: Array = PaletteData.HAIR_COLORS
	var paint_colors: Array = PaletteData.PAINT_COLORS

	var skin_idx: int = int(p.get("skinTone", 1))
	var hair_idx: int = int(p.get("hairColor", 0))
	var paint_idx: int = int(p.get("paintColor", 0))

	var skin_color: Color = skin_tones[clamp(skin_idx, 0, skin_tones.size() - 1)]
	var hair_color: Color = hair_colors[clamp(hair_idx, 0, hair_colors.size() - 1)]
	var paint_color: Color = paint_colors[clamp(paint_idx, 0, paint_colors.size() - 1)]

	skin_mat.set_shader_parameter("albedo_color", skin_color)
	hair_mat.set_shader_parameter("albedo_color", hair_color)

	# Head texture (warpaint atlas)
	var warpaint_idx: int = int(p.get("warpaint", 0))
	var tex_key = skin_color.to_html() + "|" + str(warpaint_idx) + "|" + paint_color.to_html()
	if tex_key != _head_tex_key:
		_head_tex_key = tex_key
		var new_tex = WarpaintAtlas.build_head_texture(skin_color, warpaint_idx, paint_color)
		head_mat = ToonMaterials.toon_mat_opaque_textured(new_tex)
		# M9-r2b: SOLO el cráneo lleva el atlas (jaw/cheeks = skin plano;
		# sus UVs de primitiva embarraban la pintura).
		skull.material_override = head_mat

	# ---- marca de pintura del brazo (acompaña al warpaint facial) ----
	if _arm_stripe != null:
		_arm_stripe.queue_free()
		_arm_stripe = null
	if warpaint_idx > 0:
		var stripe_mat := StandardMaterial3D.new()
		stripe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		stripe_mat.albedo_color = paint_color
		# r 0.075: el bíceps EFECTIVO llega a ~0.070 (radio 0.055 × el
		# limb-scale de peso 1.12–1.42 de _apply_build) — un anillo menor
		# queda ENTERRADO dentro del brazo (bug M9-r3, diagnóstico por
		# find_child: el nodo existía, invisible).
		# r2c: radio subido 0.074→0.083 — el BÍCEPS nuevo (Fase B r2) alcanza
		# 0.0754 en Z a esta altura y enterraba el borde frontal de la banda
		# (la lección del anillo: dimensionar contra el radio efectivo MÁXIMO).
		_arm_stripe = _cylinder_mesh(0.081, 0.083, 0.028, stripe_mat)
		_arm_stripe.name = "arm_paint_stripe"
		_arm_stripe.position = Vector3(0.0, -0.115, 0.0)
		_arm_stripe.rotation.z = 0.12
		arms[0].add_child(_arm_stripe)

	# ---- PRD Rework Fenotipo pt.7 (2026-07-14): warpaint = 2 TRAZOS
	# VERTICALES (corrige la Fase C p8 anterior, 1 franja horizontal-
	# diagonal). QA de cuerpo completo (Fable) confirmó contra la lámina:
	# "dos trazos verticales que bajan desde el nacimiento del pelo
	# cruzando ceja/sien izquierda hacia el pómulo, no diagonal ni
	# horizontal". Lado IZQUIERDO (side=-1) como antes; ambos trazos rectos
	# (sin rotation.y/z) descendiendo de la altura de `brow` (y=0.038,
	# z=0.133) a la de `cheek` (y≈-0.020, z≈0.112).
	if _face_mark != null:
		_face_mark.queue_free()
		_face_mark = null
	if warpaint_idx > 0:
		var fm_mat := StandardMaterial3D.new()
		fm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		# 20% más oscuro: el unshaded puro brilla más que el mismo color
		# blendeado en el atlas de la mejilla — así emparejan.
		fm_mat.albedo_color = paint_color.darkened(0.18)
		_face_mark = MeshInstance3D.new()
		_face_mark.name = "face_paint_mark"
		for si in range(2):
			var fm_stroke = _box_mesh(0.006, 0.045, 0.005, fm_mat)
			fm_stroke.position = Vector3(-0.058 - float(si) * 0.014, 0.008, 0.135)
			_face_mark.add_child(fm_stroke)
		head.add_child(_face_mark)

	# ---- hair swap ----
	var hair_style: int = int(p.get("hair", 0))
	var hair_k = str(hair_style)
	if hair_k != _hair_key:
		_hair_key = hair_k
		for child in hair_slot.get_children():
			hair_slot.remove_child(child)
			child.queue_free()
		var built = HairLibrary.build_hair(hair_style, hair_mat)
		if built != null:
			_apply_outline_to_children(built, hair_color, 0.025)
			hair_slot.add_child(built)

	# ---- beard swap ----
	var beard_style: int = int(p.get("beard", 0))
	# CONFIGURABLE (pedido del director): densidad de la barba Stubble.
	var beard_density: float = float(p.get("beardDensity", 0.35))
	var beard_k = str(beard_style) + "|" + str(beard_density)
	if beard_k != _beard_key:
		_beard_key = beard_k
		for child in beard_slot.get_children():
			beard_slot.remove_child(child)
			child.queue_free()
		var built_b = HairLibrary.build_beard(beard_style, hair_mat, beard_density)
		if built_b != null and built_b.get_child_count() > 0:
			_apply_outline_to_children(built_b, hair_color, 0.025)
			beard_slot.add_child(built_b)

	# ---- per-origin rim override (MUST be after warpaint rebuild so head_mat is current) ----
	_apply_origin_rim()

## Set rim_color = accent on every toon ShaderMaterial for per-origin identity.
## Also sets origin-specific rim_strength (aetherborn gets higher = glassy look).
## Ironblooded gets a bright hot-orange rim for a forge-fire silhouette glow.
func _apply_origin_rim() -> void:
	var rim_str: float
	var rim_col: Color

	if _origin_id == "aetherborn":
		rim_str = 0.28
		rim_col = accent
	elif _origin_id == "ironblooded":
		rim_str = 0.32
		rim_col = Color(1.0, 0.45, 0.12)  # bright hot forge orange
	else:
		rim_str = 0.18
		rim_col = accent

	var toon_mats: Array = [skin_mat, head_mat, leather_mat, dark_leather_mat, metal_mat, hair_mat]
	for mat in toon_mats:
		if mat is ShaderMaterial:
			mat.set_shader_parameter("rim_color", rim_col)
			mat.set_shader_parameter("rim_strength", rim_str)

# ================================================================
# _build_iron_armor — creates cel-shaded metal armor pieces for the ironblooded
# origin: left pauldron, chest plate, two greaves, two bracers.
# All pieces use metal_mat so they automatically inherit the dark-iron albedo +
# orange-emission + forge-rim applied in _build_origin_features/ironblooded.
# Each piece is recorded in _iron_armor for cleanup and archetype scaling.
# NEVER parents anything to arms[1] — the existing right-pauldron last-child
# lookup in _apply_build must stay untouched.
# ================================================================
func _build_iron_armor() -> void:
	# ---- LEFT PAULDRON — mirrored from the right pauldron on arms[1] ----
	# Parent to arms[0] (left arm root). arms[0] has no existing pauldron child,
	# so adding here does not affect the arms[1].get_child(count-1) lookup.
	var pauldron_l := Node3D.new()
	pauldron_l.name = "pauldron_l"
	pauldron_l.position = Vector3(0.0, 0.03, 0.0)
	pauldron_l.rotation.z = 0.12   # mirror of right shoulder's -0.12
	var pl_a := _box_mesh(0.13, 0.035, 0.14, metal_mat)
	_add_outline_pass(pl_a, Color("#6f7a88"))
	var pl_b := _box_mesh(0.10, 0.03, 0.11, metal_mat)
	pl_b.position.y = 0.04
	_add_outline_pass(pl_b, Color("#6f7a88"))
	var pl_stud := _box_mesh(0.035, 0.02, 0.035, accent_glow_mat)
	pl_stud.position.y = 0.065
	pauldron_l.add_child(pl_a)
	pauldron_l.add_child(pl_b)
	pauldron_l.add_child(pl_stud)
	arms[0].add_child(pauldron_l)
	_iron_armor.append({"node": pauldron_l, "base": Vector3.ONE})

	# ---- CHEST PLATE — parented to upper_spine, covers the torso ----
	var chest := _box_mesh(0.30, 0.26, 0.16, metal_mat)
	chest.name = "chest_plate"
	chest.position = Vector3(0.0, 0.04, 0.04)
	_add_outline_pass(chest, Color("#6f7a88"))
	upper_spine.add_child(chest)
	_iron_armor.append({"node": chest, "base": Vector3.ONE})

	# ---- GREAVES — one shin guard per leg, parented to each leg's knee pivot ----
	for leg in legs:
		var knee_node: Node3D = leg.get_meta("knee")
		var greave := _box_mesh(0.12, 0.22, 0.13, metal_mat)
		greave.name = "greave"
		greave.position = Vector3(0.0, -0.13, 0.02)
		_add_outline_pass(greave, Color("#6f7a88"))
		knee_node.add_child(greave)
		_iron_armor.append({"node": greave, "base": Vector3.ONE})

	# ---- BRACERS — one forearm cuff per arm, parented to each arm's elbow pivot ----
	for arm in arms:
		var elbow_node: Node3D = arm.get_meta("elbow")
		var bracer := _box_mesh(0.11, 0.14, 0.11, metal_mat)
		bracer.name = "bracer"
		bracer.position = Vector3(0.0, -0.12, 0.0)
		_add_outline_pass(bracer, Color("#6f7a88"))
		elbow_node.add_child(bracer)
		_iron_armor.append({"node": bracer, "base": Vector3.ONE})

func _build_origin_features(origin: Dictionary) -> void:
	# ---- clean up previous origin's exclusive nodes ----
	for child in feature_slot.get_children():
		feature_slot.remove_child(child)
		child.queue_free()
	for child in tail_slot.get_children():
		tail_slot.remove_child(child)
		child.queue_free()

	# Clean up ironblooded sparks (always; only re-created when ironblooded)
	if _spark_particles != null:
		_spark_particles.queue_free()
		_spark_particles = null

	# Clean up ironblooded armor pieces (always; only re-created when ironblooded)
	for entry in _iron_armor:
		var n = entry.get("node")
		if is_instance_valid(n):
			n.queue_free()
	_iron_armor.clear()

	# Clean up miststalker fur (always; only re-created when miststalker)
	if _fur_slot != null:
		_fur_slot.queue_free()
		_fur_slot = null

	# Reset metal heat glow (cleared for all non-ironblooded origins)
	metal_mat.set_shader_parameter("emission_color", Color(0.0, 0.0, 0.0, 1.0))
	metal_mat.set_shader_parameter("emission_strength", 0.0)
	metal_mat.set_shader_parameter("albedo_color", Color("#6f7a88"))

	# Reset leather to neutral originals (overwritten below for ironblooded warm tint)
	leather_mat.set_shader_parameter("albedo_color", Color("#5b4632"))
	dark_leather_mat.set_shader_parameter("albedo_color", Color("#3a2d22"))

	# Reset vein materials back to the shared instance (clears aetherborn per-vein duplicates)
	for vein in veins:
		vein.material_override = vein_mat

	var id: String = origin.get("id", "")

	if id == "aetherborn":
		# Long pointed elven ears (ConeGeometry(0.026, 0.14, 6))
		for side in [-1, 1]:
			var ear = MeshInstance3D.new()
			var mesh = CylinderMesh.new()
			mesh.top_radius = 0.001
			mesh.bottom_radius = 0.026
			mesh.height = 0.14
			ear.mesh = mesh
			ear.material_override = skin_mat
			ear.position = Vector3(side * 0.155, 0.02, 0.0)
			ear.rotation = Vector3(-0.25, 0.0, float(side) * -1.95)
			_add_outline_pass(ear, Color("#f2b186"), 0.02)
			feature_slot.add_child(ear)
		# (vein flow animation is handled in _process when _origin_id=="aetherborn")

	elif id == "miststalker":
		# Beastfolk ears (ConeGeometry(0.045, 0.11, 5)) using hair color
		for side in [-1, 1]:
			var ear = MeshInstance3D.new()
			var mesh = CylinderMesh.new()
			mesh.top_radius = 0.001
			mesh.bottom_radius = 0.045
			mesh.height = 0.11
			ear.mesh = mesh
			ear.material_override = hair_mat
			ear.position = Vector3(side * 0.082, 0.15, 0.0)
			ear.rotation.z = float(side) * -0.35
			_add_outline_pass(ear, Color("#b8451f"), 0.02)
			feature_slot.add_child(ear)

		# Tail: 6 sphere segments tapering from hips
		var tail = Node3D.new()
		var r: float = 0.035
		for i in range(6):
			var seg = MeshInstance3D.new()
			var smesh = SphereMesh.new()
			smesh.radius = r
			smesh.height = r * 2.0
			seg.mesh = smesh
			seg.material_override = hair_mat
			seg.position = Vector3(0.0, -0.05 - float(i) * 0.012, -0.12 - float(i) * 0.07)
			_add_outline_pass(seg, Color("#b8451f"), 0.02)
			tail.add_child(seg)
			r *= 0.92
		tail_slot.add_child(tail)

		# ---- Miststalker fake-fur tufts ----
		# A few flat alpha-card-like quads (thin boxes) on shoulders and torso to
		# read as a pelt silhouette. Green-tinted, slightly semi-transparent.
		# Parented to spine so they follow the torso.
		_fur_slot = Node3D.new()
		_fur_slot.name = "fur_slot"
		spine.add_child(_fur_slot)

		var fur_color: Color = Color(0.18, 0.38, 0.12, 0.72)  # mossy green, partly transparent
		var fur_mat := StandardMaterial3D.new()
		fur_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fur_mat.albedo_color = fur_color
		fur_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fur_mat.cull_mode = BaseMaterial3D.CULL_DISABLED  # visible from both sides

		# Left shoulder tuft
		var tuft_l := _box_mesh(0.08, 0.14, 0.03, fur_mat)
		tuft_l.position = Vector3(-0.22, 0.44, 0.0)
		tuft_l.rotation.z = 0.3
		_fur_slot.add_child(tuft_l)

		# Right shoulder tuft (smaller — pauldron is on this side)
		var tuft_r := _box_mesh(0.06, 0.10, 0.03, fur_mat)
		tuft_r.position = Vector3(0.22, 0.44, 0.0)
		tuft_r.rotation.z = -0.3
		_fur_slot.add_child(tuft_r)

		# Chest center tuft
		var tuft_c := _box_mesh(0.07, 0.16, 0.03, fur_mat)
		tuft_c.position = Vector3(0.0, 0.30, 0.15)
		_fur_slot.add_child(tuft_c)

		# Forearm left tuft
		var tuft_fa := _box_mesh(0.06, 0.11, 0.025, fur_mat)
		tuft_fa.position = Vector3(-0.22, 0.18, 0.0)
		tuft_fa.rotation.z = 0.15
		_fur_slot.add_child(tuft_fa)

	elif id == "ironblooded":
		# ---- Ironblooded: compact round ears + heat glow + sparks ----
		# (C6a: rama EXPLÍCITA — antes era el else, y cualquier origin
		# desconocido caía aquí con armadura de forja incluida. Un origin
		# fuera del canon ahora deja el cuerpo neutral CON OREJAS, abajo.)
		for side in [-1, 1]:
			var ear = MeshInstance3D.new()
			var smesh = SphereMesh.new()
			smesh.radius = 0.032
			smesh.height = 0.064
			ear.mesh = smesh
			ear.material_override = skin_mat
			ear.position = Vector3(side * 0.148, 0.0, 0.0)
			_add_outline_pass(ear, Color("#f2b186"), 0.02)
			feature_slot.add_child(ear)

		# Warm body tint: leather clothing reads rust/amber so the ironblooded silhouette
		# reads warm at distance (not just via the low-contrast rim).
		leather_mat.set_shader_parameter("albedo_color", Color("#6e3a1f"))
		dark_leather_mat.set_shader_parameter("albedo_color", Color("#3a1d10"))

		# Heat glow: metal parts (pauldron, prosthetic) read as heated forge-metal.
		# Dark iron albedo so the hot-orange emission pops against the dark base.
		metal_mat.set_shader_parameter("albedo_color", Color(0.22, 0.20, 0.20))
		metal_mat.set_shader_parameter("emission_color", Color(1.0, 0.42, 0.10, 1.0))
		metal_mat.set_shader_parameter("emission_strength", 1.8)

		# Cel-shaded armor pieces (left pauldron, chest plate, greaves, bracers).
		# Must be called AFTER metal_mat heat parameters are set so all pieces
		# inherit the forge look immediately on first build.
		_build_iron_armor()

		# Sparks: forge-style GPUParticles3D near right shoulder pauldron.
		# Amount ~30 gives continuous visible arcing without overdraw excess.
		_spark_particles = GPUParticles3D.new()
		_spark_particles.name = "iron_sparks"
		_spark_particles.amount = 30
		_spark_particles.lifetime = 0.70
		_spark_particles.explosiveness = 0.0          # continuous stream
		_spark_particles.fixed_fps = 0
		_spark_particles.visibility_aabb = AABB(Vector3(-0.4, -0.2, -0.4), Vector3(0.8, 1.0, 0.8))

		var spark_proc := ParticleProcessMaterial.new()
		spark_proc.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		spark_proc.emission_sphere_radius = 0.05
		spark_proc.lifetime_randomness = 0.35   # variance: not all sparks die at once
		# Biased upward/outward like forge sparks rising from hot metal
		spark_proc.direction = Vector3(0.2, 1.0, 0.0)
		spark_proc.spread = 65.0
		spark_proc.gravity = Vector3(0.0, -6.0, 0.0)   # pull sparks into arc
		spark_proc.initial_velocity_min = 0.45
		spark_proc.initial_velocity_max = 1.0
		# Slightly larger sparks so they read at a glance
		spark_proc.scale_min = 0.018
		spark_proc.scale_max = 0.038
		# Bright white-orange core → deep orange fade → transparent
		var spark_grad := GradientTexture1D.new()
		var grad := Gradient.new()
		grad.colors = PackedColorArray([
			Color(1.0, 0.90, 0.55, 1.0),   # white-hot core
			Color(1.0, 0.55, 0.12, 0.85),  # orange mid
			Color(1.0, 0.25, 0.03, 0.0)    # ember tail, transparent
		])
		grad.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
		spark_grad.gradient = grad
		spark_proc.color_ramp = spark_grad

		_spark_particles.process_material = spark_proc

		# Tiny sphere mesh for each spark — use PrimitiveMesh.material to avoid
		# lazy-surface-generation issues with surface_set_material.
		var spark_sphere := SphereMesh.new()
		spark_sphere.radius = 0.011
		spark_sphere.height = 0.022
		spark_sphere.radial_segments = 4
		spark_sphere.rings = 2
		var spark_draw_mat := StandardMaterial3D.new()
		spark_draw_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		spark_draw_mat.emission_enabled = true
		spark_draw_mat.emission = Color(1.0, 0.65, 0.15)
		spark_draw_mat.albedo_color = Color(1.0, 0.65, 0.15)
		spark_draw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		spark_draw_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		spark_sphere.material = spark_draw_mat  # PrimitiveMesh.material: safe before surface gen
		_spark_particles.draw_pass_1 = spark_sphere

		# Place near the right shoulder (arm_r is arms[1])
		_spark_particles.position = Vector3(0.0, 0.06, 0.0)
		arms[1].add_child(_spark_particles)

	else:
		# ---- Origin neutro/desconocido (M9-r1): un humano base TIENE
		# orejas — redondas simples; los origins las REEMPLAZAN arriba.
		# M9-r2/r3 (reviews M7/M6): banda ceja-nariz, SEMI-ELÍPTICA de eje
		# vertical con leve inclinación hacia atrás — la review v0.3 tumbó
		# el disco frontal ("audífonos/botones").
		for side in [-1, 1]:
			var ear = MeshInstance3D.new()
			var smesh = SphereMesh.new()
			smesh.radius = 0.030
			smesh.height = 0.060
			ear.mesh = smesh
			ear.material_override = skin_mat
			# v0.5 H4: RETRASADA a la vertical media del cráneo (adelantada
			# leía piercing en la mejilla); asoma flanqueando en la trasera.
			ear.position = Vector3(side * 0.124, -0.010, -0.034)
			ear.scale = Vector3(0.40, 1.28, 0.75)   # semi-elipse vertical
			ear.rotation.x = -0.15                  # leve inclinación atrás
			ear.rotation.z = float(side) * -0.06
			_add_outline_pass(ear, Color("#f2b186"), 0.02)
			feature_slot.add_child(ear)

			# FASE C paso 7: LÓBULO — la masa única leía como botón plano sin
			# forma (una sola bola). Bulto chico colgando bajo el pabellón
			# (mismo truco de fusión: overlap real con el ear de arriba), da
			# el quiebre lóbulo/pabellón que el resto de la cara ya tiene
			# (mandíbula/pómulo/nariz) — silueta de oreja real en perfil.
			var lobe = _sphere_mesh(0.012, skin_mat)
			lobe.scale = Vector3(0.55, 0.6, 0.55)
			lobe.position = Vector3(side * 0.120, -0.050, -0.030)
			_add_outline_pass(lobe, Color("#f2b186"), 0.02)
			feature_slot.add_child(lobe)

# ================================================================
# Motion API — mirrors JS setMotion / playAttack / update
# ================================================================

## Set locomotion parameters (speed 0..1, crouch bool).
func set_motion(speed_norm: float, crouch: bool, sliding: bool = false) -> void:
	_motion_speed = speed_norm
	_motion_crouch = crouch
	_motion_slide = sliding

## Trigger an attack animation. kind = "melee" or "bolt".
## LEGACY (prototype-0 arm snap) — kept only for the historic slice flow.
## New combat (PRD-006) uses play_strike() below.
func play_attack(kind: String) -> void:
	_attack_style = kind
	_attack_timer = 0.38

# ================================================================
# PRD-006 alcance 0 — weight-transfer strike (hip-first kinetic chain)
# ================================================================

## Start a biomech strike. The pose is driven by rig_biomech.gd:
## hips lead, spine follows, shoulder whips, elbow extends last.
## duration = full swing in seconds (weapon mass will scale this in
## PRD-006 alcance 2; 0.55 ≈ medium weapon).
func play_strike(duration: float = 0.55) -> void:
	_strike_dur = maxf(duration, 0.15)
	_strike_t = _strike_dur

## Normalized strike progress 0..1 (0 = just started, 1 = done; 0 if idle).
func strike_progress() -> float:
	if _strike_t <= 0.0 or _strike_dur <= 0.0:
		return 0.0
	return 1.0 - (_strike_t / _strike_dur)

## Current biomech phase: "windup" | "active" | "recovery" | "" (idle).
## These ARE the combat windows — CombatComponent anchors cancel/hitbox/
## chain timing here, never to arbitrary timers (Movilidad Realista §4.3).
func strike_phase() -> String:
	if _strike_t <= 0.0:
		return ""
	return _Biomech.phase_name(strike_progress())

# ================================================================
# PRD-006 alcance 3 — flinch corporal al recibir (B15/B15e)
# ================================================================

var _flinch_t: float = 0.0
var _flinch_dur: float = 0.25   # FLINCH_TIME del GuardComponent
var _flinch_amp: float = 1.0

## El golpe recibido se registra en el CUERPO: head-snap el MISMO tick
## (a 60, nunca stepped — Sifu reacciona al frame siguiente) + recoil de
## columna que respira en el reloj de pose. amp: 0.35 bloqueado · 1.0
## golpe limpio · 1.4 stagger · 1.8 posture break.
func play_flinch(amp: float = 1.0) -> void:
	_flinch_amp = clampf(amp, 0.0, 2.0)
	_flinch_t = _flinch_dur * clampf(amp, 0.75, 1.6)   # golpes duros duran más

# ================================================================
# PRD-006 (feedback del director 2026-07-08) — pose de GUARDIA sostenida.
# La guardia (RMB hold) no tenía cuerpo: el jugador no distinguía bloquear
# de recibir. `set_guard(true)` levanta el arma cruzada al frente + brazos
# arriba + brace; blend in/out. Se compone en _process (no pelea con strike:
# no se puede atacar guardando).
# ================================================================
var _guard_hold: bool = false
var _guard_blend: float = 0.0

func set_guard(active: bool) -> void:
	_guard_hold = active

# ================================================================
# PRD-006 (feedback del director 2026-07-08) — Capa 2: tell del PARRY.
# El parry Roba se veía solo del lado del enemigo (stun). `play_parry()` da
# al JUGADOR una deflexión seca: el arma batea el golpe hacia afuera y recula
# a la guardia (riposte ~0.3 s, B15b). Corre SOBRE la pose de guardia.
# ================================================================
var _parry_t: float = 0.0
var _parry_dur: float = 0.30

func play_parry(dur: float = 0.30) -> void:
	_parry_dur = maxf(dur, 0.12)
	_parry_t = _parry_dur

## Constraint report accessors (QA: autotest_biomech asserts on these).
func constraint_report() -> Dictionary:
	return _constraint_report

func reset_constraint_report() -> void:
	_constraint_report = {}

# ---- Body pop helpers (ver bloque body_pop_on_twos arriba) ----
func _anchor_body_hold() -> void:
	_held_root_pos = global_position
	_held_root_yaw = rotation.y
	_release_body_hold()

func _apply_body_hold() -> void:
	if not body_pop_on_twos or _held_root_pos == Vector3.INF:
		return
	var off: Vector3 = _held_root_pos - global_position
	off.y = 0.0   # vertical sigue continuo: body.position.y es de crouch/slide
	if off.length() > BODY_POP_SNAP:
		_held_root_pos = global_position
		_held_root_yaw = rotation.y
		off = Vector3.ZERO
	# Moving hold: capear el trailing para que no se lea como input lag.
	# El anchor se arrastra junto con el cuerpo, así el próximo tick no
	# acumula el excedente.
	if off.length() > BODY_POP_MAX:
		off = off.normalized() * BODY_POP_MAX
		_held_root_pos = global_position + off
	var local_off: Vector3 = off.rotated(Vector3.UP, -rotation.y)
	body.position.x = local_off.x
	body.position.z = local_off.z
	var yaw_off: float = wrapf(_held_root_yaw - rotation.y, -PI, PI)
	if absf(yaw_off) > BODY_POP_MAX_YAW:
		yaw_off = signf(yaw_off) * BODY_POP_MAX_YAW
		_held_root_yaw = rotation.y + yaw_off
	body.rotation.y = yaw_off

func _release_body_hold() -> void:
	body.position.x = 0.0
	body.position.z = 0.0
	body.rotation.y = 0.0

func _process(delta: float) -> void:
	_t += delta
	var speed: float = _motion_speed
	var crouch: bool = _motion_crouch

	# ---- Locomotion phase advance (faster cadence at higher speed) ----
	if speed > 0.02:
		_phase += delta * (6.5 + 7.5 * speed)

	# ---- Gameplay clocks: advance EVERY frame (never stepped) ----
	# Combat windows (strike_phase) and the legacy envelope stay continuous
	# at 60 fps even when the visible pose is sampled on 2s.
	if _attack_timer > 0.0:
		_attack_timer -= delta
	if _strike_t > 0.0:
		_strike_t -= delta
		if _strike_t <= 0.0:
			# Strike finished: release pose ownership immediately.
			hips.rotation.y = 0.0
			head.rotation.y = 0.0
			_strike_dur = 0.0

	# ---- Flinch (alcance 3): el head-snap corre CADA frame, nunca se
	# escalona — la reacción al frame siguiente es canon B15. La cabeza
	# no la posee el gait, así que el write directo no pelea con nadie. ----
	if _flinch_t > 0.0:
		_flinch_t -= delta
		var fenv: float = clampf(_flinch_t / _flinch_dur, 0.0, 1.0)
		fenv = fenv * fenv * (3.0 - 2.0 * fenv)
		head.rotation.x = -0.40 * fenv * _flinch_amp
		if _flinch_t <= 0.0:
			head.rotation.x = 0.0

	# ---- Parry clock (Capa 2): continuo a 60 como el strike; la POSE se
	# aplica abajo (en la región de pose, sampleada en 2s). ----
	if _parry_t > 0.0:
		_parry_t -= delta

	# ---- Pose stepping "on 2s" ([[Benchmark Biomecánico]]: Sable/Xrd) ----
	# The pose below only re-evaluates every POSE_STEP (~12 Hz) and HOLDS
	# between ticks — the comic-book rhythm. Gameplay above never steps.
	if animation_on_twos:
		_pose_clock += delta
		# Reloj propio del body pop (24 Hz): re-ancla el doble de rápido
		# que la pose — jerarquía cuerpo fino / extremidades en 2s.
		if body_pop_on_twos:
			_body_pop_clock += delta
			if _body_pop_clock >= BODY_POP_STEP:
				_body_pop_clock = fmod(_body_pop_clock, BODY_POP_STEP)
				_anchor_body_hold()
		if _pose_clock < POSE_STEP:
			# Held frame: the pose doesn't move, but the anatomical safety
			# net still runs — external writes to bones get clamped anyway.
			_apply_body_hold()
			_apply_joint_constraints()
			return
		delta = _pose_clock   # the pose integrates the full held interval
		_pose_clock = 0.0
		_anchor_body_hold()
	else:
		_release_body_hold()

	# ---- Speed-scaled stride amplitude — has a walk floor so slow walk still reads ----
	# amp_leg:  0.0 at idle → 0.28 at min walk → 0.62 at sprint
	# amp_arm:  follows same curve at 65% of leg
	var spd_clamped: float = clamp(speed, 0.0, 1.0)
	var amp_leg: float  = lerp(0.28, 0.62, spd_clamped) * spd_clamped  # zero at idle, walk floor once moving
	# arm swing is derived inline as leg0_swing * 0.65 (contralateral, 65% of leg amplitude)

	# Primary sinusoid for this frame — drives leg and arm swing
	var sin_ph: float  = sin(_phase)         # legs[0] swing reference
	var cos_ph: float  = cos(_phase)         # used for double-freq hip bob

	# ---- Per-leg swing signals ----
	# legs[0] (left):  forward swing when sin_ph > 0  → SWING phase positive half
	# legs[1] (right): forward swing when sin_ph < 0  → SWING phase negative half
	var leg0_swing: float = sin_ph * amp_leg
	var leg1_swing: float = -sin_ph * amp_leg

	# ---- Knee flex amplitude — floor ensures visible bend even at walk speed ----
	# Peak knee flex: ~0.60 rad (~34°) at sprint, ~0.38 rad (~22°) at slow walk
	var knee_peak: float    = lerp(0.38, 0.62, spd_clamped)
	# Soft baseline bend: ~0.10 rad (~6°) standing so knees are never locked-straight rods.
	# Crouch adds a strong baseline flex (~0.85 rad / ~49°) for a pronounced acute-angle stance.
	var knee_base: float    = 0.10 + (0.85 if crouch else 0.0)

	# Knee flex phase: knee flexes during SWING (foot off ground, swinging forward).
	# Offset by +0.15 rad so peak flex follows slightly after the leg begins its forward arc.
	# max(0, ...) keeps flex positive (natural backward bend only, never hyperextend).
	# legs[0] swings when sin_ph > 0, so knee0 flexes on positive half:
	var knee0_flex: float = knee_base + max(0.0, sin(_phase + 0.15)) * knee_peak * spd_clamped
	# legs[1] swings when sin_ph < 0, so knee1 flexes on negative half (invert):
	var knee1_flex: float = knee_base + max(0.0, sin(_phase + 0.15 + PI)) * knee_peak * spd_clamped

	# ---- Elbow flex — baseline bend + swing-coupled pump ----
	# Baseline ~0.30 rad (~17°) so elbows are never rod-straight.
	# Pump amplitude scales with speed.  Elbow flexes on the FORWARD swing of its arm.
	# arms[0] swings forward when sin_ph < 0 (contralateral to leg0).
	# arms[1] swings forward when sin_ph > 0.
	# r4 (review LOW 14): codo en reposo un poco más doblado — postura
	# relajada del concept, no maniquí vertical.
	var elbow_base: float   = 0.34
	var elbow_pump: float   = lerp(0.15, 0.55, spd_clamped) * spd_clamped
	var e0_flex: float = elbow_base + max(0.0, -sin(_phase + 0.1)) * elbow_pump
	var e1_flex: float = elbow_base + max(0.0,  sin(_phase + 0.1)) * elbow_pump

	# ---- Apply legs ----
	if legs.size() >= 2:
		# Idle settle: lerp toward neutral when speed is near zero to avoid stiff snap
		if speed > 0.02:
			legs[0].rotation.x = leg0_swing
			legs[1].rotation.x = leg1_swing
		else:
			legs[0].rotation.x = lerp(legs[0].rotation.x, 0.0, min(1.0, delta * 8.0))
			legs[1].rotation.x = lerp(legs[1].rotation.x, 0.0, min(1.0, delta * 8.0))

		var knee0: Node3D = legs[0].get_meta("knee")
		var knee1: Node3D = legs[1].get_meta("knee")
		if speed > 0.02:
			knee0.rotation.x = knee0_flex
			knee1.rotation.x = knee1_flex
		else:
			# Idle: settle to soft baseline bend (never fully locked straight)
			knee0.rotation.x = lerp(knee0.rotation.x, knee_base, min(1.0, delta * 8.0))
			knee1.rotation.x = lerp(knee1.rotation.x, knee_base, min(1.0, delta * 8.0))

	# ---- Subtle hip bob (double-frequency: two dips per stride cycle) ----
	# Bob the hips node so it stays additive with the body.position.y crouch lerp.
	# Amplitude: 0.0 at idle, up to 0.022 at sprint.
	var hip_bob: float = -abs(cos_ph) * 0.022 * spd_clamped
	# Crouch hips offset: pull the hips BACK 0.2m (local -Z) and DOWN 0.2m for a
	# low, hinged stealth stance. Smoothed via _hip_crouch (0..1).
	_hip_crouch = lerp(_hip_crouch, 1.0 if crouch else 0.0, min(1.0, delta * 10.0))
	# Bob fades out while crouched so the hips stay put during the crouch-walk.
	hips.position.y = 0.95 + hip_bob * (1.0 - _hip_crouch) - 0.10 * _hip_crouch
	hips.position.z = -0.12 * _hip_crouch                   # hips slightly back; joints do the rest

	# ---- Subtle spine counter-rotation (torso twist opposing arms for life) ----
	# Small y-rotation opposing arm swing: amplitude up to 0.06 rad at sprint.
	var spine_twist: float = -sin_ph * 0.06 * spd_clamped
	spine.rotation.y = lerp(spine.rotation.y, spine_twist, min(1.0, delta * 12.0))

	# ---- Apply arms (skipped when an attack/strike envelope is active) ----
	if _attack_timer <= 0.0 and _strike_t <= 0.0 and arms.size() >= 2:
		# Contralateral swing: left arm back when left leg forward
		var a0_swing: float = -leg0_swing * 0.65  # arm[0] opposite to leg[0]
		var a1_swing: float = -leg1_swing * 0.65  # arm[1] opposite to leg[1]
		if speed > 0.02:
			arms[0].rotation.x = a0_swing
			arms[1].rotation.x = a1_swing
		else:
			arms[0].rotation.x = lerp(arms[0].rotation.x, 0.0, min(1.0, delta * 8.0))
			arms[1].rotation.x = lerp(arms[1].rotation.x, 0.0, min(1.0, delta * 8.0))

		# r4 (review LOW 13): A-pose suave — brazos despegados del cuerpo.
		# QA 2026-07-13 (d1): con el pivote de hombro de vuelta a la lámina
		# (0.262→0.21) el splay 0.15 dejaba luz de axila corriendo por todo
		# el flanco (lectura gorila). La lámina: el brazo interior ROZA el
		# torso todo el trayecto — splay mínimo, cuelgue casi vertical.
		arms[0].rotation.z = 0.07
		arms[1].rotation.z = -0.07

		var e0: Node3D = arms[0].get_meta("elbow")
		var e1: Node3D = arms[1].get_meta("elbow")
		# Elbow rotation.x is negative to flex the forearm upward/inward (anatomical)
		if speed > 0.02:
			e0.rotation.x = -e0_flex
			e1.rotation.x = -e1_flex
		else:
			# Idle settle: relax toward the baseline bend
			e0.rotation.x = lerp(e0.rotation.x, -elbow_base, min(1.0, delta * 8.0))
			e1.rotation.x = lerp(e1.rotation.x, -elbow_base, min(1.0, delta * 8.0))

	# Attack envelope (JS: wind-up then snap; timer advances at top of _process)
	if _attack_timer > 0.0:
		var k: float = 1.0 - max(_attack_timer, 0.0) / 0.38  # 0→1
		var snap: float
		if k < 0.35:
			snap = -1.0 - k * 2.2
		else:
			snap = _lerp(-1.8, 0.4, (k - 0.35) / 0.65)

		if arms.size() >= 2:
			if _attack_style == "bolt":
				arms[0].rotation.x = snap * 0.8
				arms[1].rotation.x = snap
				arms[1].get_meta("elbow").rotation.x = -0.1
			else:
				arms[1].rotation.x = snap
				arms[1].rotation.z = -0.35
				arms[1].get_meta("elbow").rotation.x = -0.15

	# Crouch / breathe — body drop + forward trunk incline (squat trunk angle).
	var crouch_y: float = -0.35 if crouch else 0.0
	body.position.y += (crouch_y - body.position.y) * min(1.0, delta * 10.0)
	var lean: float = 0.5 if crouch else 0.0
	spine.rotation.x += (lean - spine.rotation.x) * min(1.0, delta * 10.0)

	# ---- Flinch recoil (alcance 3): la columna acusa el golpe hacia
	# atrás. Corre en el reloj de pose (hold cómic); el head-snap ya
	# disparó a 60 en el bloque de gameplay. ----
	if _flinch_t > 0.0:
		var f_rec: float = clampf(_flinch_t / _flinch_dur, 0.0, 1.0)
		spine.rotation.x -= 0.22 * f_rec * _flinch_amp

	# ── CROUCH SQUAT pose: deep HIP + KNEE flexion (matches squat reference) ──
	# Thighs flex forward at the hip; knees bend deeply; a gentle alternating stride
	# keeps the crouch-walk readable. Overrides the standing gait leg pose.
	if crouch and not _motion_slide and legs.size() >= 2 and arms.size() >= 2:
		# Crouch-WALK v2 (feedback del director 2026-07-06): the pelvis is
		# alive. A real low walk travels THROUGH the hips — pelvis rotates
		# with the stride, weight shifts laterally over the planted foot,
		# the trunk counter-rotates, and the arms counter-swing for balance
		# instead of freezing. The low squat silhouette is preserved.
		var step: float = sin(_phase) * 1.6 * spd_clamped     # alternating thigh swing
		legs[0].rotation.x = -1.0 + step
		legs[1].rotation.x = -1.0 - step
		# Knee lifts on the leg that's swinging forward (clears the ground), base stays bent.
		legs[0].get_meta("knee").rotation.x = 1.1 + max(0.0,  sin(_phase)) * 0.35 * spd_clamped
		legs[1].get_meta("knee").rotation.x = 1.1 + max(0.0, -sin(_phase)) * 0.35 * spd_clamped
		# Pelvis rotates INTO each stride (leads the stepping leg)…
		hips.rotation.y = sin(_phase) * 0.22 * spd_clamped
		# …and the weight rides laterally over whichever foot is planted.
		hips.position.x = sin(_phase + PI * 0.5) * 0.05 * spd_clamped
		# Trunk counters the pelvis (stealth: shoulders stay on target).
		spine.rotation.y = -sin(_phase) * 0.14 * spd_clamped
		# Arms counter-swing low and wide for balance, elbows soft.
		arms[0].rotation.x = -0.2 + sin(_phase) * 0.30 * spd_clamped
		arms[1].rotation.x = -0.2 - sin(_phase) * 0.30 * spd_clamped
		arms[0].get_meta("elbow").rotation.x = -0.7
		arms[1].get_meta("elbow").rotation.x = -0.7
	elif _strike_t <= 0.0:
		# Not crouch-walking / not striking: relax pelvis extras to neutral.
		hips.rotation.y = lerp(hips.rotation.y, 0.0, min(1.0, delta * 10.0))
		hips.position.x = lerp(hips.position.x, 0.0, min(1.0, delta * 10.0))

	# ── SLIDE: dedicated low committed pose (overrides crouch/gait when sliding) ──
	# Deep body drop, strong forward lean, lead leg extended, trail leg tucked,
	# arms swept back for balance — reads clearly as a power slide.
	if _motion_slide and legs.size() >= 2 and arms.size() >= 2:
		var sb: float = min(1.0, delta * 14.0)
		body.position.y  += (-0.50 - body.position.y) * sb
		spine.rotation.x += (0.55 - spine.rotation.x) * sb
		hips.position.z   = 0.0              # body handles the drop, not the hips
		hips.position.y   = 0.95 + hip_bob   # cancel the crouch hip drop while sliding
		legs[0].rotation.x = -0.62           # lead leg extended forward
		legs[1].rotation.x = 0.55            # trail leg back
		legs[0].get_meta("knee").rotation.x = 0.15   # lead nearly straight
		legs[1].get_meta("knee").rotation.x = 1.05   # trail tucked under
		arms[0].rotation.x = 0.45            # arms swept back
		arms[1].rotation.x = 0.45
		arms[0].rotation.z = 0.18
		arms[1].rotation.z = -0.18
		arms[0].get_meta("elbow").rotation.x = -0.55
		arms[1].get_meta("elbow").rotation.x = -0.55

	# ── PRD-006 STRIKE: hip-first kinetic chain (overrides arm/spine pose) ──
	# The blow is born in the hips and travels cadera→torso→hombro→brazo,
	# each segment lagged so the hand arrives last (Movilidad Realista §4.3).
	if _strike_t > 0.0:
		var sk: float = strike_progress()
		# Segment targets: coil (windup peak) → release (active peak) → 0.
		# Hips lead the rotation around Y; spine amplifies; shoulder whips
		# the arm from cocked-back to follow-through; elbow extends last.
		# Amplitudes pushed toward the ROM edge (director feedback 2026-07-06:
		# the coil must READ — a shy windup kills the weight transfer; the
		# hips are the ENGINE of the blow, not a garnish).
		var hip_rot: float   = _Biomech.segment_offset(sk, _Biomech.CHAIN_LAG["hips"],     -0.60, 0.55)
		var spine_rot: float = _Biomech.segment_offset(sk, _Biomech.CHAIN_LAG["spine"],    -0.75, 0.60)
		# Ronda #3: el twist del tronco se reparte lumbar/torácico — el
		# torácico tiene su PROPIO lag de cadena (el pecho llega después
		# de la pelvis, antes del hombro): el torso se ENROSCA, no gira
		# en bloque. Suma ~107% del total viejo; el ROM clampa.
		var chest_rot: float = _Biomech.segment_offset(sk, _Biomech.CHAIN_LAG["chest"],    -0.75, 0.60)
		var arm_x: float     = _Biomech.segment_offset(sk, _Biomech.CHAIN_LAG["shoulder"], -1.90, 0.70)
		var arm_z: float     = _Biomech.segment_offset(sk, _Biomech.CHAIN_LAG["shoulder"], -0.85, -0.10)
		# Elbow release -0.082 (no -0.10): la bisagra está pegada a su límite
		# de extensión (+0.03) y el follow-through oscila ~35% del release al
		# otro lado. Con -0.085 el pico rozaba +0.0297 (margen 0.0003 rad =
		# flake por alineado de frames en autotest_biomech, visto 2026-07-10);
		# con -0.082 el pico (+0.0287) queda DENTRO con margen real. La pose
		# autorada nunca depende del clamp; autotest_biomech lo exige.
		var elbow_x: float   = _Biomech.segment_offset(sk, _Biomech.CHAIN_LAG["elbow"],    -1.45, -0.082)

		hips.rotation.y  = hip_rot
		spine.rotation.y = spine_rot * 0.45
		upper_spine.rotation.y = chest_rot * 0.62
		# Head counter-rotates: the body coils away but the eyes stay on the
		# target — this is what makes a real windup legible. Counter against
		# the SUM of trunk segments (head hangs from upper_spine now).
		head.rotation.y = -(spine.rotation.y + upper_spine.rotation.y) * 0.7
		# Weight DRIVE: the pelvis sits back into the coil and surges forward
		# through the release — the mass travels into the target (translation,
		# not just rotation; base z was set absolutely above, += is safe).
		hips.position.z += _Biomech.segment_offset(sk, _Biomech.CHAIN_LAG["hips"], -0.05, 0.09)
		if arms.size() >= 2:
			arms[1].rotation.x = arm_x
			arms[1].rotation.z = arm_z
			arms[1].get_meta("elbow").rotation.x = elbow_x
			# Off arm counters for balance (small, opposite the swing)
			arms[0].rotation.x = -arm_x * 0.25
			arms[0].get_meta("elbow").rotation.x = -0.55
		# Weight brace at idle: front leg plants, knees soften (the body
		# receives its own transfer). Skipped while moving — locomotion owns
		# the legs (blending with momentum is PRD-006 alcance 2).
		if speed <= 0.02 and legs.size() >= 2 and not _motion_slide and not crouch:
			var brace: float = absf(spine_rot) * 0.6
			legs[0].rotation.x = -brace
			legs[1].rotation.x = brace * 0.7
			legs[0].get_meta("knee").rotation.x = 0.18 + brace * 0.4
			legs[1].get_meta("knee").rotation.x = 0.18 + brace * 0.3
		# (end-of-strike release happens at the top of _process, every frame)

	# ── GUARD hold pose (feedback del director 2026-07-08) ──
	# Arma cruzada al frente + antebrazos arriba + leve hunch de brace. Se
	# CRUZA sobre el pose idle/gait de brazos (que ya escribió este frame) por
	# blend; el strike gana (no coexisten: guardar bloquea atacar). Valores
	# dentro del ROM (el elbow guard -1.35 < el coil del strike -1.45).
	_guard_blend = lerp(_guard_blend, 1.0 if _guard_hold else 0.0, min(1.0, delta * 12.0))
	if _guard_blend > 0.001 and _strike_t <= 0.0 and arms.size() >= 2:
		var gb: float = _guard_blend
		var e0g: Node3D = arms[0].get_meta("elbow")
		var e1g: Node3D = arms[1].get_meta("elbow")
		arms[0].rotation.x = lerp(arms[0].rotation.x, -0.55, gb)   # ambos brazos suben al frente
		arms[1].rotation.x = lerp(arms[1].rotation.x, -0.65, gb)   # el del arma un poco más alto
		arms[0].rotation.z = lerp(arms[0].rotation.z,  0.34, gb)   # cruzan hacia el centro
		arms[1].rotation.z = lerp(arms[1].rotation.z, -0.42, gb)
		e0g.rotation.x = lerp(e0g.rotation.x, -1.30, gb)           # antebrazos plegados arriba
		e1g.rotation.x = lerp(e1g.rotation.x, -1.35, gb)
		# Brace: leve hunch adelante (aditivo, blended) — el cuerpo se cierra.
		spine.rotation.x += 0.14 * gb

	# ── PARRY deflect flick (Capa 2) ── El arma BATEA el golpe hacia afuera y
	# recula a la guardia. Sobrescribe el brazo del arma mientras dura (~0.3 s);
	# corre encima de la guardia (el parry sucede guardando). ROM-safe: el
	# elbow sale a -0.55 (extiende), lejos del tope; arm.z a +0.30 (afuera).
	if _parry_t > 0.0 and arms.size() >= 2:
		var pe: float = clampf(_parry_t / _parry_dur, 0.0, 1.0)
		var s: float = pe * pe * (3.0 - 2.0 * pe)   # smootherstep: snap fuerte al inicio
		var e1p: Node3D = arms[1].get_meta("elbow")
		var e0p: Node3D = arms[0].get_meta("elbow")
		# Brazo del arma: batea hacia AFUERA y arriba, extendiendo (deflexión).
		arms[1].rotation.x = lerp(arms[1].rotation.x, -1.05, s)
		arms[1].rotation.z = lerp(arms[1].rotation.z,  0.40, s)
		e1p.rotation.x     = lerp(e1p.rotation.x,     -0.50, s)
		# Off-arm: contrapeso hacia adentro/atrás — el cuerpo se abre al robar.
		arms[0].rotation.x = lerp(arms[0].rotation.x,  0.25, s)
		arms[0].rotation.z = lerp(arms[0].rotation.z, -0.15, s)
		e0p.rotation.x     = lerp(e0p.rotation.x,     -0.95, s)
		# Giro de TORSO al golpe: el cuerpo entero batea, no solo el brazo — es
		# lo que hace legible el parry (feedback del director). Lumbar + torácico.
		spine.rotation.y       += -0.22 * s
		upper_spine.rotation.y += -0.16 * s
		# La cabeza gira al acero robado (contra el giro del torso, ojos en el golpe).
		head.rotation.y = lerp(head.rotation.y, 0.18, s)

	# Idle breathe (JS: torso.scale.y = 1 + sin(t*2.1)*0.012)
	torso.scale.y = 1.0 + sin(_t * 2.1) * 0.012

	# Beast tail sway (JS: tailSlot.rotation.y = sin(t*1.7)*0.25 + swing*0.3)
	if tail_slot.get_child_count() > 0:
		tail_slot.rotation.y = sin(_t * 1.7) * 0.25 + leg0_swing * 0.3

	# ---- Vanguard per-origin animations ----
	if _archetype_class == "warrior":
		# Arcane Aegis (aetherborn): slow shield rotation / bob
		if _origin_id == "aetherborn" and _aegis_shield != null:
			_aegis_shield.rotation.z = sin(_t * 0.8) * 0.08
			_aegis_shield.rotation.y = sin(_t * 0.5) * 0.05

		# Pack-Leader (miststalker): wisp orbits head
		if _origin_id == "miststalker" and _pack_wisp != null:
			_wisp_angle += delta * 1.4  # orbit speed rad/s
			var orbit_r: float = 0.22
			_pack_wisp.position = Vector3(
				cos(_wisp_angle) * orbit_r,
				0.12 + sin(_t * 2.2) * 0.04,   # gentle up-down float
				sin(_wisp_angle) * orbit_r
			)

	# ---- Strategist per-origin animations (mage only) ----
	if _archetype_class == "mage":
		# Chrono-Weaver (aetherborn): gentle dome rotation to reinforce the time-wobble feel
		if _origin_id == "aetherborn" and _chrono_field != null:
			_chrono_field.rotation.y = sin(_t * 0.35) * 0.06
			# Pulse the ring alpha via emission scale — subtle breathing effect
			if _chrono_decal != null:
				var ring_pulse: float = 0.8 + 0.2 * sin(_t * 2.0)
				(_chrono_decal.material_override as StandardMaterial3D).emission_energy_multiplier = ring_pulse * 0.8

		# Thermite-Sage (ironblooded): ring flickers — modulate emission to simulate heat shimmer
		if _origin_id == "ironblooded" and _thermite_decal != null:
			var flicker: float = 0.85 + 0.15 * sin(_t * 6.3 + 0.7)
			(_thermite_decal.material_override as StandardMaterial3D).emission_energy_multiplier = flicker * 1.2

		# Blood-Shaman (miststalker): siphon ring slow rotation
		if _origin_id == "miststalker" and _shaman_decal != null:
			_shaman_decal.rotation.y = _t * 0.6   # slow clockwise spin

	# ---- Aetherborn: traveling vein pulse (flowing aether visual) ----
	# Only animate when aetherborn and veins are visible (arcaneMod > 0.06).
	if _origin_id == "aetherborn" and veins.size() > 0 and veins[0].visible:
		# Ensure each vein has its own material instance for independent modulation.
		# We detect this by checking if the override is still the shared vein_mat.
		for i in range(veins.size()):
			if veins[i].material_override == vein_mat:
				veins[i].material_override = vein_mat.duplicate() as StandardMaterial3D

		var base_bright: float = vein_mat.albedo_color.v  # luminance from shared reference
		for i in range(veins.size()):
			var pulse: float = 0.6 + 0.4 * sin(_t * 3.0 + float(i) * 0.9)
			var pulsed: Color = accent * (base_bright * pulse)
			var m := veins[i].material_override as StandardMaterial3D
			m.albedo_color = pulsed
			m.emission = pulsed

	# ── Ronda #3: capa de follow del torácico fuera del strike ──
	# La locomoción escribe `spine` (tronco total); el torácico acompaña
	# con lag y un sobre-giro leve (~38% extra de twist, 30% del lean) —
	# la S del torso vivo. El strike escribe upper_spine directo (arriba).
	if _strike_t <= 0.0 and upper_spine != null:
		upper_spine.rotation.y = lerpf(upper_spine.rotation.y,
				spine.rotation.y * 0.38, minf(1.0, delta * 7.0))
		# DORSAL_CURVE_X (PRD Rework Fenotipo pt.13): offset sumado al target,
		# no asignado una vez — así sobrevive al settle de idle.
		upper_spine.rotation.x = lerpf(upper_spine.rotation.x,
				spine.rotation.x * 0.30 + DORSAL_CURVE_X, minf(1.0, delta * 7.0))

	# ── PRD-006: joint constraints — ALWAYS the last pose pass ──
	# "Nada rota donde un cuerpo no rota" (Movilidad Realista §4.3): every
	# animation source above (gait, crouch, slide, legacy attack, strike)
	# gets clamped to the human-reference ROM. Attempted violations are
	# accumulated in _constraint_report for the QA assert.
	_apply_joint_constraints()

# ---- PRD-006: clamp every animated joint to its anatomical ROM ----
func _apply_joint_constraints() -> void:
	_Biomech.clamp_node(hips,  "hips_root", "hips",  _constraint_report)
	_Biomech.clamp_node(spine, "spine",     "spine", _constraint_report)
	_Biomech.clamp_node(upper_spine, "spine_upper", "spine_upper", _constraint_report)
	_Biomech.clamp_node(head,  "head",      "head",  _constraint_report)
	for i in range(arms.size()):
		var arm: Node3D = arms[i]
		var mirror: bool = int(arm.get_meta("side")) == -1  # left arm mirrors z limits
		_Biomech.clamp_node(arm, "shoulder", "shoulder_" + ("l" if mirror else "r"),
				_constraint_report, mirror)
		_Biomech.clamp_node(arm.get_meta("elbow"), "elbow",
				"elbow_" + ("l" if mirror else "r"), _constraint_report)
	for i in range(legs.size()):
		var leg: Node3D = legs[i]
		var side_l: bool = i == 0
		_Biomech.clamp_node(leg, "hip_leg", "hip_" + ("l" if side_l else "r"),
				_constraint_report)
		_Biomech.clamp_node(leg.get_meta("knee"), "knee",
				"knee_" + ("l" if side_l else "r"), _constraint_report)
