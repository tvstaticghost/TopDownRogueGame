shader_type canvas_item;

uniform float sway_strength : hint_range(0.0, 20.0) = 2.0;
uniform float sway_speed : hint_range(0.0, 10.0) = 0.25;

uniform sampler2D sway_mask;

void vertex() {
	// Called for every vertex the material is visible on.
	vec3 mask_rgb = texture(sway_mask, UV).rgb;
	float mask_value = step(0.0, mask_rgb.r + mask_rgb.g + mask_rgb.b);
	float sway = cos(TIME * sway_speed + VERTEX.y * 0.05) * sway_strength * (VERTEX.y / 100.0);
	VERTEX.x += sway * mask_value;
}

void fragment() {
	// Called for every pixel the material is visible on.
}