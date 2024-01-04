extends Control

@onready var ejection_message = get_node("%EjectionMessage")
@onready var votes = GameManager.get_current_game_key("votes")

@export var NEXT_ROUND_TIME = 5
@onready var next_round_timer = Timer.new()

@onready var most_voted_player = GameManager.get_current_game_key("most_voted_player")


func _ready():
	if  most_voted_player == null:
		ejection_message.text = "[center]Nikt nie został wyrzucony.[/center]"
	elif most_voted_player["is_lecturer"]:
		ejection_message.text = "[center]" + most_voted_player['username'] + " został wyrzucony.[/center]"
	else:
		ejection_message.text = "[center]" + most_voted_player['username'] + " nie był wykładowcą.[/center]"

	#NEXT ROUND TIMER
	add_child(next_round_timer)
	next_round_timer.autostart = true
	next_round_timer.one_shot = true
	next_round_timer.connect("timeout", _on_next_round_timer_timeout)
	next_round_timer.start(NEXT_ROUND_TIME)


#Następna runda
func _on_next_round_timer_timeout():
	self.queue_free()
#	self.get_parent().get_node("%Button").show()

	GameManager.next_round()
