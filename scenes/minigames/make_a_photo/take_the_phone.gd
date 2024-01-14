extends Button

var _characterBody2D: CharacterBody2D

func _on_pressed():
	self.visible = false
	
	_characterBody2D = get_tree().get_first_node_in_group("phone")
	_characterBody2D.show_the_phone_and_start()
