extends Area2D

# minigra która będzie włączona przez ten przecisk
@export var minigame_scene : PackedScene

var _is_player_inside : bool = false

@onready var minigame_menu = get_parent().get_node("MinigameMenu")

func _on_body_entered(body):
	if body.name.to_int() == multiplayer.get_unique_id():
		_is_player_inside = true
		minigame_menu.show_use_button(minigame_scene)


func _on_body_exited(body):
	if body.name.to_int() == multiplayer.get_unique_id():
		_is_player_inside = false
		minigame_menu.hide_use_button()
