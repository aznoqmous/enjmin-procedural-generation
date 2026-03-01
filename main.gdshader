shader_type spatial;

uniform sampler2D flow_map;
uniform sampler3D noise;
uniform float amplitude;
uniform float amplitude_pow;
varying vec3 vVertex;
varying vec3 vNormal;

uniform vec4 base_color: source_color;
uniform vec4 height_color: source_color;
uniform float min_height;
uniform float height;

void vertex() {
	// Called for every vertex the material is visible on.
	//VERTEX += texture(flow_map, VERTEX.xz * 0.1 + TIME / 100.0).xyz;
	vVertex = VERTEX;
	vNormal = NORMAL;
}

vec4 lerp(vec4 a, vec4 b, float t){ 
	t = clamp(t, 0, 1);
	return a * (1.0 - t) + b *t;
}
void fragment() {
	// Called for every pixel the material is visible on.
	
	float current_height = length(vVertex) - min_height;
	
	float ddd = clamp(dot(vVertex, vNormal), 0, 1);
	float sstep = smoothstep(min_height, height  + dot(vVertex, vNormal) / 2.0, current_height);
	vec4 color = lerp(base_color, height_color, current_height / height);
	//vec4 color = vec4(1.0);
	//color += step(current_height / height, texture(noise, vVertex + vec3(TIME, TIME / 2.0, TIME / 3.0) / 10.0));
	
	
	ALBEDO = color.xyz;
	//float darkness = current_height;
	//ALBEDO *= pow(darkness, 0.5);
	
	float steps = 20.0;
	ALBEDO = floor(ALBEDO * steps) / steps;
	//ALBEDO = vNormal;
	

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
