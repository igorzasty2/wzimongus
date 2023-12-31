extends Node2D


@onready var player_sprite = $PlayerSprite


func _ready():
	_update_skin(GameManager.get_registered_player_key(get_parent().name.to_int(), "skin"))

	GameManager.skin_changed.connect(_on_skin_changed)


func _exit_tree():
	GameManager.skin_changed.disconnect(_on_skin_changed)


func _on_skin_changed(id: int, skin: int):
	if id == get_parent().name.to_int():
		_update_skin(skin)


func _update_skin(skin: int):
	var skin_image: Image

	match skin:
		0:
			player_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		1:
			player_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
	# Poniższe do uzupełnienia!!!!
		2:
			player_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		3:
			player_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
		4:
			player_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		5:
			player_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
		6:
			player_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		7:
			player_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
		8:
			player_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		9:
			player_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
		10:
			player_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		11:
			player_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
