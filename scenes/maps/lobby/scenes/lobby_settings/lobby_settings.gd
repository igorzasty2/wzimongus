extends CanvasLayer

@onready var max_connections = $SettingsContainer/MarginContainer/VBoxContainer/MaxConnectionsContainer/MaxConnectionsInput
@onready var lecturers_amount_alert = $SettingsContainer/MarginContainer/VBoxContainer/LecturersAmountAlert
@onready var max_lecturers = $SettingsContainer/MarginContainer/VBoxContainer/MaxLecturersContainer/MaxLecturersInput
@onready var kill_cooldown = $SettingsContainer/MarginContainer/VBoxContainer/KillCooldownContainer/KillCooldownInput
@onready var sabotage_cooldown = $SettingsContainer/MarginContainer/VBoxContainer/SabotageCooldownContainer/SabotageCooldownInput
@onready var kill_radius = $SettingsContainer/MarginContainer/VBoxContainer/KillRadiusContainer/KillRadiusInput
@onready var task_amount = $SettingsContainer/MarginContainer/VBoxContainer/TaskAmountContainer/TaskAmountInput
@onready var emergency_cooldown = $SettingsContainer/MarginContainer/VBoxContainer/EmergencyCooldownContainer/EmergencyCooldownInput
@onready var student_light_radius = $SettingsContainer/MarginContainer/VBoxContainer/StudentLightRadiusContainer/StudentLightRadiusInput
@onready var lecturer_light_radius = $SettingsContainer/MarginContainer/VBoxContainer/LecturerLightRadiusContainer/LecturerLightRadiusInput

func _ready():
	# Ustawia aktualizacje ilości maksymalnych połączeń
	if multiplayer.is_server():
		_update_max_connections()
		GameManager.player_registered.connect(_update_max_connections)
		GameManager.player_deregistered.connect(_update_max_connections)


func _input(event):
	if event.is_action_pressed("pause_menu") && visible:
		hide()
		get_viewport().set_input_as_handled()


func _on_save_button_pressed():	
	GameManager.change_server_settings(max_connections.text.to_int(), max_lecturers.text.to_int(), kill_cooldown.get_selected_id(), sabotage_cooldown.get_selected_id(), kill_radius.get_selected_id(), task_amount.get_selected_id(), emergency_cooldown.get_selected_id(), student_light_radius.get_selected_id(), lecturer_light_radius.get_selected_id())
	hide()


func _on_visibility_changed():
	$SettingsContainer.visible = visible
	var settings = GameManager.get_server_settings()
	if settings["max_players"]:
		max_connections.selected = max_connections.get_item_index(settings["max_players"])
		max_lecturers.selected = max_lecturers.get_item_index(settings["max_lecturers"])
		kill_cooldown.selected = kill_cooldown.get_item_index(settings["kill_cooldown"])
		sabotage_cooldown.selected = sabotage_cooldown.get_item_index(settings["sabotage_cooldown"])
		kill_radius.selected = kill_radius.get_item_index(settings["kill_radius"])
		task_amount.selected = task_amount.get_item_index(settings["task_amount"])
		emergency_cooldown.selected = emergency_cooldown.get_item_index(settings["emergency_cooldown"])
		student_light_radius.selected = student_light_radius.get_item_index(settings["student_light_radius"])
		lecturer_light_radius.selected = lecturer_light_radius.get_item_index(settings["lecturer_light_radius"])
		_on_connections_lecturers_item_selected(max_connections.selected)


func _on_connections_lecturers_item_selected(_index: int):
	# Ustawia widoczność alertu o zbyt dużej ilości wykładowców
	lecturers_amount_alert.visible = true if ceil(max_connections.text.to_int() / 4.0) < max_lecturers.text.to_int() else false


## Aktualizuje selekcje ilości maksymalnej ilości połączeń
func _update_max_connections(_id: int = 0, _player: Dictionary = {}):
	max_connections.clear()

	# Dodaje opcje do wyboru
	var idx = 0
	for i in range(max(3, GameManager.get_registered_players().size()), 11):
		max_connections.add_item(str(i),i)

		# Ustawia aktualną ilość połączeń jako zaznaczoną
		if i == GameManager.get_server_settings().max_players:
			max_connections.select(idx)

		idx += 1
