extends CanvasLayer

@onready var current_players_counter = $CurrentPlayersCounter
@onready var lobby_settings_button = $LobbySettingsButton
@onready var start_game_button = $StartGameButton


func _ready():
	if !multiplayer.is_server():
		lobby_settings_button.hide()
		start_game_button.hide()

	_update_current_players_counter()

	GameManager.player_registered.connect(_update_current_players_counter)
	GameManager.player_deregistered.connect(_update_current_players_counter)
	GameManager.server_settings_changed.connect(_update_current_players_counter)


func _exit_tree():
	GameManager.player_registered.disconnect(_update_current_players_counter)
	GameManager.player_deregistered.disconnect(_update_current_players_counter)
	GameManager.server_settings_changed.disconnect(_update_current_players_counter)


func _on_lobby_settings_button_pressed():
	get_parent().get_node("LobbySettings").show()


func _on_start_game_button_pressed():
	GameManager.start_game()


func _update_current_players_counter(_id: int = 0, _player: Dictionary = {}):
	current_players_counter.text = str(GameManager.get_registered_players().size()) + "/" + str(GameManager.get_server_settings().max_players)
