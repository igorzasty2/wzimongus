class_name SaveUserSettings 
extends Resource

# default values of settings
@export_range(0,100) var volume: int = DefaultSettings.DEFAULT_VOLUME
@export var full_screen: bool = DefaultSettings.DEFAULT_FULL_SCREEN
@export var v_sync: bool = DefaultSettings.DEFAULT_V_SYNC
@export var resolution: Vector2i = DefaultSettings.DEFAULT_RESOLUTION

@export var controls_dictionary = DefaultSettings.DEFAULT_CONTROLS_DICTIONARY.duplicate(true)

# saves settings
func save():
	ResourceSaver.save(self, "user://user_settings.tres")

# loads saved/default settings
static func load_or_create():
	var res: SaveUserSettings = load("user://user_settings.tres") as SaveUserSettings
	if res==null:
		res = SaveUserSettings.new()
	return res

# restores default sound and graphics settings
func restore_default_sound_and_graphics():
	volume = DefaultSettings.DEFAULT_VOLUME
	full_screen = DefaultSettings.DEFAULT_FULL_SCREEN
	v_sync = DefaultSettings.DEFAULT_V_SYNC
	resolution= DefaultSettings.DEFAULT_RESOLUTION
	save()

# restores default controls settings
func restore_default_controls():
	controls_dictionary = DefaultSettings.DEFAULT_CONTROLS_DICTIONARY.duplicate(true)
	save()
