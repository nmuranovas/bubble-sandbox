extends Node3D

@export var speed: float = 0.3
@export var path_follow: PathFollow3D

var died = false

const target_angle = deg_to_rad(-90)
const target_position = -0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not died:
		path_follow.progress += speed * delta
		return
	
	if rotation.z > target_angle:
		rotation.z -= 1.0 * delta
	
	if position.y > target_position:
		position.y -= 0.2 * delta
	


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Bubble:
		died = true
		Autobusas.get_achievement.emit("boat")
		
