extends Control

@onready var error_pop_up = $ErrorPopUp

func _ready():
	GameManager.change_map.connect(_change_map)
	GameManager.error_occured.connect(_on_error_occured)
	error_pop_up.left_pressed.connect(_on_error_pop_up_closed)

## Zmień wyświetlaną globalnie mapę.
func _change_map(scene: String):
	var maps = $Maps

	# Usuń aktualną mapę.
	for i in maps.get_children():
		maps.remove_child(i)
		i.queue_free()

	# Dodaj nową mapę.
	maps.add_child(load(scene).instantiate())

func _on_error_occured(message: String):
	var maps = $Maps

	# Usuń aktualną mapę.
	for i in maps.get_children():
		maps.remove_child(i)
		i.queue_free()
	
	error_pop_up.set_information(message)
	error_pop_up.show()

func _on_error_pop_up_closed():
	GameManager.end_game()
