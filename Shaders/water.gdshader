//Original shadertoy source: https://www.shadertoy.com/view/mtfBRr
//Credits to Leon Denise
//https://leon196.github.io/
//(@leondenise): https://twitter.com/leondenise
//Godot version: https://godotshaders.com/shader/water-toon-torrent-shader/
shader_type spatial;

render_mode cull_disabled;

uniform vec2 R = vec2(.8, .6);
uniform float scale = 0.5;
uniform float speed = 1.0;
uniform float wave_speed = 0.5;
uniform vec3 direction = vec3(1,1,0);
uniform float distortion = 0.5;
uniform float layers = 2.;
uniform float shades = 3.;
uniform int steps = 6;

uniform vec3 tint: source_color = vec3(.459,.765,1.);
uniform float alpha = 0.5;

varying vec3 world_position;

float gyroid (vec3 seed) { return dot(sin(seed + TIME * wave_speed),cos(seed.yzx)); }

float fbm (vec3 seed)
{
    float result = 0., a = .5;
    for (int i = 0; i < steps; ++i, a /= 2.) {
        seed += direction * TIME*speed*.01/a;
        seed.z += result*distortion;
        result += gyroid(seed/a)*a;
    }
    return result;
}

void vertex()
{
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment()
{
    float shape = fbm(world_position*scale);
    float gradient = fract(shape*layers);
    float shade = round(pow(gradient, 4.)*shades)/shades;
    vec3 color = mix(tint*mix(.6,.8,gradient), vec3(1), shade);
    ALBEDO = vec3(color);
    ALPHA = alpha;
}
