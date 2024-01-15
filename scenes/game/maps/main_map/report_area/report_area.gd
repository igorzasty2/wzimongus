## Klasa obszaru raportowania.
class_name ReportArea
extends Area2D

## Określa czy jest przyciskiem.
@export var is_button: bool = false
## Tekstura znalezionego ciała.
@export var body_texture: Texture

## Interfejs.
@onready var _user_interface = get_tree().root.get_node("Game/Maps/MainMap/UserInterface")
## Przycisk alarmowy.
@onready var _emergency_button = get_tree().root.get_node("Game/Maps/MainMap/InteractionPoints/EmergencyButton")

## Określa czy gracz jest w zasięgu.
var is_player_inside: bool = false

# Określa czy czas oczekiwania na włączenie się przycisku alarmowego się skończył.
var _is_wait_time_over: bool = false

## Sygnał aktywujący/deaktywujący przyciski w interfejsie.
signal button_active(button_name: String, is_active: bool)
## Sygnał przełączający podświetlenie przycisku awaryjnego.
signal toggle_button_highlight(is_active: bool)


func _ready():
	if is_button:
		_emergency_button.emergency_timer_timeout.connect(_on_end_emergency_timer_timeout)

	button_active.connect(_user_interface.toggle_button_active)
	GameManagerSingleton.next_round_started.connect(_on_next_round_started)
	GameManagerSingleton.vent_entered.connect(_on_vent_entered)


func _input(event):
	if event.is_action_pressed("report") || event.is_action_pressed("interact"):
		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		if GameManagerSingleton.get_current_game_value("is_input_disabled"):
			return

		if event.is_action_pressed("report"):
			if is_button:
				return

		if event.is_action_pressed("interact"):
			if !is_button:
				return

			if !_is_wait_time_over:
				return

			if GameManagerSingleton.is_sabotage:
				return

		if !is_player_inside:
			return

		if GameManagerSingleton.get_current_player_value("is_dead"):
			return

		if GameManagerSingleton.is_meeting_called:
			return

		GameManagerSingleton.is_meeting_called = true

		var body_id = null

		if !is_button:
			body_id = get_parent().victim_id

		_emergency_button.handle_report(is_button, body_id)


## Obsługuje zakończenie emergency timer'a.
func _on_end_emergency_timer_timeout(is_over: bool):
	_is_wait_time_over = is_over
	if (
		is_player_inside
		&& !GameManagerSingleton.get_registered_player_value(GameManagerSingleton.get_current_player_id(), "is_dead")
		&& !GameManagerSingleton.is_meeting_called
		&& _is_wait_time_over
	):
		button_active.emit("InteractButton", true)
		toggle_button_highlight.emit(true)


## Obsługuje wejście gracza do venta dla ciała
func _on_vent_entered(is_inside_vent:bool):
	if !GameManagerSingleton.get_current_player_value("is_lecturer"):
		return

	var bodies = get_overlapping_bodies()

	for body in bodies:
		if (
			body.name.to_int() == GameManagerSingleton.get_current_player_id()
			&& !GameManagerSingleton.get_current_player_value("is_dead")
			&& !is_button
		):
			is_player_inside = !is_inside_vent
			button_active.emit("ReportButton", !is_inside_vent)
			return


## Usuwa ciało z mapy.
func _on_next_round_started():
	if !is_button:
		get_parent().queue_free()


## Obsługuje wejście gracza.
func _on_body_entered(body):
	if (
		body.name.to_int() == GameManagerSingleton.get_current_player_id()
		&& !GameManagerSingleton.get_registered_player_value(body.name.to_int(), "is_dead")
		&& !body.is_in_vent
	):
		is_player_inside = true

		if is_button:
			if _is_wait_time_over && !GameManagerSingleton.is_meeting_called && !GameManagerSingleton.is_sabotage:
				button_active.emit("InteractButton", true)
				toggle_button_highlight.emit(true)
		else:
			button_active.emit("ReportButton", true)


## Obsługuje wyjście gracza.
func _on_body_exited(body):
	if (
		body.name.to_int() == GameManagerSingleton.get_current_player_id()
		&& !GameManagerSingleton.get_registered_player_value(body.name.to_int(), "is_dead")
		&& !body.is_in_vent
	):
		is_player_inside = false

		if is_button:
			button_active.emit("InteractButton", false)
			toggle_button_highlight.emit(false)
		else:
			button_active.emit("ReportButton", false)
