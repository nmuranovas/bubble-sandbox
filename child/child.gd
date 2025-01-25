extends CharacterBody3D

@export var target: Node3D
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var attention_range: float = 10.0
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var jump_when_bubble_above_height: float = 1.5
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var follow_deadzone: float = 0.5

@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var walk_speed = 2.0
@export_custom(PROPERTY_HINT_NONE, "suffix:rad/s") var rotate_speed = 5.0
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var jump_velocity = 3.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var arms: Node3D = $Arms

func _ready() -> void:
	set_physics_process(false)
	call_deferred("actor_setup")

func actor_setup():
	# Wait a for the NavigationServer to sync
	await NavigationServer3D.map_changed
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Reset the horizontal velocity
	velocity.x = 0
	velocity.z = 0
	
	var distance_to_target = Vector2(global_position.x, global_position.z) \
		.distance_to(Vector2(target.global_position.x, target.global_position.z))
	
	if distance_to_target > attention_range:
		move_and_slide()
		arms.rotation.x = turn_towards_angle(arms.rotation.x, -PI / 2.0, 4.0, delta)
		return
	
	var next_position = target.global_position
	if distance_to_target > follow_deadzone:
		navigation_agent.target_position = target.global_position
		next_position = navigation_agent.get_next_path_position()
	
	var direction = (global_position - next_position)
	var angle = atan2(direction.x, direction.z)
	
	rotation.y = turn_towards_angle(rotation.y, angle, rotate_speed, delta)
	
	if distance_to_target > follow_deadzone and angle_difference(rotation.y, angle) < 0.4:
		velocity += Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * walk_speed
	if distance_to_target < follow_deadzone and is_on_floor() and \
		target.global_position.y - global_position.y > jump_when_bubble_above_height:
		# Have the child jump up and down, reaching for the bubble
		velocity.y = jump_velocity
	
	# Do arm movement
	var target_direction = (global_position - target.global_position)
	var horizontal_distance = sqrt(target_direction.x * target_direction.x + target_direction.z * target_direction.z)
	var vertical_angle = atan2(horizontal_distance, target_direction.y)
	
	var angle_arms = atan2(direction.rotated(Vector3.UP, angle).y, direction.rotated(Vector3.UP, angle).z)
	arms.rotation.x = vertical_angle - PI/2.0
	
	move_and_slide()

func turn_towards_angle(current_angle: float, target_angle: float, walk_speed: float, delta: float) -> float:
	# Normalize the angles to ensure correct calculations
	current_angle = wrapf(current_angle, -PI, PI)
	target_angle = wrapf(target_angle, -PI, PI)
	
	var angle_diff = target_angle - current_angle
	angle_diff = wrapf(angle_diff, -PI, PI)
	
	var max_step = walk_speed * delta
	
	var step = clamp(angle_diff, -max_step, max_step)
	
	return current_angle + step
