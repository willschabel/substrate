shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D texture_albedo   : source_color,        filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_normal   : hint_normal,         filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_roughness : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_heightmap : hint_default_white, filter_linear_mipmap, repeat_enable;

uniform float uv_scale         : hint_range(0.01, 2.0)  = 0.25;
uniform float triplanar_blend  : hint_range(1.0, 8.0)   = 4.0;
uniform float heightmap_scale  : hint_range(0.0, 0.05)  = 0.02;
uniform float normal_depth     : hint_range(0.0, 4.0)   = 1.0;

void fragment() {
	vec3 wpos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 wnrm = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);

	// Triplanar blend weights
	vec3 blend = pow(abs(wnrm), vec3(triplanar_blend));
	blend /= blend.x + blend.y + blend.z;

	// World-space UVs per projection axis.
	// U is sign-flipped per axis so opposite walls (E/W, N/S) are not mirrored.
	// X projection (E/W walls): U=Z*sign(nx), V=Y.
	// Y projection (floor/ceiling): U=X, V=Z.
	// Z projection (N/S walls): U=X*sign(nz), V=Y.
	vec2 uv_x = vec2(wpos.z * sign(wnrm.x), -wpos.y) * uv_scale;
	vec2 uv_y = wpos.xz * uv_scale;
	vec2 uv_z = vec2(wpos.x * sign(wnrm.z), -wpos.y) * uv_scale;

	// View direction in world space
	vec3 vdir = normalize((INV_VIEW_MATRIX * vec4(VIEW, 0.0)).xyz);

	// Parallax offset on each axis.
	// Depth component = vdir.axis * sign(wnrm.axis) — always positive for front-facing surfaces.
	// U parallax is sign-flipped to match the UV flip above.
	float hx = texture(texture_heightmap, uv_x).r - 0.5;
	float hy = texture(texture_heightmap, uv_y).r - 0.5;
	float hz = texture(texture_heightmap, uv_z).r - 0.5;

	float dx = max(vdir.x * sign(wnrm.x), 0.001);
	float dy = max(vdir.y * sign(wnrm.y), 0.001);
	float dz = max(vdir.z * sign(wnrm.z), 0.001);

	uv_x += clamp((vec2(vdir.z * sign(wnrm.x), -vdir.y) / dx) * hx * heightmap_scale * blend.x, vec2(-0.04), vec2(0.04));
	uv_y += clamp((vdir.xz / dy) * hy * heightmap_scale * blend.y, vec2(-0.04), vec2(0.04));
	uv_z += clamp((vec2(vdir.x * sign(wnrm.z), -vdir.y) / dz) * hz * heightmap_scale * blend.z, vec2(-0.04), vec2(0.04));

	// Albedo
	ALBEDO = (texture(texture_albedo, uv_x) * blend.x
			+ texture(texture_albedo, uv_y) * blend.y
			+ texture(texture_albedo, uv_z) * blend.z).rgb;

	// Roughness
	ROUGHNESS = texture(texture_roughness, uv_x).r * blend.x
			  + texture(texture_roughness, uv_y).r * blend.y
			  + texture(texture_roughness, uv_z).r * blend.z;

	// Normal map — whiteout triplanar blend, then transform to view space.
	vec3 nx = texture(texture_normal, uv_x).rgb * 2.0 - 1.0;
	vec3 ny = texture(texture_normal, uv_y).rgb * 2.0 - 1.0;
	vec3 nz = texture(texture_normal, uv_z).rgb * 2.0 - 1.0;

	// Scale normal depth
	nx.xy *= normal_depth;
	ny.xy *= normal_depth;
	nz.xy *= normal_depth;

	// Whiteout blend — reconstruct world-space normal from each projection.
	// R channel (nx.x) points along the U axis; sign-flip propagates the UV flip.
	// V=-wpos.y flips the Y tangent axis; negate G channel contribution to world Y.
	nx = vec3(-nx.y + wnrm.y, nx.x * sign(wnrm.x) + wnrm.z, abs(nx.z) * wnrm.x);
	ny = vec3(ny.xy + wnrm.xz, abs(ny.z) * wnrm.y);
	nz = vec3(nz.x * sign(wnrm.z) + wnrm.x, -nz.y + wnrm.y, abs(nz.z) * wnrm.z);

	vec3 world_n = normalize(nx.zxy * blend.x + ny.xzy * blend.y + nz.xyz * blend.z);
	NORMAL = normalize((VIEW_MATRIX * vec4(world_n, 0.0)).xyz);

	METALLIC = 0.0;
}
