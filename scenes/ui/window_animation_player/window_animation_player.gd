extends AnimationPlayer

## Okno do animacji
var window : Node

func _ready():
	window = get_parent()
	window.visibility_changed.connect(_on_visibility_changed)
	

func _on_visibility_changed():
	if window.visible==true:
		play("window_animation")
