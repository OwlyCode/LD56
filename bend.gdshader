shader_type spatial;
render_mode world_vertex_coords, depth_draw_opaque, depth_prepass_alpha, cull_disabled, unshaded;
const float CURVATURE = 5.0;
const float CURVATURE_ACTIVE = 1.0;
const float CURVATURE_DISTANCE = 30.0;

uniform sampler2D BASE_TEX;

void vertex() {
	if(CURVATURE_ACTIVE > 0.01) {
		NORMAL = (MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz;
		float dist = length(INV_VIEW_MATRIX[3].xyz - VERTEX) / CURVATURE_DISTANCE;
		VERTEX.y -= pow(dist, CURVATURE);
	}
}

void fragment() {
	vec4 tex = texture(BASE_TEX, UV);
	
	if(tex.a < 0.3) {
		discard;
	}
	
	ALBEDO = tex.rgb;
	ALPHA = tex.a;
}