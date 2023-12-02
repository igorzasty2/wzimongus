extends CanvasLayer

signal leave_game
signal pause_state_changed(paused:bool)

@onready var pop_up_window = $PopUpWindow
@onready var settings_container = $SettingsContainer


func _ready():
	settings_container.visible = true
	visible = false
	pop_up_window.visible = false


func _input(event):
	if event.is_action_pressed("pause_menu"):
		visible = !visible
		emit_signal("pause_state_changed", visible)
		settings_container.visible = visible
		pop_up_window.visible = false


func _on_leave_game_button_pressed():
	pop_up_window.visible = true
	settings_container.visible = false
	emit_signal("pause_state_changed", visible)


func _on_back_to_game_button_pressed():
	visible = false
	emit_signal("pause_state_changed", visible)


func _on_pop_up_window_left_pressed():
	emit_signal("leave_game")
	emit_signal("pause_state_changed", true)
	get_tree().change_scene_to_file("res://scenes/ui/start_menu/start_menu.tscn")


func _on_pop_up_window_right_pressed():
	emit_signal("pause_state_changed", false)
	pop_up_window.visible = false
	visible = false
	settings_container.visible = true


# prevents from closing pause menu when rebinding controls
func _on_settings_button_rebind(is_rebinded):
	set_process_input(!is_rebinded)
