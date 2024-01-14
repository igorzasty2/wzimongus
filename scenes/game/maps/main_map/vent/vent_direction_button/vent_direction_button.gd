## Klasa przycisku kierunkowego venta.
class_name VentDirectionButton
extends Node2D

## Sygnał emitowany po naciśnięciu przycisku kierunkowego.
signal direction_button_pressed(button_id)

## Identyfikator przycisku kierunkowego.
var id: int


func _ready():
	visible = false


func _on_button_button_down():
	emit_signal("direction_button_pressed", id)
