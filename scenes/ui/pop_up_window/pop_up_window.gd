extends Control

@onready var label = $Panel/MarginContainer/Label
@onready var left_button = $Panel/MarginContainer/HBoxContainer/LeftButton
@onready var right_button =  $Panel/MarginContainer/HBoxContainer/RightButton
@onready var middle_button = $Panel/MarginContainer/HBoxContainer/MiddleButton

## True - jedne przycisk, False - dwa przyciski
@export var one_button : bool = false

@export var information : String = "information"
@export var left_button_text : String = "left"
@export var right_button_text : String = "right"
@export var middle_button_text : String = "middle"

signal left_pressed
signal right_pressed
signal middle_pressed

func _ready():
	label.text = information
	if one_button==true:
		middle_button.text = middle_button_text
		left_button.queue_free()
		right_button.queue_free()
	else:
		left_button.text = left_button_text
		right_button.text = right_button_text
		middle_button.queue_free()

## Obsługuje naciśnięcie lewego przycisku
func _on_left_button_pressed():
	emit_signal("left_pressed")

## Obsługuje naciśnięcie prawegeo przycisku
func _on_right_button_pressed():
	emit_signal("right_pressed")

func set_information(text: String):
	information = text
	label.text = text

## Obsługuje naciśnięcie środkowego przycisku
func _on_middle_button_pressed():
	emit_signal("middle_pressed")
