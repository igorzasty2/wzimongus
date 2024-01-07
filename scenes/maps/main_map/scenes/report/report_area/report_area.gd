extends Area2D

## Określa czy przycisk
@export var is_button:bool = false
## Tekstura znalezionego ciała
@export var body_texture:Texture

## Ekran głosowania
var voting_screen = preload("res://scenes/ui/voting_screen/voting_screen.tscn")
## Ekran reporta
var report_screen = preload("res://scenes/maps/main_map/scenes/report/report_screen/report_screen.tscn")

## Tablica wszystkich graczy
var player_array
## Tablica wszystkich tasków
var task_array
## Tablica wszystkich ciał
var body_array
## Tablica z pozycjami do spotkania podczas głosowania
var meeting_positions

## Określa czy gracz jest w zasięgu
var is_player_inside:bool = false

## Przycisk awaryjny
var emergency_button
# Określa czy czas oczekiwania się skończył
var is_wait_time_over:bool = false

## Odniesienie do UserInterface
var user_interface
## Odniesienie to TaskListDisplay
var task_list

## Sygnał aktywujący przyciski w interfejsie
signal button_active(button_name:String, is_active:bool)

func _ready():
	GameManager.next_round_started.connect(on_next_round_started)
	if is_button:
		emergency_button = $".."
		emergency_button.emergency_timer_timeout.connect(_on_end_emergency_timer_timeout)
	
	player_array = get_tree().root.get_node("Game/Maps/MainMap/Players").get_children()
	task_array = get_tree().root.get_node("Game/Maps/MainMap/Tasks").get_children()
	meeting_positions = get_tree().root.get_node("Game/Maps/MainMap/MeetingPositions").get_children()
	
	user_interface = get_tree().root.get_node("Game/Maps/MainMap/UserInterface")
	task_list = get_tree().root.get_node("Game/Maps/MainMap/TaskListDisplay")
	
	button_active.connect(user_interface.toggle_button_active)
	


func _input(event):
	# Obłsuguje odpowiednio naciśnięcie przycisku do zebrania lub do reportowania
	if !GameManager.get_current_game_key("is_input_disabled") && ((event.is_action_pressed("report") && !is_button) || (event.is_action_pressed("interact") && is_button && is_wait_time_over)) && is_player_inside && !GameManager.get_current_player_key("is_dead") && !GameManager.is_meeting_called:
		
		print("reported")
		
		GameManager.is_meeting_called = true
		
		# Aktualizuje tablice
		player_array = get_tree().root.get_node("Game/Maps/MainMap/Players").get_children()
		task_array = get_tree().root.get_node("Game/Maps/MainMap/Tasks").get_children()
		# body_array = get_tree().root.get_node("Game/Maps/MainMap/Bodies").get_children()
		
		
		# Chowa przyciski z interfejsu i liste tasków
		user_interface.bottom_buttons_toggle_visiblity.rpc(false)
		toggle_task_list_visibility.rpc(false)
		
		# Zamyka taski
		close_tasks.rpc()
		
		# Instancjonuje ekran głosowania
		open_voting_screen.rpc()
		
		# Pokazuje ekran z ciałem/spotkaniem, po czym rozpoczyna głosowanie
		show_hide_report_screen.rpc()
		
		# Wyłącza ruch gracza - później włącza się przez voting_screen w game_manager
		GameManager.set_input_status(false)
		
		# Wyciąga impostorów z ventów i przenosi graczy na start - nie działa
		var player_id = multiplayer.get_remote_sender_id()

		if player_id != 1:
			move_players_to_position()

		move_players_to_position.rpc_id(player_id)


@rpc("call_local", "reliable")
## Przenosi graczy na miejsce spotkania
func move_players_to_position():
	for i in range(0, player_array.size()):
		player_array[i].is_teleport = true
		player_array[i].teleport_position = meeting_positions[i].global_position


## Obsługuje zakończenie emergeny_timer
func _on_end_emergency_timer_timeout(is_over: bool):
	is_wait_time_over = is_over
	if is_player_inside:
		button_active.emit("InteractButton", true)


## Pokazuje interfejs, usuwa wszystkie ciała - zrobić jak będą ciała
func on_next_round_started():
	print("next round")
	GameManager.is_meeting_called = false
	
	# Pokazuje przyciski z interfejsu i liste zadań
	user_interface.bottom_buttons_toggle_visiblity.rpc(true)
	toggle_task_list_visibility.rpc(true)

	# Usuwa ciało z mapy
	if !is_button:
		queue_free()


## Obsługuje wejście gracza
func _on_body_entered(body):
	if body.name.to_int() == multiplayer.get_unique_id() && !GameManager.get_registered_player_key(name.to_int(), "is_dead"):
		is_player_inside = true
		
		if is_button:
			if is_wait_time_over:
				button_active.emit("InteractButton", true)
		else:
			button_active.emit("ReportButton", true)


## Obsługuje wyjście gracza
func _on_body_exited(body):
	if body.name.to_int() == multiplayer.get_unique_id() && !GameManager.get_registered_player_key(name.to_int(), "is_dead"):
		is_player_inside = false
		
		if is_button:
			button_active.emit("InteractButton", false)
		else:
			button_active.emit("ReportButton", false)


@rpc("call_local", "any_peer")
## Instancjonuje ekran głosowania
func open_voting_screen():
	var voting_screen_instance = voting_screen.instantiate()
	get_node("CanvasLayer").add_child(voting_screen_instance)
	GameManager.set_input_status(false)


@rpc("call_local", "any_peer")
## Pokazuje ekran reporta, po czym go chowa, rozpoczyna głosowanie
func show_hide_report_screen():
	var report_screen_instance = report_screen.instantiate()
	report_screen_instance.is_meeting = is_button
	#report_screen_instance.body_texture = body_texture
	get_node("CanvasLayer").add_child(report_screen_instance)
	await get_tree().create_timer(1.5).timeout
	get_node("CanvasLayer").get_child(1).queue_free()
	
	# Rozpoczyna głosowanie
	get_node("CanvasLayer").get_child(0).start_voting()


@rpc("call_local", "any_peer")
## Zamyka wszystkie taski
func close_tasks():
	for task in task_array:
		task.close_minigame()


@rpc("call_local", "any_peer")
## Przełącza widoczność listy zadań
func toggle_task_list_visibility(is_visible:bool):
	task_list.visible = is_visible
