extends HBoxContainer

@onready var message = get_node("%Message")

func init(text):
	message.text = text

