extends CanvasLayer

signal leave_game

@onready var pop_up_window = $PopUpWindow
@onready var settings_container = $SettingsContainer

func _ready():
	settings_container.visible = true
	visible = false
	pop_up_window.visible = false

func _input(event):
	if event.is_action_pressed("pause_menu"):
		visible = !visible
		settings_container.visible = visible
		pop_up_window.visible = false

func _on_leave_game_button_pressed():
	pop_up_window.visible = true
	settings_container.visible = false

func _on_back_to_game_button_pressed():
	visible = false

func _on_pop_up_window_left_pressed():
	emit_signal("leave_game")
	get_tree().change_scene_to_file("res://scenes/ui/start_menu/start_menu.tscn")	

func _on_pop_up_window_right_pressed():
	pop_up_window.visible = false
	visible = false
	settings_container.visible = true
