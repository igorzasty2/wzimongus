extends TextureButton


func _on_button_pressed():
	get_parent().get_parent().player_pressed(self.name)
