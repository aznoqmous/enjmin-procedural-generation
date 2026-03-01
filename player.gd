@tool
extends RigidBody3D
@export var gravity = 9.8

func _physics_process(delta: float) -> void:

	move_and_collide(-position.normalized() * delta * gravity)
	#rotation = Vector3.RIGHT.rotated(position.normalized(), Vector3.FORWARD)
	look_at(position + position.normalized())
