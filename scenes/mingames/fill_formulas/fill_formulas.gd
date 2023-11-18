extends Node2D

const formulas = {0: "F=m*v", 1: "v=s/t", 2:"a=v/t", 3:"P=a*a", 4:"P=a*h", 5:"P=2πr"}
var innertext:RichTextLabel
var letters = []
var isMoving = false
var isMovingId = 0
var moving
var generated = []
var times_generated = 0
var point = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	random_generate()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	letters = _get_letters()
	var spaces = _get_spaces()
	for l in letters:
		if moving != null && moving.placed == false:
			var correct_space = _get_correct_space(moving.id, spaces)
			if(correct_space.correct_area.has_point(moving.position)):
				if(!Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
					moving.position = correct_space.position
					moving.placed = true
					correct_space.queue_free()
					point += 1
			else: if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && l.placed != true:
				l.return_to_orig_pos()
	if((point == 3 || point == 6) && point/3 == times_generated):
		random_generate()
	if(point == 9):
		$finish.visible = true
		for l in get_children():
			if(l.name != "finish"):
				l.queue_free()

func _generate_letters(formula:String):
	var r = ["024", "204", "240", "042", "402", "420"]
	var c = randi_range(0,5)
	c = r[c]
	for i in range(3):
		var letter = preload("res://scenes/mingames/fill_formulas/assets/subscenes/letter.tscn").instantiate()
		var shift = Vector2(130, 0)
		letter.position = $firstLetter.position + i * shift
		innertext = letter.get_node("./LetterInBox")
		innertext.text = "[center][font_size={55}][color=black]"
		innertext.text += formula[int(c[i])] + "[/color][/font_size][/center]"
		letter.original_position = letter.position
		letter.id = formula[int(c[i])]
		add_child(letter)
	$Hint.text += formula + "\n"
	
func _generate_formula(formula:String):
	var x_shift = Vector2(80, 0)
	var y_shift = Vector2(0, 120)
	for i in range(0, formula.length()):
		if(i % 2 == 0):
			var space = preload("res://scenes/mingames/fill_formulas/assets/subscenes/space.tscn").instantiate()
			space.position = $startOfFormula.position + x_shift * i + y_shift * times_generated
			space.wanted_letter = formula[i]
			add_child(space)
			space._set_area()
		else:
			var text:RichTextLabel = RichTextLabel.new()
			text.position = ($startOfFormula.position - Vector2(40, 40)) + x_shift * i + y_shift * times_generated
			text.size = Vector2(80, 80)
			text.bbcode_enabled = true
			text.text = "[center][font_size={55}][color=black]" + formula[i] + "[/color][/font_size][/center]"
			add_child(text)
			
func _get_letters():
	var children = [] 
	for child in get_children():
		if child is StaticBody2D:
			children.append(child)
	return children
func _get_spaces():
	var spaces = []
	for child in get_children():
		if child is Area2D:
			spaces.append(child)
	return spaces
func _get_correct_space(letter, spaces):
	for space in spaces:
		if space.wanted_letter == letter:
			return space
			
func random_generate():
	var r = randi_range(0, formulas.size()-1)
	if !generated.has(formulas[r]):
		_generate_formula(formulas[r])
		_generate_letters(formulas[r])
		generated.append(formulas[r])
		times_generated += 1
