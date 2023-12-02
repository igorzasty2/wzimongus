class_name SaveUserSettings 
extends Resource


# default values of settings
@export_range(0,100) var volume: int = 20
@export var full_screen: bool = false
@export var v_sync: bool = true
@export var resolution: Vector2i = Vector2i(1152, 648)

@export var controls_dictionary = {
	"sabotage" : [KEY_TAB, null],
	"use_vent" : [KEY_V, null],
	"interact" : [KEY_E, KEY_SPACE],
	"fail" : [KEY_Q, null],
	"report" : [KEY_R, null],
	"pause_menu" : [KEY_ESCAPE, null],
	"move_left" : [KEY_A, KEY_LEFT],
	"move_right" : [KEY_D, KEY_RIGHT],
	"move_down" : [KEY_S, KEY_DOWN],
	"move_up" : [KEY_W, KEY_UP]
}

# saves settings
func save():
	ResourceSaver.save(self, "user://user_settings.tres")

# loads saved/default settings
static func load_or_create():
	var res: SaveUserSettings = load("user://user_settings.tres") as SaveUserSettings
	if res==null:
		res = SaveUserSettings.new()
	return res
