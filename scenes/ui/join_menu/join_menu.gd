extends Control

@onready var username_input = $InputsContainer/UsernameContainer/UsernameInput
@onready var address_input = $InputsContainer/AddressContainer/AddressInput
@onready var port_input = $InputsContainer/PortContainer/PortInput
@onready var server_list = $ServerPanel/Table/ServerListScroll/ServerList

func _on_join_button_pressed():
	GameManager.set_current_player_key("username", username_input.text)

	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

	GameManager.join_lobby.call_deferred(address_input.text, port_input.text.to_int())


func _on_server_listener_new_server(server_info):
	var server_node = preload("res://scenes/ui/join_menu/server_node/server_node.tscn").instantiate()
	server_node.init.call_deferred(server_info)
	server_node.connect("server_selected", _on_server_selected)
	server_list.add_child(server_node)


func _on_server_listener_remove_server(server_ip):
	for server_node in server_list.get_children():
		if server_node.get_server_ip() == server_ip:
			server_node.disconnect("server_selected", _on_server_selected)
			server_list.remove_child(server_node)
			server_node.queue_free()


func _on_server_selected(server_info):
	address_input.text = server_info["ip"]
	port_input.text = str(server_info["port"])


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/play_menu/play_menu.tscn")
