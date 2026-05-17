shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_a   : source_color,    filter_linear_mipmap, repeat_enable;
uniform sampler2D albedo_b   : source_color,    filter_linear_mipmap, repeat_enable;
uniform sampler2D albedo_c   : source_color,    filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_a   : hint_normal,     filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_b   : hint_normal,     filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_c   : hint_normal,     filter_linear_mipmap, repeat_enable;
uniform sampler2D roughness_a : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D roughness_b : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D roughness_c : hint_default_white, filter_linear_mipmap, repeat_enable;

uniform float tile_scale  : hint_range(0.01, 10.0) = 0.667;
uniform float normal_depth : hint_range(0.0, 4.0)  = 1.0;

void fragment() {
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 tile_uv   = world_pos.xz * tile_scale;
	vec2 cell      = floor(tile_uv);
	vec2 local_uv  = fract(tile_uv);

	// Two independent hashes per cell — one picks variant, one picks rotation
	float h1 = fract(sin(dot(cell, vec2(127.1, 311.7))) * 43758.5453);
	float h2 = fract(sin(dot(cell, vec2(269.5, 183.3))) * 43758.5453);

	int variant  = int(h1 * 3.0);  // 0 = a, 1 = b, 2 = c
	int rotation = int(h2 * 4.0);  // 0 = 0°, 1 = 90°, 2 = 180°, 3 = 270°

	// Rotate local UV and its derivatives together so mip levels stay correct
	vec2 dx = dFdx(local_uv);
	vec2 dy = dFdy(local_uv);
	vec2 ruv;
	vec2 rdx;
	vec2 rdy;
	if (rotation == 0) {
		ruv = local_uv;
		rdx = dx; rdy = dy;
	} else if (rotation == 1) {
		ruv = vec2(local_uv.y, 1.0 - local_uv.x);
		rdx = vec2(dx.y, -dx.x); rdy = vec2(dy.y, -dy.x);
	} else if (rotation == 2) {
		ruv = vec2(1.0 - local_uv.x, 1.0 - local_uv.y);
		rdx = -dx; rdy = -dy;
	} else {
		ruv = vec2(1.0 - local_uv.y, local_uv.x);
		rdx = vec2(-dx.y, dx.x); rdy = vec2(-dy.y, dy.x);
	}

	vec4 alb;
	if      (variant == 0) alb = textureGrad(albedo_a, ruv, rdx, rdy);
	else if (variant == 1) alb = textureGrad(albedo_b, ruv, rdx, rdy);
	else                   alb = textureGrad(albedo_c, ruv, rdx, rdy);
	ALBEDO = alb.rgb;

	float rough;
	if      (variant == 0) rough = textureGrad(roughness_a, ruv, rdx, rdy).r;
	else if (variant == 1) rough = textureGrad(roughness_b, ruv, rdx, rdy).r;
	else                   rough = textureGrad(roughness_c, ruv, rdx, rdy).r;
	ROUGHNESS = rough;

	vec3 nrm;
	if      (variant == 0) nrm = textureGrad(normal_a, ruv, rdx, rdy).rgb;
	else if (variant == 1) nrm = textureGrad(normal_b, ruv, rdx, rdy).rgb;
	else                   nrm = textureGrad(normal_c, ruv, rdx, rdy).rgb;
	NORMAL_MAP       = nrm;
	NORMAL_MAP_DEPTH = normal_depth;

	METALLIC = 0.0;
}
