extends Node2D


@onready var alt_sprite = $AltSprite


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
			alt_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		1:
			alt_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
	# Poniższe do uzupełnienia!!!!
		2:
			alt_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		3:
			alt_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
		4:
			alt_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		5:
			alt_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
		6:
			alt_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		7:
			alt_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
		8:
			alt_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		9:
			alt_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
		10:
			alt_sprite.texture = load("res://scenes/player/assets/skins/alt_spritesheet.png")
		11:
			alt_sprite.texture = load("res://scenes/player/assets/skins/nerd_spritesheet.png")
