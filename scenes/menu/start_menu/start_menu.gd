extends Control

@onready var _menu: Control = $Menu
@onready var _settings: Control = $Settings
@onready var _credits: Control = $Credits


func _ready():
	# Ustawia minimalną wielkość okna na 800x600
	DisplayServer.window_set_min_size(Vector2i(800, 600))
	_settings.visible = false
	_credits.visible = false


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/play_menu/play_menu.tscn")


func _on_settings_button_pressed():
	$ButtonPressSound.play()
	_toggle_visibility(_settings)


func _on_exit_button_pressed():
	$ButtonPressSound.play()
	get_tree().quit()


func _on_settings_exit_settings():
	$ButtonPressSound.play()
	_toggle_visibility(_settings)


func _on_settings_back_button_pressed():
	$ButtonPressSound.play()
	_toggle_visibility(_settings)


func _on_credits_back_button_pressed():
	$ButtonPressSound.play()
	_toggle_visibility(_credits)


func _on_credits_button_pressed():
	$ButtonPressSound.play()
	_toggle_visibility(_credits)


## Odpowiada za przełączanie widoczności menu i danego node'a
func _toggle_visibility(node: Control):
	node.visible = !node.visible
	_menu.visible = !_menu.visible
