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

## Określa czy gracz jest w zasięgu
var is_player_inside:bool = false

## Przycisk awaryjny
var emergency_button
# Określa czy czas oczekiwania się skończył
var is_wait_time_over:bool = false

var user_interface
var task_list

signal button_active(button_name:String, is_active:bool)

func _ready():
	GameManager.next_round_started.connect(on_next_round_started)
	
	if is_button:
		emergency_button = $".."
		emergency_button.emergency_timer_timeout.connect(_on_end_emergency_timer_timeout)
		
		player_array = get_parent().get_parent().get_parent().get_node("Players").get_children()
		task_array = get_parent().get_parent().get_parent().get_node("Tasks").get_children()
		user_interface = get_parent().get_parent().get_parent().get_node("UserInterface")
		task_list = get_parent().get_parent().get_parent().get_node("TaskListDisplay")
		

	else:
		player_array = get_parent().get_node("Players").get_children()	# tu tez jak bedzie jako dziecko ciala trzeba bedzie dac wiecej/mniej razy get_parent()
		task_array = get_parent().get_node("Tasks").get_children()	# tu tez jak bedzie jako dziecko ciala trzeba bedzie dac wiecej/mniej razy get_parent()
		user_interface = get_parent().get_node("UserInterface")	# tu tez jak bedzie jako dziecko ciala trzeba bedzie dac wiecej/mniej razy get_parent()
		task_list = get_parent().get_node("TaskListDisplay")	# tu tez jak bedzie jako dziecko ciala trzeba bedzie dac wiecej/mniej razy get_parent()
	
	button_active.connect(user_interface.toggle_button_active)


func _input(event):
	# Obłsuguje odpowiednio naciśnięcie przycisku do zebrania lub do reportowania
	if !GameManager.get_current_game_key("is_input_disabled") && ((event.is_action_pressed("report") && !is_button) || (event.is_action_pressed("interact") && is_button && is_wait_time_over)) && is_player_inside && !GameManager.get_current_player_key("is_dead"):
		print("reported")
		# Aktualizuje tablice
		if is_button:
			player_array = get_parent().get_parent().get_parent().get_node("Players").get_children()
			task_array = get_parent().get_parent().get_parent().get_node("Tasks").get_children()
			# zaktualizowac tez tablice ciał
		
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
		
		# Wyciąga impostorów z ventów - zrobić jak będą venty
		
		
		# Przenosi graczy na start - zrobić jak będą venty
		
		

## Obsługuje zakończenie emergeny_timer
func _on_end_emergency_timer_timeout(is_over: bool):
	is_wait_time_over = is_over
	if is_player_inside:
		button_active.emit("InteractButton", true)


## Chowa wszystkie ciała na mapie, pokazuje interfejs, usuwa wszystkie ciała - zrobić jak będą ciała
func on_next_round_started():
	print("next round")
	# Pokazuje przyciski z interfejsu i liste zadań
	user_interface.bottom_buttons_toggle_visiblity.rpc(true)
	toggle_task_list_visibility.rpc(true)
	
	# Usuwa ciała z mapy - zrobić jak będą ciała
#	for body in body_array:
#		if body==self:
#			continue
#		body.queue_free()

	if !is_button:
		queue_free()


## Obsługuje wejście gracza
func _on_body_entered(body):
	if body.name.to_int() == GameManager.get_current_player_id() && !GameManager.get_current_player_key("is_dead"):
		print("report area entered")
		is_player_inside = true
		
		if is_button:
			if is_wait_time_over:
				button_active.emit("InteractButton", true)
		else:
			button_active.emit("ReportButton", true)


## Obsługuje wyjście gracza
func _on_body_exited(body):		# TUTAJ JEST PROBLEM JAK SIE WYJDZIE PODCZAS BYCIA W ŚRODKU BO CURRENT PLATER CHYBA NIE ISTNIE
	if body.name.to_int() == GameManager.get_current_player_id() && !GameManager.get_current_player_key("is_dead"):
		print("report area exited")
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
## Pokazuje, po czym chowa ekran reporta, rozpoczyna głosowanie
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
