## Klasa do wyświetlania listy zadań
class_name TaskListDisplay
extends CanvasLayer

## Referencja do node'a przechowującego listę zadań.
@onready var _task_list_node = $VBoxContainer/Control/TaskList
## Referencja do node'a przechowującego pasek postępu zadań wszystich graczy.
@onready var _progress_bar = $VBoxContainer/ProgressBar

func _ready():
	TaskManager.tasks_change.connect(_update_task_list)
	TaskManager.global_tasks_completed_amount_change.connect(_update_progress_bar)

## Odświeża listę zadań na ekranie.
func _update_task_list():
	var tasks_string = ""
	
	for i in TaskManager.current_player_tasks:
		for prop_index in range(TaskManager.current_player_tasks[i].minigame_scene.get_state().get_node_property_count(0)):
			if TaskManager.current_player_tasks[i].minigame_scene.get_state().get_node_property_name(0, prop_index) == "polish_name":
				tasks_string += TaskManager.current_player_tasks[i].minigame_scene.get_state().get_node_property_value(0, prop_index)
				break
		
		tasks_string += "\n"
	
	_task_list_node.text = tasks_string


## Odświeża pasek postępu zadań wszystkich graczy na ekranie.
func _update_progress_bar():
	_progress_bar.value = int(float(TaskManager.global_tasks_completed_amount) / TaskManager.global_tasks_amount * 100)


func _exit_tree():
	TaskManager.tasks_change.disconnect(_update_task_list)
