extends TextureButton

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")

func show_and_ready():
	self.visible = true

func hide_and_not_ready():
	self.visible = false

