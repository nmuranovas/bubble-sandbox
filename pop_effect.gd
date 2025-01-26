extends GPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.play(0)
	emitting = true
	
	await get_tree().create_timer(2).timeout
	
	queue_free()
	
