extends Control

@onready var volume_slider = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VolumeSlider
@onready var full_screen_checkbox = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/FullScreenCheckBox
@onready var v_sync_checkbox = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VSyncCheckBox
@onready var resolution_slider = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/ResolutionSlider

@onready var tab_container = $TabContainer

@onready var volume_output = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VolumeOutput
@onready var resolution_output = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/ResolutionOutput

# resolutions array
var resolutions = [Vector2i(800,600), Vector2i(1024,768), Vector2i(1152,648), Vector2i(1152,864), Vector2i(1280,720),
Vector2i(1280,800),Vector2i(1280,960), Vector2i(1360,768), Vector2i(1366,768), Vector2i(1400,1050), Vector2i(1440,900), Vector2i(1600,900),
Vector2i(1600,1200), Vector2i(1680,1050), Vector2i(1792,1344), Vector2i(1856,1392), Vector2i(1920,1080), Vector2i(1920,1200),
Vector2i(1920,1440), Vector2i(2048,1152), Vector2i(2560,1440), Vector2i(2560,1600), Vector2i(3440,1440), Vector2i(3840,2160)]

var user_sett: SaveUserSettings

var full_screen_value : bool
var v_sync_value : bool
var volume_value : int
var resolution_value : int

func _ready():
	user_sett = SaveUserSettings.load_or_create()
	
	# setting default/saved values
	if user_sett.volume == 0:	# when zero doesnt trigger automatically
		_on_volume_slider_value_changed(0)
	volume_slider.value = user_sett.volume
	full_screen_checkbox.button_pressed = user_sett.full_screen
	v_sync_checkbox.button_pressed = user_sett.v_sync
	if user_sett.resolution == 0:	# when zero doesnt trigger automatically
		_on_resolution_slider_value_changed(0)
	resolution_slider.value = user_sett.resolution
	# setting local values
	full_screen_value = user_sett.full_screen
	volume_value = user_sett.volume
	resolution_value = user_sett.resolution
	v_sync_value = user_sett.v_sync
	
	# loading saved files
	_on_save_button_pressed()
	
	# handling highest resolution
	limit_highest_resolution()
	
	# setting first tab to default
	tab_container.current_tab = 0

# limits highest resolution available
func limit_highest_resolution():
	var screen_size : Vector2i = DisplayServer.screen_get_size()
	# users screen resolution is available
	if resolutions.has(screen_size):
		var index : int = resolutions.find(screen_size)
		var amount : int = resolutions.slice(0, index).size()
		resolution_slider.max_value = amount*3
	# users screen resolution is not available
	else:
		var index : int;
		for i in range(0, resolutions.size()):
			if (screen_size.x * screen_size.y < resolutions[i].x * resolutions[i].y) && i>0:
				index = i-1
				break
		var amount : int = resolutions.slice(0, index).size()
		resolution_slider.max_value = amount*3

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

# handles resolution setting and displayed value
func _on_resolution_slider_value_changed(value):
	var index : int = int(value/3)
	resolution_output.text = str(resolutions[index].x,"x",resolutions[index].y)
	resolution_value = value

# saves all settings
func _on_save_button_pressed():
	# setting the settings
	if full_screen_value== true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)		
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	AudioServer.set_bus_volume_db(0,linear_to_db(volume_value))
	
	if v_sync_value == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	var index : int = resolution_value/3
	DisplayServer.window_set_size(resolutions[index])
	# prevents buggy button
	get_node("SaveButton").release_focus()
	# saving
	if user_sett != null:
		user_sett.full_screen = full_screen_value
		user_sett.volume = volume_value
		user_sett.v_sync = v_sync_value
		user_sett.resolution = resolution_value
		user_sett.save()

# cancels unsaved changes when hidden
func _on_hidden():
	_ready()
