shader_type canvas_item;

uniform float sway_strength : hint_range(0.0, 20.0) = 5.0;
uniform float sway_speed : hint_range(0.0, 10.0) = 2.0;

void vertex() {
	// Called for every vertex the material is visible on.
	float sway = cos(TIME * sway_speed + VERTEX.y * 0.05) * sway_strength * (VERTEX.y / 100.0);
	VERTEX.x += sway;
}

void fragment() {
	// Called for every pixel the material is visible on.
}