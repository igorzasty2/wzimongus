extends Control

@onready var players = get_node("%Players")
@onready var registered_players = GameManager.get_registered_players()

var player_box = preload("res://scenes/ui/voting_screen/player_box/player_box.tscn")

func _ready():
	for i in registered_players.keys():
		var new_player_box = player_box.instantiate()
		players.add_child(new_player_box)

		new_player_box.init(registered_players[i].username)




func _on_end_vote_timer_timeout():
	pass # Replace with function body.
