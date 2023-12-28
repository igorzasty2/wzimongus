extends Control

@onready var action = $HBoxContainer/Action
@onready var left_button = $HBoxContainer/LeftButton
@onready var right_button = $HBoxContainer/RightButton

@export var action_label_name : String = "action name"
@export var action_project_name : String

enum Side {LEFT, RIGHT}

var pressed_button

signal rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button)

var user_sett: UserSettingsManager

var saved_event : InputEventKey

func _ready():
	# Wczytuje zapisane ustawienia
	user_sett = UserSettingsManager.load_or_create()
	
	InputMap.action_erase_events(action_project_name)
	if user_sett.controls_dictionary[action_project_name][0] != null:
		saved_event = InputEventKey.new()
		saved_event.physical_keycode = user_sett.controls_dictionary[action_project_name][0]
		InputMap.action_add_event(action_project_name, saved_event)
	if user_sett.controls_dictionary[action_project_name][1] != null:
		saved_event = InputEventKey.new()
		saved_event.physical_keycode = user_sett.controls_dictionary[action_project_name][1]
		InputMap.action_add_event(action_project_name, saved_event)
	var xx : InputEventKey = InputMap.action_get_events("ui_accept")[0] as InputEventKey

	# Ustawia nazwy etykiet
	action.text = action_label_name
	
	# Ustawia nazwy przycisków
	set_buttons_names()

# Ustawia tekst w przyciskach
func set_buttons_names():
	if InputMap.has_action(action_project_name) == true:
		var input_actions = InputMap.action_get_events(action_project_name)
		if input_actions.size() > 0:
			left_button.text = OS.get_keycode_string(input_actions[0].physical_keycode)
		else:
			left_button.text = ""
		if input_actions.size() > 1:
			right_button.text = OS.get_keycode_string(input_actions[1].physical_keycode)
		else:
			right_button.text = ""

# Obsługuje wciśnięcie lewego przycisku
func _on_left_button_pressed():
	left_button.release_focus()
	pressed_button = Side.LEFT
	emit_signal("rebind_button_pressed",action_label_name, action_project_name, Side.LEFT, left_button, right_button)

# Obsługuje wciśnięcie prawego przycisku
func _on_right_button_pressed():
	right_button.release_focus()
	pressed_button = Side.RIGHT
	emit_signal("rebind_button_pressed",action_label_name, action_project_name, Side.RIGHT, left_button, right_button)
