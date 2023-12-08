extends Control

@onready var ejection_message = get_node("%EjectionMessage")
@onready var votes = GameManager.get_votes()

func _ready():
	var most_voted_player_id
	var max_vote = 0
	var prev_max_vote = 0
	var is_tie = false

	for vote_key in votes.keys():
		var votes_count = votes[vote_key].size()
		if votes_count > max_vote:
			max_vote = votes_count
			most_voted_player_id = vote_key
			is_tie = false
		elif votes_count == max_vote and votes_count != prev_max_vote:
			is_tie = true

		prev_max_vote = votes_count


	if is_tie:
		most_voted_player_id = ""
	
	if str(max_vote) == "":
		ejection_message.text = "No one was ejected."
	elif(GameManager.get_registered_player_key(most_voted_player_id, 'impostor')):
		ejection_message.text = GameManager.get_registered_player_key(most_voted_player_id, 'username') + " was ejected."
	else:
		ejection_message.text = GameManager.get_registered_player_key(most_voted_player_id, 'username') + " was not an impostor."
		

