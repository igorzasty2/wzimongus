extends Node


signal task_completed;
# TODO: Potrzebuje tutaj załadować minigry jako słownik, aby móc przez nie iterować.
# Minigre muszą przechowywać swoją lokację i inne metadane potrzebne do zrobienia taska.
var minigames = {}

# Task ID bieżącego zadania.
var current_task_id = null


# Przechowuje wszystkie zadania w słowniku specyficznej dla serwera.
var tasks_server = {}
# Przechowuje zadania bieżącego gracza.
var tasks_player = {}


# Usuwa task z lokalnego słownika tasków.
@rpc("any_peer", "call_local")
func mark_task_as_complete_player():
	# Usuwa zadanie z listy zadań bieżącego gracza.
	var player_id = multiplayer.get_unique_id()
	tasks_player.erase(current_task_id)

	mark_task_as_complete_server.rpc_id(1, player_id, current_task_id)


# Usuwa task z serwerowego słownika tasków.
@rpc("any_peer", "call_remote")
func mark_task_as_complete_server(player_id, task_id):
	# Usuwa zadanie z listy tasków na serwerze.
	tasks_server[player_id].erase(task_id)
	
	# Usuwa gracza ze słowniku tasków jeżeli wszystkie taski są zrobione.
	if tasks_server[player_id].is_empty():
		tasks_server.erase(player_id)

	if tasks_server.is_empty():
		# TODO: zaznacz że crewmate wygrali jeżeli nie ma już tasków do zrobienia.
		pass


# Generuje wszystkie taski dla wszystkich gracze i potem wysyła te taski
# graczom ze pomocą rpc_id.
@rpc("authority", "call_local")
func assign_tasks_server(task_amount):
	minigames = get_node("/root/lobby_menu/Map/Map/Tasks").get_children()
#	print(get_node("/root/Map"))
	# TODO: żeby ten kod działał do końca trzeba stworzyć słownik minigier.
	if multiplayer.is_server() and tasks_server.is_empty():
		# Unikalny id dla każdego tasku.
		var id_counter = 0

		for i in MultiplayerManager.current_game["registered_players"]:
			# true w duplicate oznacza że kopia tego będzie głęboka
			var available_tasks = minigames.duplicate(true)
			var tasks_dict = {}
			
			# Tworzy słownik task_amount ilości losowych tasków.
			for task_number in range(task_amount):
#				var random_key = available_tasks.keys()[randi() % available_tasks.size()]
				var random_key = randi() % available_tasks.size()
				
				tasks_dict[id_counter] = available_tasks[random_key]
				available_tasks.erase(random_key)
				
				id_counter += 1
			
			# Zapisywania słownika tasków odpowiednemu graczowi w słownik serwerowy.
			tasks_server[i] = tasks_dict
			print("I'm assigning")
			assign_tasks_player.rpc_id(i, tasks_dict)
				

# Dodaje przesłane przez serwer taski w lokalną listę tasków.
@rpc("authority", "call_local")
func assign_tasks_player(tasks):
	tasks_player = tasks

	for i in tasks_player:
		var task = get_node(tasks_player[i].get_path())
		task.enable_task(i)


func _input(event):
	if event.is_action_pressed("interact"):
		if TaskManager.current_task_id != null:
			get_tree().change_scene_to_file("res://scenes/minigames/reactor_memory_answer/reactor_memory_answer.tscn")
