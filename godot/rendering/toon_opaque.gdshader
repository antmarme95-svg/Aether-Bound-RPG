// toon_opaque.gdshader — toon.gdshader SIN escritura de ALPHA (paridad total
// de uniforms: textura, emission, vertex color, rim, ramp).
// El toon del prototipo escribe ALPHA → manda todo al pase transparente →
// invisible para hint_screen_texture (el post Melancolía lo borra). Esta
// variante es el toon del RIG desde C6 (2026-07-10): el personaje vive en el
// pase opaco, el Sobel del post le dibuja la línea de tinta (Art Bible: nítida
// de cerca, grisácea a media distancia, ausente en el horizonte).
shader_type spatial;
render_mode ambient_light_disabled;

// ----- diffuse ramp texture (global pipeline resource — toon_ramp.tres) -----
uniform sampler2D toon_ramp : source_color, hint_default_white, filter_nearest;

// ----- uniforms (idénticos a toon.gdshader) -----
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform bool use_texture = false;
uniform bool use_vertex_color = false;

uniform vec4 emission_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_strength : hint_range(0.0, 8.0) = 0.0;

uniform vec4 rim_color : source_color = vec4(0.749, 0.910, 1.0, 1.0); // #bfe8ff
uniform float rim_strength : hint_range(0.0, 1.0) = 0.18;

uniform float ambient_lift : hint_range(0.0, 1.0) = 0.14;

void fragment() {
	vec4 base = albedo_color;
	if (use_texture) {
		base *= texture(albedo_texture, UV);
	}
	if (use_vertex_color) {
		base *= COLOR;
	}
	ALBEDO = base.rgb;
	// (sin ALPHA: pase opaco — visible al depth/screen texture del post)

	EMISSION = ALBEDO * ambient_lift
	         + emission_color.rgb * emission_strength;

	float fresnel = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	fresnel = pow(fresnel, 3.0) * rim_strength;
	EMISSION += rim_color.rgb * fresnel;

	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}

void light() {
	float ndl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
	float ramp = texture(toon_ramp, vec2(ndl, 0.5)).r;
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ramp;
}
