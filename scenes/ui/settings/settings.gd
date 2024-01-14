## Klasa ustawień
class_name Settings
extends Control

## Slider dźwięku
@onready var _volume_slider = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VolumeSlider
## Slider skali interfejsu
@onready var _interface_scale_slider = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/InterfaceScaleSlider
## Checkbox fullscreen'a
@onready var _full_screen_checkbox = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/FullScreenCheckBox
# Checkbox ustawienia v-sync
@onready var _v_sync_checkbox = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VSyncCheckBox

## Label skali interfejsu
@onready var _interface_scale_output = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/InterfaceScaleOutput
## Label dźwięku
@onready var _volume_output = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VolumeOutput

## Okno przypisywania przycisku
@onready var _key_rebind_window = $TabContainer/Controls/KeyRebindWindow
## Nazwa przypisywanej akcji
@onready var _action_name = $TabContainer/Controls/KeyRebindWindow/Panel/VBoxContainer/ActionName
## Okno informujące o tym, że przycisk jest już w użyciu
@onready var _key_used_window = $TabContainer/Controls/KeyUsedWindow

## Przycisk domyślnych ustawień dźwięku
@onready var _default_sound_graphics_button = $TabContainer/Default/MarginContainer/VBoxContainer/VBoxContainer/DefaultSoundGraphicsButton
## Przycisk domyślnych ustawień sterowania
@onready var _default_controls_button = $TabContainer/Default/MarginContainer/VBoxContainer/VBoxContainer2/DefaultControlsButton

## Określa czy można zamknąć
@export var can_close:bool = true

## Akcje
const _ACTIONS = ["pause_menu", "sabotage", "use_vent", "interact", "fail", "report", "move_left", "move_right", "move_up", "move_down", "chat_open", "change_group"]


## Ustawienia użytkownika
var _user_sett: UserSettingsManager

## Strona przycisku
enum _Side {LEFT, RIGHT}

## Nazwa akcji w label'u
var _action_label_name : String
## Nazwa akcji w ustawieniach projektu
var _action_project_name : String
## Strona przycisku
var _button_side : _Side
## Lewy przycisk
var _left_button : Button
## Prawy przycisk
var _right_button : Button

var _primary_event_storage : InputEventKey
var _secondary_event_storage : InputEventKey

# Eventy akcji przed przypisaniem nowych akcji
var _primary_event_backup : InputEventKey
var _secondary_event_backup : InputEventKey

## Określa czy zapisywanie jest anulowane
var _is_canceled : bool = false

## Określa czy obecnie jest zmieniane przypisanie przycisku
signal button_rebind(is_rebinded:bool)

func _ready():
	_user_sett = UserSettingsManager.load_or_create()
	set_process_unhandled_key_input(false)

	# Ustawia domyślne/zapisane wartości dla dźwięku i grafiki
	_volume_slider.value = _user_sett.volume
	_on_volume_slider_value_changed(_user_sett.volume)
	_full_screen_checkbox.button_pressed = _user_sett.full_screen
	_on_full_screen_checkbox_toggled(_user_sett.full_screen)
	_v_sync_checkbox.button_pressed = _user_sett.v_sync
	_on_v_sync_check_box_toggled(_user_sett.v_sync)
	_interface_scale_slider.value = _user_sett.interface_scale
	_on_interface_scale_slider_value_changed(_user_sett.interface_scale)
	
	_key_rebind_window.visible = false
	_key_used_window.visible = false


# Obsługuje input z klawiatury podczas przypisywania klawiszy
func _unhandled_key_input(event):
	_rebind_key(event, _button_side)
	if _is_canceled != true:
		save_control_settings(_action_project_name, _primary_event_storage, _secondary_event_storage)
	_is_canceled = false
	emit_signal("button_rebind", false)
	set_process_unhandled_key_input(false)


# Obsługuje anulowanie przypisania klawiszy
func _on_cancel_button_pressed():
	_is_canceled = true
	if is_processing_unhandled_key_input():
		_unhandled_key_input(null)
	_key_rebind_window.visible = false
	can_close = true


# Obsługuje usuwanie przypisania klawiszy
func _on_delete_button_pressed():
	_is_canceled = true
	if is_processing_unhandled_key_input():
		_unhandled_key_input(null)

	# Nie pozwala na puste przypisanie klawiszy
	if _button_side == _Side.LEFT && _secondary_event_backup != null:
		save_control_settings(_action_project_name, _secondary_event_backup, null)
	elif _button_side == _Side.RIGHT && _primary_event_backup != null:
		save_control_settings(_action_project_name, _primary_event_backup, null)

	_key_rebind_window.visible = false
	can_close = true


# Obsługuje przypisanie klawisza podczas gdy przypisane klawisze się powtarzają, a gracz wybierze "tak"
func _on_yes_button_pressed():
	_key_used_window.visible = false
	can_close = true


# Obsługuje przypisanie klawisza podczas gdy przypisane klawisze się powtarzają, a gracz wybierze "nie"
func _on_no_button_pressed():
	save_control_settings(_action_project_name, _primary_event_backup, _secondary_event_backup)
	_key_used_window.visible = false
	can_close = true


# Zmienia przypisanie klawisza
func _rebind_key(event, button):
	if event == null:
		return
	if _is_canceled:
		return
	if InputMap.has_action(_action_project_name):
		var input_actions = InputMap.action_get_events(_action_project_name)
		var event_key : String = OS.get_keycode_string(event.physical_keycode)
		var amount = input_actions.size()
		var primary_event : InputEventKey = null
		var primary_event_key : String = ""
		if amount > 0:
			primary_event = input_actions[0]
			primary_event_key = OS.get_keycode_string(primary_event.physical_keycode)
		var secondary_event : InputEventKey = null
		var secondary_event_key : String = ""
		if amount > 1:
			secondary_event = input_actions[1]
			secondary_event_key = OS.get_keycode_string(secondary_event.physical_keycode)

		if button == _Side.LEFT:
			primary_event = event
			if event_key == secondary_event_key:
				secondary_event = null
		if button == _Side.RIGHT:
			secondary_event = event
			if event_key == primary_event_key:
				primary_event = event
				secondary_event = null

		_primary_event_storage = primary_event
		_secondary_event_storage = secondary_event

		# Sprawdza czy event jest już używany w innej akcji
		if _is_already_used(event):
			_key_rebind_window.visible = false
			_key_used_window.visible = true
			can_close = false
			emit_signal("button_rebind", false)
			return

		_key_rebind_window.visible = false
		can_close = true


## Zapisuje ustawienia sterowania
func save_control_settings(action_name : String, primary_butt : InputEventKey, secondary_butt : InputEventKey):
	InputMap.action_erase_events(_action_project_name)
	if primary_butt!= null:
		InputMap.action_add_event(_action_project_name, primary_butt)
	if secondary_butt!= null:
		InputMap.action_add_event(_action_project_name, secondary_butt)
	_set_buttons_names()
	if primary_butt != null:
		_user_sett.controls_dictionary[action_name][0] = primary_butt.physical_keycode
	else:
		_user_sett.controls_dictionary[action_name][0] = null
	if secondary_butt != null:
		_user_sett.controls_dictionary[action_name][1] = secondary_butt.physical_keycode
	else:
		_user_sett.controls_dictionary[action_name][1] = null
	_user_sett.save()


## Obsługuje powtarzające się przypisania klawiszy
func _is_already_used(event:InputEventKey):
	var key = event.physical_keycode
	for ac in _ACTIONS :
		if _action_project_name == ac:
			continue
		var events = InputMap.action_get_events(ac)
		for ev in events:
			if ev.physical_keycode == key:
				return true
	return false


## Ustawia tekst w przyciskach
func _set_buttons_names():
	if InputMap.has_action(_action_project_name) == true:
		var input_actions = InputMap.action_get_events(_action_project_name)
		if input_actions.size() > 0:
			_left_button.text = OS.get_keycode_string(input_actions[0].physical_keycode)
		else:
			_left_button.text = ""
		if input_actions.size() > 1:
			_right_button.text = OS.get_keycode_string(input_actions[1].physical_keycode)
		else:
			_right_button.text = ""


## Ustawia lokalne wartości potrzebne do przypisywania klawiszy
func _assign(action_label_name, action_project_name, side, left_button, right_button):
	self._action_label_name = action_label_name
	self._action_project_name = action_project_name
	self._button_side = side
	self._left_button = left_button
	self._right_button = right_button

	if InputMap.has_action(action_project_name):
		var input_actions = InputMap.action_get_events(action_project_name)
		_primary_event_backup = null
		_secondary_event_backup = null
		if input_actions.size()>0:
			_primary_event_backup = input_actions[0]
		if input_actions.size()>1:
			_secondary_event_backup = input_actions[1]

	_action_name.text = action_label_name
	_key_rebind_window.visible = true
	can_close = false
	emit_signal("button_rebind", true)
	set_process_unhandled_key_input(true)


## Obsługuje ustawienia pełnego ekranu
func _on_full_screen_checkbox_toggled(button_pressed):
	if button_pressed==true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_user_sett.full_screen = button_pressed
	_user_sett.save()


## Obsługuje ustawienia dźwięku i wyświetlaną wartość
func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0,linear_to_db(value))
	_volume_output.text = str(value)
	_user_sett.volume = value
	_user_sett.save()


## Obsługuje ustawienia skali interfejsu i wyświetlaną wartość
func _on_interface_scale_slider_value_changed(value):
	_interface_scale_output.text = str(value)
	_user_sett.change_interface_scale(value)
	_user_sett.save()


## Obsługuje ustawienia v-sync
func _on_v_sync_check_box_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_user_sett.v_sync = button_pressed
	_user_sett.save()


# Obsługuje wciśnięcie przycisku przypisania
func _on_sabotage_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_use_vent_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_interact_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_fail_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_report_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_pause_menu_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_move_left_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_move_right_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_move_down_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_move_up_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_chat_open_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_change_group_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	_assign(action_label_name, action_project_name, side, left_button, right_button)


## Obsługuje przywracanie domyślnych ustawień dźwięku i grafiki
func _on_default_sound_graphics_button_pressed():
	_default_sound_graphics_button.release_focus()
	_user_sett.restore_default_sound_and_graphics()
	_ready()


## Obsługuje przywracanie domyślnych ustawień sterowania
func _on_default_controls_button_pressed():
	_default_controls_button.release_focus()
	_user_sett.restore_default_controls()

	# Stosuje przywrócone wartości dla każdej akcji
	var parent = find_child("Controls").find_child("MarginContainer").find_child("VBoxContainer")
	for child in parent.get_children():
		if !(child is HSeparator):
			if child.has_method("start"):
				child.start()


## Zapobiega zmianie zakładki podczas przypisywania klawiszy
func _on_tab_container_tab_changed(_tab):
	if _key_rebind_window.visible || _key_used_window.visible:
		$TabContainer.current_tab = 1
