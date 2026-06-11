// BotW-style cel shader — stepped diffuse ramp + fresnel rim.
// Ramp steps lifted from PaletteData.TOON_RAMP_STEPS = [0.42, 0.62, 0.86, 1.0].
// Shadow floor starts at 0.42 (not 0) for the lifted-pastel BotW look.
shader_type spatial;
render_mode ambient_light_disabled;

// ----- ramp constants (must match PaletteData.TOON_RAMP_STEPS) -----
const float STEP0 = 0.42;
const float STEP1 = 0.62;
const float STEP2 = 0.86;
const float STEP3 = 1.0;

// ----- uniforms -----
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform bool use_texture = false;

uniform vec4 emission_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_strength : hint_range(0.0, 8.0) = 0.0;

// Fresnel rim — sky-ish blue default matching the aetherborn ambient
uniform vec4 rim_color : source_color = vec4(0.749, 0.910, 1.0, 1.0); // #bfe8ff
uniform float rim_strength : hint_range(0.0, 1.0) = 0.25;

void vertex() {
	// Standard passthrough; normals transformed by Godot automatically.
}

void fragment() {
	vec4 base = albedo_color;
	if (use_texture) {
		base *= texture(albedo_texture, UV);
	}
	ALBEDO = base.rgb;
	ALPHA = base.a;

	// Fresnel rim computed in fragment using view direction
	float fresnel = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	fresnel = pow(fresnel, 3.0) * rim_strength;
	EMISSION = emission_color.rgb * emission_strength + rim_color.rgb * fresnel;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}

void light() {
	// Per-light stepped diffuse ramp.
	// LIGHT is the direction FROM surface TO light (normalised) in view space.
	float NdotL = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;

	// Quantise into 4 BotW-style bands, floor at 0.42.
	float ramp;
	if (NdotL < STEP0) {
		ramp = STEP0;          // lifted shadow — no pure black
	} else if (NdotL < STEP1) {
		ramp = STEP1;
	} else if (NdotL < STEP2) {
		ramp = STEP2;
	} else {
		ramp = STEP3;
	}

	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ramp;
}
