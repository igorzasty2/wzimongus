## Minigra polegająca na ustawieniu wykresu funkcji sin(x) w odpowiednim miejscu.
class_name GraphTheFunctionMinigame
extends Node2D

signal minigame_end

@export var polish_name : String

var _x_func
var _y_func

func _ready():
	var x = randi() % 15 - 7
	var y = randi() % 9 - 4
	while x == 0 && y == 0:
		x = randi() % 15 - 7
		y = randi() % 9 - 4
	_x_func = x
	_y_func = y
	var textToInput = "[center]Skonstruuj wykres sinusa przy użyciu podanego wzoru sin(x"
	if x > 0:
		textToInput += " - "
	else:
		textToInput += " + "
	textToInput += str(abs(x)) + ")"
	if y > 0:
		textToInput += " + "
	else:
		textToInput += " - "
	textToInput += str(abs(y)) + "[/center]"
	$TextEdit.text = textToInput


func _check_if_all_coincidence():
	if $HSlider.value == _x_func and $VSlider.value == _y_func:
		minigame_end.emit()


func _on_v_slider_drag_ended(_value_changed):
	$VText.text = str($VSlider.value)
	var new_position = Vector2(632 + $HSlider.value * 41, 410 - $VSlider.value * 40)
	$Pngegg.position = new_position
	$TextEdit2.text = "[center]f(x) = sin(x"
	if($HSlider.value < 0):
		$TextEdit2.text += " + " + str(abs($HSlider.value))
	else:
		$TextEdit2.text += " - " + str(abs($HSlider.value))
	if($VSlider.value < 0):
		$TextEdit2.text += ") - "+str(abs($VSlider.value))+"[/center]"
	else:
		$TextEdit2.text += ") + " + str(abs($VSlider.value))
		
	_check_if_all_coincidence()


func _on_h_slider_drag_ended(_value_changed):
	$HText.text = str($HSlider.value)
	var new_position = Vector2(632 + $HSlider.value * 41, 410 - $VSlider.value * 40)
	$Pngegg.position = new_position
	$TextEdit2.text = "[center]f(x) = sin(x"
	if($HSlider.value < 0):
		$TextEdit2.text += " + " + str(abs($HSlider.value))
	else:
		$TextEdit2.text += " - " + str(abs($HSlider.value))
	if($VSlider.value < 0):
		$TextEdit2.text += ") - "+str(abs($VSlider.value))+"[/center]"
	else:
		$TextEdit2.text += ") + " + str(abs($VSlider.value))
	_check_if_all_coincidence()
