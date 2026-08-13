extends SkeletonModifier3D
class_name SpikeTwoBoneIK

## Solver de IK de dos huesos, escrito a mano.
##
## Por que existe: el `TwoBoneIK3D` que Godot 4.7.1 trae de fabrica **no
## produce salida**. Probado en escena minima aislada con 9 variantes de
## configuracion, todas en 0 pixeles, contra una variante de CONTROL que si
## mueve el render (ver tools/min_ik_repro.gd). No es nuestro rig.
##
## Se implementa como `SkeletonModifier3D` y no escribiendo huesos desde un
## `_physics_process` porque el framework de modifiers es el que garantiza
## el ORDEN correcto: corre dentro del update del Skeleton3D, despues de
## que el AnimationMixer escribio la pose. Escribiendo por afuera, la
## animacion nos pisaria el resultado la mitad de los frames.
##
## Matematica: ley de cosenos clasica. Dado el hombro/cadera A, la
## rodilla/codo B y la punta C, mas un objetivo T y una direccion de polo:
##   - se limita la distancia |T-A| al alcance de la cadena
##   - se resuelve el angulo en A con la ley de cosenos
##   - se ubica B en el plano que definen (T-A) y el polo
##   - se rota el hueso raiz para llevar B a su lugar, y el del medio para
##     llevar C al objetivo
## Nada de iteraciones: es analitico y determinista.

class Chain:
	var root_bone: int = -1
	var mid_bone: int = -1
	var end_bone: int = -1
	var target: Node3D
	var pole: Vector3 = Vector3(0, 0, 1)
	## Si es true, la punta ademas COPIA la orientacion del objetivo (es lo
	## que hace que la planta del pie acompane la pendiente).
	var align_end: bool = true

var chains: Array[Chain] = []

func add_chain(root_name: String, mid_name: String, end_name: String,
		target: Node3D, pole: Vector3 = Vector3(0, 0, 1), align_end: bool = true) -> bool:
	var skel := get_skeleton()
	if skel == null:
		push_warning("SpikeTwoBoneIK: sin Skeleton3D")
		return false
	var c := Chain.new()
	c.root_bone = skel.find_bone(root_name)
	c.mid_bone = skel.find_bone(mid_name)
	c.end_bone = skel.find_bone(end_name)
	if c.root_bone < 0 or c.mid_bone < 0 or c.end_bone < 0:
		push_warning("SpikeTwoBoneIK: huesos no encontrados: %s/%s/%s" % [root_name, mid_name, end_name])
		return false
	c.target = target
	c.pole = pole
	c.align_end = align_end
	chains.append(c)
	return true

func _process_modification() -> void:
	var skel := get_skeleton()
	if skel == null:
		return
	for c in chains:
		_solve(skel, c)

func _solve(skel: Skeleton3D, c: Chain) -> void:
	if c.target == null or not c.target.is_inside_tree():
		return

	# Todo en espacio de esqueleto: es donde viven las poses de hueso.
	var to_skel: Transform3D = skel.global_transform.affine_inverse()
	var target_t: Transform3D = to_skel * c.target.global_transform

	var t_root: Transform3D = skel.get_bone_global_pose(c.root_bone)
	var t_mid: Transform3D = skel.get_bone_global_pose(c.mid_bone)
	var t_end: Transform3D = skel.get_bone_global_pose(c.end_bone)

	var a: Vector3 = t_root.origin
	var b: Vector3 = t_mid.origin
	var e: Vector3 = t_end.origin

	var l1: float = a.distance_to(b)
	var l2: float = b.distance_to(e)
	if l1 < 0.0001 or l2 < 0.0001:
		return

	var target_pos: Vector3 = target_t.origin
	var to_target: Vector3 = target_pos - a
	var dist: float = to_target.length()
	if dist < 0.0001:
		return
	var dir: Vector3 = to_target / dist
	# Se recorta a lo que la cadena alcanza de verdad; el 0.999 evita la
	# extension perfecta, que deja el plano de la rodilla indefinido.
	var reach: float = clampf(dist, absf(l1 - l2) + 0.001, (l1 + l2) * 0.999)

	# Plano de flexion: lo definen la direccion al objetivo y el polo.
	var pole_dir: Vector3 = (t_root.basis * c.pole).normalized()
	var bend_normal: Vector3 = dir.cross(pole_dir)
	if bend_normal.length() < 0.0001:
		# Polo alineado con el objetivo: se elige cualquier perpendicular.
		bend_normal = dir.cross(Vector3.UP)
		if bend_normal.length() < 0.0001:
			bend_normal = dir.cross(Vector3.RIGHT)
	bend_normal = bend_normal.normalized()

	# Ley de cosenos: angulo en A entre (B-A) y (T-A).
	var cos_a: float = clampf((l1 * l1 + reach * reach - l2 * l2) / (2.0 * l1 * reach), -1.0, 1.0)
	var angle_a: float = acos(cos_a)

	var new_b: Vector3 = a + (Basis(bend_normal, angle_a) * dir) * l1
	var new_e: Vector3 = a + dir * reach

	# --- Hueso raiz: se lo rota para llevar B a su lugar nuevo ---
	var q1 := _rotation_between(b - a, new_b - a)
	var root_basis: Basis = Basis(q1) * t_root.basis
	skel.set_bone_global_pose(c.root_bone, Transform3D(root_basis, a))

	# --- Hueso del medio: arrastrado por q1, se lo rota para llevar C ---
	var e_after_q1: Vector3 = new_b + q1 * (e - b)
	var q2 := _rotation_between(e_after_q1 - new_b, new_e - new_b)
	var mid_basis: Basis = Basis(q2) * Basis(q1) * t_mid.basis
	skel.set_bone_global_pose(c.mid_bone, Transform3D(mid_basis, new_b))

	# --- Punta: posicion resuelta, y orientacion del objetivo si se pidio ---
	var end_basis: Basis = target_t.basis if c.align_end else (Basis(q2) * Basis(q1) * t_end.basis)
	skel.set_bone_global_pose(c.end_bone, Transform3D(end_basis, new_e))

func _rotation_between(from_v: Vector3, to_v: Vector3) -> Quaternion:
	var f: Vector3 = from_v.normalized()
	var t: Vector3 = to_v.normalized()
	if f.length_squared() < 0.5 or t.length_squared() < 0.5:
		return Quaternion.IDENTITY
	var d: float = clampf(f.dot(t), -1.0, 1.0)
	if d > 0.99999:
		return Quaternion.IDENTITY
	if d < -0.99999:
		var axis: Vector3 = f.cross(Vector3.UP)
		if axis.length() < 0.0001:
			axis = f.cross(Vector3.RIGHT)
		return Quaternion(axis.normalized(), PI)
	var cross: Vector3 = f.cross(t)
	if cross.length() < 0.000001:
		return Quaternion.IDENTITY
	return Quaternion(cross.normalized(), acos(d))
