shader_type canvas_item;

uniform float texture_shift = 0.0;
uniform vec4 gs_modulate : source_color = vec4(0.0, 0.0, 0.0, 0.0);

void fragment(){
	vec2 uv = UV;
	uv.x += texture_shift;
	vec4 color = texture(TEXTURE, uv);
	color = color + gs_modulate;
	COLOR = color;
}