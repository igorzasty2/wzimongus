## Klasa przycisku do zakończenia minigry.
class_name MakeAPhotoToMakeAPhoto
extends Button


func _on_pressed():
	get_parent().minigame_end.emit()


## Pokazuje przycisk.
func show_and_ready():
	self.visible = true


## Chowa przycisk.
func hide_and_not_ready():
	self.visible = false
