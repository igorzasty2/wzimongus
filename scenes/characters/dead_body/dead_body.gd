## Klasa reprezentująca zwłoki gracza.
class_name DeadBody
extends Node2D

## Identyfikator gracza, którego zwłoki reprezentuje ten obiekt.
@export var victim_id: int

@onready var _sprite = $DeadBodySprite
@onready var _label = $DeadBodyLabel


## Inicjuje zwłoki gracza.
func set_dead_player(victim: int) -> void:
	victim_id = victim
	var victim_node = get_tree().root.get_node("Game/Maps/MainMap/Players/"+str(victim))
	var victim_sprite = victim_node.get_node("Skins/Control/PlayerSprite")
	
	name = "DeadBody"+str(victim)
	_label.text = "Oblany student (" + GameManagerSingleton.get_registered_player_value(victim, "username") + ")"
	
	_sprite.texture = victim_sprite.texture
	_sprite.hframes = 5
	_sprite.vframes = 2
	_sprite.frame = 0
	
	_sprite.material = null
	_sprite.modulate = Color(0, 0.275, 1)
	_sprite.rotation = PI/2 - PI/12
	
	global_position = get_parent().get_parent().get_node("Players/"+str(victim)).global_position
	_label.size.x = 600
	_label.position = Vector2(-_label.size.x / 2,-100)
