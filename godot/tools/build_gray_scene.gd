extends SceneTree

## Construye la escena gris del Protocolo A.
##
##   godot --headless --path godot --script res://tools/build_gray_scene.gd
##   → res://scenes/gray_test.tscn
##
## La escena se genera con codigo y no a mano en el editor por la misma razon
## que el resto del spike: queda diffeable, y las alturas -- que son lo unico
## que hace al test valido o invalido -- quedan como numeros con su
## justificacion al lado, no como transforms arrastrados con el mouse.
##
## ------------------------------------------------------------------------
## EL DISENO DEL NIVEL, Y POR QUE
## ------------------------------------------------------------------------
##
## §1 pide tres cosas del espacio, y las tres tienen consecuencia geometrica:
##
## 1. "Una cornisa alcanzable SOLO con el boton". La mesa central tiene el
##    frente a pico: no hay rampa, ni escalon, ni caja apilable. Sin el boton
##    no hay forma de subir. Si la hubiera, al minuto 5 el tester subiria por
##    ahi y P daria 0 por un motivo ajeno a lo que se mide.
##
## 2. "En una ruta que el jugador va a recorrer VARIAS VECES". La mesa es un
##    circuito de una sola direccion: se sube por el frente con el boton, se
##    cruza por arriba, se cae por el fondo (2.4 m, sin dano) y se vuelve
##    caminando por el costado hasta el frente. El tester repite el loop
##    porque es la unica forma de volver arriba, sin que nadie le pida nada
##    ni haya un objetivo escrito.
##
## 3. "Sin arte". Cajas grises. Dos tonos, y el segundo tono es funcion y no
##    decoracion: lo que se puede pisar tiene que distinguirse de lo que no,
##    o un rojo del test seria de legibilidad y no de reflejo (§0.4).
##
## La torre existe por una cuarta razon que no esta en §1 y conviene dejar
## dicha: el pilar del juego es que el Pivote te da EL MUNDO, la
## verticalidad. Si el boton sirviera para una sola cornisa, la perdida seria
## un obstaculo. Encadenando saltos hasta un mirador desde el que se ve todo
## el nivel, el boton pasa a ser el acceso a la altura en general -- y eso es
## lo que el minuto 5 tiene que sacar.
##
## ------------------------------------------------------------------------
## POR QUE LA TORRE ESTA ARRIBA DE LA MESA Y NO AL COSTADO
## ------------------------------------------------------------------------
##
## La primera version la tenia al lado. La captura desde el punto de partida
## mostro el problema: una mesa de 12 x 12 y 2.4 m de alto, vista con la
## camara del juego, se lee como un MURO BLANCO. La cara superior queda casi
## de canto y desde el suelo no hay nada que diga que arriba se puede estar.
##
## Eso rompe el test entero por un motivo que no tiene que ver con el pilar:
## si el tester no sabe que hay algo arriba, no intenta subir, P da bajo, y
## el rojo seria de legibilidad (§0.4) y no de reflejo.
##
## Con la torre ENCIMA, desde el suelo se ven dos bloques parados sobre la
## mesa. Un bloque apoyado sobre una superficie es la forma mas barata que
## existe de decir "esto es una superficie" sin cartel, sin flecha y sin
## objetivo escrito. Y de paso toda la verticalidad del nivel queda del otro
## lado del boton: al minuto 5 no se pierde una cornisa, se pierde el piso
## de arriba entero.

## Gravedad y impulso, decididos por tacto el 2026-08-19.
##
## La gravedad NO es la de la Tierra a proposito. Con 9.8 el salto duraba
## 1.53 s en el aire y el director lo reporto como "raro" -- flotado, que es
## como se lee la gravedad real en un juego. Con 22 el vuelo baja a 1.02 s.
##
## El IMPULSO esta calculado para conservar EXACTAMENTE el alcance que ya
## estaba validado (2.87 m): v = sqrt(2 * g * apice) = sqrt(2 * 22 * 2.8699).
## Por eso todas las alturas del nivel siguen valiendo sin tocarse: lo unico
## que cambio es el tiempo en el aire.
const IMPULSO: float = 11.2372
const GRAVEDAD: float = 22.0
## Altura maxima que gana el jugador con una pulsacion desde el piso:
## v^2 / 2g = 7.5^2 / 19.6 = 2.87 m.
const APICE: float = (IMPULSO * IMPULSO) / (2.0 * GRAVEDAD)

## Alturas ABSOLUTAS sobre el piso. Cada una tiene que estar dentro del
## apice medido desde la anterior, y fuera del alcance desde el piso.
const ALTURA_MESA: float = 2.4      # margen de 0.47 m sobre el apice
const MESA_LADO: float = 12.0
const ALTURA_ESCALON: float = 4.6   # 2.4 + 2.2, sobre la mesa
const ALTURA_MIRADOR: float = 7.0   # 4.6 + 2.4, sobre el escalon
const TORRE_LADO: float = 5.0
## Cuanto se extiende la zona de la cornisa mas alla de cada cara de la
## mesa. 3 m es la profundidad que §4.1 fijo para la version de una sola
## cara; se conserva, aplicada a las cuatro.
const ZONA_MARGEN: float = 3.0
const SUELO_LADO: float = 44.0
const MURO_ALTO: float = 7.0

## Tres grises bien separados. NO es paleta: es la unica pista que tiene el
## tester para distinguir lo que se pisa de lo que no. La primera version
## tenia los tres valores a menos de 0.25 de distancia y en la captura el
## nivel entero se leia como una mancha plana -- con eso, un rojo del test
## habria sido de legibilidad y no de reflejo (§0.4).
const GRIS_SUELO := Color(0.30, 0.30, 0.33)
const GRIS_PISABLE := Color(0.78, 0.78, 0.80)
const GRIS_MURO := Color(0.17, 0.17, 0.20)

var _mat_suelo: StandardMaterial3D
var _mat_pisable: StandardMaterial3D
var _mat_muro: StandardMaterial3D


func _initialize() -> void:
	_check_alturas()

	_mat_suelo = _material(GRIS_SUELO)
	_mat_pisable = _material(GRIS_PISABLE)
	_mat_muro = _material(GRIS_MURO)

	var root := Node3D.new()
	root.name = "GrayTest"
	root.set_script(load("res://scripts/gray_session.gd"))

	_add_environment(root)
	_add_suelo(root)
	_add_muros(root)
	_add_mesa(root)
	_add_torre(root)
	_add_player(root)
	_add_systems(root)

	_own_all(root, root)

	var packed := PackedScene.new()
	var err: int = packed.pack(root)
	if err != OK:
		push_error("pack fallo: %d" % err)
		quit(1)
		return

	DirAccess.make_dir_recursive_absolute("res://scenes")
	err = ResourceSaver.save(packed, "res://scenes/gray_test.tscn")
	if err != OK:
		push_error("save fallo: %d" % err)
		quit(1)
		return

	print("OK  res://scenes/gray_test.tscn")
	print("    apice de un salto: %.2f m" % APICE)
	print("    cornisa a %.2f m (margen %.2f m)" % [ALTURA_MESA, APICE - ALTURA_MESA])
	print("    mirador a %.2f m (desde el escalon de %.2f m)" % [ALTURA_MIRADOR, ALTURA_ESCALON])
	quit(0)


## El nivel no vale nada si las alturas no cierran. Esto falla la
## construccion antes de que nadie corra una sesion contra un nivel imposible
## -- o peor, contra uno trivial.
func _check_alturas() -> void:
	assert(ALTURA_MESA < APICE, "la cornisa quedaria inalcanzable con el boton")
	assert(ALTURA_MESA > 1.0, "la cornisa se subiria caminando")
	assert(ALTURA_ESCALON < ALTURA_MESA + APICE, "el escalon no se alcanza desde la mesa")
	assert(ALTURA_ESCALON > APICE, "el escalon se alcanzaria desde el piso")
	assert(ALTURA_MIRADOR < ALTURA_ESCALON + APICE, "el mirador quedaria inalcanzable")
	assert(ALTURA_MIRADOR > ALTURA_MESA + APICE, "el mirador se alcanzaria desde la mesa")

	# El jugador NO usa esta constante: saca su gravedad de ProjectSettings.
	# Si las dos se separan, el nivel queda disenado para una fisica y jugado
	# con otra, y todas las alturas mienten sin que nada avise. Se chequea con
	# un if y no con un assert porque los assert se sacan en release.
	var g_proyecto: float = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))
	if absf(g_proyecto - GRAVEDAD) > 0.01:
		push_error("gravedad desincronizada: project.godot dice %.2f y el nivel se diseno con %.2f"
			% [g_proyecto, GRAVEDAD])
		quit(1)


# --------------------------------------------------------------------------

func _material(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 1.0
	m.metallic = 0.0
	return m


## Iluminacion neutra: una direccional suave y ambiente plano. No hay
## iluminacion de autor (§1) pero tampoco puede ser plana del todo -- sin
## sombra no se leen los bordes, y no leer un borde es un fallo de
## legibilidad que contaminaria el resultado.
func _add_environment(root: Node3D) -> void:
	var we := WorldEnvironment.new()
	we.name = "Environment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.46, 0.50, 0.58)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.50, 0.52, 0.60)
	# Ambiente bajo a proposito. Con ambiente alto todas las caras de una
	# caja reciben lo mismo y los bordes desaparecen: la cara superior de la
	# mesa y su cara frontal quedaban del mismo tono y la cornisa no se leia
	# como algo a lo que se pueda subir.
	env.ambient_light_energy = 0.35
	we.environment = env
	root.add_child(we)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	root.add_child(sun)


func _box(parent: Node3D, nombre: String, pos: Vector3, size: Vector3,
		mat: StandardMaterial3D) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = nombre
	body.position = pos

	var mesh := MeshInstance3D.new()
	mesh.name = "Mesh"
	var bm := BoxMesh.new()
	bm.size = size
	mesh.mesh = bm
	mesh.material_override = mat
	body.add_child(mesh)

	var col := CollisionShape3D.new()
	col.name = "Col"
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)

	parent.add_child(body)
	return body


func _add_suelo(root: Node3D) -> void:
	_box(root, "Suelo", Vector3(0, -0.5, 0),
		Vector3(SUELO_LADO, 1.0, SUELO_LADO), _mat_suelo)


## Muros de contencion. No son nivel: son el borde del mundo. Sin ellos el
## tester se cae al vacio y la sesion se pierde por una razon que no es la
## que se esta midiendo.
func _add_muros(root: Node3D) -> void:
	var h: float = SUELO_LADO * 0.5
	var t: float = 1.0
	var muros := Node3D.new()
	muros.name = "Muros"
	root.add_child(muros)
	_box(muros, "Norte", Vector3(0, MURO_ALTO * 0.5, -h),
		Vector3(SUELO_LADO, MURO_ALTO, t), _mat_muro)
	_box(muros, "Sur", Vector3(0, MURO_ALTO * 0.5, h),
		Vector3(SUELO_LADO, MURO_ALTO, t), _mat_muro)
	_box(muros, "Este", Vector3(h, MURO_ALTO * 0.5, 0),
		Vector3(t, MURO_ALTO, SUELO_LADO), _mat_muro)
	_box(muros, "Oeste", Vector3(-h, MURO_ALTO * 0.5, 0),
		Vector3(t, MURO_ALTO, SUELO_LADO), _mat_muro)


## La mesa central Y la zona de la cornisa. El frente mira a +Z, que es de
## donde llega el jugador desde el punto de partida.
func _add_mesa(root: Node3D) -> void:
	_box(root, "Mesa", Vector3(0, ALTURA_MESA * 0.5, 0),
		Vector3(MESA_LADO, ALTURA_MESA, MESA_LADO), _mat_pisable)

	# --- LA ZONA DE LA CORNISA -------------------------------------------
	#
	# RODEA LA MESA ENTERA. Decision del director, 2026-08-19, sobre dato.
	#
	# La primera version cubria solo la cara frontal, 3 m de fondo, que es la
	# lectura literal de §4.1 ("caja delante de la cornisa"). Las dos corridas
	# de prueba mostraron que esa lectura no describe lo que pasa: hubo 2
	# pulsaciones muertas DENTRO de la zona contra 34 y 63 FUERA. No es que no
	# se insistiera -- se insistio mucho, en otro lado.
	#
	# La causa es geometrica y no de conducta: la mesa tiene cuatro caras y el
	# jugador da vueltas, asi que tres de cada cuatro aproximaciones caian
	# fuera por construccion. Con una sola cara cubierta, P medía "insistio
	# desde el lado que elegimos nosotros", no "insistio frente a la cornisa".
	#
	# NO mueve los umbrales firmados en §0.3: cambia que "frente a la cornisa"
	# signifique lo que el jugador realmente hace.
	var zone := Area3D.new()
	zone.name = "LedgeZone"
	zone.set_script(load("res://scripts/ledge_zone.gd"))
	zone.set("ledge_id", "cornisa_01")
	zone.set("zone_width", MESA_LADO + 2.0 * ZONA_MARGEN)
	zone.set("zone_depth", MESA_LADO + 2.0 * ZONA_MARGEN)
	# La altura queda POR DEBAJO de la mesa a proposito: parado arriba, el
	# jugador no cuenta como "frente a la cornisa" -- ya esta del otro lado.
	zone.set("zone_height", ALTURA_MESA - 0.2)
	zone.position = Vector3.ZERO
	root.add_child(zone)


## Torre de dos peldanos, PARADA SOBRE LA MESA. Los dos bloques se tocan: la
## altura es el problema, no la punteria. Un salto de precision agregaria una
## variable de habilidad que no es la que se mide.
func _add_torre(root: Node3D) -> void:
	var torre := Node3D.new()
	torre.name = "Torre"
	root.add_child(torre)
	var h: float = TORRE_LADO * 0.5
	_box(torre, "Escalon", Vector3(h, ALTURA_ESCALON * 0.5, -2.0),
		Vector3(TORRE_LADO, ALTURA_ESCALON, TORRE_LADO), _mat_pisable)
	_box(torre, "Mirador", Vector3(-h, ALTURA_MIRADOR * 0.5, -2.0),
		Vector3(TORRE_LADO, ALTURA_MIRADOR, TORRE_LADO), _mat_pisable)


func _add_player(root: Node3D) -> void:
	var p := CharacterBody3D.new()
	p.name = "Player"
	p.set_script(load("res://scripts/gray_player.gd"))
	# Nace donde arranca. Mover un cuerpo despues de meterlo al arbol
	# dispara un enter/exit fantasma en el CSV (leccion del 2026-08-13).
	p.position = Vector3(0, 0.1, 16)

	var col := CollisionShape3D.new()
	col.name = "Col"
	var cap := CapsuleShape3D.new()
	cap.radius = 0.4
	cap.height = 1.8
	col.shape = cap
	col.position = Vector3(0, 0.9, 0)
	p.add_child(col)

	var mesh := MeshInstance3D.new()
	mesh.name = "Mesh"
	var cm := CapsuleMesh.new()
	cm.radius = 0.4
	cm.height = 1.8
	mesh.mesh = cm
	mesh.material_override = _material(Color(0.80, 0.80, 0.84))
	mesh.position = Vector3(0, 0.9, 0)
	p.add_child(mesh)

	var pivot := Node3D.new()
	pivot.name = "CameraPivot"
	pivot.position = Vector3(0, 1.5, 0)
	p.add_child(pivot)

	var arm := SpringArm3D.new()
	arm.name = "SpringArm"
	arm.spring_length = 5.0
	arm.margin = 0.3
	pivot.add_child(arm)

	var cam := Camera3D.new()
	cam.name = "Camera"
	cam.current = true
	arm.add_child(cam)

	root.add_child(p)


func _add_systems(root: Node3D) -> void:
	var tel := Node.new()
	tel.name = "Telemetry"
	tel.set_script(load("res://scripts/telemetry.gd"))
	root.add_child(tel)

	var drv := Node.new()
	drv.name = "BondDriver"
	drv.set_script(load("res://scripts/bond_driver.gd"))
	drv.set("impulse", IMPULSO)
	drv.set("scene_id", "gray_test")
	root.add_child(drv)


## Solo se apropian nodos creados aca. No hay escenas instanciadas en este
## arbol, asi que la trampa del spike (dos arboles al empaquetar) no aplica
## -- pero la recursion se deja explicita para que se vea que es a proposito.
func _own_all(node: Node, owner_node: Node) -> void:
	for c in node.get_children():
		c.owner = owner_node
		_own_all(c, owner_node)
