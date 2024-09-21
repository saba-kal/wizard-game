shader_type spatial;

uniform sampler2D heightmap : repeat_disable;
uniform float min_height = -2.5f;
uniform float max_height = 2.5f;
uniform float height_offset = 0.1f;

void vertex() {
    float height_val = texture(heightmap, UV).x;
    height_val = clamp(height_val, 0.0, 1.0);
    VERTEX.y = mix(min_height, max_height, height_val) + height_offset; 
}
