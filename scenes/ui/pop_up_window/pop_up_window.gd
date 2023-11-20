extends Control

@onready var label = $Panel/MarginContainer/Label
@onready var left_button = $Panel/MarginContainer/HBoxContainer/LeftButton
@onready var right_button =  $Panel/MarginContainer/HBoxContainer/RightButton

@export var information : String = "information"
@export var left_button_text : String = "left"
@export var right_button_text : String = "right"

signal left_pressed
signal right_pressed

func _ready():
	visible = false
	label.text = information
	left_button.text = left_button_text
	right_button.text = right_button_text

func _on_left_button_pressed():
	emit_signal("left_pressed")

func _on_right_button_pressed():
	emit_signal("right_pressed")
