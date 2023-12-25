extends Control

@onready var ejection_message = get_node("%EjectionMessage")
@onready var votes = GameManager.get_votes()

@export var NEXT_ROUND_TIME = 5
@onready var next_round_timer = Timer.new()


func _ready():
	if multiplayer.is_server():
		var most_voted_player_id = get_most_voted_player_id()

		if most_voted_player_id != null:
			GameManager.set_most_voted_player.rpc(GameManager.get_registered_players()[most_voted_player_id])
		update_ejection_message.rpc()

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

@rpc("call_local", "authority", "reliable")
func update_ejection_message():
	var most_voted_player = GameManager.get_current_game_key("most_voted_player")

	if  most_voted_player == null:
		ejection_message.text = "[center]No one was ejected.[/center]"
	elif most_voted_player["is_lecturer"]:
		#TODO: GameManager.set_registered_player_key(player_id, 'alive', false)
		ejection_message.text = "[center]" + most_voted_player['username'] + " was ejected.[/center]"
	else:
		#TODO: GameManager.set_registered_player_key(player_id, 'alive', false)
		ejection_message.text = "[center]" + most_voted_player['username'] + " was not an impostor.[/center]"


func _on_next_round_timer_timeout():
	self.queue_free()
	self.get_parent().get_node("%Button").show()

	GameManager.next_round()

