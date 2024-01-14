## Klasa wiadomości czatu.
class_name ChatMessage
extends HBoxContainer

## Referencja do avataru gracza
@onready var _avatar = get_node("%Avatar")
## Referencja do nazwy gracza
@onready var _username = get_node("%Username")
## Referencja do wiadomości
@onready var _message = get_node("%Message")

## Inicjalizacja wiadomości.
func init(player: Dictionary, messageText: String, color: Color):
	_avatar.texture = _get_skin_texture(player.skin)
	_username.text = "[color=#" + color.to_html(false) + "]" + player.username + "[/color]"
	_message.text = messageText


func _get_skin_texture(skin_id: int) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = load(GameManagerSingleton.SKINS[skin_id]["resource"])
	texture.region = Rect2(127.5, 0, 420, 420)
	return texture
