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
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		1:
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")
	# Poniższe do uzupełnienia!!!!
		2:
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		3:
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")
		4:
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		5:
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")
		6:
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		7:
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")
		8:
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		9:
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")
		10:
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		11:
			skin_image = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")

	alt_sprite.texture = ImageTexture.create_from_image(skin_image)
