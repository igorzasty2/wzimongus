extends Node2D

@onready var node = $"."
@onready var sprite = $DeadBodySprite
@onready var label = $DeadBodyLabel

func set_dead_player(victim: int) -> void:
	var victim_node = get_tree().root.get_node("Game/Maps/MainMap/Players/"+str(victim))
	var victim_sprite = victim_node.get_node("Skins/PlayerSprite")
	sprite.texture = victim_sprite.texture
	sprite.hframes = 5
	sprite.vframes = 2
	sprite.frame = 0
	
	sprite.material = null
	sprite.modulate = Color(0, 0.275, 1)
	sprite.rotation = PI/2 - PI/12
	
	node.global_position = get_parent().get_parent().get_node("Players/"+str(victim)).global_position
	label.size.x = 600
	label.position = Vector2(-label.size.x / 2,-100)
