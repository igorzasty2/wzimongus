## Przycisk do ukrywania okna.
class_name BackgroundButton
extends Button

@export var window : Node = null

func _on_button_down():
	window.visible = false
