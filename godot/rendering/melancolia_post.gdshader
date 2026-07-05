// melancolia_post.gdshader — the 4-layer "Melancolía Gráfica" screen-space pass.
// Fullscreen quad (QuadMesh size 2x2) parented anywhere; POSITION override in
// vertex() makes it cover the screen. Reads screen + depth.
//
// Layer 1: Sobel edge ink, attenuated by linear depth ("brush runs out of ink").
// Layer 2: soft luminance quantization, 3-4 bands, jittered band edges.
// Layer 3: aerial perspective toward pastel + glowing edges (color per hour).
// Layer 4: paper grain + line boil (time-quantized UV wobble on the ink).
shader_type spatial;
render_mode unshaded, fog_disabled, depth_test_disabled, cull_disabled, depth_draw_never;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear, repeat_disable;
uniform sampler2D depth_tex : hint_depth_texture, filter_nearest, repeat_disable;

// --- layer 1: ink ---
uniform vec4 ink_color : source_color = vec4(0.10, 0.09, 0.11, 1.0);
uniform float ink_strength : hint_range(0.0, 2.0) = 1.0;
uniform float edge_threshold : hint_range(0.0, 2.0) = 0.30;
uniform float edge_gain : hint_range(0.0, 24.0) = 10.0;
uniform float ink_fade_dist : hint_range(1.0, 400.0) = 70.0; // lin depth where ink is ~gone

// --- layer 2: bands ---
uniform float band_count : hint_range(2.0, 6.0) = 4.0;
uniform float band_mix : hint_range(0.0, 1.0) = 0.45;
uniform float band_jitter : hint_range(0.0, 0.5) = 0.10;

// --- layer 3: air ---
uniform vec4 aerial_color : source_color = vec4(0.73, 0.80, 0.85, 1.0);
uniform float aerial_start : hint_range(0.0, 200.0) = 35.0;
uniform float aerial_end : hint_range(10.0, 600.0) = 220.0;
uniform float aerial_max : hint_range(0.0, 1.0) = 0.55;
uniform vec4 glow_color : source_color = vec4(1.0, 0.92, 0.75, 1.0);
uniform float glow_strength : hint_range(0.0, 2.0) = 0.35;
// god rays (radial gather toward the sun's screen position; hour-driven)
uniform vec2 sun_screen = vec2(0.5, 0.35);
uniform vec4 ray_color : source_color = vec4(1.0, 0.9, 0.7, 1.0);
uniform float ray_strength : hint_range(0.0, 2.0) = 0.0;

// --- layer 4: paper ---
uniform float grain_amount : hint_range(0.0, 0.3) = 0.055;
uniform float boil_amount : hint_range(0.0, 4.0) = 1.1;   // pixels of line wobble
uniform float boil_fps : hint_range(1.0, 24.0) = 8.0;

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float lin_depth(vec2 uv, mat4 inv_proj) {
	float d = texture(depth_tex, uv).r;
	vec3 ndc = vec3(uv * 2.0 - 1.0, d);
	vec4 view = inv_proj * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 px = 1.0 / VIEWPORT_SIZE;

	// ---- layer 4a: line boil offset (time-quantized, hand-drawn wobble) ----
	float tq = floor(TIME * boil_fps) / boil_fps;
	vec2 boil = (vec2(
		hash12(uv * 311.7 + tq * 17.0),
		hash12(uv * 197.3 + tq * 29.0)) - 0.5) * boil_amount * px;
	vec2 euv = uv + boil;

	// ---- depth ----
	float raw_d = texture(depth_tex, uv).r;
	bool is_sky = raw_d <= 0.000001; // reversed-z: far plane ~0
	float lin = lin_depth(uv, INV_PROJECTION_MATRIX);

	// ---- layer 1: Sobel on linear depth around euv ----
	float dl = lin_depth(euv + vec2(-px.x, 0.0), INV_PROJECTION_MATRIX);
	float dr = lin_depth(euv + vec2(px.x, 0.0), INV_PROJECTION_MATRIX);
	float du = lin_depth(euv + vec2(0.0, -px.y), INV_PROJECTION_MATRIX);
	float dd = lin_depth(euv + vec2(0.0, px.y), INV_PROJECTION_MATRIX);
	float grad = abs(dr - dl) + abs(dd - du);
	// normalize by distance so far geometry doesn't edge on every texel
	float e = clamp((grad / max(lin * 0.02, 0.02) - edge_threshold) * edge_gain, 0.0, 1.0);
	float fade = exp(-lin / ink_fade_dist);
	float ink_a = is_sky ? 0.0 : e * ink_strength * max(fade, 0.06);
	// ink greys out with distance ("running out of ink")
	vec3 ink_rgb = mix(aerial_color.rgb, ink_color.rgb, clamp(fade * 1.4, 0.0, 1.0));

	// ---- base color ----
	vec3 col = texture(screen_tex, uv).rgb;

	// ---- layer 2: soft quantization with jittered band edges ----
	float lum = dot(col, vec3(0.299, 0.587, 0.114));
	float jn = (hash12(uv * 521.9 + tq * 7.0) - 0.5) * band_jitter;
	float q = (floor(clamp(lum + jn, 0.0, 0.999) * band_count) + 0.5) / band_count;
	vec3 qcol = col * (q / max(lum, 0.02));
	col = mix(col, qcol, is_sky ? band_mix * 0.35 : band_mix);

	// ---- layer 3: aerial perspective + glowing edges ----
	if (!is_sky) {
		float a = smoothstep(aerial_start, aerial_end, lin) * aerial_max;
		col = mix(col, aerial_color.rgb, a);
		// backlit halo: only CRISP distant edges catch the hour's light
		col += glow_color.rgb * (e * e * (1.0 - fade) * glow_strength);
	}

	// ---- layer 1 composite: ink on top ----
	col = mix(col, ink_rgb, ink_a);

	// ---- layer 3b: god rays (the air has weight) ----
	if (ray_strength > 0.001) {
		vec2 rdir = sun_screen - uv;
		float rdist = length(rdir);
		vec2 rstep = rdir / 24.0;
		vec2 suv = uv;
		float acc = 0.0;
		for (int i = 0; i < 24; i++) {
			suv += rstep;
			vec3 sc = texture(screen_tex, suv).rgb;
			float b = max(dot(sc, vec3(0.333)) - 0.70, 0.0);
			float sky_w = texture(depth_tex, suv).r <= 0.000001 ? 1.0 : 0.25;
			acc += b * sky_w;
		}
		acc /= 24.0;
		col += ray_color.rgb * acc * exp(-rdist * 2.2) * ray_strength;
	}

	// ---- layer 4b: paper grain (static-ish, subtle) ----
	float g = hash12(floor(uv * VIEWPORT_SIZE * 0.55));
	col *= 1.0 + (g - 0.5) * grain_amount;

	ALBEDO = col;
	// Forces the quad into the transparent pass so hint_screen_texture
	// samples the COMPLETED opaque scene of the current frame (without this
	// the quad runs in the opaque pass and feeds back a washed-out copy).
	ALPHA = 1.0;
}
