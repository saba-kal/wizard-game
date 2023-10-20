shader_type spatial;
render_mode cull_disabled;
render_mode unshaded;

uniform vec4 color : source_color = vec4(1.0f);
uniform float flow_speed = 0.1f;
uniform float noise_scale = 1.0f;
uniform sampler2D noise_texture : source_color;

varying vec3 vertex_normal;

void vertex() {
    vertex_normal = NORMAL; // Make the normal the color.
}

void fragment() {
    vec4 textureColor = texture(noise_texture, UV * noise_scale + vec2(0, TIME * flow_speed));
    ALBEDO = textureColor.rgb * color.rgb * 10.0;
    if (abs(vertex_normal.y) > 0.1){
        ALPHA = 0.0;
    }
    else {
        ALPHA = UV.y * textureColor.r * color.a;
    }
}
