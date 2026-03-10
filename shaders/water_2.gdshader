shader_type spatial;
render_mode cull_disabled ;

uniform float water_level;
uniform sampler3D noise;
uniform vec4 water_color: source_color;

varying float elevation;
varying float diff;
varying vec3 vVertex;

void vertex() {
	
	// Called for every vertex the material is visible on.
	elevation = length(VERTEX);
	float wlevel = water_level - 0.1 + abs(texture(noise, VERTEX / 100.0 + vec3(sin(TIME) / 100.0)).r / 10.0);
	diff = elevation - wlevel;
	VERTEX = normalize(VERTEX) * wlevel;
	
	NORMAL = VERTEX;
	vVertex = VERTEX;
}

vec3 lerp(vec3 a, vec3 b, float t){ 
	t = clamp(t, 0, 1);
	return a * (1.0 - t) + b *t;
}

void fragment() {
	// Called for every pixel the material is visible on.
	float waves = texture(noise, vVertex / 3.0 + vec3(TIME / 500.0, 0.0, 0.0)).x;
	float water_streams = texture(noise, vVertex / 10.0 + vec3(TIME / 500.0, 0.0, TIME / 500.0)).x;
	float water_streams_d = texture(noise, vVertex / 10.0 + vec3(TIME / 500.0, TIME / 500.0, 0.0)).x;
	
	float levels = clamp(
		1.0 
		- step(0.6 + waves / 10.0, abs(diff))/20.0
		- step(0.5 + waves / 10.0, abs(diff))/20.0
		- step(0.4 + waves / 10.0, abs(diff))/20.0
		- step(0.3 + waves / 10.0, abs(diff))/20.0
		- step(0.2 + waves / 10.0, abs(diff))/10.0
		- step(0.1 + waves / 10.0, abs(diff))/5.0 
		- step(0.001 + waves / 10.0, abs(diff))/2.0
		, 
		0, 1
	);
	float water_noise = (step(0.45, water_streams) - step(0.5, water_streams)) / 20.0;
	water_noise -= (step(0.45, water_streams_d) - step(0.5, water_streams_d)) / 20.0;
	//water_noise = 0.0;
	
	ALBEDO = vec3(pow(levels, 1) + water_noise);
	ALBEDO *= water_color.xyz;
	float variance = texture(noise, vVertex / 2.0 + vec3(TIME / 50.0, TIME / 50.0, 0.0)).x;
	ALBEDO = lerp(vec3(1.0), ALBEDO, step(variance / 50.0, abs(diff)));
	//ALPHA = 0.9;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
