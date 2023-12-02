extends HBoxContainer

@onready var username = get_node("%Username")
@onready var message = get_node("%Message")

func init(usernameText: String, messageText: String, color: Color):

	username.text = "[color=#" + color.to_html(false) + "]" + usernameText + "[/color]"
	message.text = messageText

