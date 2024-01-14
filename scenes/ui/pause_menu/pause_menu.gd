extends CanvasLayer

@onready var _pop_up_window = $PopUpWindow
@onready var _settings_container = $SettingsContainer

func _ready():
	visible = false
	_settings_container.visible = false
	_pop_up_window.visible = false


func _input(event):
	if event.is_action_pressed("pause_menu"):
		visible = !GameManagerSingleton.get_current_game_value("is_paused")
		GameManagerSingleton.set_pause_menu_status(visible)
		_settings_container.visible = visible
		_pop_up_window.visible = false


func _on_leave_game_button_pressed():
	_pop_up_window.visible = true
	_settings_container.visible = false


func _on_back_to_game_button_pressed():
	visible = false
	GameManagerSingleton.set_pause_menu_status(visible)
	_settings_container.visible = visible


func _on_pop_up_window_left_pressed():
	visible = false
	GameManagerSingleton.set_pause_menu_status(visible)
	_settings_container.visible = visible
	_pop_up_window.visible = false

	GameManagerSingleton.end_game()


func _on_pop_up_window_right_pressed():
	visible = false
	GameManagerSingleton.set_pause_menu_status(visible)
	_settings_container.visible = visible
	_pop_up_window.visible = false


## Zapobiega zamknięciu menu pauzy podczas zmiany przypisania przycisków
func _on_settings_button_rebind(is_rebinded):
	set_process_input(!is_rebinded)


## Wychodzi z menu pauzy gdy naciśnie się poza oknem
func _on_button_button_down():
	if $SettingsContainer/Settings.can_close==true:
		_on_back_to_game_button_pressed()
