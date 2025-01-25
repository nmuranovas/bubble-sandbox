extends Control

@export var list_node: Control
@export var list_text: RichTextLabel

@export var pop_up_node: Control
@export var pop_up_text: RichTextLabel

@export var pop_up_time: float = 3

var achievments: Array = [
	{
		'is_done': false,
		'code': 'pop',
		'list_text': 'ayo',
		'done_text': 'gg my man'
	},
	{
		'is_done': true,
		'code': 'boat',
		'list_text': 'ayo',
		'done_text': 'gg my man'
	},
	{
		'is_done': false,
		'code': 'crows',
		'list_text': 'ayo',
		'done_text': 'gg my man'
	},
]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_list_text()
	pop_up_node.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("ui_accept"):
		complete('pop')
	
	if Input.is_action_just_pressed("ui_cancel"):
		list_node.visible = not list_node.visible


func complete(code: String):
	var achievment = find_by_code(code)
	
	if achievment['is_done'] == true:
		return
	
	# list stuff
	achievment['is_done'] = true
	update_list_text()
	
	# pop-up stuff
	pop_up_text.text = achievment['done_text']
	pop_up_node.visible = true
	
	var timer = Timer.new()
	add_child(timer)
	
	timer.wait_time = pop_up_time
	timer.one_shot = true
	timer.timeout.connect(hide_pop_up) 
	
	timer.start()


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
		return '☑  ' + achievment['list_text']
	else:
		return '☐  ' + achievment['list_text']
