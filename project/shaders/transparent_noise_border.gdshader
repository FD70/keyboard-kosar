shader_type canvas_item;

uniform float texture_shift = 0.0;

uniform sampler2D textureNoise: repeat_enable;
uniform float radius: hint_range(0.0, 1.0) = 0.459;
uniform float effectControl: hint_range(0.0, 1.0) = 0.309;
uniform float burnSpeed: hint_range(0.0, 1.0) = 0.076;
uniform float shape: hint_range(0.0, 1.0) = 1.0;
uniform vec2 s_direction = vec2(0.0, 1.0);

void fragment() {
	vec2 uv = UV;
	uv.x += texture_shift;
	
    //vec2 centerDistVec = vec2(0.5) - uv;
    vec2 centerDistVec = vec2(0.5) -uv.x;
    
	float distToCircleEdge = length(centerDistVec) * radius;
	float distToSquareEdge = 0.5*(0.5 - min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
	float distToEdge = mix(distToCircleEdge,distToSquareEdge,shape);

    float gradient = smoothstep(0.5, 0.5 - radius, distToEdge);

    vec2 direction = s_direction * burnSpeed;
    float noiseValue = texture(textureNoise, uv + direction * TIME).r;

    float opacity = step(radius, mix(gradient, noiseValue, effectControl) - distToEdge);

    COLOR = texture(TEXTURE, uv) * vec4(1.0, 1.0, 1.0, opacity);
}
