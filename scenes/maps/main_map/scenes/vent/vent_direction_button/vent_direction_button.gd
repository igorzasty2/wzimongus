class_name VentDirectionButton
extends Node2D

var id

signal direction_button_pressed(button_id)

func _ready():
	visible = false

# Obsługuje naciśnięcie przycisku kierunkowego
func _on_button_button_down():
	emit_signal("direction_button_pressed", id)
