extends Area2D

@export var area_radius = 140
@export var is_button:bool = false

var voting_screen = preload("res://scenes/ui/voting_screen/voting_screen.tscn")
var report_screen = preload("res://scenes/maps/main_map/scenes/report/report_screen/report_screen.tscn")

var player_array
var task_array
var is_player_inside:bool = false
# Czas przez jaki widać ekran reporta
var await_time:float = 1.5

func _ready():
	$CollisionShape2D.shape.set_radius(area_radius)
	if is_button:
		player_array = get_parent().get_parent().get_parent().get_node("Players").get_children()
		task_array = get_parent().get_parent().get_parent().get_node("Tasks").get_children()
	else:
		player_array = get_parent().get_node("Players").get_children()	# tu tez jak bedzie jako dziecko ciala trzeba bedzie dac wiecej razy get_parent()
		task_array = get_parent().get_node("Tasks").get_children()	# tu tez jak bedzie jako dziecko ciala trzeba bedzie dac wiecej razy get_parent()
	
func _input(event):
	# Obłsuguje odpowiednio naciśnięcie przycisku do zebrania i reportowania
	if ((event.is_action_pressed("report") && !is_button) || (event.is_action_pressed("interact") && is_button)) && is_player_inside && !GameManager.get_current_player_key("is_dead"):
		
		# Instancjonuje głosowanie
		open_voting_screen.rpc()
		
		# Pokazuje ekran z ciałem/spotkaniem, po czym rozpoczyna głosowanie
		show_hide_report_screen.rpc()
		
		# Zamyka taski - nie działa
		for task in task_array:
			task.close_minigame()
		
		# Wyłącza ruch gracza - true później włącza się przez voting_screen w game_manager
		GameManager.set_input_status(false)
		
		# Wyciąga impostorów z ventów - zrobić jak będą venty
		
		
		
		# Przenosi graczy na start - zrobić jak będą venty
		
		# Usuwa wszystkie ciała z mapy - zrobić jak będą ciała


func _on_body_entered(body):
	if body.name.to_int() == GameManager.get_current_player_id() && !GameManager.get_current_player_key("is_dead"):
		print("report area entered")
		is_player_inside = true


func _on_body_exited(body):
	if body.name.to_int() == GameManager.get_current_player_id() && !GameManager.get_current_player_key("is_dead"):
		print("report area exited")
		is_player_inside = false


@rpc("call_local", "any_peer")
## Instancjonuje ekran głosowania
func open_voting_screen():
	var voting_screen_instance = voting_screen.instantiate()
	get_node("CanvasLayer").add_child(voting_screen_instance)
	GameManager.set_input_status(false)


@rpc("call_local", "any_peer")
## Pokazuje, po czym chowa ekran reporta 
func show_hide_report_screen():
	var report_screen_instance = report_screen.instantiate()
	report_screen_instance.is_meeting = is_button
	get_node("CanvasLayer").add_child(report_screen_instance)
	await get_tree().create_timer(await_time).timeout
	get_node("CanvasLayer").get_child(1).queue_free()
	
	# Rozpoczyna głosowanie
	get_node("CanvasLayer").get_child(0).start_voting()
