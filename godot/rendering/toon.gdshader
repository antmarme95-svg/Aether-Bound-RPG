// BotW-style cel shader — stepped diffuse ramp + fresnel rim.
// Ramp steps: 4 bands from 0 to 1.  The shadow lift comes from
// WorldEnvironment ambient (set per-scene), NOT from a per-light floor.
// This prevents multi-light stacking from blowing out to white.
shader_type spatial;
render_mode ambient_light_disabled;

// ----- ramp band thresholds -----
// NdotL < THRESH0 → dark band (0.0), < THRESH1 → mid-dark (0.38),
// < THRESH2 → mid-bright (0.62), else → full bright (1.0).
const float THRESH0 = 0.20;
const float THRESH1 = 0.50;
const float THRESH2 = 0.78;

// ----- uniforms -----
uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform bool use_texture = false;
// vertex-colour support (for terrain / multimesh)
uniform bool use_vertex_color = false;

uniform vec4 emission_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float emission_strength : hint_range(0.0, 8.0) = 0.0;

// Fresnel rim
uniform vec4 rim_color : source_color = vec4(0.749, 0.910, 1.0, 1.0); // #bfe8ff
uniform float rim_strength : hint_range(0.0, 1.0) = 0.18;

// Ambient lift — replaces the old per-light floor.
// Set this per-scene to match WorldEnvironment ambient energy.
uniform float ambient_lift : hint_range(0.0, 1.0) = 0.14;

void vertex() {
	// Standard passthrough; normals transformed by Godot automatically.
}

void fragment() {
	vec4 base = albedo_color;
	if (use_texture) {
		base *= texture(albedo_texture, UV);
	}
	if (use_vertex_color) {
		base *= COLOR;
	}
	ALBEDO = base.rgb;
	ALPHA = base.a;

	// Ambient lift baked into EMISSION so it shows even with no lights
	EMISSION = ALBEDO * ambient_lift
	         + emission_color.rgb * emission_strength;

	// Fresnel rim
	float fresnel = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	fresnel = pow(fresnel, 3.0) * rim_strength;
	EMISSION += rim_color.rgb * fresnel;

	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}

void light() {
	// Stepped diffuse ramp — no artificial floor here.
	float NdotL = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION;

	float ramp;
	if (NdotL < THRESH0) {
		ramp = 0.0;
	} else if (NdotL < THRESH1) {
		ramp = 0.38;
	} else if (NdotL < THRESH2) {
		ramp = 0.62;
	} else {
		ramp = 1.0;
	}

	DIFFUSE_LIGHT += ALBEDO * LIGHT_COLOR * ramp;
}
