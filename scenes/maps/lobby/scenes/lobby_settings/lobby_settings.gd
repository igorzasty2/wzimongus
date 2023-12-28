extends CanvasLayer

@onready var max_connections = $SettingsContainer/MarginContainer/VBoxContainer/MaxConnectionsContainer/MaxConnectionsInput
@onready var lecturers_amount_alert = $SettingsContainer/MarginContainer/VBoxContainer/LecturersAmountAlert
@onready var max_lecturers = $SettingsContainer/MarginContainer/VBoxContainer/MaxLecturersContainer/MaxLecturersInput


func _ready():
	hide()
	lecturers_amount_alert.hide()


func _input(event):
	if event.is_action_pressed("pause_menu") && visible:
		hide()
		get_viewport().set_input_as_handled()


func _on_save_button_pressed():
	GameManager.change_server_settings(max_connections.text.to_int(), max_lecturers.text.to_int())
	hide()


func _on_visibility_changed():
	get_parent().update_input()


func _on_connections_lecturers_item_selected(_index: int):
	# Ustawia widoczność alertu o zbyt dużej ilości wykładowców
	lecturers_amount_alert.visible = true if ceil(max_connections.text.to_int() / 4.0) < max_lecturers.text.to_int() else false
