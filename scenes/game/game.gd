extends Control

func _ready():
	GameManager.change_map.connect(_change_map)

## Zmień wyświetlaną globalnie mapę.
func _change_map(scene: String):
	var maps = $Maps

	# Usuń aktualną mapę.
	for i in maps.get_children():
		maps.remove_child(i)
		i.queue_free()

	# Dodaj nową mapę.
	maps.add_child(load(scene).instantiate())
