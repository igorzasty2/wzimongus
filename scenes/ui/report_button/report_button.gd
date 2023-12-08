extends Button

var voting_screen = preload("res://scenes/ui/voting_screen/voting_screen.tscn")


func _on_pressed():
	_open_voting_screen.rpc()


@rpc("call_local", "any_peer")
func _open_voting_screen():
	var voting_screen_instance = voting_screen.instantiate()
	self.get_parent().add_child(voting_screen_instance)
	GameManager.set_input_status(false)
	GameManager.set_pause_status(true)
	self.hide()
