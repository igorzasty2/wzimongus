## Klasa odpowiedzialna za interfejs użytkownika na głównej mapie.
class_name MainMapUserInterface
extends CanvasLayer

@onready var _grid_container = $GridContainer
@onready var _grid_container_2 = $GridContainer2
@onready var _filler = $GridContainer/Filler
@onready var _fail_label = $GridContainer/FailButton/FailLabel
@onready var _sabotage_label = $GridContainer/SabotageButton/SabotageLabel

var _task_list_display

var _user_sett: UserSettingsManager

var _initial_grid_container_scale

var _initial_grid_container_2_scale

var _initial_task_list_display_scale

# Na początku gry ustawia odpowiedni interface w zależności czy gracz jest imposotrem czy crewmatem, wyłącza wszystkie przyciski poza ustawieniami
func _ready():
	_task_list_display = get_parent().get_node("TaskListDisplay")
	
	_initial_grid_container_scale = _grid_container.scale
	_initial_grid_container_2_scale = _grid_container_2.scale
	_initial_task_list_display_scale = _task_list_display.scale
	
	_user_sett = UserSettingsManager.load_or_create()
	_user_sett.interface_scale_value_changed.connect(_on_interface_scale_changed)
	_on_interface_scale_changed(_user_sett.interface_scale)
	
	# Gracz jest impostorem
	if GameManagerSingleton.get_current_player_value("is_lecturer"):
		toggle_button_active("VentButton", false)
		toggle_button_active("FailButton", false)
		toggle_button_active("SabotageButton", false)
		
		update_time_left("FailLabel","")
		update_time_left("SabotageLabel","")
	# Gracz jest crewmatem
	else: 
		_remove_button("VentButton")
		_remove_button("FailButton")
		_remove_button("SabotageButton")
		_fill_grid(3)
		
	toggle_button_active("ReportButton", false)
	toggle_button_active("InteractButton", false)


func _on_interface_scale_changed(value:float):
	_grid_container.scale = _initial_grid_container_scale * value
	_grid_container_2.scale = _initial_grid_container_2_scale * value
	_task_list_display.scale = _initial_task_list_display_scale * value


## Obsługuje naciśnięcie przycisku do reportowania
func _on_report_button_button_down():
	GameManagerSingleton.execute_action("report")


## Obsługuje naciśnięcie przycisku interakcji
func _on_interact_button_button_down():
	GameManagerSingleton.execute_action("interact")


## Obsługuje naciśnięcie przycisku do ventowania
func _on_vent_button_button_down():
	GameManagerSingleton.execute_action("use_vent")


## Obsługuje naciśnięcie przycisku do oblewania
func _on_fail_button_button_down():
	GameManagerSingleton.execute_action("fail")


## Obsługuje naciśnięcie przycisku sabotażu
func _on_sabotage_button_button_down():
	GameManagerSingleton.execute_action("sabotage")


## Obsługuje naciśnięcie przycisku do otwierania menu pauzy
func _on_pause_button_button_down():
	GameManagerSingleton.execute_action("pause_menu")


## Aktywuje i deaktywuje przycisk o danej nazwie
func toggle_button_active(button_name:String, is_active:bool):
	var button : TextureButton = get_node("GridContainer").get_node(button_name)
	if button != null:
		button.disabled = !is_active
		_toggle_button_visual(button, is_active)


## Zmienia wygląd przycisku
func _toggle_button_visual(button:TextureButton, is_on:bool):
	if is_on:
		button.modulate = Color8(255, 255, 255, 255)
	else:
		button.modulate = Color8(130, 130, 130, 100)


## Usuwa przycik o danej nazwie
func _remove_button(button_name:String):
	var button : TextureButton = get_node("GridContainer").get_node(button_name)
	button.queue_free()


## Napełnia siatkę daną ilością zapełniaczy
func _fill_grid(amount:int):
	for i in range(0, amount):
		var filler_duplicate = _filler.duplicate()
		_grid_container.add_child(filler_duplicate)
		_grid_container.move_child(filler_duplicate, 0)


## Aktualizuje zawartość etykiety
func update_time_left(label_name: String , value:String):
	if label_name == _fail_label.name:
		_fail_label.text = value
	elif label_name == _sabotage_label.name:
		_sabotage_label.text = value
