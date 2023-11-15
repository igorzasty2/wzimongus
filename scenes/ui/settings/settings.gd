extends Control

@onready var volume_slider = $TabContainer/SoundAndGraphics/MarginContainer/SettingsList/Options/VolumeSlider
@onready var full_screen_checkbox = $TabContainer/SoundAndGraphics/MarginContainer/SettingsList/Options/FullScreenCheckBox
@onready var v_sync_checkbox = $TabContainer/SoundAndGraphics/MarginContainer/SettingsList/Options/VSyncCheckBox

var user_sett: SaveUserSettings

func _ready():
	user_sett = SaveUserSettings.load_or_create()
	# setting default/saved values
	volume_slider.value = user_sett.volume
	full_screen_checkbox.button_pressed = user_sett.full_screen
	v_sync_checkbox.button_pressed = user_sett.v_sync
	
func _on_full_screen_checkbox_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)		
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if user_sett!=null:
		user_sett.full_screen = button_pressed;
		user_sett.save()

func _on_sound_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0,linear_to_db(value))
	if user_sett!=null:
		user_sett.volume = value;
		user_sett.save()


func _on_v_sync_check_box_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if user_sett!=null:
		user_sett.v_sync = button_pressed
		user_sett.save()
	
