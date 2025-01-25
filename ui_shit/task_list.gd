extends Control

@export var list_node: Control
@export var list_text: RichTextLabel

@export var pop_up_node: Control
@export var pop_up_text: RichTextLabel

@export var pop_up_time: float = 5

var achievments: Array = [
	{
		'is_done': false,
		'code': 'crows',
		'list_text': 'pop on bowl of Šaltibarščiai',
		'list_done': '“Shall I burst here?'
	},
	{
		'is_done': false,
		'code': 'sandwich',
		'list_text': 'land on sandwich ruining it',
		'list_done': '“You weren\'t going to eat that, were you?'
	},
	{
		'is_done': false,
		'code': 'soda',
		'list_text': 'knock empty soda can into recycles bin',
		'list_done': '“I want my deposit back!'
	},
	{
		'is_done': false,
		'code': 'children',
		'list_text': 'avoid being popped by children',
		'list_done': 'cute little monsters'
	},
	{
		'is_done': false,
		'code': 'flock',
		'list_text': 'traverse course through bird flock',
		'list_done': 'Get the flock out of my way'
	},
	{
		'is_done': false,
		'code': 'news_paper',
		'list_text': 'hit old mans news paper',
		'list_done': 'No news is good news'
	},
	{
		'is_done': false,
		'code': 'fountain',
		'list_text': 'land peacefully in water fountain',
		'list_done': 'time for a soak'
	},
	{
		'is_done': false,
		'code': 'boat',
		'list_text': 'pop and push paper boat',
		'list_done': 'Whatever blows your boat'
	},
	{
		'is_done': false,
		'code': 'up',
		'list_text': 'float all the way up out of frame',
		'list_done': 'I’m way to high, maaaaan'
	},
	{
		'is_done': false,
		'code': 'crows',
		'list_text': 'pop around crows',
		'list_done': 'I could just murder a crow'
	},
	{
		'is_done': false,
		'code': 'paint',
		'list_text': 'splatter on painters canvas',
		'list_done': 'We cant all be Picasso'
	},
	{
		'is_done': false,
		'code': 'chair',
		'list_text': 'stick to chair',
		'list_done': 'Have a seat!'
	},
	{
		'is_done': false,
		'code': 'flower',
		'list_text': 'pop on a flower',
		'list_done': 'A rose by any other name…'
	},
	{
		'is_done': false,
		'code': 'tree',
		'list_text': 'pop on a tree',
		'list_done': 'Its about time you branched out'
	},
	{
		'is_done': false,
		'code': 'crows',
		'list_text': 'ayo',
		'done_text': 'gg my man'
	}
]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_list_text()
	pop_up_node.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_pressed("ui_accept"):
		complete('sandwich')
	
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
	pop_up_text.text = achievment['list_done']
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
		return '☑    [s]' + achievment['list_text'] + '[/s]'
	else:
		return '☐    ' + achievment['list_text']
