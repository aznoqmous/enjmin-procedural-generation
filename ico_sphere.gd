@tool
extends Node3D
@export var water_mesh_instance_3d: MeshInstance3D
@export var cloud_mesh_instance_3d: MeshInstance3D
@export var ground_mesh_instance_3d: MeshInstance3D
@export var multimesh_instance_3d: MultiMeshInstance3D

@export var water_level := 1.0:
	set(value):
		water_level = value
		if not ground_mesh_instance_3d: return;
		ground_mesh_instance_3d.material_override.set("shader_parameter/min_height", value - 0.02)
		water_mesh_instance_3d.material_override.set("shader_parameter/water_level", value)
		ground_mesh_instance_3d.material_override.set("shader_parameter/water_level", value)

@export var radius := 1.0:
	set(value):
		radius = value
		build()
		
@export var subdivisions := 2:
	set(value):
		subdivisions = value
		build()
		
@export var amplitude := 4.0 :
	set(value):
		amplitude = value
		build()

@export var amplitude_pow := 1.4:
	set(value):
		amplitude_pow = clamp(value, 0.01, 100.0)
		build()

@export var noise : FastNoiseLite

@export var house_min_elevation = 0.0
@export var house_max_elevation = 1.0

func _ready():
	build()
	
func _process(delta):
	#rotate_y(delta / 50.0)
	pass

func get_mesh_arrays(surface: int = 0):
	if ground_mesh_instance_3d.mesh == null:
		return null
	if surface >= ground_mesh_instance_3d.mesh.get_surface_count():
		return null
	return ground_mesh_instance_3d.mesh.surface_get_arrays(surface)
	
func build():
	if not multimesh_instance_3d: return;
	current_house_index = 0
	multimesh_instance_3d.multimesh.instance_count = 0
	multimesh_instance_3d.multimesh.instance_count = 900

	ground_mesh_instance_3d.mesh = generate_icosphere_mesh(radius, subdivisions)
	var mesh_arrays : Array = get_mesh_arrays()
	var vert_array : PackedVector3Array = mesh_arrays[Mesh.ARRAY_VERTEX]
	
	for vidx in range( vert_array.size() ) :
		#var point = sphere_point_to_uv(vert_array[vidx], mesh_instance_3d.global_position, radius)
		#vert_array[vidx] *= noise.get_noise_2d(point.x, point.y)
		var value = 1.5 + pow(amplitude_pow, abs(noise.get_noise_3d(vert_array[vidx].x, vert_array[vidx].y, vert_array[vidx].z))) * amplitude
		vert_array[vidx] *= value
		if value > house_min_elevation and value < house_max_elevation:
			create_house(vert_array[vidx])

	#mesh_arrays[Mesh.ARRAY_TANGENT].clear()
	#mesh_arrays[Mesh.ARRAY_NORMAL].clear()
	
	var arr_mesh: = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	arr_mesh.regen_normal_maps()
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(arr_mesh, 0)
	surface_tool.generate_normals()
	arr_mesh = surface_tool.commit()
	
	ground_mesh_instance_3d.mesh = arr_mesh
	water_mesh_instance_3d.mesh = arr_mesh
	cloud_mesh_instance_3d.mesh = arr_mesh
	
func create_icosphere(radius: float = 1.0, subdivisions: int = 2, position: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = generate_icosphere_mesh(radius, subdivisions)
	mesh_instance.transform.origin = position
	add_child(mesh_instance)
	return mesh_instance

var middle_point_cache := {}
var vertices : Array[Vector3]
func get_middle_point(i1: int, i2: int) -> int:
	var key = str(min(i1,i2)) + "_" + str(max(i1,i2))
	if middle_point_cache.has(key):
		return middle_point_cache[key]
	
	var midpoint = (vertices[i1] + vertices[i2]) * 0.5
	vertices.append(midpoint.normalized())
	var index = vertices.size() - 1
	middle_point_cache[key] = index
	return index
	
func generate_icosphere_mesh(radius: float, subdivisions: int, flip_faces: bool = true) -> ArrayMesh:
	var t := (1.0 + sqrt(5.0)) / 2.0
	
	# Initial icosahedron vertices
	vertices = [
		Vector3(-1,  t,  0), Vector3( 1,  t,  0),
		Vector3(-1, -t,  0), Vector3( 1, -t,  0),
		Vector3( 0, -1,  t), Vector3( 0,  1,  t),
		Vector3( 0, -1, -t), Vector3( 0,  1, -t),
		Vector3( t,  0, -1), Vector3( t,  0,  1),
		Vector3(-t,  0, -1), Vector3(-t,  0,  1),
	]
	
	# Normalize initial vertices
	for i in vertices.size():
		vertices[i] = vertices[i].normalized()
	
	var faces: Array = [
		[0,11,5],[0,5,1],[0,1,7],[0,7,10],[0,10,11],
		[1,5,9],[5,11,4],[11,10,2],[10,7,6],[7,1,8],
		[3,9,4],[3,4,2],[3,2,6],[3,6,8],[3,8,9],
		[4,9,5],[2,4,11],[6,2,10],[8,6,7],[9,8,1]
	]
	
	middle_point_cache = {}
	
	# Subdivide
	for _i in subdivisions:
		var new_faces = []
		for face in faces:
			var a = get_middle_point(face[0], face[1])
			var b = get_middle_point(face[1], face[2])
			var c = get_middle_point(face[2], face[0])
			
			new_faces.append([face[0], a, c])
			new_faces.append([face[1], b, a])
			new_faces.append([face[2], c, b])
			new_faces.append([a, b, c])
		faces = new_faces
	
	# Scale to radius
	for i in vertices.size():
		vertices[i] = vertices[i] * radius
	
	# Build arrays
	var final_vertices: PackedVector3Array = PackedVector3Array()
	var normals: PackedVector3Array = PackedVector3Array()
	var indices: PackedInt32Array = PackedInt32Array()
	
	for v in vertices:
		final_vertices.append(v)
		normals.append(v.normalized())
	
	for face in faces:
		if flip_faces:
			indices.append(face[0])
			indices.append(face[2])
			indices.append(face[1])
		else:
			indices.append(face[0])
			indices.append(face[1])
			indices.append(face[2])
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = final_vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	return mesh

var current_house_index = 0
func create_house(pos: Vector3):
	if current_house_index >= multimesh_instance_3d.multimesh.instance_count: return
	
	var transform = Transform3D()
	transform.origin = pos
	transform = transform.looking_at(Vector3.ZERO, Vector3.UP)
	transform.basis = transform.basis * Basis().scaled(Vector3(
		randf_range(0.1, 0.5),
		randf_range(0.1, 0.5),
		randf_range(0.1, 1.0),
	))

	multimesh_instance_3d.multimesh.set_instance_transform(current_house_index, transform)
	current_house_index += 1
