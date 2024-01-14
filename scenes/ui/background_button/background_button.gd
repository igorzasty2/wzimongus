## Klasa przycisku, który ukrywa okno.
class_name BackgroundButton
extends Button

## Okno, które ma być ukrywane.
@export var window: Node = null


func _on_button_down():
	$WindowCloseSound.play()
	window.visible = false
