extends HBoxContainer


@onready var avatar = get_node("%Avatar")
@onready var username = get_node("%Username")
@onready var message = get_node("%Message")


func init(usernameText: String, messageText: String, color: Color):
	var texture = AtlasTexture.new()
	texture.atlas = load("res://scenes/player/assets/skins/alt_spritesheet.png")
	texture.region = Rect2(127.5, 0, 420, 420)
	avatar.texture = texture

	username.text = "[color=#" + color.to_html(false) + "]" + usernameText + "[/color]"
	message.text = messageText
