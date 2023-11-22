extends Node
# TODO: Needs to load minigames as a list here so that we can iterate through them
var minigames = []

# Task id is being assigned to every task. Should be incremented every time a task is assigned.
var task_id = 0

# Stores all the tasks in a server specific list.
var tasks_server = []
# Stores current player's tasks.
var tasks_player = []


@rpc("any_peer", "call_local")
func mark_task_as_done(task_id, player_id):
	if multiplayer.is_server():
		# Removes task from task_list_server by task id reference.
		var task_index = _find_task_list_index_by_task_id(tasks_server, task_id)
		if task_index != null:
			tasks_server.remove_at(task_index)	
		
	
	if player_id == multiplayer.get_unique_id():
		# Removes task from current player's task list.
		var task_index = _find_task_list_index_by_task_id(tasks_player, task_id)
		if task_index != null:
			tasks_player.remove_at(task_index)


func _find_task_list_index_by_task_id(task_list, task_id):
	for i in range(len(task_list)):
		if task_list[i].task_id == task_id:
			return i


@rpc("authority", "call_local")
func assign_tasks_server():
	# TODO: for this function to work first minigames list should be created.
	if multiplayer.is_server():
		if tasks_server.is_empty():
			# TODO: populate tasks_server here
			# my proposition is to generate task player by player
			
			# TODO: send task list to the corresponding player
			# assign_tasks_player.rpc_id(player_id, tasks)
			pass


@rpc("authority", "call_remote")
func assign_tasks_player(tasks):
	tasks_player.append_array(tasks)
