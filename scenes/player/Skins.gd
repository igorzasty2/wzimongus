extends Node2D

func _ready():
	
	var skin: Image	
	var foto: ImageTexture
	match GameManager.get_current_player_key("skin"):
		0:
			skin = Image.load_from_file("res://scenes/player/assets/skins/alt_spritesheet.png")
		1:
			skin = Image.load_from_file("res://scenes/player/assets/skins/nerd_spritesheet.png")
			
	foto = ImageTexture.create_from_image(skin)
	$AltSprite.texture = foto
