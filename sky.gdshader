shader_type sky;
uniform sampler3D noise;

vec4 quat_multiply(vec4 q, vec4 p) {
	float a = q.w, b = q.x, c = q.y, d = q.z;
	float w = p.w, x = p.x, y = p.y, z = p.z;

	return vec4(
		a * x + b * w + c * z - d * y, // i
		a * y - b * z + c * w + d * x, // j
		a * z + b * y - c * x + d * w, // k
	 	a * w - b * x - c * y - d * z // w
	);
}

vec3 rotate(vec3 vert, vec3 axis, float angle) {
	vec4 q;
	
	q.x = axis.x * sin(angle/2.0);
	q.y = axis.y * sin(angle/2.0);
	q.z = axis.z * sin(angle/2.0);
	q.w = cos(angle / 2.0);

	vec4 p = vec4(vert, 0.0);
	
	vec4 q_conj = vec4(-q.xyz, q.w);
	//q /= sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w);
	return quat_multiply(quat_multiply(q, p), q_conj).xyz;
}

void sky() {
	vec3 eye = rotate(EYEDIR, vec3(0.0, 1.0, 0.0), TIME / 100.0);
	COLOR = vec3(step(1.4, length(texture(noise, EYEDIR).rgb)));
	COLOR += vec3(texture(noise, eye / 50.0).r * texture(noise, eye / 10.0).r / 20.0 * (1.0 - abs(EYEDIR.y) * 2.0));
}
