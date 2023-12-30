extends Control

@onready var menu: Control = $Menu
@onready var settings: Control = $Settings
@onready var credits: Control = $Credits

func _ready():
	# Ustawia minimalną wielkość okna na 800x600
	DisplayServer.window_set_min_size(Vector2i(800,600))
	settings.visible = false
	credits.visible = false


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/play_menu/play_menu.tscn")


func _on_settings_button_pressed():
	toggle_visibility(settings)


func _on_exit_button_pressed():
	get_tree().quit()


func _on_settings_exit_settings():
	toggle_visibility(settings)


func _on_settings_back_button_pressed():
	toggle_visibility(settings)


func _on_credits_back_button_pressed():
	toggle_visibility(credits)


func _on_credits_button_pressed():
	toggle_visibility(credits)


## Odpowiada za przełączanie widoczności menu i danego node'a
func toggle_visibility(node: Control):
	node.visible = !node.visible
	menu.visible = !menu.visible
