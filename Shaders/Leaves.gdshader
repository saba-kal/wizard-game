shader_type spatial;
render_mode depth_draw_opaque;
render_mode cull_disabled;
render_mode depth_prepass_alpha;

uniform vec3 color1 : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;
uniform sampler2D leafTexture : source_color;
uniform vec2 leaf_texture_scale = vec2(1.0f);
uniform vec2 leaf_texture_offset = vec2(0.0f);


varying vec3 worldPos;

void vertex() 
{
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() 
{
	vec3 noiseLevel = texture(noise, worldPos.xz / noiseScale).rgb;
	ALBEDO = mix(color1, color2, UV.y) * mix(color1, color2, noiseLevel.r) * texture(leafTexture, (UV + leaf_texture_offset) * leaf_texture_scale).rgb;
	
	ALPHA = texture(leafTexture, (UV + leaf_texture_offset) * leaf_texture_scale).r;
	
	if(!FRONT_FACING)
	{
		NORMAL = -NORMAL;
	}
}