extends Control

@onready var username = get_node("%Username")



func init(nickname: String):
	username.text = nickname
	
