extends Control


func _on_host_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/host_menu/host_menu.tscn")


func _on_join_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/join_menu/join_menu.tscn")


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/start_menu/start_menu.tscn")
