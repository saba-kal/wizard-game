shader_type spatial;

render_mode cull_disabled, unshaded, shadows_disabled, depth_prepass_alpha;

uniform float horizontal_stretch = 5.0f;
uniform float verticak_stretch = 0.5f;
uniform float twist_amount = 2.0f;
uniform float y_scroll_speed = 1.0f;
uniform float noise_scale = 1.0f;
uniform float brightness = 1.0f;
uniform float fire_amount: hint_range(0.0, 1.0) = 1.0f;
uniform sampler2D albedo_texture : source_color;
uniform sampler2D noise_texture : source_color;


void fragment() {

    // Edge smoothing/blurring
    float xp = smoothstep( 0.0, 0.1, UV.x ); // Left edge
    float xn = smoothstep( 1.0, 0.8, UV.x ); // Right edge
    float yp = smoothstep( 0.0, 0.1, 1.0 - UV.y ); // Bottom edge
    float yn = smoothstep( 1.0, 0.1, 1.0 - UV.y ); // Top edge
    float fall_off = xp*xn*yp*yn;

    // Fire noise effect
    vec2 noise_uv = vec2(
        UV.x * horizontal_stretch + UV.y * twist_amount,
        UV.y * verticak_stretch - TIME * y_scroll_speed) * noise_scale;
    float noise_val = texture(noise_texture, noise_uv).r;

    float alpha = fall_off * smoothstep(noise_val, 1.0, UV.y * fire_amount);
    ALPHA = alpha;

    // Fire color
    float color_noise_val = (noise_val * 0.6) + (UV.y * 0.4);
    vec2 albedo_uv = vec2(1.0 - color_noise_val, 0.0);
    vec3 albedo_val = texture(albedo_texture, albedo_uv).rgb;
    vec3 albedo_val_2 = texture(albedo_texture, vec2(1.0 - UV.y, 0.0)).rgb;

    ALBEDO = albedo_val * brightness;
}
