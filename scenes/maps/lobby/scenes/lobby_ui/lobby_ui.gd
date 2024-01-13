extends CanvasLayer

@onready var current_players_counter = $CurrentPlayersCounter

@onready var start_game_alert = $StartGameAlert
@onready var start_game_button = $StartGameButton

@onready var lobby_settings_button = $GridContainer2/LobbySettingsButton
@onready var interact_button = $GridContainer2/InteractButton

@onready var pause_button = $GridContainer/PauseButton
@onready var chat_button = $GridContainer/ChatButton

@onready var grid_container = $GridContainer
@onready var grid_container_2 = $GridContainer2

var user_sett: UserSettingsManager

var initial_start_game_button_scale

var initial_grid_container_scale

var initial_grid_container_2_scale

var initial_current_players_counter_scale

func _ready():
	initial_start_game_button_scale = start_game_button.scale
	initial_grid_container_scale = grid_container.scale
	initial_grid_container_2_scale = grid_container_2.scale
	initial_current_players_counter_scale = current_players_counter.scale
	
	user_sett = UserSettingsManager.load_or_create()
	user_sett.interface_scale_value_changed.connect(on_interface_scale_changed)
	on_interface_scale_changed(user_sett.interface_scale)
	
	if !multiplayer.is_server():
		lobby_settings_button.texture_normal = null
		lobby_settings_button.disabled = true

		start_game_alert.hide()
		start_game_button.hide()
	
	if multiplayer.is_server():
		_update_start_game_button()

		GameManager.player_registered.connect(_update_start_game_button)
		GameManager.player_deregistered.connect(_update_start_game_button)

	_update_current_players_counter()

	GameManager.player_registered.connect(_update_current_players_counter)
	GameManager.player_deregistered.connect(_update_current_players_counter)
	GameManager.server_settings_changed.connect(_update_current_players_counter)
	
	toggle_interact_button_active(false)


func on_interface_scale_changed(value:float):
	start_game_button.scale = initial_start_game_button_scale * value
	grid_container.scale = initial_grid_container_scale * value
	grid_container_2.scale = initial_grid_container_2_scale * value
	current_players_counter.scale = initial_current_players_counter_scale * value


func _update_start_game_button(_id: int = 0, _player: Dictionary = {}):
	if GameManager.get_registered_players().size() >= 3:
		start_game_alert.hide()
		start_game_button.disabled = false
		toggle_button_visual(start_game_button, true)
	else:
		start_game_alert.show()
		start_game_button.disabled = true
		toggle_button_visual(start_game_button, false)


func _update_current_players_counter(_id: int = 0, _player: Dictionary = {}):
	current_players_counter.text = str(GameManager.get_registered_players().size()) + "/" + str(GameManager.get_server_settings().max_players)


func _on_lobby_settings_button_button_down():
	get_parent().get_node("LobbySettings").show()


func _on_start_game_button_button_down():
	GameManager.start_game()


func _on_interact_button_button_down():
	GameManager.execute_action("interact")


func _on_chat_button_button_down():
	if get_parent().get_node("Chat").get_node("%InputText").visible:
		GameManager.execute_action("pause_menu")
	else:
		GameManager.execute_action("chat_open")


func _on_pause_button_button_down():
	GameManager.execute_action("pause_menu")


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
