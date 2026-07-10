## WarpaintAtlas — ports WarpaintAtlas.js canvas logic to the Godot Image API.
## 512x256 RGBA8 image: skin base fill + optional warpaint pattern + bottom cheek shadow.
##
## GODOT SphereMesh UV LAYOUT (determined by debug renders):
##   u=0 and u=1 are BOTH at the FRONT center seam (+Z, facing the camera).
##   u=0.5 is at the BACK of the sphere (-Z).
##   The visible face (camera at +Z) occupies u=0..~0.15 and u=~0.85..1.0
##   wrapping around the seam, plus the left/right cheek sides.
##   v=0 is the top pole (crown), v=1 is the bottom pole (chin/neck).
##   Empirically: eye/brow zone = v~0.30..0.42, nose/cheek = v~0.42..0.55.
##
## All patterns are drawn as TWO symmetric halves (left edge + right edge of
## the 512-wide image) so they straddle the front-center UV seam correctly.
class_name WarpaintAtlas extends RefCounted

const W = 512
const H = 256

# ---- Calibrated UV constants for Godot SphereMesh front-seam layout ----
# Face half-width: the visible face occupies roughly u=0..0.25 AND u=0.75..1.0
# We draw each "side" of the face as a left-strip and a right-strip.
# Wider than originally estimated to cover the full cheek-to-cheek span.
const FACE_HALF_W  = int(0.25 * W)   # 128 px — half-face strip width each edge
const FACE_CY_BROW = int(0.40 * H)   # 102 — brow top (eye geometry at sphere y=0.018, v~0.46)
const FACE_CY_EYE  = int(0.46 * H)   # 118 — eye centre
const FACE_CY_NOSE = int(0.52 * H)   # 133 — nose bridge
const FACE_CY_CHIN = int(0.60 * H)   # 154 — chin

# Cheek zone extends same as face half (they're the same strip)
const CHEEK_HALF_W = int(0.25 * W)   # 128 px

# Cache: key = "<skinHex>_<index>_<paintHex>" -> ImageTexture
static var _cache: Dictionary = {}

## Build (or return cached) head texture for the given parameters.
static func build_head_texture(skin: Color, warpaint_index: int, paint: Color) -> ImageTexture:
	var key = skin.to_html() + str(warpaint_index) + paint.to_html()
	if _cache.has(key):
		return _cache[key]

	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)

	# --- base skin fill ---
	img.fill(skin)

	# --- faint cel cheek shadow (bottom 22% of image, ~7% opacity black) ---
	var shadow_color = Color(0.0, 0.0, 0.0, 0.07)
	_blend_rect(img, Rect2i(0, int(0.78 * H), W, int(0.22 * H) + 1), shadow_color)

	# --- warpaint pattern ---
	if warpaint_index != 0:
		_draw_pattern(img, warpaint_index, paint)

	var tex = ImageTexture.create_from_image(img)
	_cache[key] = tex
	return tex

# Blend a solid color rect over the image (alpha-compositing).
static func _blend_rect(img: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		if y >= H:
			break
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if x >= W:
				break
			var base = img.get_pixel(x, y)
			var result = base.blend(color)
			img.set_pixel(x, y, result)

# Draw a horizontal line of `thickness` pixels (for stripes/bars)
static func _hline(img: Image, x0: int, x1: int, y: int, thick: int, color: Color) -> void:
	for dy in range(thick):
		var py = y + dy
		if py < 0 or py >= H:
			continue
		for x in range(x0, x1 + 1):
			if x < 0 or x >= W:
				continue
			img.set_pixel(x, py, color)

# Draw a vertical line of `thickness` pixels
static func _vline(img: Image, x: int, y0: int, y1: int, thick: int, color: Color) -> void:
	for dx in range(thick):
		var px = x + dx
		if px < 0 or px >= W:
			continue
		for y in range(y0, y1 + 1):
			if y < 0 or y >= H:
				continue
			img.set_pixel(px, y, color)

# Draw a diagonal slash from (x0,y0) to (x1,y1) with given pixel thickness
static func _slash(img: Image, x0: int, y0: int, x1: int, y1: int, thick: int, color: Color) -> void:
	var steps = max(abs(x1 - x0), abs(y1 - y0))
	if steps == 0:
		return
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var px = int(lerp(float(x0), float(x1), t))
		var py = int(lerp(float(y0), float(y1), t))
		for dx in range(-thick / 2, thick / 2 + 1):
			for dy in range(-thick / 2, thick / 2 + 1):
				var nx = px + dx
				var ny = py + dy
				if nx >= 0 and nx < W and ny >= 0 and ny < H:
					img.set_pixel(nx, ny, color)

# Draw a filled rectangle
static func _fill_rect(img: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		if y < 0 or y >= H:
			continue
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if x < 0 or x >= W:
				continue
			img.set_pixel(x, y, color)

# Draw a small filled circle (dot)
static func _dot(img: Image, cx: int, cy: int, r: int, color: Color) -> void:
	for y in range(cy - r, cy + r + 1):
		for x in range(cx - r, cx + r + 1):
			if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r:
				if x >= 0 and x < W and y >= 0 and y < H:
					img.set_pixel(x, y, color)

# Helper: draw a symmetric face element on both left-edge and right-edge strips.
# Mirrors x so that left strip (x=0..w) and right strip (x=W-w..W) are both painted.
# x_inner is measured from the face center (u=0/1 seam) outward.
static func _face_hband(img: Image, y0: int, height: int, half_width: int, color: Color) -> void:
	# Left strip: x=0..half_width
	_fill_rect(img, Rect2i(0, y0, half_width, height), color)
	# Right strip: x=W-half_width..W
	_fill_rect(img, Rect2i(W - half_width, y0, half_width, height), color)

# Draw a slash on both left and right face strips (mirrored).
static func _face_slash_sym(img: Image, xL0: int, y0: int, xL1: int, y1: int, thick: int, color: Color) -> void:
	# Left strip: xL0/xL1 measured from left edge (small values)
	_slash(img, xL0, y0, xL1, y1, thick, color)
	# Mirror: x_right = W - 1 - xL
	_slash(img, W - 1 - xL0, y0, W - 1 - xL1, y1, thick, color)

static func _draw_pattern(img: Image, idx: int, paint: Color) -> void:
	match idx:
		1:
			# Slash Crimson: three diagonal slashes on both sides of face.
			# Right (character's left) = left strip; Left (character's right) = right strip.
			for i in range(3):
				var xL0 = 8 + i * 16
				var xL1 = 28 + i * 16
				_slash(img, xL0, FACE_CY_BROW - 10, xL1, FACE_CY_CHIN - 10, 8, paint)
				_slash(img, W - 1 - xL0, FACE_CY_BROW - 10, W - 1 - xL1, FACE_CY_CHIN - 10, 8, paint)

		2:
			# Hexbrand: hexagon on forehead center + vertical drop line.
			# The forehead center seam = x=0 and x=W (same UV point).
			# Draw on left strip mirrored.
			var cy = FACE_CY_BROW - 16
			var r = 17
			var pts_l: Array = []
			var pts_r: Array = []
			for i in range(7):
				var a = (float(i) / 6.0) * PI * 2.0 + PI / 6.0
				var dx = int(cos(a) * r)
				var dy = int(sin(a) * r * 0.9)
				pts_l.append(Vector2i(abs(dx), cy + dy))
				pts_r.append(Vector2i(W - 1 - abs(dx), cy + dy))
			for i in range(6):
				_slash(img, pts_l[i].x, pts_l[i].y, pts_l[i + 1].x, pts_l[i + 1].y, 5, paint)
				_slash(img, pts_r[i].x, pts_r[i].y, pts_r[i + 1].x, pts_r[i + 1].y, 5, paint)
			# Drop line from hex bottom to nose: at the seam edges
			_vline(img, 0, cy + r, FACE_CY_NOSE, 4, paint)
			_vline(img, W - 1, cy + r, FACE_CY_NOSE, 4, paint)

		3:
			# Tribal Tide: wave hooks on both cheeks.
			for i in range(3):
				# Left strip (character's right cheek)
				var bx_l = CHEEK_HALF_W - 8 - i * 6
				var by = FACE_CY_EYE + 16 + i * 14
				_slash(img, bx_l, by, bx_l - 22, by - 10, 6, paint)
				_slash(img, bx_l - 22, by - 10, bx_l - 30, by + 8, 6, paint)
				# Right strip (character's left cheek) — mirrored
				var bx_r = W - 1 - CHEEK_HALF_W + 8 + i * 6
				_slash(img, bx_r, by, bx_r + 22, by - 10, 6, paint)
				_slash(img, bx_r + 22, by - 10, bx_r + 30, by + 8, 6, paint)

		4:
			# Eye of Ash: full horizontal band across both eyes.
			# Band height: from brow line to just below eye — 30px tall.
			var band_y = FACE_CY_BROW
			var band_h = FACE_CY_EYE - FACE_CY_BROW + 18
			# Draw on both face-strip edges (wraps around front seam)
			_face_hband(img, band_y, band_h, CHEEK_HALF_W, paint)

		5:
			# Jagged Crown: zigzag across forehead — on both face strips.
			var y0 = FACE_CY_BROW - 8
			# Left strip zigzag
			var x = 4
			var up = true
			while x < FACE_HALF_W - 4:
				var nx = x + 10
				var ny = y0 - 18 if up else y0
				_slash(img, x, y0, nx, ny, 6, paint)
				x = nx
				up = !up
			# Right strip zigzag (mirrored)
			x = W - 5
			up = true
			while x > W - FACE_HALF_W + 4:
				var nx = x - 10
				var ny = y0 - 18 if up else y0
				_slash(img, x, y0, nx, ny, 6, paint)
				x = nx
				up = !up

		6:
			# Scout Marks (concept humano canónico — reviews v0.2/v0.3):
			# BILATERAL y ASIMÉTRICO — franja diagonal en la FRENTE (lado
			# DERECHO del personaje) + franja diagonal en la MEJILLA (lado
			# IZQUIERDO). Lateralidad VERIFICADA por la review v0.3: la cara
			# vive en la costura u=0 (x=0/W) y x CHICO = lado DERECHO del
			# personaje (su izquierda = el espejo W-1-x). Franjas ALARGADAS
			# (~4:1), no triángulos.
			# Scout Marks: desde M9-r4 AMBAS franjas van como GEOMETRÍA en
			# el rig (character_rig._face_mark). Motivos: el v del atlas se
			# comprime no-linealmente cerca de la ceja (debug de retícula
			# M9-r3 — la franja de frente no es posicionable) y el _slash
			# escalona la de mejilla en "gusano" (review v0.4 M6). El
			# patrón 6 en el atlas queda intencionalmente vacío.
			pass

		_:
			pass # index 0 = no paint
