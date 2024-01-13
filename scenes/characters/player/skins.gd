## Skrypt wyboru skórki
extends Node2D

## Referencja do sprite'a postaci.
@onready var player_sprite = $Control/PlayerSprite


func _ready():
	_update_skin(GameManagerSingleton.get_registered_player_key(get_parent().name.to_int(), "skin"))

	GameManagerSingleton.skin_changed.connect(_on_skin_changed)


func _exit_tree():
	GameManagerSingleton.skin_changed.disconnect(_on_skin_changed)


func _on_skin_changed(id: int, skin: int):
	if id == get_parent().name.to_int():
		_update_skin(skin)


func _update_skin(skin: int):
	player_sprite.texture = load(GameManagerSingleton.skins[skin]["resource"])
