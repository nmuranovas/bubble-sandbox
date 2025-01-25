extends PathFollow3D

@export var speed = 6;
@export var reparent_node : Node3D;

@onready var previous_position : Vector3 = $Bird.global_position;
@onready var current_position : Vector3 = $Bird.global_position;
@onready var bird: RigidBody3D = $Bird;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += speed * delta
	previous_position = current_position
	current_position = bird.global_position
	
func _on_bird_touched() -> void:
	print("Touched")
	
	var movement_vector = current_position - previous_position
	print(movement_vector)
	
	bird.call_deferred("reparent", reparent_node)

	bird.apply_impulse(movement_vector)
	
