extends Control

@export var list_node: Control
@export var list_text: RichTextLabel

@export var pop_up_node: Control
@export var pop_up_text: RichTextLabel

@export var pop_up_time: float = 5

@export var menu_open_sound: AudioStreamPlayer
@export var menu_close_sound: AudioStreamPlayer
@export var achievment_pop_sound: AudioStreamPlayer

var achievments: Array = [
	{
		'is_done': false,
		'code': 'child',
		'list_text': 'Get popped by a child',
		'list_done': 'Cute little monsters'
	},
	{
		'is_done': false,
		'code': 'boat',
		'list_text': 'Push paper boat',
		'list_done': 'Whatever blows your boat'
	},
	{
		'is_done': false,
		'code': 'crows',
		'list_text': 'Pop around crows',
		'list_done': 'I could just murder a crow'
	},
	{
		'is_done': false,
		'code': 'kill_crow',
		'list_text': 'Hit a crow',
		'list_done': 'We\'re going down'
	},
	{
		'is_done': false,
		'code': 'tree',
		'list_text': 'Pop on a tree',
		'list_done': 'Its about time you branched out'
	}
]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_list_text()
	pop_up_node.visible = false
	Autobusas.get_achievement.connect(complete)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		list_node.visible = not list_node.visible
		
		if list_node.visible:
			menu_open_sound.play(0)
		else:
			menu_close_sound.play(0)


func complete(code: String):
	var achievment = find_by_code(code)
	
	if achievment['is_done'] == true:
		return
	
	# list stuff
	achievment['is_done'] = true
	update_list_text()
	
	# pop-up stuff
	pop_up_text.text = achievment['list_done']
	pop_up_node.visible = true
	
	var timer = Timer.new()
	add_child(timer)
	
	timer.wait_time = pop_up_time
	timer.one_shot = true
	timer.timeout.connect(hide_pop_up) 
	
	timer.start()
	
	# also sound
	achievment_pop_sound.play(0)


func hide_pop_up():
	pop_up_node.visible = false

 
func find_by_code(code: String) -> Dictionary:
	for achievment in achievments:
		if achievment['code'] == code:
			return achievment
	
	print('No achievment found with code ' + code)
	assert(false)
	return achievments[0]


func update_list_text():
	list_text.text = generate_text()


func generate_text() -> String:
	var all_text: String = ''
	
	for achievment in achievments:
		all_text += with_strikethrough(achievment) + '\n'
	
	return all_text


func with_strikethrough(achievment: Dictionary) -> String:
	
	if achievment['is_done']:
		return '☒    [s]' + achievment['list_text'] + '[/s]'
	else:
		return '☐    ' + achievment['list_text']
