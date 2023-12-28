extends CanvasLayer

@onready var crewmate_interface = $CrewmateInterface
@onready var lecturer_interface = $LecturerInterface

# Na początku gry ustawia odpowiedni interface w zależności czy gracz jest imposotrem czy crewmatem, wyłącza wszystkie przyciski poza ustawieniami
func _ready():
	# Gracz jest impostorem
	if GameManager.get_current_player_key("is_lecturer"):
		crewmate_interface.visible = false
		lecturer_interface.visible = true
		
		toggle_button_active("VentButton", false)
		toggle_button_active("FailButton", false)
		toggle_button_active("SabotageButton", false)
		toggle_button_active("ReportButton", false)
		toggle_button_active("InteractButton", false)
	# Gracz jest crewmatem
	else: 
		crewmate_interface.visible = true
		lecturer_interface.visible = false
		
		toggle_button_active("ReportButton", false)
		toggle_button_active("InteractButton", false)


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


# Aktywuje i deaktywuje dany przycisk interakcji
func toggle_button_active(button_name:String, is_active:bool):
	var button : TextureButton
	if GameManager.get_current_player_key("is_lecturer") == true:
		button = get_node("LecturerInterface").get_node("GridContainer").get_node(button_name)
	else:
		button = get_node("CrewmateInterface").get_node("GridContainer").get_node(button_name)
	
	button.disabled = !is_active
	toggle_button_visual(button, is_active)


# Zmienia wygląd przycisku
func toggle_button_visual(button:TextureButton, is_on:bool):
	if is_on:
		button.modulate = Color8(255, 255, 255, 255)
	else:
		button.modulate = Color8(130, 130, 130, 100)
