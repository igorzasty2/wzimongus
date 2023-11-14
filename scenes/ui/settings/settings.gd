extends Control

@onready var sound_volume_slider = $SettingsList/Sliders/SoundVolumeSlider
@onready var full_screen_checkbox = $SettingsList/Sliders/FullScreenCheckbox

var user_sett: SaveUserSettings

func _ready():
	user_sett = SaveUserSettings.load_or_create()
	sound_volume_slider.value = user_sett.master_volume
	full_screen_checkbox.button_pressed = user_sett.full_screen

func _on_full_screen_checkbox_toggled(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)		
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if user_sett:
		user_sett.full_screen= full_screen_checkbox.button_pressed;
		user_sett.save()

func _on_sound_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0,linear_to_db(value))
	if user_sett:
		user_sett.master_volume = value;
		user_sett.save()

