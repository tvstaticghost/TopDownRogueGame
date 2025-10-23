shader_type canvas_item;

float rand(vec2 seed) {
    return fract(sin(dot(seed, vec2(12.9898, 78.233))) * 43758.5453123);
}

void vertex() {
    // Random value per vertex based on position
    float strength = 5.0; // max horizontal break amount
    float direction = rand(VERTEX.xy + vec2(10.0, 20.0)) >= 0.5 ? 1.0 : -1.0;
    float amount = rand(VERTEX.xy) * strength;

    VERTEX.x += direction * amount;

    // Optional: Add more break near the top (or bottom) of the trail
    // For example, more distortion near y = 0
    float fade = VERTEX.y; // assuming trail runs vertically
    VERTEX.x *= fade; // less distortion at bottom
}

void fragment() {
    COLOR.a = 0.2; // translucent trail
}
