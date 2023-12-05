extends Control

@onready var username = get_node("%Username")
@onready var decision = get_node("%Decision")

signal player_voted

var player_key

func init(username: String, player_key: int):
	self.username.text = username
	self.player_key = player_key

	if GameManager.get_current_player_key("died"):
		self.disconnect("player_voted", _on_button_pressed)
	


func _on_button_pressed():
	if GameManager.get_current_player_key("voted"):
		return

	decision.visible = true



func _on_decision_no_pressed():
	decision.visible = false

func _on_decision_yes_pressed():
	decision.visible = false
	emit_signal("player_voted", player_key)
