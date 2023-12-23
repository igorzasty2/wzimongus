extends MarginContainer

signal server_selected(server_info)

var _server_info

@onready var lobby_name = $EntryContainer/InfoContainer/LobbyName
@onready var server_address = $EntryContainer/InfoContainer/ServerAddress

func init(server_info):
	_server_info = server_info
	lobby_name.text = server_info.name
	server_address.text = server_info.ip + ":" + str(server_info.port)


func get_server_ip():
	return _server_info.ip


func _on_button_pressed():
	server_selected.emit(_server_info)
