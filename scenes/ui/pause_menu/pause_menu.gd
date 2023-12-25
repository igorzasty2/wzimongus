extends CanvasLayer

@onready var pop_up_window = $PopUpWindow
@onready var settings_container = $SettingsContainer


func _ready():
	visible = false
	settings_container.visible = false
	pop_up_window.visible = false


func _input(event):
	if event.is_action_pressed("pause_menu"):
		visible = !GameManager.get_current_game_key("is_paused")
		GameManager.set_pause_menu_status(visible)
		settings_container.visible = visible
		pop_up_window.visible = false


func _on_leave_game_button_pressed():
	pop_up_window.visible = true
	settings_container.visible = false


func _on_back_to_game_button_pressed():
	visible = false
	GameManager.set_pause_menu_status(visible)
	settings_container.visible = visible


func _on_pop_up_window_left_pressed():
	visible = false
	GameManager.set_pause_menu_status(visible)
	settings_container.visible = visible
	pop_up_window.visible = false

	GameManager.end_game()


func _on_pop_up_window_right_pressed():
	visible = false
	GameManager.set_pause_menu_status(visible)
	settings_container.visible = visible
	pop_up_window.visible = false


# prevents from closing pause menu when rebinding controls
func _on_settings_button_rebind(is_rebinded):
	set_process_input(!is_rebinded)
