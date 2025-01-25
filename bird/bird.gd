extends RigidBody3D

signal bird_touched;

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var main_body_collision: CollisionShape3D = $BirdArea/CollisionShape3D
@onready var right_wing_collision: CollisionShape3D = $RightWingAttach/Area3D/CollisionShape3D
@onready var left_wing_collision: CollisionShape3D = $LeftWingAttach/Area3D/CollisionShape3D
@onready var beak_collision: CollisionShape3D = $BeakArea/CollisionShape3D


func _ready() -> void:
	animation_player.play("BAKED_crowfly_2")

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("POP!")
	# Add method call to death handling here
	
func _on_body_entered(body: Node) -> void:
	print("Bird was touched by: " + body.name)
	
	set_deferred("gravity_scale", 1)
	animation_player.stop(true)
	
	main_body_collision.set_deferred("disabled", true)
	right_wing_collision.set_deferred("disabled", true)
	left_wing_collision.set_deferred("disabled", true)
	beak_collision.set_deferred("disabled", true)
	
	bird_touched.emit()
