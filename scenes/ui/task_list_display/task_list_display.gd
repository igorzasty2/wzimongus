extends CanvasLayer

@onready var _task_list_node = $TaskList

func _ready():
	TaskManager.tasks_change.connect(_update_task_list)


func _update_task_list():
	var tasks_string = ""
	
	for i in TaskManager.current_player_tasks:
		tasks_string += str(TaskManager.current_player_tasks[i].minigame_scene)
		tasks_string += "\n"
	
	_task_list_node.text = tasks_string


func _exit_tree():
	TaskManager.tasks_change.disconnect(_update_task_list)
