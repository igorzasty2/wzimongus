extends Control

@onready var volume_slider = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VolumeSlider
@onready var full_screen_checkbox = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/FullScreenCheckBox
@onready var v_sync_checkbox = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VSyncCheckBox
@onready var resolution_slider = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/ResolutionSlider

@onready var tab_container = $TabContainer

@onready var volume_output = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/VolumeOutput
@onready var resolution_output = $TabContainer/SoundAndGraphics/MarginContainer/GridContainer/ResolutionOutput

# resolutions dictionary
const RESOLUTIONS : Dictionary ={"800x600" : Vector2i(800,600),"1024x768" : Vector2i(1024,768), "1152x648" : Vector2i(1152,648),"1152x864" : Vector2i(1152,864), 
"1280x720" : Vector2i(1280,720), "1280x800" : Vector2i(1280,800), "1280x960" : Vector2i(1280,960), "1360x768" : Vector2i(1360,768),
"1366x768" : Vector2i(1366,768), "1400x1050" : Vector2i(1400,1050), "1440x900" : Vector2i(1440,900), "1600x900" : Vector2i(1600,900),
"1600x1200" : Vector2i(1600,1200), "1680x1050" : Vector2i(1680,1050), "1792x1344" : Vector2i(1792,1344), "1856x1392" : Vector2i(1856,1392),
"1920x1080" : Vector2i(1920,1080), "1920x1200" : Vector2i(1920,1200), "1920x1440" : Vector2i(1920,1440), "2048x1152" : Vector2i(2048,1152),
"2560x1440" : Vector2i(2560,1440), "2560x1600" : Vector2i(2560,1600), "3440x1440" : Vector2i(3440,1440), "3840x2160" : Vector2i(3840,2160)}

var user_sett: SaveUserSettings

var full_screen_value : bool
var v_sync_value : bool
var volume_value : int
var resolution_value : int

func _ready():
	user_sett = SaveUserSettings.load_or_create()
	
	# setting default/saved values	
	volume_slider.value = user_sett.volume
	full_screen_checkbox.button_pressed = user_sett.full_screen
	v_sync_checkbox.button_pressed = user_sett.v_sync
	resolution_slider.value = user_sett.resolution*3
	
	# setting local values
	full_screen_value = user_sett.full_screen
	volume_value = user_sett.volume
	resolution_value = user_sett.resolution
	v_sync_value = user_sett.v_sync
	
	# loading saved files
	_on_save_button_pressed()
	
	# handling highest resolution
	var screen_size : Vector2i = DisplayServer.screen_get_size()
	for i in range(0, RESOLUTIONS.size()):
		if screen_size.x * screen_size.y < RESOLUTIONS.values()[i].x * RESOLUTIONS.values()[i].y:
			# block from setting to higher resolution
			resolution_slider.max_value -= 3
	
	# setting first tab to default
	tab_container.current_tab = 0

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
	resolution_output.text = RESOLUTIONS.keys()[index]
	resolution_value = index

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
	
	DisplayServer.window_set_size(RESOLUTIONS.values()[resolution_value])
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
	
