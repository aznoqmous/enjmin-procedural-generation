shader_type spatial;

uniform float water_level;
uniform sampler3D noise;

varying float elevation;
varying float diff;
varying vec3 vVertex;

void vertex() {
	// Called for every vertex the material is visible on.
	elevation = length(VERTEX);
	diff = elevation - water_level;
	VERTEX = normalize(VERTEX) * water_level;
	
	NORMAL = VERTEX;
	vVertex = VERTEX;
}

void fragment() {
	// Called for every pixel the material is visible on.
	float waves = texture(noise, vVertex / 10.0 + vec3(TIME / 1000.0, 0.0, 0.0)).y;
	float water_streams = texture(noise, vVertex / 10.0 + vec3(TIME / 1000.0, 0.0, 0.0)).x;
	ALBEDO = vec3(clamp(1.0 - step(0.1 + waves / 10.0, abs(diff))/5.0 - step(0.02 + waves / 10.0, abs(diff))/2.0, 0, 1));
	ALBEDO += vec3(step(0.45, water_streams) - step(0.5, water_streams)) / 10.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
