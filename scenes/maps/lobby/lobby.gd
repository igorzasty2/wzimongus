extends Control

signal load_finished

@onready var start_game_button = $StartGameButton
@onready var server_advertiser = $ServerAdvertiser

func _ready():
	# Ukrywa przycisk rozpoczęcia gry przed klientami.
	if !multiplayer.is_server():
		start_game_button.hide()

	# Włącza broadcast serwera.
	if multiplayer.is_server():
		_update_broadcast_info()

		GameManager.player_registered.connect(_update_broadcast_info)
		GameManager.player_deregistered.connect(_update_broadcast_info)

	# Aktualizuje listę graczy.
	_update_player_list()

	GameManager.player_registered.connect(_update_player_list)
	GameManager.player_deregistered.connect(_update_player_list)


func _exit_tree():
	if multiplayer.is_server():
		GameManager.player_registered.disconnect(_update_broadcast_info)
		GameManager.player_deregistered.disconnect(_update_broadcast_info)

	GameManager.player_registered.disconnect(_update_player_list)
	GameManager.player_deregistered.disconnect(_update_player_list)


func _update_broadcast_info(_id = null, _player = null):
	server_advertiser.serverInfo = GameManager.get_server_settings()
	server_advertiser.serverInfo["player_count"] = GameManager.get_registered_players().size()


## Aktualizuje listę graczy.
func _update_player_list(_id = null, _player = null):
	var player_list = "Lista graczy:\n"
	var idx = 1

	for i in GameManager.get_registered_players():
		player_list += str(idx) + '. '
		player_list += GameManager.get_registered_player_key(i, "username")
		player_list += "\n"

		idx += 1

	$PlayerList.text = player_list


func _on_start_game_button_button_down():
	GameManager.start_game()
