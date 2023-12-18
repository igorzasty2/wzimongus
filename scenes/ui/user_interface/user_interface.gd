extends CanvasLayer

@onready var crewmate_interface = $CrewmateInterface
@onready var impostor_interface = $ImpostorInterface

# Na początku gry ustawia odpowiedni interface w zależności czy gracz jest imposotrem czy crewmatem
func _ready():
	if GameManager._current_player["impostor"]:
		crewmate_interface.visible = false
		impostor_interface.visible = true
	else: 
		crewmate_interface.visible = true
		impostor_interface.visible = false

# Wykonuje podaną akcję
func execute_action(action_name:String):
	var event = InputEventAction.new()
	event.action = action_name
	event.pressed = true
	Input.parse_input_event(event)

# Obsługuje naciśnięcie przycisku do reportowania
func _on_report_button_button_down():
	execute_action("report")
	print("report button pressed")

# Obsługuje naciśnięcie przycisku interakcji
func _on_interact_button_button_down():
	execute_action("interact")
	print("interact button pressed")

# Obsługuje naciśnięcie przycisku do ventowania
func _on_vent_button_button_down():
	execute_action("use_vent")
	print("vent button pressed")

# Obsługuje naciśnięcie przycisku do oblewania
func _on_fail_button_button_down():
	execute_action("fail")
	print("fail button pressed")

# Obsługuje naciśnięcie przycisku sabotażu
func _on_sabotage_button_button_down():
	execute_action("sabotage")
	print("sabotage button pressed")

# Obsługuje naciśnięcie przycisku do otwierania menu pauzy
func _on_pause_button_button_down():
	execute_action("pause_menu")
	print("pause button pressed")
