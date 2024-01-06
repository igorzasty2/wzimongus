extends Node2D

var x_func
var y_func
# Called when the node enters the scene tree for the first time.
func _ready():
	var x = randi() % 15 - 7
	var y = randi() % 9 - 4
	while x == 0 && y == 0:
		x = randi() % 15 - 7
		y = randi() % 9 - 4
	x_func = x
	y_func = y
	var textToInput = "Skonstruuj wykres sinusa przy użyciu podanego wzoru sin(x"
	if x > 0:
		textToInput += " - "
	else:
		textToInput += " + "
	textToInput += str(abs(x)) + ")"
	if y > 0:
		textToInput += " + "
	else:
		textToInput += " - "
	textToInput += str(abs(y))
	$TextEdit.text = textToInput


func check_if_all_coincidence():
	if $HSlider.value == x_func and $VSlider.value == y_func:
		get_tree().quit()


func _on_v_slider_drag_ended(value_changed):
	$VText.text = str($VSlider.value)
	var new_position = Vector2(632 + $HSlider.value * 41, 410 - $VSlider.value * 40)
	$Pngegg.position = new_position
	check_if_all_coincidence()


func _on_h_slider_drag_ended(value_changed):
	$HText.text = str($HSlider.value)
	var new_position = Vector2(632 + $HSlider.value * 41, 410 - $VSlider.value * 40)
	$Pngegg.position = new_position
	check_if_all_coincidence()
