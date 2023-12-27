extends Control

@onready var ejection_message = get_node("%EjectionMessage")
@onready var votes = GameManager.get_votes()

@export var NEXT_ROUND_TIME = 5
@onready var next_round_timer = Timer.new()

signal most_voted_player_set


func _ready():
	#Serwer oblicza wyniki głosowania i aktualizuje wiadomość o wydaleniu gracza
	if multiplayer.is_server():
		var most_voted_player_id = get_most_voted_player_id()

		if most_voted_player_id != null:
			update_ejection_message.rpc(GameManager.get_registered_players()[most_voted_player_id])
		else:
			update_ejection_message.rpc(null)

	#NEXT ROUND TIMER
	add_child(next_round_timer)
	next_round_timer.autostart = true
	next_round_timer.one_shot = true
	next_round_timer.connect("timeout", _on_next_round_timer_timeout)
	next_round_timer.start(NEXT_ROUND_TIME)

#Zwraca id gracza z największą ilością głosów, jeśli jest remis zwraca null
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

#Aktualizuje wiadomość o wydaleniu gracza
@rpc("call_local", "authority", "reliable")
func update_ejection_message(most_voted_player):
	if  most_voted_player == null:
		ejection_message.text = "[center]No one was ejected.[/center]"
	elif most_voted_player["is_lecturer"]:
		ejection_message.text = "[center]" + most_voted_player['username'] + " was ejected.[/center]"
	else:
		ejection_message.text = "[center]" + most_voted_player['username'] + " was not a lecturer.[/center]"


#Następna runda
func _on_next_round_timer_timeout():
	self.queue_free()
	self.get_parent().get_node("%Button").show()

	GameManager.next_round()
