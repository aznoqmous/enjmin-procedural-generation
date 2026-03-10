@tool
extends Node3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var water_mesh_instance_3d: MeshInstance3D = $WaterMeshInstance3D

@export var radius := 1.0:
	set(value):
		radius = value
		build()

@export var frequency := 1.0 :
	set(value):
		frequency = value
		noise.frequency = value
		build()

@export var seed := 0 :
	set(value):
		seed = value
		noise.seed = value
		build()

@export var radial_segments := 64 :
	set(value):
		radial_segments = value
		build()
		
@export var rings := 32 :
	set(value):
		rings = value
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


func _ready():
	# build()
	pass

var building := false

func build():
	building = true
	var o_groundMesh := SphereMesh.new()
	o_groundMesh.radial_segments = radial_segments
	o_groundMesh.rings = rings
	o_groundMesh.radius = radius
	
	var mesh_arrays : Array = o_groundMesh.get_mesh_arrays()
	var vert_array : PackedVector3Array = mesh_arrays[Mesh.ARRAY_VERTEX]
	
	for vidx in range( vert_array.size() ) :
		#var point = sphere_point_to_uv(vert_array[vidx], mesh_instance_3d.global_position, radius)
		#vert_array[vidx] *= noise.get_noise_2d(point.x, point.y)
		
		vert_array[vidx] *= 1.5 + pow(amplitude_pow, abs(noise.get_noise_3d(vert_array[vidx].x, vert_array[vidx].y, vert_array[vidx].z))) * amplitude
		
	#mesh_arrays[Mesh.ARRAY_TANGENT].clear()
	#mesh_arrays[Mesh.ARRAY_NORMAL].clear()
	
	var arr_mesh: = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	arr_mesh.regen_normal_maps()
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(arr_mesh, 0)
	surface_tool.generate_normals()
	arr_mesh = surface_tool.commit()
	
	mesh_instance_3d.mesh = arr_mesh
	water_mesh_instance_3d.mesh = arr_mesh
	building = false
	
	mesh_instance_3d.material_override.set("shader_parameter/amplitude", amplitude)
	mesh_instance_3d.material_override.set("shader_parameter/amplitude_pow", amplitude_pow)
	
func sphere_point_to_uv(point: Vector3, sphere_center: Vector3, radius: float) -> Vector2:
	var dir: Vector3 = (point - sphere_center).normalized()
	var u: float = 0.5 + atan2(dir.z, dir.x) / (TAU)
	var v: float = 0.5 - asin(dir.y) / PI
	return Vector2(u, v)
