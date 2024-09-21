shader_type spatial;
render_mode depth_prepass_alpha;

uniform sampler2D heightmap : repeat_disable;
uniform float min_height = -2.5f;
uniform float max_height = 2.5f;
uniform float height_offset = 0.05f;
uniform float alpha : hint_range(0, 1) = 0.8f;
uniform int octaves = 2;
uniform vec2 offset = vec2(0.5, 0.5);
uniform vec2 tiling = vec2(1.0, 1.0);
uniform float offset_strength : hint_range(0, 1);
uniform float fade_amount : hint_range(0, 1) = 1;
uniform float fade_smoothing : hint_range(0, 1) = 0.5;
uniform float hypotenuse = 0.707;
uniform sampler2D gradient : source_color;

// Source: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
vec2 hash( vec2 p ){
    p = vec2( dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3)));
    return fract(sin(p)*43758.5453);
}

// Source: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
float voronoi( in vec2 x ){
    float function = mod(TIME,4.0);
    bool multiply_by_F1 = mod(TIME,8.0) >= 4.0;
    bool is_inverse = mod(TIME,16.0) >= 8.0;
    float distance_type	= mod(TIME/16.0,4.0);
    vec2 n = floor( x );
    vec2 f = fract( x );

    float F1 = 8.0;
    float F2 = 8.0;

    for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ ){
            vec2 g = vec2(float(i),float(j));
            vec2 o = hash( n + g );
            
            o = 0.5 + 0.41*sin( 6.2831*o );	
            vec2 r = g - f + o;
            float d =sqrt(dot(r,r));

            if( d<F1 ) { 
                F2 = F1; 
                F1 = d; 
            } 
            else if( d<F2 ) {
                F2 = d;
            }
    }
	
    float c = (F1+F2)/2.0;
    c = (F1+F2)/2.0;
    c *= F1;

    return c;
}

float fbm( in vec2 p ){
    float s = 0.0;
    float m = 0.0;
    float a = 0.5;

    for( int i=0; i<octaves; i++ ){
        float noise_val = voronoi(p);
        s += a * noise_val;
        m += a;
        a *= 0.2;
        p *= 1.0;
    }
    return s/m;
}

void vertex() {
    float height_val = texture(heightmap, UV).x;
    height_val = clamp(height_val, 0.0, 1.0);
    VERTEX.y = mix(min_height, max_height, height_val) + height_offset; 
}

void fragment() {
    float noise_val = fbm(vec2(UV.x, UV.y) * 8.0);
    vec4 gradient_color = texture(gradient, vec2(noise_val, UV.y));
    ALBEDO = gradient_color.xyz;

    //Fadeout. Source: https://github.com/gamedevserj/Godot-Shaders/blob/master/CircularFadeOutShader/circular_fade_out_shader.shader
    vec2 center = UV * tiling - offset;
    float fade_distance = length(center);
    float inverted_fade_amount = fade_amount + noise_val * 0.2;
    float remapped_fade = inverted_fade_amount * (inverted_fade_amount * hypotenuse + fade_smoothing) - fade_smoothing;
    float fade_mask = smoothstep(0.0, 1.0 * fade_smoothing, remapped_fade - fade_distance);
    ALPHA = fade_mask * alpha;
}