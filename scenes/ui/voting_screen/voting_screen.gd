extends Control

@onready var players = get_node("%Players")
@onready var end_vote_text = get_node("%EndVoteText")
@onready var skip_decision = get_node("%Decision")
@onready var skip_button = get_node("%SkipButton")

@export var VOTING_TIME = 60
@onready var voting_timer = Timer.new()

@export var EJECT_PLAYER_TIME = 5
@onready var eject_player_timer = Timer.new()

var player_box = preload("res://scenes/ui/voting_screen/player_box/player_box.tscn")

var time = 0
var secs

func _ready():
	_render_player_boxes()

	#End voting timer
	add_child(voting_timer)
	voting_timer.autostart = true
	voting_timer.one_shot = true
	voting_timer.connect("timeout", _on_end_voting_timer_timeout)
	voting_timer.start(VOTING_TIME)

	#Eject player timer
	add_child(eject_player_timer)
	eject_player_timer.connect("timeout", _on_eject_player_timer_timeout)


func _process(delta):
	if time < VOTING_TIME:
		time += delta
		secs = VOTING_TIME - fmod(time, VOTING_TIME)
		var time_passed = "%02d" % (secs)
		end_vote_text.text = "Voting ends in " + time_passed + " seconds"


func _on_player_voted(voted_player_key):
	skip_button.disabled = true
	GameManager.set_player_key("voted", true)
	add_player_vote.rpc(voted_player_key, multiplayer.get_unique_id())


@rpc("call_local", "any_peer")
func add_player_vote(player_key, voted_by):
	GameManager.add_vote(player_key, voted_by)


func _on_skip_button_pressed():

	if GameManager.get_current_player_key("voted_for"):
		return

	skip_decision.visible = true


func _on_decision_yes_pressed():
	GameManager.set_player_key("voted", true)
	skip_decision.visible = false


func _on_decision_no_pressed():
	skip_decision.visible = false



func _render_player_boxes():

	var registered_players = GameManager.get_registered_players()

	var votes = GameManager.get_votes()

	for key in registered_players.keys():
		var new_player_box = player_box.instantiate()
		players.add_child(new_player_box)

		var player_votes = votes[key] if key in votes else []
		new_player_box.init(registered_players[key].username, key, player_votes)
		new_player_box.connect("player_voted", _on_player_voted)


func _on_end_voting_timer_timeout():
	if GameManager.get_current_player_key("voted"):
		GameManager.set_player_key("voted_for", true)

	end_vote_text.text = "Voting has ended"

	for child in players.get_children():
		child.queue_free()
		
	_render_player_boxes()

	eject_player_timer.start(EJECT_PLAYER_TIME)


func _on_eject_player_timer_timeout():
	_change_scene_to_ejection_screen.rpc()

@rpc("call_local", "any_peer")
func _change_scene_to_ejection_screen():
	get_tree().change_scene_to_file("res://scenes/ui/ejection_screen/ejection_screen.tscn")
	self.queue_free()
