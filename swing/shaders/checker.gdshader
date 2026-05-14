shader_type spatial;

uniform vec4 color_a : source_color = vec4(0.85, 0.85, 0.85, 1.0);
uniform vec4 color_b : source_color = vec4(0.25, 0.25, 0.25, 1.0);
uniform float tile_size : hint_range(0.25, 10.0) = 2.0;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 grid = floor(world_pos.xz / tile_size);
	float checker = mod(grid.x + grid.y, 2.0);
	ALBEDO = mix(color_a.rgb, color_b.rgb, checker);
	ROUGHNESS = 0.8;
	METALLIC = 0.0;
}
