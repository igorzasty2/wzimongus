extends Button

## Obsługa przycisku 'confirm' - powoduje przełączenie do sceny 'minigame_copying_files_loading.tscn'
func _on_confirm_button_down():
	self.disabled = true
	
	## Przełączenie do sceny 'minigame_copying_files_loading.tscn'
	get_tree().change_scene_to_file("res://scenes/minigames/copying-files/minigame_copying_files_loading.tscn")
	


