extends Control

@onready var username = get_node("%Username")
@onready var decision = get_node("%Decision")
@onready var voted_by_container = get_node("%VotedBy")

signal player_voted
signal player_selected

var player_key
var display_tween

var voted_by_scene = preload("res://scenes/ui/voting_screen/voted_by/voted_by.tscn")


func init(username: String, player_key: int, voted_by):
	self.username.text = username
	self.player_key = player_key

	for vote in voted_by:
		var voted_by_instance = voted_by_scene.instantiate()
		voted_by_instance.modulate.a = 0;
		display_tween = get_tree().create_tween()
		display_tween.tween_property(voted_by_instance, "modulate:a", 1, 0.25)
		
		voted_by_container.add_child(voted_by_instance)

	if GameManager.get_current_player_key("died"):
		self.disconnect("player_voted", _on_button_pressed)


func _on_button_pressed():
	if GameManager.get_current_game_key("is_voted") || GameManager.get_current_game_key("is_vote_preselected"):
		return
	
	if decision.visible:
		decision.visible = false
		GameManager.set_current_game_key("is_vote_preselected", false)
		return
	
	decision.visible = true
	GameManager.set_current_game_key("is_vote_preselected", true)


func _on_decision_no_pressed():
	decision.visible = false
	GameManager.set_current_game_key("is_vote_preselected", false)


func _on_decision_yes_pressed():
	decision.visible = false
	emit_signal("player_voted", player_key)
