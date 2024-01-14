## Klasa okienka z informacją.
class_name PopUpWindow
extends Control

@onready var _label = $Panel/MarginContainer/Label
@onready var _left_button = $Panel/MarginContainer/HBoxContainer/LeftButton
@onready var _right_button =  $Panel/MarginContainer/HBoxContainer/RightButton
@onready var _middle_button = $Panel/MarginContainer/HBoxContainer/MiddleButton

## True - jedne przycisk, False - dwa przyciski.
@export var one_button : bool = false

## Wyświetlana informacja.
@export var information : String = "information"
## Tekst na lewym przycisku.
@export var left_button_text : String = "left"
## Tekst na prawym przycisku.
@export var right_button_text : String = "right"
## Tekst na środkowym przycisku.
@export var middle_button_text : String = "middle"

## Emitowany po naciśnięciu przycisku z lewej strony.
signal left_pressed
## Emitowany po naciśnięciu przycisku z prawej strony.
signal right_pressed
## Emitowany po naciśnięciu przycisku na środku.
signal middle_pressed

func _ready():
	_label.text = information
	if one_button==true:
		_middle_button.text = middle_button_text
		_left_button.queue_free()
		_right_button.queue_free()
	else:
		_left_button.text = left_button_text
		_right_button.text = right_button_text
		_middle_button.queue_free()


## Obsługuje naciśnięcie lewego przycisku.
func _on_left_button_pressed():
	emit_signal("left_pressed")


## Obsługuje naciśnięcie prawegeo przycisku.
func _on_right_button_pressed():
	emit_signal("right_pressed")


## Ustawia wyświetlaną informacje.
func set_information(text: String):
	information = text
	_label.text = text


## Obsługuje naciśnięcie środkowego przycisku.
func _on_middle_button_pressed():
	emit_signal("middle_pressed")
