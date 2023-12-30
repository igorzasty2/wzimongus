extends Node2D

@export
var sprite: Texture2D
@export
var minigame: PackedScene

signal character_entered(character, minigame)
signal character_exited(character)

# Called when the node enters the scene tree for the first time.
func _ready():
	if sprite != null:
		$Sprite2D.texture = sprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	character_entered.emit(body, minigame)


func _on_area_2d_body_exited(body):
	character_exited.emit(body)
