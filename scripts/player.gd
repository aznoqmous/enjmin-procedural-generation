extends CharacterBody3D

@export var gravity_power = 9.8
@export var movement_speed = 3.0
@export var camera_3d: Camera3D
@export var camera_container: Node3D

var gravity : Vector3
var movement : Vector3
var mouse_position : Vector2
var mouse_speed := 0.01

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _physics_process(delta: float) -> void:
	gravity = -position.normalized()
	movement = Vector3.ZERO
	
	if Input.is_action_pressed("MoveForward"): movement += Vector3.FORWARD
	if Input.is_action_pressed("MoveBackward"): movement += Vector3.BACK
	if Input.is_action_pressed("MoveLeft"): movement += Vector3.LEFT
	if Input.is_action_pressed("MoveRight"): movement += Vector3.RIGHT
	
	look_at(position + position.normalized())
	
	movement = transform.basis * camera_container.transform.basis * camera_3d.transform.basis * movement;
	
	if Input.is_action_pressed("Jump"): movement -= gravity * 5.0
	
	if is_on_ceiling() or is_on_floor() or is_on_wall():
		velocity = lerp(velocity, (movement * movement_speed), delta * 10.0)
	else:
		velocity += gravity * gravity_power * delta
	
	move_and_slide()
	
		
	
func _input(event):
	if event is InputEventMouseMotion:
		camera_3d.rotation.y = camera_3d.rotation.y - event.relative.x * mouse_speed
		camera_3d.rotation.x = camera_3d.rotation.x - event.relative.y * mouse_speed
