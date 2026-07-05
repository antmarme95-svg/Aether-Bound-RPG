// toon_foliage.gdshader — alpha-cutout leaf-clump cards (TotK/Sable technique).
// Cards carry a clump texture (scalloped alpha silhouette); mesh normals are
// baked RADIAL from the crown center ("spherified") so the cel ramp bands the
// whole canopy as one soft volume. ALPHA_SCISSOR keeps the opaque pass, so
// the melancolia post (screen_texture + Sobel ink) sees and outlines the cards.
shader_type spatial;
render_mode ambient_light_disabled, cull_disabled;

uniform sampler2D toon_ramp : source_color, hint_default_white, filter_nearest;
uniform sampler2D clump_tex : source_color, hint_default_white, filter_linear;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform float alpha_scissor : hint_range(0.0, 1.0) = 0.5;
uniform vec4 rim_color : source_color = vec4(0.749, 0.910, 1.0, 1.0);
uniform float rim_strength : hint_range(0.0, 1.0) = 0.06;
uniform float ambient_lift : hint_range(0.0, 1.0) = 0.24;

void fragment() {
	vec4 t = texture(clump_tex, UV);
	ALBEDO = t.rgb * albedo_color.rgb;
	ALPHA = t.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
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
