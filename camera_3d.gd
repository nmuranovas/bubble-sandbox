extends Node3D

@export var player: RigidBody3D
@onready var camera_3d: Camera3D = $SpringArm3D/Camera3D
@onready var spring_arm_3d: SpringArm3D = $SpringArm3D

func _ready() -> void:
	spring_arm_3d.add_excluded_object(player.get_rid())

func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(player.global_position, delta * 15)
	

func _input(event):
	if event is InputEventMouseMotion:
		rotate(Vector3.UP, -event.relative.x * 0.001)
		rotate_object_local(Vector3.RIGHT, -event.relative.y * 0.001)
