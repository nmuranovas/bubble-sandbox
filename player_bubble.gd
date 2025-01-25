extends RigidBody3D

@onready var camera: Camera3D = $Camera
@export var move_speed : float = 20.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	var move_dir = Input.get_vector("move_forward", "move_back", "move_left", "move_right")

	var forward = camera.global_transform.basis.z
	var left = camera.global_transform.basis.x
	
	var force_dir = Vector3(forward.x, 0, forward.z).normalized()
	var force = move_dir.x * force_dir * move_speed + move_dir.y * left * move_speed
	
	if Input.is_action_pressed("move_up"):
		force += Vector3.UP * move_speed
	if Input.is_action_pressed("move_down"):
		force += Vector3.DOWN * move_speed
	
	apply_central_force(force)


func _input(event):
	if event is InputEventMouseMotion:
		rotate(Vector3.UP, -event.relative.x * 0.001)
		rotate_object_local(Vector3.RIGHT, -event.relative.y * 0.001)
