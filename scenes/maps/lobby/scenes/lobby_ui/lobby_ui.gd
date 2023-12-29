extends CanvasLayer

@onready var current_players_counter = $CurrentPlayersCounter
@onready var start_game_button = $StartGameButton

@onready var lobby_settings_button = $GridContainer/LobbySettingsButton

@onready var interact_button = $InteractButton

@onready var pause_button = $GridContainer/PauseButton
@onready var chat_button = $GridContainer/ChatButton

var is_chat_open = false

func _ready():
	if !multiplayer.is_server():
		lobby_settings_button.hide()
		start_game_button.hide()

	_update_current_players_counter()

	GameManager.player_registered.connect(_update_current_players_counter)
	GameManager.player_deregistered.connect(_update_current_players_counter)
	GameManager.server_settings_changed.connect(_update_current_players_counter)
	
	toggle_interact_button_active(false)


func _exit_tree():
	GameManager.player_registered.disconnect(_update_current_players_counter)
	GameManager.player_deregistered.disconnect(_update_current_players_counter)
	GameManager.server_settings_changed.disconnect(_update_current_players_counter)


func _update_current_players_counter(_id: int = 0, _player: Dictionary = {}):
	current_players_counter.text = str(GameManager.get_registered_players().size()) + "/" + str(GameManager.get_server_settings().max_players)


func _on_lobby_settings_button_button_down():
	get_parent().get_node("LobbySettings").show()


func _on_start_game_button_button_down():
	GameManager.start_game()


func _on_interact_button_button_down():
	pass # Replace with function body.


func _on_chat_button_button_down():
	if is_chat_open:
		execute_action("pause_menu")
		is_chat_open = false
	else:
		execute_action("chat_open")
		is_chat_open = true


func _on_pause_button_button_down():
	execute_action("pause_menu")


# Wykonuje podaną akcję
func execute_action(action_name:String):
	var event = InputEventAction.new()
	event.action = action_name
	event.pressed = true
	Input.parse_input_event(event)


# Aktywuje i deaktywuje przycisk interakcji
func toggle_interact_button_active(is_active:bool):
	interact_button.disabled = !is_active
	toggle_button_visual(interact_button, is_active)


# Zmienia wygląd przycisku
func toggle_button_visual(button:TextureButton, is_on:bool):
	if is_on:
		button.modulate = Color8(255, 255, 255, 255)
	else:
		button.modulate = Color8(130, 130, 130, 100)
