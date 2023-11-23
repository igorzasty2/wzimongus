extends Node

# TODO: Potrzebuje tutaj załadować minigry jako listę, aby móc przez nie iterować
var minigames = {}

# Task ID bieżącego zadania.
var current_task_id = 0


# Przechowuje wszystkie zadania w liście specyficznej dla serwera.
var tasks_server = {}
# Przechowuje zadania bieżącego gracza.
var tasks_player = {}


@rpc("any_peer", "call_local")
func mark_task_as_done_player():
	# Usuwa zadanie z listy zadań bieżącego gracza.
	var player_id = multiplayer.get_unique_id()
	tasks_player.erase(current_task_id)

	mark_task_as_done_server.rpc_id(1, player_id, current_task_id)


@rpc("call_remote", "any_peer")
func mark_task_as_done_server(player_id, task_id):
	# Usuwa zadanie z listy tasków na serwerze.
	tasks_server[player_id].erase(task_id)

	if tasks_server.is_empty():
		# TODO: zaznacz że crewmate wygrali jeżeli nie ma już tasków do zrobienia
		pass


@rpc("authority", "call_local")
func assign_tasks_server(task_amount):
	# TODO: for this function to work first minigames list should be created.
	if multiplayer.is_server():
		if tasks_server.is_empty():
			var _id_counter = 0
			for i in MultiplayerManager.players:
				var tasks_dict = {}

				for task_number in range(task_amount):
					# TODO: refactor to generate random task with no repetitions.
					tasks_dict[_id_counter] = minigames[randi() % minigames.size()]
				
				tasks_server[i] = tasks_dict
				assign_tasks_player.rpc_id(1, tasks_dict)
				
				_id_counter += 1

@rpc("authority", "call_remote")
func assign_tasks_player(tasks):
	
	tasks_player.append_array(tasks)
