extends AnimationPlayer

var window : Node

func _ready():
	window = get_parent()
	window.visibility_changed.connect(on_visibility_changed)
	

func on_visibility_changed():
	if window.visible==true:
		play("window_animation")
