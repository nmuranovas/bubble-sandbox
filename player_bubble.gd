extends RigidBody3D

@onready var camera: Camera3D = $Camera
@export var move_speed : float = 25.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("move_forward"):
		apply_central_force(-camera.global_transform.basis.z * move_speed )
	if Input.is_action_pressed("move_back"):
		apply_central_force(camera.global_transform.basis.z * move_speed)
	if Input.is_action_pressed("move_left"):
		apply_central_force(-camera.global_transform.basis.x * move_speed)
	if Input.is_action_pressed("move_right"):
		apply_central_force(camera.global_transform.basis.x * move_speed)
	if Input.is_action_pressed("move_up"):
		apply_central_force(camera.global_transform.basis.y * move_speed)
	if Input.is_action_pressed("move_down"):
		apply_central_force(-camera.global_transform.basis.y * move_speed)


func _input(event):
	if event is InputEventMouseMotion:
		rotate(Vector3.UP, -event.relative.x * 0.001)
		rotate_object_local(Vector3.RIGHT, -event.relative.y * 0.001)
		# print(camera.global_transform.basis.z)
