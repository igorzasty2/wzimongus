class_name Message
extends HBoxContainer

## Referencja do avataru gracza
@onready var avatar = get_node("%Avatar")
## Referencja do nazwy gracza
@onready var username = get_node("%Username")
## Referencja do wiadomości
@onready var message = get_node("%Message")

## Inicjalizacja wiadomości
func init(player: Dictionary, messageText: String, color: Color):
	avatar.texture = _get_skin_texture(player.skin)
	username.text = "[color=#" + color.to_html(false) + "]" + player.username + "[/color]"
	message.text = messageText


func _get_skin_texture(skin_id: int) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = load(GameManagerSingleton.skins[skin_id]["resource"])
	texture.region = Rect2(127.5, 0, 420, 420)
	return texture
