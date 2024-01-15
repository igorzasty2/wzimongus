## Klasa odpowiedzialna za wyświetlenie wiadomości po wyrzuceniu gracza.
class_name EjectionMessage
extends Control

## Czas do następnej rundy
@export var next_round_time = 5

## Referencja do wiadomości, która wyświetla się po wyrzuceniu gracza
@onready var _ejection_message = %EjectionMessage

## Referencja do najczęściej głosowanego gracza
var _most_voted_player = GameManagerSingleton.get_current_game_value("most_voted_player")
## Timer do następnej rundy
var _next_round_timer = Timer.new()


func _ready():
	GameManagerSingleton.teleport_players()

	if _most_voted_player == null:
		_ejection_message.text = "[center]Nikt nie został usunięty z grupy[/center]"
	elif _most_voted_player["is_lecturer"]:
		_ejection_message.text = "[center]" + _most_voted_player['username'] + " był wykładowcą[/center]"
	else:
		_ejection_message.text = "[center]" + _most_voted_player['username'] + " nie był wykładowcą[/center]"

	add_child(_next_round_timer)
	_next_round_timer.autostart = true
	_next_round_timer.one_shot = true
	_next_round_timer.connect("timeout", _on_next_round_timer_timeout)
	_next_round_timer.start(next_round_time)


func _on_next_round_timer_timeout():
	self.queue_free()
	GameManagerSingleton.new_round()
