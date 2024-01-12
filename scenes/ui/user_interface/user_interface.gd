extends CanvasLayer

@onready var grid_container = $GridContainer
@onready var grid_container_2 = $GridContainer2
@onready var filler = $GridContainer/Filler
@onready var fail_label = $GridContainer/FailButton/FailLabel
@onready var sabotage_label = $GridContainer/SabotageButton/SabotageLabel

var task_list_display

var user_sett: UserSettingsManager

var initial_grid_container_scale

var initial_grid_container_2_scale

var initial_task_list_display_scale

# Na początku gry ustawia odpowiedni interface w zależności czy gracz jest imposotrem czy crewmatem, wyłącza wszystkie przyciski poza ustawieniami
func _ready():
	task_list_display = get_parent().get_node("TaskListDisplay")
	
	initial_grid_container_scale = grid_container.scale
	initial_grid_container_2_scale = grid_container_2.scale
	initial_task_list_display_scale = task_list_display.scale
	
	user_sett = UserSettingsManager.load_or_create()
	user_sett.interface_scale_value_changed.connect(on_interface_scale_changed)
	on_interface_scale_changed(user_sett.interface_scale)
	
	# Gracz jest impostorem
	if GameManager.get_current_player_key("is_lecturer"):
		toggle_button_active("VentButton", false)
		toggle_button_active("FailButton", false)
		toggle_button_active("SabotageButton", false)
		
		update_time_left("FailLabel","")
		update_time_left("SabotageLabel","")
	# Gracz jest crewmatem
	else: 
		remove_button("VentButton")
		remove_button("FailButton")
		remove_button("SabotageButton")
		fill_grid(3)
		
	toggle_button_active("ReportButton", false)
	toggle_button_active("InteractButton", false)


func on_interface_scale_changed(value:float):
	grid_container.scale = initial_grid_container_scale * value
	grid_container_2.scale = initial_grid_container_2_scale * value
	task_list_display.scale = initial_task_list_display_scale * value


# Obsługuje naciśnięcie przycisku do reportowania
func _on_report_button_button_down():
	GameManager.execute_action("report")


# Obsługuje naciśnięcie przycisku interakcji
func _on_interact_button_button_down():
	GameManager.execute_action("interact")


# Obsługuje naciśnięcie przycisku do ventowania
func _on_vent_button_button_down():
	GameManager.execute_action("use_vent")


# Obsługuje naciśnięcie przycisku do oblewania
func _on_fail_button_button_down():
	GameManager.execute_action("fail")


# Obsługuje naciśnięcie przycisku sabotażu
func _on_sabotage_button_button_down():
	GameManager.execute_action("sabotage")


# Obsługuje naciśnięcie przycisku do otwierania menu pauzy
func _on_pause_button_button_down():
	GameManager.execute_action("pause_menu")


# Aktywuje i deaktywuje przycisk o danej nazwie
func toggle_button_active(button_name:String, is_active:bool):
	var button : TextureButton = get_node("GridContainer").get_node(button_name)
	if button != null:
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
## Przełącza widoczność interfejsu
func toggle_visiblity(is_visible:bool):
	visible = is_visible


## Aktualizuje zawartość etykiety
func update_time_left(label_name: String , value:String):
	if label_name == fail_label.name:
		fail_label.text = value
	elif label_name == sabotage_label.name:
		sabotage_label.text = value
