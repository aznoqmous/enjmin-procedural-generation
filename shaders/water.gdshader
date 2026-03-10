shader_type spatial;
uniform vec4 water_color: source_color;
uniform sampler3D noise;
varying vec3 vVertex;

varying float elevation;
varying vec3 offset;

void vertex() {
	offset = vec3(TIME / 2.0, TIME / 3.0, 0.0) / 10.0;
	elevation = texture(noise, VERTEX + offset).x;
	VERTEX += vec3(elevation) / 100.0;
	vVertex = VERTEX;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = water_color.xyz;
	ALBEDO *= elevation + 0.5;
	float steps = 100.0;
	ALBEDO = floor(ALBEDO * steps) / steps;
	ALPHA = pow(elevation, 0.01);
}

//void light() {
	//// Called for every pixel for every light affecting the material.
	//// Uncomment to replace the default light processing function with this one.
	//SPECULAR_LIGHT = vec3(elevation);
//}
