extends Control

@onready var username_input = $InputsContainer/UsernameContainer/UsernameInput
@onready var address_input = $InputsContainer/AddressContainer/AddressInput
@onready var port_input = $InputsContainer/PortContainer/PortInput
@onready var server_list = $ServerList

func _on_join_button_button_down():
	GameManager.set_player_key("username", username_input.text)

	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

	GameManager.join_game.call_deferred(address_input.text, port_input.text.to_int())


func _on_server_listener_new_server(server_info):
	print(server_info)
	var server_node = Label.new()
	server_node.text = "%s:%s - %s" % [server_info.ip, server_info.port, server_info.name]
	server_list.add_child(server_node)


func _on_server_listener_remove_server(server_ip):
	print(server_ip)
	for server_node in server_list.get_children():
		if server_node.text.find(server_ip) != -1:
			server_list.remove_child(server_node)
			server_node.queue_free()
			break
