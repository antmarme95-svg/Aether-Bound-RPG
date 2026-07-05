# process_clump.gd — one-shot: convierte la sprite sheet de grumos (fondo
# blanco) en el asset foliage_clump.png (alpha + tonos casi-blancos tintables).
# Run: godot --headless --path godot --script res://tools/process_clump.gd
extends SceneTree

const SRC := "C:/Users/tonom/OneDrive/Documentos/Borisawa/Aether Bound/90-Raw/concept/foliage-clumps-v1.png"
const DST := "res://rendering/foliage_clump.png"
# celda elegida de la grid 3x3 (fila 0, col 2: grumo ancho y esponjoso)
const CELL := Rect2i(682, 0, 342, 342)

func _init() -> void:
	var img := Image.load_from_file(SRC)
	if img == null:
		push_error("no pude cargar " + SRC)
		quit(1)
		return
	var cell := img.get_region(CELL)
	var sz := cell.get_size()
	var out := Image.create(sz.x, sz.y, false, Image.FORMAT_RGBA8)
	var min_x := sz.x
	var min_y := sz.y
	var max_x := 0
	var max_y := 0
	for y in range(sz.y):
		for x in range(sz.x):
			var c := cell.get_pixel(x, y)
			var minc: float = min(c.r, min(c.g, c.b))
			var a: float = clampf(((1.0 - minc) - 0.08) * 8.0, 0.0, 1.0)
			if a <= 0.01:
				out.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var lum := (c.r + c.g + c.b) / 3.0
			var v: float
			if lum < 0.5:
				v = 0.14  # tinta: se queda oscura
			else:
				v = clampf(0.78 + (lum - 0.55) * (0.22 / 0.42), 0.70, 1.0)
			out.set_pixel(x, y, Color(v, v, v, a))
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	# recorte al contenido + margen
	var m := 4
	var rect := Rect2i(
		maxi(min_x - m, 0), maxi(min_y - m, 0),
		mini(max_x - min_x + 2 * m, sz.x), mini(max_y - min_y + 2 * m, sz.y))
	var trimmed := out.get_region(rect)
	trimmed.save_png(ProjectSettings.globalize_path(DST))
	print("[process_clump] OK -> ", ProjectSettings.globalize_path(DST),
		" (", trimmed.get_width(), "x", trimmed.get_height(), ")")
	quit(0)
