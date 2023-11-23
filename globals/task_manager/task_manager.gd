extends Node

# TODO: Potrzebuje tutaj załadować minigry jako słownik, aby móc przez nie iterować.
# Minigre muszą przechowywać swoją lokację i inne metadane potrzebne do zrobienia taska.
var minigames = {}

# Task ID bieżącego zadania.
var current_task_id = 0


# Przechowuje wszystkie zadania w słowniku specyficznej dla serwera.
var tasks_server = {}
# Przechowuje zadania bieżącego gracza.
var tasks_player = {}


# Usuwa task z lokalnego słownika tasków.
@rpc("any_peer", "call_local")
func mark_task_as_done_player():
	# Usuwa zadanie z listy zadań bieżącego gracza.
	var player_id = multiplayer.get_unique_id()
	tasks_player.erase(current_task_id)

	mark_task_as_done_server.rpc_id(1, player_id, current_task_id)


# Usuwa task z serwerowego słownika tasków.
@rpc("any_peer", "call_remote")
func mark_task_as_done_server(player_id, task_id):
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
	# TODO: żeby ten kod działał do końca trzeba stworzyć słownik minigier.
	if multiplayer.is_server():
		if tasks_server.is_empty():

			# Unikalny id dla każdego tasku.
			var id_counter = 0

			for i in MultiplayerManager.players:
				var tasks_dict = {}
				var random_minigame_indexes = []
				
				# Tworzy słownik task_amount ilości losowych tasków.
				for task_number in range(task_amount):
					var minigame_index
					
					# Losuje minigame_index dopóki nie będzie unikalna minigra.
					while true:
						minigame_index = randi() % minigames.size()
						if minigame_index not in random_minigame_indexes:
							break
					
					
					tasks_dict[id_counter] = minigames[minigame_index]
					random_minigame_indexes.append(minigame_index)
					
					id_counter += 1
				
				# Zapisywania słownika tasków odpowiednemu graczowi w słownik serwerowy.
				tasks_server[i] = tasks_dict
				assign_tasks_player.rpc_id(MultiplayerManager.players[i].id, tasks_dict)
				

# Dodaje przesłane przez serwer taski w lokalną listę tasków.
@rpc("authority", "call_remote")
func assign_tasks_player(tasks):
	tasks_player = tasks
