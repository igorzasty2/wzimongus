extends TextureButton

var characterBody2D: CharacterBody2D

func _on_pressed():
	self.visible = false
	
	characterBody2D = get_tree().get_first_node_in_group("phone")
	characterBody2D.show_the_phone_and_start()


func _on_makeaphoto_pressed():
	pass # Replace with function body.
