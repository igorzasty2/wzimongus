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
var players
## Tablica wszystkich tasków
var tasks
## Tablica wszystkich ciał
var dead_bodies
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

## Przechowuje grafikę ciała
var dead_body_sprite

## Sygnał aktywujący przyciski w interfejsie
signal button_active(button_name:String, is_active:bool)
## Sygnał przełączający podświetlenie przycisku awaryjnego
signal toggle_button_highlight(is_active:bool)

func _ready():
	GameManager.next_round_started.connect(on_next_round_started)
	GameManager.player_killed.connect(on_player_killed)
	if is_button:
		emergency_button = get_parent()
		emergency_button.emergency_timer_timeout.connect(_on_end_emergency_timer_timeout)
	
	players = get_tree().root.get_node("Game/Maps/MainMap/Players").get_children()
	tasks = get_tree().root.get_node("Game/Maps/MainMap/Tasks").get_children()
	meeting_positions = get_tree().root.get_node("Game/Maps/MainMap/MeetingPositions").get_children()
	
	user_interface = get_tree().root.get_node("Game/Maps/MainMap/UserInterface")
	task_list = get_tree().root.get_node("Game/Maps/MainMap/TaskListDisplay")
	
	button_active.connect(user_interface.toggle_button_active)


func _input(event):
	# Obłsuguje odpowiednio naciśnięcie przycisku do zebrania lub do reportowania
	if (
	((event.is_action_pressed("report") && !is_button) || ((event.is_action_pressed("interact") && is_button && is_wait_time_over)))
	&& !GameManager.get_current_game_key("is_input_disabled")
	&& !GameManager.get_current_game_key("paused") 
	&& is_player_inside 
	&& !GameManager.get_current_player_key("is_dead") 
	&& !GameManager.is_meeting_called):
		
		GameManager.is_meeting_called = true
		
		# Aktualizuje tablice
		players = get_tree().root.get_node("Game/Maps/MainMap/Players").get_children()
		tasks = get_tree().root.get_node("Game/Maps/MainMap/Tasks").get_children()
		dead_bodies = get_tree().root.get_node("Game/Maps/MainMap/DeadBodies").get_children()
		
		# Chowa przyciski z interfejsu i liste tasków
		user_interface.toggle_visiblity.rpc(false)
		toggle_task_list_visibility.rpc(false)
		
		# Zamyka taski - zrobić jeszcze zamykanie kamer
		close_tasks.rpc()
		
		# Instancjonuje ekran głosowania
		open_voting_screen.rpc()
		
		# Pokazuje ekran z ciałem/spotkaniem, po czym rozpoczyna głosowanie
		show_hide_report_screen.rpc()
		


## Obsługuje zakończenie emergeny_timer
func _on_end_emergency_timer_timeout(is_over: bool):
	is_wait_time_over = is_over
	if is_player_inside && !GameManager.get_registered_player_key(multiplayer.get_unique_id(), "is_dead"):
		button_active.emit("InteractButton", true)
		toggle_button_highlight.emit(true)


## Pokazuje interfejs, usuwa wszystkie ciała - zrobić jak będą ciała
func on_next_round_started():
	print("next round")
	GameManager.is_meeting_called = false
	
	# Pokazuje przyciski z interfejsu i liste zadań
	user_interface.toggle_visiblity.rpc(true)
	toggle_task_list_visibility.rpc(true)

	# Usuwa ciało z mapy
	if !is_button:
		get_parent().queue_free()


## Obsługuje wejście gracza
func _on_body_entered(body):
	if body.name.to_int() == multiplayer.get_unique_id() && !GameManager.get_registered_player_key(body.name.to_int(), "is_dead") && !body.is_in_vent:
		is_player_inside = true
		
		if is_button:
			if is_wait_time_over:
				button_active.emit("InteractButton", true)
				toggle_button_highlight.emit(true)
		else:
			button_active.emit("ReportButton", true)


## Obsługuje wyjście gracza
func _on_body_exited(body):
	if body.name.to_int() == multiplayer.get_unique_id() && !GameManager.get_registered_player_key(body.name.to_int(), "is_dead") && !body.is_in_vent:
		is_player_inside = false
		
		if is_button:
			button_active.emit("InteractButton", false)
			toggle_button_highlight.emit(false)
		else:
			button_active.emit("ReportButton", false)


func on_player_killed(player_id:int):
	if player_id == multiplayer.get_unique_id():
		if is_button:
			button_active.emit("InteractButton", false)
		else:
			button_active.emit("ReportButton", false)


@rpc("call_local", "any_peer")
## Instancjonuje ekran głosowania
func open_voting_screen():
	var voting_screen_instance = voting_screen.instantiate()
	get_node("CanvasLayer").add_child(voting_screen_instance)
	
	# Wyłącza ruch gracza - później włącza się przez voting_screen w game_manager
	GameManager.set_input_status(false)


@rpc("call_local", "any_peer")
## Pokazuje ekran reporta, po czym go chowa, rozpoczyna głosowanie
func show_hide_report_screen():
	var report_screen_instance = report_screen.instantiate()
	report_screen_instance.is_meeting = is_button
	if !is_button:
		dead_body_sprite = get_parent().get_node("DeadBodySprite").texture
	report_screen_instance.body_texture = dead_body_sprite
	get_node("CanvasLayer").add_child(report_screen_instance)
	await get_tree().create_timer(1.5).timeout
	get_node("CanvasLayer").get_child(1).queue_free()
	
	# Rozpoczyna głosowanie
	get_node("CanvasLayer").get_child(0).start_voting()


@rpc("call_local", "any_peer")
## Zamyka wszystkie taski
func close_tasks():
	for task in tasks:
		task.close_minigame()


@rpc("call_local", "any_peer")
## Przełącza widoczność listy zadań
func toggle_task_list_visibility(is_visible:bool):
	task_list.visible = is_visible
