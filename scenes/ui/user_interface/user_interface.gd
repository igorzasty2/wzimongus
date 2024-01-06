extends CanvasLayer

@onready var grid_container = $GridContainer
@onready var filler = $GridContainer/Filler


# Na początku gry ustawia odpowiedni interface w zależności czy gracz jest imposotrem czy crewmatem, wyłącza wszystkie przyciski poza ustawieniami
func _ready():
	# Gracz jest impostorem
	if GameManager.get_current_player_key("is_lecturer"):
		toggle_button_active("VentButton", false)
		toggle_button_active("FailButton", false)
		toggle_button_active("SabotageButton", false)
		toggle_button_active("ReportButton", false)
		toggle_button_active("InteractButton", false)
	# Gracz jest crewmatem
	else: 
		remove_button("VentButton")
		remove_button("FailButton")
		remove_button("SabotageButton")
		fill_grid(3)
		
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


# Obsługuje naciśnięcie przycisku interakcji
func _on_interact_button_button_down():
	execute_action("interact")


# Obsługuje naciśnięcie przycisku do ventowania
func _on_vent_button_button_down():
	execute_action("use_vent")


# Obsługuje naciśnięcie przycisku do oblewania
func _on_fail_button_button_down():
	execute_action("fail")


# Obsługuje naciśnięcie przycisku sabotażu
func _on_sabotage_button_button_down():
	execute_action("sabotage")


# Obsługuje naciśnięcie przycisku do otwierania menu pauzy
func _on_pause_button_button_down():
	execute_action("pause_menu")


# Aktywuje i deaktywuje przycisk o danej nazwie
func toggle_button_active(button_name:String, is_active:bool):
	var button : TextureButton = get_node("GridContainer").get_node(button_name)
	
	button.disabled = !is_active
	toggle_button_visual(button, is_active)


# Zmienia wygląd przycisku
func toggle_button_visual(button:TextureButton, is_on:bool):
	if is_on:
		button.modulate = Color8(255, 255, 255, 255)
	else:
		button.modulate = Color8(130, 130, 130, 100)


# Zmienia wioczność przycisku o danej nazwie
func remove_button(button_name:String):
	var button : TextureButton = get_node("GridContainer").get_node(button_name)
	button.queue_free()


# Napełnia siatkę daną ilością zapełniaczy
func fill_grid(amount:int):
	for i in range(0, amount):
		var filler_duplicate = filler.duplicate()
		grid_container.add_child(filler_duplicate)
		grid_container.move_child(filler_duplicate, 0)


@rpc("call_local", "any_peer")
## Przełącza widoczność przycisków na dole
func bottom_buttons_toggle_visiblity(is_visible:bool):
	$GridContainer.visible = is_visible
