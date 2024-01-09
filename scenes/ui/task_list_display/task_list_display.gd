extends CanvasLayer

@onready var _task_list_node = $TaskList

func _ready():
	TaskManager.tasks_change.connect(_update_task_list)


func _update_task_list():
	var tasks_string = ""
	
	for i in TaskManager.current_player_tasks:
		for prop_index in range(TaskManager.current_player_tasks[i].minigame_scene.get_state().get_node_property_count(0)):
			if TaskManager.current_player_tasks[i].minigame_scene.get_state().get_node_property_name(0, prop_index) == "polish_name":
				tasks_string += TaskManager.current_player_tasks[i].minigame_scene.get_state().get_node_property_value(0, prop_index)
				break
		
		tasks_string += "\n"
	
	_task_list_node.text = tasks_string


func _exit_tree():
	TaskManager.tasks_change.disconnect(_update_task_list)
