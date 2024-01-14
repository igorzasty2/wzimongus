## Klasa przycisku awaryjnego spotkania.
class_name EmergencyButton
extends Node2D

## Timer
@onready var _emergency_timer = Timer.new()
## Label pozostałego czasu
@onready var _time_left_label = $TimeLeftLabel
## Tekstura przycisku
@onready var _sprite_2d = $Sprite2D
## Label wyświetlający pozostałą ilość użyć
@onready var _uses_left_label = $UsesLeftLabel
## Area reportu
@onready var _report_area = $ReportArea
## Canvas w którym będzie instancjonowane głosowanie
@onready var _voting_canvas = get_tree().root.get_node("Game/Maps/MainMap/VotingCanvas")
## Główna mapa
@onready var _main_map = get_tree().root.get_node("Game/Maps/MainMap")
## Interfejs
@onready var _user_interface = get_tree().root.get_node("Game/Maps/MainMap/UserInterface")

## Ekran głosowania
var _voting_screen = preload("res://scenes/game/maps/main_map/voting_screen/voting_screen.tscn")
## Ekran reporta
var _report_screen = preload("res://scenes/game/maps/main_map/report_screen/report_screen.tscn")

# Czas oczekiwania od początku rundy na aktywację przycisku
var _wait_time = GameManagerSingleton.get_server_settings()["emergency_cooldown"]
## Określa czy czas oczekiwania się skończył
var _is_wait_time_over: bool = false

## Kolor podświetlenia przycisku w zasięgu
var _in_range_color = [255, 255, 255, 255]
## Kolor podświetlenia przycisku poza zasięgiem
var _out_of_range_color = [0, 0, 0, 0]

## Wszyscy gracze
var _players

## Określa czy przycisk wywołał spotkanie czy ciało
var _is_caller_button: bool

## Emitowany, gdy zakończy się czas oczekiwania na aktywację przycisku.
signal emergency_timer_timeout(is_over: bool)
## Emitowany, gdy przycisk interfejsu ma być aktywowany/deaktywowany.
signal button_active(button_name: String, is_active: bool)


func _ready():
	GameManagerSingleton.next_round_started.connect(_on_next_round_started)
	GameManagerSingleton.map_load_finished.connect(_on_map_load_finished)
	GameManagerSingleton.player_killed.connect(_on_player_killed)
	GameManagerSingleton.sabotage_started.connect(_on_sabotage_started)

	_report_area.toggle_button_highlight.connect(_toggle_button_highlight)

	_uses_left_label.text = "Pozostało użyć: 1"

	_toggle_button_highlight(false)

	button_active.connect(_user_interface.toggle_button_active)


func _process(_delta):
	# Wyświetla pozostały czas do możliwości użycia przycisku
	_time_left_label.text = str(int(_emergency_timer.get_time_left()))


## Wywoływane w momencie oblania gracza
func _on_player_killed(id: int, is_victim: bool):
	if GameManagerSingleton.get_current_player_id() == id && is_victim:
		_uses_left_label.text = ""
		_toggle_button_highlight(false)
		button_active.emit("InteractButton", false)
		button_active.emit("ReportButton", false)


## Wywoływane po zakończeniu ładowania mapy
func _on_map_load_finished():
	add_child(_emergency_timer)
	_emergency_timer.autostart = true
	_emergency_timer.one_shot = true
	_emergency_timer.timeout.connect(_on_end_emergency_timer_timeout)
	_emergency_timer.start(_wait_time)


## Obsługuje zakończenie emergeny_timer
func _on_end_emergency_timer_timeout():
	_is_wait_time_over = true
	set_process(false)
	_time_left_label.text = ""
	emergency_timer_timeout.emit(true)


## Na początku rundy restartuje timer z czasem oczekiwania na aktywację przycisku, przywraca widoczność elementów interfejsu
func _on_next_round_started():
	_voting_canvas.get_child(0).queue_free()

	if GameManagerSingleton.get_current_player_value("is_dead") && _uses_left_label.text != "":
		_uses_left_label.text = ""

	GameManagerSingleton.is_meeting_called = false

	button_active.emit("ReportButton", false)
	button_active.emit("InteractButton", false)
	_toggle_button_highlight(false)

	set_process(true)
	_is_wait_time_over = false

	_emergency_timer.start(_wait_time)
	emergency_timer_timeout.emit(false)


## Włącza i wyłącza podświetlenie przycisku awaryjnego
func _toggle_button_highlight(is_on: bool):
	if is_on:
		_sprite_2d.material.set_shader_parameter("line_color", _in_range_color)
	else:
		_sprite_2d.material.set_shader_parameter("line_color", _out_of_range_color)


## Wywoływane po naciśnięciu przycisku, wyłącza możliwość ponownego użycia
func _button_used():
	_uses_left_label.text = "Pozostało użyć: 0"
	_report_area.monitoring = false
	_report_area.monitorable = false


## Obsługuje report/zebranie awaryjne.
func handle_report(is_button: bool, body_id):
	GameManagerSingleton.is_meeting_called = true

	_is_caller_button = is_button

	_update_array()

	_request_displaying_report_screen.rpc_id(1, is_button, body_id)

	if _is_caller_button:
		_button_used()


## Aktualizuje tablice, która mogła ulec zmianie
func _update_array():
	_players = get_tree().root.get_node("Game/Maps/MainMap/Players").get_children()


@rpc("any_peer", "call_local", "reliable")
func _request_displaying_report_screen(is_button: bool, dead_body_id):
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED

	_display_report_screen.rpc(is_button, dead_body_id)


@rpc("call_local", "reliable")
func _display_report_screen(is_button: bool, dead_body_id):
	_main_map.close_modals()

	_instantiate_voting_screen()

	_show_hide_report_screen(is_button, dead_body_id)


## Instancjonuje ekran głosowania
func _instantiate_voting_screen():
	var voting_screen_instance = _voting_screen.instantiate()
	_voting_canvas.add_child(voting_screen_instance)

	GameManagerSingleton.is_meeting_called = true
	_is_wait_time_over = false

	button_active.emit("ReportButton", false)
	button_active.emit("InteractButton", false)


## Pokazuje ekran reporta na chwilę, po czym rozpoczyna głosowanie
func _show_hide_report_screen(is_button: bool, dead_body_id):
	var report_screen_instance = _report_screen.instantiate()
	report_screen_instance.is_emergency_meeting = is_button

	if !is_button && dead_body_id != null:
		report_screen_instance.body_texture_id = dead_body_id

	_voting_canvas.add_child(report_screen_instance)

	await get_tree().create_timer(1.5).timeout
	_voting_canvas.get_child(1).queue_free()

	# Rozpoczyna głosowanie
	_voting_canvas.get_child(0).start_voting()


## Obsługuje rozpoczęcie/zakończenie sabotażu dla przycisku awaryjnego
func _on_sabotage_started(has_started: bool):
	if _emergency_timer.time_left > 0:
		return

	var bodies = _report_area.get_overlapping_bodies()
	for body in bodies:
		if (
			body.name.to_int() == GameManagerSingleton.get_current_player_id()
			&& !GameManagerSingleton.get_current_player_value("is_dead")
			&& _report_area.monitorable
			&& _report_area.monitoring
		):
			_toggle_button_highlight(!has_started)
			button_active.emit("InteractButton", !has_started)
