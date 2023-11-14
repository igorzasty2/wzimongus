class_name SaveUserSettings extends Resource

# default values of settings
@export_range(0,100) var master_volume: int = 20
@export var full_screen: bool = false

func save():
	ResourceSaver.save(self, "user://user_settings.tres")
	
static func load_or_create():
	var res:  SaveUserSettings = load("user://user_settings.tres") as SaveUserSettings
	if res==null:
		res = SaveUserSettings.new()
	return res
