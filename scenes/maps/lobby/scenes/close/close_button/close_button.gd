extends TextureButton

@export var window : Node = null

func _on_pressed():
	window.visible = false
