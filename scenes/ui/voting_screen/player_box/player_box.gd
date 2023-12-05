extends Control

@onready var username = get_node("%Username")
@onready var decision = get_node("%Decision")
@onready var voted_by_container = get_node("%VotedBy")

signal player_voted

var player_key

var voted_by_scene = preload("res://scenes/ui/voting_screen/voted_by/voted_by.tscn")

func init(username: String, player_key: int, voted_by):
	self.username.text = username
	self.player_key = player_key

	for vote in voted_by:
		var voted_by_instance = voted_by_scene.instantiate()
		voted_by_container.add_child(voted_by_instance)
		

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
