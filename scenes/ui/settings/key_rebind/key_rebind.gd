## Klasa obsługująca przypisanie przycisków do akcji.
class_name SettingsKeyRebind
extends Control

## Etykieta z nazwą akcji.
@onready var _action = $HBoxContainer/Action
## Lewy przycisk przypisania.
@onready var _left_button = $HBoxContainer/LeftButton
## Prawy przycisk przypisania.
@onready var _right_button = $HBoxContainer/RightButton

## Nazwa akcji dla etykiety.
@export var action_label_name: String = "_action name"
## Nazwa akcji w ustawieniach projektu.
@export var action_project_name: String

## Strona przycisku.
enum _Side { LEFT, RIGHT }

## Wciśnięty przycisk.
var _pressed_button

## Emitowany po naciśnięciu przycisku.
signal rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button)

## Ustawienia użytkownika.
var _user_sett: UserSettingsManager

## Zapisany event.
var _saved_event: InputEventKey


func _ready():
	start()


## Obsługuje przypisanie przycisków i ustawienie nazw etykiet i nazw przycisków.
func start():
	# Wczytuje zapisane ustawienia.
	_user_sett = UserSettingsManager.load_or_create()

	InputMap.action_erase_events(action_project_name)
	if _user_sett.controls_dictionary[action_project_name][0] != null:
		_saved_event = InputEventKey.new()
		_saved_event.physical_keycode = _user_sett.controls_dictionary[action_project_name][0]
		InputMap.action_add_event(action_project_name, _saved_event)
	if _user_sett.controls_dictionary[action_project_name][1] != null:
		_saved_event = InputEventKey.new()
		_saved_event.physical_keycode = _user_sett.controls_dictionary[action_project_name][1]
		InputMap.action_add_event(action_project_name, _saved_event)

	# Ustawia nazwy etykiet.
	_action.text = action_label_name

	# Ustawia nazwy przycisków.
	_set_buttons_names()


## Ustawia tekst w przyciskach.
func _set_buttons_names():
	if InputMap.has_action(action_project_name) == true:
		var input_actions = InputMap.action_get_events(action_project_name)
		if input_actions.size() > 0:
			_left_button.text = OS.get_keycode_string(input_actions[0].physical_keycode)
		else:
			_left_button.text = ""
		if input_actions.size() > 1:
			_right_button.text = OS.get_keycode_string(input_actions[1].physical_keycode)
		else:
			_right_button.text = ""


## Obsługuje wciśnięcie lewego przycisku.
func _on_left_button_pressed():
	_left_button.release_focus()
	_pressed_button = _Side.LEFT
	emit_signal(
		"rebind_button_pressed", action_label_name, action_project_name, _Side.LEFT, _left_button, _right_button
	)


## Obsługuje wciśnięcie prawego przycisku.
func _on_right_button_pressed():
	_right_button.release_focus()
	_pressed_button = _Side.RIGHT
	emit_signal(
		"rebind_button_pressed", action_label_name, action_project_name, _Side.RIGHT, _left_button, _right_button
	)
