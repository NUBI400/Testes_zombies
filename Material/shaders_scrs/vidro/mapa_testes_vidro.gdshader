shader_type spatial;

uniform sampler2D noise_texture;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

void fragment() {
	vec2 _uv = UV * 1.0;
	
	vec3 color = texture(screen_texture, SCREEN_UV).xyz;
	vec3 noise = texture(noise_texture, _uv).xyz;
	
	ALBEDO = color;
	NORMAL_MAP = noise;
	ROUGHNESS = 0.5;
}