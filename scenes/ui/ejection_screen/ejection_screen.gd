extends Control

@onready var ejection_message = get_node("%EjectionMessage")
@onready var votes = GameManager.get_votes()

@export var NEXT_ROUND_TIME = 5
@onready var next_round_timer = Timer.new()


func _ready():
	var most_voted_player_id = get_most_voted_player_id()
	var message = get_ejection_message(most_voted_player_id)
	ejection_message.text = message

	#NEXT ROUND TIMER
	add_child(next_round_timer)
	next_round_timer.autostart = true
	next_round_timer.one_shot = true
	next_round_timer.connect("timeout", _on_next_round_timer_timeout)
	next_round_timer.start(NEXT_ROUND_TIME)

	
func get_most_voted_player_id():
	var most_voted_players = []
	var max_vote = 0

	for vote_key in votes.keys():
		var votes_count = votes[vote_key].size()
		if votes_count > max_vote:
			max_vote = votes_count
			most_voted_players = [vote_key]
		elif votes_count == max_vote:
			most_voted_players.append(vote_key)

	if most_voted_players.size() > 1 || most_voted_players.size() == 0:
		return null
	else:
		return most_voted_players[0]


func get_ejection_message(player_id):
	if player_id == null:
		return "[center]No one was ejected.[/center]"
	elif GameManager.get_registered_player_key(player_id, 'impostor'):
		#TODO: GameManager.set_registered_player_key(player_id, 'alive', false)
		return "[center]" + GameManager.get_registered_player_key(player_id, 'username') + " was ejected.[/center]"
	else:
		#TODO: GameManager.set_registered_player_key(player_id, 'alive', false)
		return "[center]" + GameManager.get_registered_player_key(player_id, 'username') + " was not an impostor.[/center]"


func _on_next_round_timer_timeout():
	self.queue_free()
	GameManager.set_input_status(true)
	GameManager.set_pause_status(false)
	self.get_parent().get_node("%report_button").show()
	GameManager.set_player_key("voted", false)

	#! Nie powinno usuwać tutaj, tylko w GameManagerze, podczas inicjalizacji następnej rundy
	GameManager._votes = {}

