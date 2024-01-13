class_name EjectionMessage
extends Control

## Referencja do wiadomości, która wyświetla się po wyrzuceniu gracza
@onready var ejection_message = get_node("%EjectionMessage")
## Referencja do głosów przechowywanych w GameManager
@onready var votes = GameManagerSingleton.get_current_game_key("votes")

## Czas do następnej rundy
@export var NEXT_ROUND_TIME = 5
## Timer do następnej rundy
@onready var next_round_timer = Timer.new()

## Referencja do najczęściej głosowanego gracza
@onready var most_voted_player = GameManagerSingleton.get_current_game_key("most_voted_player")

func _ready():
	GameManagerSingleton.teleport_players()
	
	if  most_voted_player == null:
		ejection_message.text = "[center]Nikt nie został usunięty z grupy[/center]"
	elif most_voted_player["is_lecturer"]:
		ejection_message.text = "[center]" + most_voted_player['username'] + " został usunięty z grupy[/center]"
	else:
		ejection_message.text = "[center]" + most_voted_player['username'] + " nie był wykładowcą[/center]"

	add_child(next_round_timer)
	next_round_timer.autostart = true
	next_round_timer.one_shot = true
	next_round_timer.connect("timeout", _on_next_round_timer_timeout)
	next_round_timer.start(NEXT_ROUND_TIME)


func _on_next_round_timer_timeout():
	self.queue_free()
	GameManagerSingleton.new_round()
