# Zarządza logiką lobby
extends Control

func _ready():
	GameManager.change_map.connect(_change_map)

# Zmienia mapę na serwerze
func _change_map(scene):
	var loaded_scene = load(scene)
	var maps = $Maps

	# Usuwa obecną mapę
	for i in maps.get_children():
		maps.remove_child(i)
		i.queue_free()
	
	# Dodaje nową mapę
	maps.add_child(loaded_scene.instantiate())
