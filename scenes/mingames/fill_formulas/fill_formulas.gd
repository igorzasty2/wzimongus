extends Node2D

const formulas = {0: "F=m*v", 1: "v=s/t", 2:"a=v/t"}
var innertext:RichTextLabel
var letters = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var r = randi_range(0, formulas.size()-1)
	_generate_letters(formulas[r])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	letters = get_children()
	for i in range(1, 4):
		var l = letters[-i]
		if(l.position.y > 620 || l.position.y < 20 || l.position.x > 900 || l.position.x < 215):
			l.return_to_orig_pos()

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
		letter.id = i
		add_child(letter)
	$Hint.text += formula + "\n"
