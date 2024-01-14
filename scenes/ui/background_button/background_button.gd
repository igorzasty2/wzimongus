extends Button

@export var window : Node = null

func _on_button_down():
	$WindowCloseSound.play()
	window.visible = false
