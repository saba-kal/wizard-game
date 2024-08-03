shader_type spatial;

render_mode ambient_light_disabled, depth_prepass_alpha, cull_disabled;

uniform vec4 albedo : source_color = vec4(1.0f);
uniform sampler2D albedo_texture : source_color;
uniform vec2 albedo_texture_scale = vec2(1.0f);
uniform vec2 albedo_texture_offset = vec2(0.0f);
uniform bool clamp_diffuse_to_max = false;
uniform float light_strength : hint_range(0.0f, 20.0f) = 1.0;
uniform float contrast : hint_range(0.0f, 10.0f) = 1.0;
uniform float saturation : hint_range(0, 3) = 1.0;

uniform float red_val : hint_range(0, 1) = 1.0;
uniform float green_val : hint_range(0, 1) = 1.0;
uniform float blue_val : hint_range(0, 1) = 1.0;

uniform int cuts : hint_range(1, 8) = 3;
uniform float wrap : hint_range(-2.0f, 2.0f) = 0.0f;
uniform float steepness : hint_range(1.0f, 8.0f) = 1.0f;

uniform bool use_attenuation = true;

uniform bool use_specular = true;
uniform float specular_strength : hint_range(0.0f, 1.0f) = 1.0f;
uniform float specular_shininess : hint_range(0.0f, 32.0f) = 16.0f;
uniform sampler2D specular_map : source_color;

uniform bool use_rim = true;
uniform float rim_width : hint_range(0.0f, 16.0f) = 8.0f;
uniform vec4 rim_color : source_color = vec4(1.0f);

uniform bool use_ramp = false;
uniform sampler2D ramp : source_color;

uniform bool use_borders = false;
uniform float border_width = 0.01f;

uniform bool use_dissolve = false;
uniform sampler2D dissolve_texture : source_color;
uniform float dissolve_value : hint_range(0,1);
uniform float dissolve_brightness : hint_range(0,10) = 1.0;
uniform float dissolve_burn_size: hint_range(0.0, 1.0, 0.01);
uniform vec4 dissolve_burn_color: source_color;

varying vec3 vertex_pos;
varying vec3 normal;

mat4 contrast_matrix(){
    float t = ( 1.0 - contrast ) / 2.0;
    return mat4( 
        vec4(contrast, 0, 0, 0),
        vec4(0, contrast, 0, 0),
        vec4(0, 0, contrast, 0),
        vec4(t, t, t, 1));
}

mat4 saturation_matrix(){
    vec3 luminance = vec3( 0.3086, 0.6094, 0.0820 );
    float oneMinusSat = 1.0 - saturation;

    vec3 red = vec3( luminance.x * oneMinusSat );
    red+= vec3(saturation, 0, 0)*red_val;
    vec3 green = vec3( luminance.y * oneMinusSat );
    green += vec3( 0,saturation, 0 )*green_val;
    vec3 blue = vec3( luminance.z * oneMinusSat );
    blue += vec3( 0, 0,saturation )*blue_val;

    return mat4(vec4(red, 0),vec4(green,0),vec4(blue,0),vec4(0, 0, 0, 1));
}

float split_specular(float specular) {
    return step(0.5f, specular);
}

void vertex() {
    vertex_pos = VERTEX;
    normal = NORMAL;
}

void fragment() {
    vec4 albedo_tex = texture(albedo_texture, (UV + albedo_texture_offset) * albedo_texture_scale);
    vec4 main_albedo = albedo * albedo_tex;
    main_albedo = main_albedo * contrast_matrix() * saturation_matrix();
    if (use_dissolve){
        // Credit: https://godotshaders.com/shader/2d-dissolve-with-burn-edge/
        vec4 noise_texture = texture(dissolve_texture, UV);
        float burn_size_step = dissolve_burn_size * step(0.001, dissolve_value) * step(dissolve_value, 0.999);
        float threshold = smoothstep(noise_texture.x-burn_size_step, noise_texture.x, dissolve_value);
        float border = smoothstep(noise_texture.x, noise_texture.x + burn_size_step, dissolve_value);
        ALPHA = threshold;
        ALBEDO = mix(dissolve_burn_color, main_albedo, border).rgb;
        EMISSION = mix(dissolve_burn_color.rgb * dissolve_brightness, vec3(0), border);
    }
    else{
        ALBEDO = main_albedo.rgb;
        ALPHA = albedo_tex.a;
    }
}

void light() {
	// Attenuation.
	float attenuation = 1.0f;
	if (use_attenuation) {
		attenuation = ATTENUATION;
	}
	
	// Diffuse lighting.
	float NdotL = dot(NORMAL, LIGHT);
	float diffuse_amount = NdotL + (attenuation - 1.0) + wrap;
	//float diffuse_amount = NdotL * attenuation + wrap;
	diffuse_amount *= steepness;
	float cuts_inv = 1.0f / float(cuts);
	float diffuse_stepped = clamp(diffuse_amount + mod(1.0f - diffuse_amount, cuts_inv), 0.08f, 1.0f);

	// Calculate borders.
	float border = 0.0f;
	if (use_borders) {
		float corr_border_width = length(cross(NORMAL, LIGHT)) * border_width * steepness;
		border = step(diffuse_stepped - corr_border_width, diffuse_amount)
				 - step(1.0 - corr_border_width, diffuse_amount);
	}
	
	// Apply diffuse result to different styles.
	vec3 diffuse = ALBEDO.rgb * LIGHT_COLOR / PI * light_strength;
	if (use_ramp) {
		diffuse *= texture(ramp, vec2(diffuse_stepped * (1.0f - border), 0.0f)).rgb;
	} else {
		diffuse *= diffuse_stepped * (1.0f - border);
	}
	
	if (clamp_diffuse_to_max) {
		// Clamp diffuse to max for multiple light sources.
		DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, diffuse);
	} else {
		DIFFUSE_LIGHT += diffuse;
	}
	
	// Specular lighting.
	if (use_specular) {
		vec3 H = normalize(LIGHT + VIEW);
		float NdotH = dot(NORMAL, H);
		float specular_amount = max(pow(NdotH, specular_shininess*specular_shininess), 0.0f)
							    * texture(specular_map, UV).r
								* attenuation;
		specular_amount = split_specular(specular_amount);
		SPECULAR_LIGHT += specular_strength * specular_amount * LIGHT_COLOR;
	}
	
	// Simple rim lighting.
	if (use_rim) {
		float NdotV = dot(NORMAL, VIEW);
		float rim_light = pow(1.0 - NdotV, rim_width);
		DIFFUSE_LIGHT += rim_light * rim_color.rgb * rim_color.a * LIGHT_COLOR / PI;
	}
}