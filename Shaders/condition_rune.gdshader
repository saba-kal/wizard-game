// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_disabled;

uniform vec4 albedo : source_color;
uniform sampler2D diffuse_curve;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform vec4 metallic_texture_channel;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;



void light(){
    vec3 litness = texture(diffuse_curve, vec2(dot(NORMAL, LIGHT), 0.0)).rgb;
	DIFFUSE_LIGHT +=  LIGHT_COLOR * ATTENUATION * litness;
}



void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {


	ALBEDO = albedo.rgb;

	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
}
