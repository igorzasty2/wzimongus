## Skrypt wyboru skórki
extends Node2D

## Referencja do sprite'a postaci.
@onready var player_sprite = $Control/PlayerSprite


func _ready():
	_update_skin(GameManager.get_registered_player_key(get_parent().name.to_int(), "skin"))

	GameManager.skin_changed.connect(_on_skin_changed)


func _exit_tree():
	GameManager.skin_changed.disconnect(_on_skin_changed)


func _on_skin_changed(id: int, skin: int):
	if id == get_parent().name.to_int():
		_update_skin(skin)


func _update_skin(skin: int):
	match skin:
		0:
			player_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		1:
			player_sprite.texture = load("res://scenes/player/assets/skins/barbie_spritesheet.png")
		2:
			player_sprite.texture = load("res://scenes/player/assets/skins/ecoswir_spritesheet.png")
		3:
			player_sprite.texture = load("res://scenes/player/assets/skins/femboy_spritesheet.png")
		4:
			player_sprite.texture = load("res://scenes/player/assets/skins/gamer_spritesheet.png")
		5:
			player_sprite.texture = load("res://scenes/player/assets/skins/gymbro_spritesheet.png")
		6:
			player_sprite.texture = load("res://scenes/player/assets/skins/hipster_spritesheet.png")
		7:
			player_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
		8:
			player_sprite.texture = load("res://scenes/player/assets/skins/punk_spritesheet.png")
		9:
			player_sprite.texture = load("res://scenes/player/assets/skins/rasta_spritesheet.png")
		10:
			player_sprite.texture = load("res://scenes/player/assets/skins/tiktoker_spritesheet.png")
		11:
			player_sprite.texture = load("res://scenes/player/assets/skins/wixiarz_spritesheet.png")
