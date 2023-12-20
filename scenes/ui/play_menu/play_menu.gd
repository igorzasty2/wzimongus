extends Control

func _on_host_button_button_down():
	get_tree().change_scene_to_file("res://scenes/ui/host_menu/host_menu.tscn")


func _on_join_button_button_down():
	get_tree().change_scene_to_file("res://scenes/ui/join_menu/join_menu.tscn")
