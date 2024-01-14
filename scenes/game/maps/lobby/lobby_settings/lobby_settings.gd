## Skrypt odpowiadający za obsługę menu ustawień serwera.
extends CanvasLayer


@onready var _settings_container = $SettingsContainer
@onready var _max_players = %MaxPlayersInput
@onready var _lecturers_amount_alert = %LecturersAmountAlert
@onready var _max_lecturers = %MaxLecturersInput
@onready var _kill_cooldown = %KillCooldownInput
@onready var _sabotage_cooldown = %SabotageCooldownInput
@onready var _kill_radius = %KillRadiusInput
@onready var _task_amount = %TaskAmountInput
@onready var _emergency_cooldown = %EmergencyCooldownInput
@onready var _student_light_radius = %StudentLightRadiusInput
@onready var _lecturer_light_radius = %LecturerLightRadiusInput
@onready var _voting_time = %VotingTimeInput
@onready var _discussion_time = %DiscussionTimeInput


func _ready():
	# Ustawia aktualizacje ilości maksymalnych połączeń
	if multiplayer.is_server():
		_update_max_players()
		GameManagerSingleton.player_registered.connect(_update_max_players)
		GameManagerSingleton.player_deregistered.connect(_update_max_players)


func _input(event):
	if event.is_action_pressed("pause_menu"):
		if !visible:
			return

		hide()
		get_viewport().set_input_as_handled()


func _on_save_button_pressed():
	GameManagerSingleton.change_server_settings(_max_players.text.to_int(), _max_lecturers.text.to_int(), _kill_cooldown.get_selected_id(), _sabotage_cooldown.get_selected_id(), _kill_radius.get_selected_id(), _task_amount.get_selected_id(), _emergency_cooldown.get_selected_id(), _student_light_radius.get_selected_id(), _lecturer_light_radius.get_selected_id(), _voting_time.get_selected_id(), _discussion_time.get_selected_id())
	hide()


func _on_visibility_changed():
	_settings_container.visible = visible
	var settings = GameManagerSingleton.get_server_settings()
	if settings["max_players"]:
		_max_players.selected = _max_players.get_item_index(settings["max_players"])
		_max_lecturers.selected = _max_lecturers.get_item_index(settings["max_lecturers"])
		_kill_cooldown.selected = _kill_cooldown.get_item_index(settings["kill_cooldown"])
		_sabotage_cooldown.selected = _sabotage_cooldown.get_item_index(settings["sabotage_cooldown"])
		_kill_radius.selected = _kill_radius.get_item_index(settings["kill_radius"])
		_task_amount.selected = _task_amount.get_item_index(settings["task_amount"])
		_emergency_cooldown.selected = _emergency_cooldown.get_item_index(settings["emergency_cooldown"])
		_student_light_radius.selected = _student_light_radius.get_item_index(settings["student_light_radius"])
		_lecturer_light_radius.selected = _lecturer_light_radius.get_item_index(settings["lecturer_light_radius"])
		_voting_time.selected = _voting_time.get_item_index(settings["voting_time"])
		_discussion_time.selected = _discussion_time.get_item_index(settings["discussion_time"])
		_on_connections_lecturers_item_selected(_max_players.selected)


func _on_connections_lecturers_item_selected(_index: int):
	# Ustawia widoczność alertu o zbyt dużej ilości wykładowców
	_lecturers_amount_alert.visible = true if ceil(_max_players.text.to_int() / 4.0) < _max_lecturers.text.to_int() else false


## Aktualizuje selekcje ilości maksymalnej ilości połączeń
func _update_max_players(_id: int = 0, _player: Dictionary = {}):
	_max_players.clear()

	# Dodaje opcje do wyboru
	var idx = 0
	for i in range(max(3, GameManagerSingleton.get_registered_players().size()), 11):
		_max_players.add_item(str(i),i)

		# Ustawia aktualną ilość połączeń jako zaznaczoną
		if i == GameManagerSingleton.get_server_settings().max_players:
			_max_players.select(idx)

		idx += 1
