extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tree_area_body_entered(body: Node3D) -> void:
	print("POP on a tree!")
	if body is Bubble:
		Autobusas.die_signal.emit()
		Autobusas.get_achievement.emit("tree")
