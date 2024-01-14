## Klasa odpowiadająca za interfejs użytkownika w lobby.
class_name LobbyUserInterface
extends CanvasLayer

@onready var _current_players_counter = $CurrentPlayersCounter

@onready var _start_game_alert = $StartGameAlert
@onready var _start_game_button = $StartGameButton

@onready var _lobby_settings_button = $GridContainer2/LobbySettingsButton
@onready var _interact_button = $GridContainer2/InteractButton

@onready var _grid_container = $GridContainer
@onready var _grid_container_2 = $GridContainer2

var _user_sett: UserSettingsManager

var _initial_start_game_button_scale

var _initial_grid_container_scale

var _initial_grid_container_2_scale

var _initial_current_players_counter_scale

func _ready():
	_initial_start_game_button_scale = _start_game_button.scale
	_initial_grid_container_scale = _grid_container.scale
	_initial_grid_container_2_scale = _grid_container_2.scale
	_initial_current_players_counter_scale = _current_players_counter.scale
	
	_user_sett = UserSettingsManager.load_or_create()
	_user_sett.interface_scale_value_changed.connect(_on_interface_scale_changed)
	_on_interface_scale_changed(_user_sett.interface_scale)
	
	if !multiplayer.is_server():
		_lobby_settings_button.texture_normal = null
		_lobby_settings_button.disabled = true

		_start_game_alert.hide()
		_start_game_button.hide()
	
	if multiplayer.is_server():
		_update_start_game_button()

		GameManagerSingleton.player_registered.connect(_update_start_game_button)
		GameManagerSingleton.player_deregistered.connect(_update_start_game_button)

	_update_current_players_counter()

	GameManagerSingleton.player_registered.connect(_update_current_players_counter)
	GameManagerSingleton.player_deregistered.connect(_update_current_players_counter)
	GameManagerSingleton.server_settings_changed.connect(_update_current_players_counter)
	
	toggle_interact_button_active(false)


func _on_interface_scale_changed(value:float):
	_start_game_button.scale = _initial_start_game_button_scale * value
	_grid_container.scale = _initial_grid_container_scale * value
	_grid_container_2.scale = _initial_grid_container_2_scale * value
	_current_players_counter.scale = _initial_current_players_counter_scale * value


func _update_start_game_button(_id: int = 0, _player: Dictionary = {}):
	if GameManagerSingleton.get_registered_players().size() >= 3:
		_start_game_alert.hide()
		_start_game_button.disabled = false
		_toggle_button_visual(_start_game_button, true)
	else:
		_start_game_alert.show()
		_start_game_button.disabled = true
		_toggle_button_visual(_start_game_button, false)


func _update_current_players_counter(_id: int = 0, _player: Dictionary = {}):
	_current_players_counter.text = str(GameManagerSingleton.get_registered_players().size()) + "/" + str(GameManagerSingleton.get_server_settings().max_players)


func _on_lobby_settings_button_button_down():
	get_parent().get_node("LobbySettings").show()


func _on_start_game_button_button_down():
	GameManagerSingleton.start_game()


func _on_interact_button_button_down():
	GameManagerSingleton.execute_action("interact")


func _on_chat_button_button_down():
	if get_parent().get_node("Chat").get_node("%InputText").visible:
		GameManagerSingleton.execute_action("pause_menu")
	else:
		GameManagerSingleton.execute_action("chat_open")


func _on_pause_button_button_down():
	GameManagerSingleton.execute_action("pause_menu")


# Aktywuje i deaktywuje przycisk interakcji
func toggle_interact_button_active(is_active:bool):
	_interact_button.disabled = !is_active
	_toggle_button_visual(_interact_button, is_active)


# Zmienia wygląd przycisku
func _toggle_button_visual(button:TextureButton, is_on:bool):
	if is_on:
		button.modulate = Color8(255, 255, 255, 255)
	else:
		button.modulate = Color8(130, 130, 130, 100)
