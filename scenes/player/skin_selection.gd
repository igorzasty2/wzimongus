extends Node2D

func _ready():
	skin_change()
	
func skin_change():	
	var skin: Image	
	var foto: ImageTexture
	match GameManager.get_registered_player_key(get_parent().name.to_int(),"skin"):
		0:
			skin = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		1:
			skin = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")
	# Poniższe do uzupełnienia!!!!
		2:
			skin = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		3:
			skin = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")
		4:
			skin = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		5:
			skin = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")
		6:
			skin = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		7:
			skin = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")
		8:
			skin = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		9:
			skin = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")

	foto = ImageTexture.create_from_image(skin)
	$AltSprite.texture = foto
