shader_type spatial;
uniform sampler3D noise;

uniform float cloud_height = 1.0;
uniform float cloud_min_height = 1.0;
varying float cloud_elevation;
void vertex() {
	float elevation = length(VERTEX);
	cloud_elevation = texture(noise, vec3(
		VERTEX.x / 100.0 - TIME / 200.0, 
		VERTEX.y / 30.0 - TIME / 300.0, 
		VERTEX.z / 200.0 - TIME / 100.0
		)
	).x;
	cloud_elevation = smoothstep(0.1, 0.6, cloud_elevation);
	cloud_elevation *= 1.0 - smoothstep(cloud_min_height, cloud_min_height + 0.1, elevation);
	VERTEX = normalize(VERTEX) * cloud_elevation * cloud_height;
	NORMAL = VERTEX;
}

void fragment() {
	// Called for every pixel the material is visible on.
	//ALPHA = 0.7;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
