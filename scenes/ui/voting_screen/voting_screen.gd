extends Control

@onready var registered_players = GameManager.get_registered_players()

@onready var players = get_node("%Players")
@onready var end_vote_text = get_node("%EndVoteText")
@onready var skip_decision = get_node("%Decision")
@onready var skip_button = get_node("%SkipButton")

var player_box = preload("res://scenes/ui/voting_screen/player_box/player_box.tscn")

var time = 0
var secs

func _ready():
	_render_player_boxes()

func _process(delta):
	if time < 60:

		time += delta

		secs = 60 - fmod(time, 60)

		var time_passed = "%02d" % (secs)

		end_vote_text.text = "Voting ends in " + time_passed + " seconds"


func _on_player_voted(voted_player_key):
	GameManager.set_player_key("voted", true)


func _on_skip_button_pressed():

	if GameManager.get_current_player_key("voted"):
		return

	skip_decision.visible = true


func _on_decision_yes_pressed():
	GameManager.set_player_key("voted", true)
	skip_decision.visible = false


func _on_decision_no_pressed():
	skip_decision.visible = false



func _render_player_boxes():
	for key in registered_players.keys():
		var new_player_box = player_box.instantiate()
		players.add_child(new_player_box)

		new_player_box.init(registered_players[key].username, key)
		new_player_box.connect("player_voted", _on_player_voted)


func _on_end_voting_timer_timeout():
	if GameManager.get_current_player_key("voted"):
		GameManager.set_player_key("voted", true)
		end_vote_text.text = "Voting has ended"

		for child in players.get_children():
			child.queue_free()
		
		_render_player_boxes()
