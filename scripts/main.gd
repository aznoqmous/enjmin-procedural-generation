extends Node3D
@onready var directional_light_3d: DirectionalLight3D = $WorldEnvironment/DirectionalLight3D

func _process(delta: float) -> void:
	directional_light_3d.rotate_x(delta * TAU / 30.0)
