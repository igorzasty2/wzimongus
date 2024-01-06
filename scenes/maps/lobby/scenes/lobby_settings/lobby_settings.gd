extends CanvasLayer

@onready var max_connections = $SettingsContainer/MarginContainer/VBoxContainer/MaxConnectionsContainer/MaxConnectionsInput
@onready var lecturers_amount_alert = $SettingsContainer/MarginContainer/VBoxContainer/LecturersAmountAlert
@onready var max_lecturers = $SettingsContainer/MarginContainer/VBoxContainer/MaxLecturersContainer/MaxLecturersInput
@onready var kill_cooldown = $SettingsContainer/MarginContainer/VBoxContainer/KillCooldownContainer/KillCooldownInput
@onready var kill_radius = $SettingsContainer/MarginContainer/VBoxContainer/KillRadiusContainer/KillRadiusInput

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
	GameManager.change_server_settings(max_connections.text.to_int(), max_lecturers.text.to_int(), kill_cooldown.get_selected_id(), kill_radius.get_selected_id())
	hide()


func _on_visibility_changed():
	$SettingsContainer.visible = visible


func _on_connections_lecturers_item_selected(_index: int):
	# Ustawia widoczność alertu o zbyt dużej ilości wykładowców
	lecturers_amount_alert.visible = true if ceil(max_connections.text.to_int() / 4.0) < max_lecturers.text.to_int() else false


## Aktualizuje selekcje ilości maksymalnej ilości połączeń
func _update_max_connections(_id: int = 0, _player: Dictionary = {}):
	max_connections.clear()

	# Dodaje opcje do wyboru
	var idx = 0
	for i in range(max(3, GameManager.get_registered_players().size()), 11):
		max_connections.add_item(str(i))

		# Ustawia aktualną ilość połączeń jako zaznaczoną
		if i == GameManager.get_server_settings().max_players:
			max_connections.select(idx)

		idx += 1
