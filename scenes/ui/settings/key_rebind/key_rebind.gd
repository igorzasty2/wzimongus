extends Control

@onready var action = $HBoxContainer/Action
@onready var left_button = $HBoxContainer/LeftButton
@onready var right_button = $HBoxContainer/RightButton

@export var action_label_name : String = "action name"
@export var action_project_name : String

# saving here
@export var primary_button : String = "-"
@export var secondary_button : String = "-"

const LISTENING : String = "Słuchanie..."
enum Side {LEFT, RIGHT}

var pressed_button

func _ready():
	set_process_unhandled_key_input(false)
	# setting label names
	action.text = action_label_name
	# setting initial key names
	set_button_name(Side.LEFT)
	set_button_name(Side.RIGHT)

# sets text inside button
func set_button_name(button):
	if InputMap.has_action(action_project_name) == true:
		var input_actions = InputMap.action_get_events(action_project_name)
		# setting left button key name
		if button == Side.LEFT && input_actions.size()>0:
			left_button.text = OS.get_keycode_string(input_actions[0].physical_keycode)
		#setting right button key name
		if button == Side.RIGHT && input_actions.size()>1:
			right_button.text = OS.get_keycode_string(input_actions[1].physical_keycode)
		elif button == Side.RIGHT:
			clear_button_name(Side.RIGHT)

# clears text inside button
func clear_button_name(button):
	if button == Side.LEFT:
		left_button.text = ""
	else:
		right_button.text = ""

# handles left button pressed
func _on_left_button_pressed():
	# prevents buggy button
	left_button.release_focus()
	pressed_button = Side.LEFT
	left_button.text = LISTENING
	if right_button.text == LISTENING:
		set_button_name(Side.RIGHT)
	set_process_unhandled_key_input(true)

# handles right button pressed
func _on_right_button_pressed():
	# prevents buggy button
	right_button.release_focus()
	pressed_button = Side.RIGHT
	right_button.text = LISTENING
	if left_button.text == LISTENING:
		set_button_name(Side.LEFT)
	set_process_unhandled_key_input(true)

# handles keyboard input
func _unhandled_key_input(event):
	rebind_key(event, pressed_button)
	set_process_unhandled_key_input(false)

# rebinds action key
func rebind_key(event, button):
	if InputMap.has_action(action_project_name):
		var input_actions = InputMap.action_get_events(action_project_name)
		var event_key : String = OS.get_keycode_string(event.physical_keycode)
		var amount = input_actions.size()
		var primary_event : InputEvent = input_actions[0]
		var primary_event_key : String = OS.get_keycode_string(primary_event.physical_keycode)
		var secondary_event : InputEvent = null
		var secondary_event_key : String = ""
		var check = true
		if amount > 1:
			secondary_event = input_actions[1]
			secondary_event_key = OS.get_keycode_string(secondary_event.physical_keycode)

		if button == Side.LEFT:
			if event_key == secondary_event_key:
				InputMap.action_erase_event(action_project_name, primary_event)
				clear_button_name(Side.RIGHT)
			else:
				InputMap.action_erase_events(action_project_name)
				InputMap.action_add_event(action_project_name, event)
				if secondary_event != null:
					InputMap.action_add_event(action_project_name, secondary_event)

		if button == Side.RIGHT:
			if event_key == primary_event_key:
				clear_button_name(button)
				check = false
			if secondary_event == null:
				InputMap.action_add_event(action_project_name, event)
			elif event_key != primary_event_key:
				InputMap.action_erase_event(action_project_name, secondary_event)
				InputMap.action_add_event(action_project_name, event)

		if check == true:
			set_button_name(button)

func _on_hidden():
	if left_button.text == LISTENING:
		set_button_name(Side.LEFT)
	if right_button.text == LISTENING:
		set_button_name(Side.RIGHT)
	set_process_unhandled_key_input(false)
