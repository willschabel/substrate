shader_type sky;

uniform vec4 background_color : source_color = vec4(0.95, 0.97, 1.0, 1.0);
uniform vec4 line_color : source_color = vec4(0.45, 0.72, 1.0, 1.0);
uniform float grid_scale : hint_range(1.0, 50.0) = 8.0;
uniform float line_thickness : hint_range(0.005, 0.1) = 0.025;
uniform float fade_distance : hint_range(0.1, 1.0) = 0.6;
uniform vec3 travel_offset = vec3(0.0);

void sky() {
	vec3 dir = normalize(EYEDIR);

	// Project direction onto grid planes, shifted by travel_offset to animate movement
	vec2 grid_xz = dir.xz / (abs(dir.y) + 0.001) * grid_scale + travel_offset.xz;
	vec2 grid_xy = dir.xy / (abs(dir.z) + 0.001) * grid_scale + travel_offset.xy;
	vec2 grid_zy = dir.zy / (abs(dir.x) + 0.001) * grid_scale + travel_offset.zy;

	vec2 f_xz = abs(fract(grid_xz) - 0.5);
	vec2 f_xy = abs(fract(grid_xy) - 0.5);
	vec2 f_zy = abs(fract(grid_zy) - 0.5);

	float line_xz = step(0.5 - line_thickness, max(f_xz.x, f_xz.y));
	float line_xy = step(0.5 - line_thickness, max(f_xy.x, f_xy.y));
	float line_zy = step(0.5 - line_thickness, max(f_zy.x, f_zy.y));

	// Weight each projection by how directly we're looking at that plane
	float w_xz = pow(abs(dir.y), 0.5);
	float w_xy = pow(abs(dir.z), 0.5);
	float w_zy = pow(abs(dir.x), 0.5);
	float w_total = w_xz + w_xy + w_zy + 0.001;

	float grid = (line_xz * w_xz + line_xy * w_xy + line_zy * w_zy) / w_total;

	// Fade lines toward the horizon
	float horizon_fade = smoothstep(0.0, fade_distance, abs(dir.y));
	grid *= horizon_fade;

	COLOR = mix(background_color.rgb, line_color.rgb, grid);
}
