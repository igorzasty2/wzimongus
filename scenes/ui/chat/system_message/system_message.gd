extends HBoxContainer

@onready var message = get_node("%Message")


func _ready():
	pass # Replace with function body.

func init(text):
	message.text = text

