class_name VentDirectionButton
extends Node2D

signal direction_button_pressed(button_id)

func _ready():
	visible = false

var id

# handles direction button press
func _on_button_button_down():
	emit_signal("direction_button_pressed", id)
