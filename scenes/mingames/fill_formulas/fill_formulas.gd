extends Node2D

const FORMULAS = {0: "F=m*v", 1: "v=s/t", 2:"a=v/t", 3:"P=a*a", 4:"P=a*h", 5:"P=2πr", 6:"P=a*h/2"}
@export
var how_many_formulas = 3
@export
var white_gui = false
var is_moving = false
var is_moving_id = 0
var moving
var generated = []
var times_generated = 0
var point = 0
var wanted_points = 0
var finished = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_random_generate()
	if(white_gui):
		$MinigameGui.texture = preload("res://scenes/mingames/fill_formulas/assets/guiElements/minigame_gui2.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var letters = _get_letters()
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
	if(point == wanted_points && times_generated != how_many_formulas):
		wanted_points = 0
		point = 0
		_random_generate()
	if(point == wanted_points && times_generated == how_many_formulas):
		if(finished == false):
			_finish_game()
			finished = true

func _generate_letters(formula:String):
	var r = ceil(formula.length()/2.0)
	var sequence = []
	var inner_text:RichTextLabel
	while sequence.size() < r:
		var rand = randi_range(0, r-1) * 2
		if !sequence.has(rand):
			sequence.append(rand)
	for i in range(sequence.size()):
		var Letter = preload("res://scenes/mingames/fill_formulas/assets/subscenes/letter.tscn").instantiate()
		var shift = Vector2(130, 0)
		Letter.position = $FirstLetter.position + i * shift
		inner_text = Letter.get_node("./LetterInBox")
		inner_text.text = "[center][font_size={55}][color=black]"
		inner_text.text += formula[int(sequence[i])] + "[/color][/font_size][/center]"
		Letter.original_position = Letter.position
		Letter.id = formula[int(sequence[i])]
		add_child(Letter)
	
func _generate_formula(formula:String):
	var x_shift = Vector2(80, 0)
	var y_shift = Vector2(0, 120)
	for i in range(0, formula.length()):
		if(i % 2 == 0):
			var Space = preload("res://scenes/mingames/fill_formulas/assets/subscenes/space.tscn").instantiate()
			Space.position = $StartOfFormula.position + x_shift * i + y_shift * times_generated
			Space.wanted_letter = formula[i]
			add_child(Space)
			Space.set_area()
			wanted_points += 1
		else:
			var text:RichTextLabel = RichTextLabel.new()
			text.position = ($StartOfFormula.position - Vector2(40, 40)) + x_shift * i + y_shift * times_generated
			text.size = Vector2(80, 80)
			text.bbcode_enabled = true
			text.text = "[center][font_size={55}][color=black]" + formula[i] + "[/color][/font_size][/center]"
			add_child(text)
	$Hint.text += "[center][font_size={23}][color=black]" + formula + "[/color][/font_size][/center]\n"
			
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
			
func _random_generate():
	var r = randi_range(0, FORMULAS.size()-1)
	if !generated.has(FORMULAS[r]):
		_generate_formula(FORMULAS[r])
		_generate_letters(FORMULAS[r])
		generated.append(FORMULAS[r])
		times_generated += 1
		
func _finish_game():
	$Hint.text = "[center][font_size={70}][color=green]√[/color][/font_size][/center]"
	$FinishTimer.start()

func _on_finish_timer_timeout():
	$Finish.visible = true
	for l in get_children():
		if(l.name != "Finish"):
			l.queue_free()
