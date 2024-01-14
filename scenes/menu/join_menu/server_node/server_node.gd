## Klasa reprezentująca pojedynczy serwer w liście serwerów.
class_name JointMenuServerNode
extends MarginContainer

## Emitowany, gdy gracz wybierze serwer.
signal server_selected(server_info)

var _server_info

@onready var _lobby_name = $EntryContainer/InfoContainer/LobbyName
@onready var _server_address = $EntryContainer/InfoContainer/ServerAddress
@onready var _player_count = $EntryContainer/InfoContainer/PlayerCount

## Inicjalzuje.
func init(server_info):
	_server_info = server_info
	_lobby_name.text = server_info["lobby_name"]
	_server_address.text = server_info["ip"] + ":" + str(server_info["port"])
	_player_count.text = str(server_info["player_count"]) + "/" + str(server_info["max_players"])


func get_server_ip():
	return _server_info["ip"]


func _on_button_pressed():
	server_selected.emit(_server_info)
