extends Control

@onready var ejection_message = get_node("%EjectionMessage")
@onready var votes = GameManager.get_votes()

func _ready():
	var vote_count = _count_votes()
	var max_votes = 0
	var max_vote = ""
	var is_tie = false

	for vote in vote_count:
		if vote_count[vote] > max_votes:
			max_votes = vote_count[vote]
			max_vote = vote
			is_tie = false
		elif vote_count[vote] == max_votes:
			is_tie = true

	if is_tie:
		max_vote = ""
	
	if str(max_vote) == "":
		ejection_message.text = "No one was ejected."
	elif(GameManager.get_registered_player_key(max_vote, 'impostor')):
		ejection_message.text = GameManager.get_registered_player_key(max_vote, 'username') + " was ejected."
	else:
		ejection_message.text = GameManager.get_registered_player_key(max_vote, 'username') + " was not an impostor."
		

func _count_votes():
	var vote_count = {}
	for vote in votes:
		if vote in vote_count:
			vote_count[vote] += 1
		else:
			vote_count[vote] = 1
	return vote_count
