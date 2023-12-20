extends Control

@onready var volume_slider = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VolumeSlider
@onready var full_screen_checkbox = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/FullScreenCheckBox
@onready var v_sync_checkbox = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VSyncCheckBox
@onready var resolution_slider = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/ResolutionSlider

@onready var volume_output = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VolumeOutput
@onready var resolution_output = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/ResolutionOutput

@onready var save_button = $TabContainer/SoundAndGraphics/MarginContainer/SaveButton

@onready var key_rebind_window = $KeyRebindWindow
@onready var action_name = $KeyRebindWindow/Panel/VBoxContainer/ActionName
@onready var key_used_window = $KeyUsedWindow

@onready var default_sound_graphics_button = $TabContainer/Default/MarginContainer/VBoxContainer/VBoxContainer/DefaultSoundGraphicsButton
@onready var default_controls_button = $TabContainer/Default/MarginContainer/VBoxContainer/VBoxContainer2/DefaultControlsButton

# resolutions array
const RESOLUTIONS = [Vector2i(800,600), Vector2i(1024,768), Vector2i(1152,648), Vector2i(1152,864), Vector2i(1280,720),
Vector2i(1280,800),Vector2i(1280,960), Vector2i(1360,768), Vector2i(1366,768), Vector2i(1400,1050), Vector2i(1440,900), Vector2i(1600,900),
Vector2i(1600,1200), Vector2i(1680,1050), Vector2i(1792,1344), Vector2i(1856,1392), Vector2i(1920,1080), Vector2i(1920,1200),
Vector2i(1920,1440), Vector2i(2048,1152), Vector2i(2560,1440), Vector2i(2560,1600), Vector2i(3440,1440), Vector2i(3840,2160)]

var resolutions_dynamic = RESOLUTIONS.duplicate(true)

const ACTIONS = ["pause_menu", "sabotage", "use_vent", "interact", "fail", "report", "move_left", "move_right", "move_up", "move_down"]

var user_sett: UserSettingsManager

var full_screen_value : bool
var v_sync_value : bool
var volume_value : int
var resolution_value : Vector2i

enum Side {LEFT, RIGHT}

var action_label_name : String
var action_project_name : String
var button_side : Side
var left_button : Button
var right_button : Button

var primary_event_storage : InputEventKey
var secondary_event_storage : InputEventKey

# action events before assigning new actions
var primary_event_backup : InputEventKey
var secondary_event_backup : InputEventKey

var is_canceled : bool = false

signal button_rebind(is_rebinded:bool)

func _ready():
	user_sett = UserSettingsManager.load_or_create()
	set_process_unhandled_key_input(false)

	# handling highest resolution
	limit_highest_resolution()

	# setting default/saved values for sound and graphics
	volume_slider.value = user_sett.volume
	_on_volume_slider_value_changed(user_sett.volume)
	full_screen_checkbox.button_pressed = user_sett.full_screen
	_on_full_screen_checkbox_toggled(user_sett.full_screen)
	v_sync_checkbox.button_pressed = user_sett.v_sync
	_on_v_sync_check_box_toggled(user_sett.v_sync)
	var slider_value = 0
	if resolutions_dynamic.has(user_sett.resolution):
		slider_value = resolutions_dynamic.find(user_sett.resolution)
		resolution_slider.value = slider_value
		if slider_value == 0:
			_on_resolution_slider_value_changed(0)
	else:
		resolution_slider.value = int(resolution_slider.max_value/2)
	_on_resolution_slider_value_changed(slider_value)
	
	# applying saved files for sound and graphics
	_on_save_button_pressed()
	
	key_rebind_window.visible = false
	key_used_window.visible = false

# limits highest resolution available
func limit_highest_resolution():
	var screen_size : Vector2i = DisplayServer.screen_get_size()
	# users screen resolution is available
	if RESOLUTIONS.has(screen_size):
		var index : int = RESOLUTIONS.find(screen_size) + 1
		resolutions_dynamic = RESOLUTIONS.slice(0, index)
	# users screen resolution is not available
	else:
		var index : int
		if screen_size.x * screen_size.y > RESOLUTIONS.back().x * RESOLUTIONS.back().y:
			if !resolutions_dynamic.has(screen_size):
				resolutions_dynamic.append(screen_size)
		else:
			for i in range(0, RESOLUTIONS.size()):
				if (screen_size.x * screen_size.y < RESOLUTIONS[i].x * RESOLUTIONS[i].y) && i>0:
					index = i-1
					break
			resolutions_dynamic = RESOLUTIONS.slice(0, index)
			resolutions_dynamic.append(screen_size)

	resolution_slider.max_value = resolutions_dynamic.size()-1

# handles resolution setting and displayed value
func _on_resolution_slider_value_changed(value):
	resolution_output.text = str(resolutions_dynamic[value].x,"x",resolutions_dynamic[value].y)
	resolution_value = resolutions_dynamic[value]

# handles keyboard input when rebinding
func _unhandled_key_input(event):
	rebind_key(event, button_side)
	if is_canceled != true:
		save_control_settings(action_project_name, primary_event_storage, secondary_event_storage)
	is_canceled = false
	emit_signal("button_rebind", false)
	set_process_unhandled_key_input(false)

# handles canceling key rebinding
func _on_cancel_button_pressed():
	is_canceled = true
	if is_processing_unhandled_key_input():
		_unhandled_key_input(null)
	key_rebind_window.visible = false
	

# handles deleting key bindings
func _on_delete_button_pressed():
	is_canceled = true
	if is_processing_unhandled_key_input():
		_unhandled_key_input(null)
		
	# doesnt allow empty key bindings
	if button_side == Side.LEFT && secondary_event_backup != null:
		save_control_settings(action_project_name, secondary_event_backup, null)
	elif button_side == Side.RIGHT && primary_event_backup != null:
		save_control_settings(action_project_name, primary_event_backup, null)

	key_rebind_window.visible = false

# handles key rebininding when user picks yes when repeated bindings
func _on_yes_button_pressed():
	key_used_window.visible = false

# handles key rebininding when user picks no when repeated bindings
func _on_no_button_pressed():
	save_control_settings(action_project_name, primary_event_backup, secondary_event_backup)
	key_used_window.visible = false
	

# rebinds action key
func rebind_key(event, button):
	if event == null:
		return
	if is_canceled:
		return
	if InputMap.has_action(action_project_name):
		var input_actions = InputMap.action_get_events(action_project_name)
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

		if button == Side.LEFT:
			primary_event = event
			if event_key == secondary_event_key:
				secondary_event = null
		if button == Side.RIGHT:
			secondary_event = event
			if event_key == primary_event_key:
				primary_event = event
				secondary_event = null

		primary_event_storage = primary_event
		secondary_event_storage = secondary_event

		# checks if event is already used with another action
		if is_already_used(event):
			key_rebind_window.visible = false
			key_used_window.visible = true
			emit_signal("button_rebind", false)
			return

		key_rebind_window.visible = false

# saves control settings
func save_control_settings(action_name : String, primary_butt : InputEventKey, secondary_butt : InputEventKey):
	InputMap.action_erase_events(action_project_name)
	if primary_butt!= null:
		InputMap.action_add_event(action_project_name, primary_butt)
	if secondary_butt!= null:
		InputMap.action_add_event(action_project_name, secondary_butt)
	set_buttons_names()
	if primary_butt != null:
		user_sett.controls_dictionary[action_name][0] = primary_butt.physical_keycode
	else:
		user_sett.controls_dictionary[action_name][0] = null
	if secondary_butt != null:
		user_sett.controls_dictionary[action_name][1] = secondary_butt.physical_keycode
	else:
		user_sett.controls_dictionary[action_name][1] = null
	user_sett.save()

# handles repeated key bindings
func is_already_used(event:InputEventKey):
	var key = event.physical_keycode
	for ac in ACTIONS :
		if action_project_name == ac:
			continue
		var events = InputMap.action_get_events(ac)
		for ev in events:
			if ev.physical_keycode == key:
				return true
	return false

# sets text inside buttons
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

# sets local values needed for binding keys
func assign(action_label_name, action_project_name, side, left_button, right_button):
	self.action_label_name = action_label_name
	self.action_project_name = action_project_name
	self.button_side = side
	self.left_button = left_button
	self.right_button = right_button
	
	if InputMap.has_action(action_project_name):
		var input_actions = InputMap.action_get_events(action_project_name)
		primary_event_backup = null
		secondary_event_backup = null
		if input_actions.size()>0:
			primary_event_backup = input_actions[0]
		if input_actions.size()>1:
			secondary_event_backup = input_actions[1]
	
	action_name.text = action_label_name
	key_rebind_window.visible = true
	emit_signal("button_rebind", true)
	set_process_unhandled_key_input(true)

# handles full screen setting
func _on_full_screen_checkbox_toggled(button_pressed):
	full_screen_value = button_pressed

# handles volume setting and displayed value
func _on_volume_slider_value_changed(value):
	volume_value = value
	volume_output.text = str(value)

# handles v-sync setting
func _on_v_sync_check_box_toggled(button_pressed):
	v_sync_value = button_pressed

# saves and applies sound and graphics settings
func _on_save_button_pressed():
	# setting the settings
	if full_screen_value== true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_min_size(DisplayServer.screen_get_size())
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_min_size(Vector2i(800,600))
	
	AudioServer.set_bus_volume_db(0,linear_to_db(volume_value))
	
	if v_sync_value == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	#if get_window() != null:
		# base resolution
		#get_viewport().content_scale_size = resolution_value
		# stretch scale
		#get_viewport().content_scale_factor = float(resolution_value.x)/resolution_value.y
	DisplayServer.window_set_size(resolution_value)
	
	# prevents buggy button
	if save_button.is_inside_tree():
		save_button.release_focus()
	# saving
	if user_sett != null:
		user_sett.full_screen = full_screen_value
		user_sett.volume = volume_value
		user_sett.v_sync = v_sync_value
		user_sett.resolution = resolution_value
		user_sett.save()

# cancels unsaved changes in sound and graphics by loading previous save settings when hidden
func _on_hidden():
	_ready()

# handles key rebind button press
func _on_sabotage_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_use_vent_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_interact_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_fail_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_report_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_pause_menu_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_move_left_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_move_right_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_move_down_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	assign(action_label_name, action_project_name, side, left_button, right_button)

func _on_move_up_key_rebind_rebind_button_pressed(action_label_name, action_project_name, side, left_button, right_button):
	assign(action_label_name, action_project_name, side, left_button, right_button)

# handles restore default sound and graphics button
func _on_default_sound_graphics_button_pressed():
	default_sound_graphics_button.release_focus()
	user_sett.restore_default_sound_and_graphics()
	_ready()

# handles restore default controls button
func _on_default_controls_button_pressed():
	default_controls_button.release_focus()
	user_sett.restore_default_controls()

	# apply restored values for every action
	var parent = find_child("Controls").find_child("MarginContainer").find_child("VBoxContainer")
	for child in parent.get_children():
		if !(child is HSeparator):
			if child.has_method("_ready"):
				child._ready()
