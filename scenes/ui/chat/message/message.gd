extends HBoxContainer


@onready var avatar = get_node("%Avatar")
@onready var username = get_node("%Username")
@onready var message = get_node("%Message")


func init(player: Dictionary, messageText: String, color: Color):
	avatar.texture = _get_skin_texture(player.skin)
	username.text = "[color=#" + color.to_html(false) + "]" + player.username + "[/color]"
	message.text = messageText


func _get_skin_texture(skin_id: int) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = load(GameManager.skins[skin_id]["resource"])
	texture.region = Rect2(127.5, 0, 420, 420)
	return texture
