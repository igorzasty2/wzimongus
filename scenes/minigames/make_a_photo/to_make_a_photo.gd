class_name MakeAPhotoToMakeAPhoto
extends Button

func _on_pressed():
	get_parent().minigame_end.emit()

func show_and_ready():
	self.visible = true

func hide_and_not_ready():
	self.visible = false

