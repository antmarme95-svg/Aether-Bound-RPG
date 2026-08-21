// toon_golden.gdshader — golden-scene variant of toon.gdshader.
// Identical cel ramp, but OPAQUE (no ALPHA write): the prototype toon writes
// ALPHA which pushes every object into the transparent pass, so they never
// appear in hint_screen_texture and the melancolia post pass erases them.
shader_type spatial;
render_mode ambient_light_disabled;

uniform sampler2D toon_ramp : source_color, hint_default_white, filter_nearest;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform bool use_vertex_color = false;
uniform vec4 rim_color : source_color = vec4(0.749, 0.910, 1.0, 1.0);
uniform float rim_strength : hint_range(0.0, 1.0) = 0.10;
uniform float ambient_lift : hint_range(0.0, 1.0) = 0.24;

void fragment() {
	vec4 base = albedo_color;
	if (use_vertex_color) {
		base *= COLOR;
	}
	ALBEDO = base.rgb;
	EMISSION = ALBEDO * ambient_lift;
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0) * rim_strength;
	EMISSION += rim_color.rgb * fresnel;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}

void light() {
	float ndl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;
	float ramp = texture(toon_ramp, vec2(ndl, 0.5)).r;
	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ramp;
}
