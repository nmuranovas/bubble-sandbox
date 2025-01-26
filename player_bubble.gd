class_name Bubble
extends RigidBody3D

@export var move_speed : float = 2.5

@export var disable_movement: bool

@export var explosion_particles: PackedScene

@export var spawn: Node3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@export var camera: Camera3D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const BUBBLE_WOBBLE_SFX_1 = preload("res://assets/audio/Bubble_Wobble_Sfx_1.wav")
const BUBBLE_WOBBLE_SFX_2 = preload("res://assets/audio/Bubble_Wobble_Sfx_2.wav")
const BUBBLE_WOBBLE_SFX_3 = preload("res://assets/audio/Bubble_Wobble_Sfx_3.wav")

var bounce_sounds = []

@onready var bubble: MeshInstance3D = $Bubble

var accumulator: Vector3 = Vector3.ZERO

var last_bounce_delta : float = 0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Autobusas.die_signal.connect(die)
	bounce_sounds = [BUBBLE_WOBBLE_SFX_1, BUBBLE_WOBBLE_SFX_2, BUBBLE_WOBBLE_SFX_3]

func die():
	var particles = explosion_particles.instantiate()
	add_child(particles)
	particles.global_position = global_position
	bubble.visible = false
	disable_movement = true
	freeze = true
	
	await get_tree().create_timer(3).timeout
	
	freeze = false
	disable_movement = false
	bubble.visible = true
	global_position = spawn.global_position
	global_rotation = spawn.global_rotation
	

#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#state.transform.basis = state.transform.basis.rotated(Vector3.UP, accumulator.y)
	#state.transform.basis = state.transform.basis.rotated(Vector3.RIGHT.rotated(Vector3.UP, rotation.y+accumulator.y), accumulator.x)
	#accumulator = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if disable_movement: return
	
	var move_dir = Input.get_vector("move_forward", "move_back", "move_left", "move_right")
	if move_dir == Vector2.ZERO and not Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_down"): return

	var forward = camera.global_transform.basis.z
	var left = camera.global_transform.basis.x
	
	var force_dir = Vector3(forward.x, 0, forward.z).normalized()
	var force = move_dir.x * force_dir * move_speed + move_dir.y * left * move_speed
	
	if Input.is_action_pressed("move_up"):
		force += Vector3.UP * move_speed * 1.5
	if Input.is_action_pressed("move_down"):
		force += Vector3.DOWN * move_speed * 1.5
	
	apply_central_force(force)
	last_bounce_delta += delta
	

func _input(event):
	if event is InputEventKey and event.keycode == KEY_TAB:
		Autobusas.die_signal.emit()
	


func _on_body_entered(_body: Node) -> void:
	if last_bounce_delta < 0.20:
		return

	audio_stream_player.stream = bounce_sounds.pick_random()
	audio_stream_player.pitch_scale = randf_range(0.8, 1.2)
	audio_stream_player.play()
	last_bounce_delta = 0
