class_name SaveUserSettings 
extends Resource


# default values of settings
@export_range(0,100) var volume: int = 20
@export var full_screen: bool = false
@export var v_sync: bool = true
@export var resolution: Vector2i = Vector2i(1152, 648)

@export var controls_dictionary = {
	"sabotage" : [null, null],#[InputMap.action_get_events("sabotage")[0], null], 
	"use_vent" : [null, null],#[InputMap.action_get_events("use_vent")[0], null], 
	"interact" : [null, null],#[InputMap.action_get_events("interact")[0], InputMap.action_get_events("interact")[1]], 
	"fail" : [null, null],#[InputMap.action_get_events("fail")[0], null],
	"report" : [null, null],#[InputMap.action_get_events("report")[0], null],
	"pause_menu" : [null, null],#[InputMap.action_get_events("pause_menu")[0], null],
	"move_left" : [null, null],#[InputMap.action_get_events("move_left")[0], InputMap.action_get_events("move_left")[1]],
	"move_right" : [null, null],#[InputMap.action_get_events("move_right")[0], InputMap.action_get_events("move_right")[1]],
	"move_down" : [null, null],#[InputMap.action_get_events("move_down")[0], InputMap.action_get_events("move_down")[1]],
	"move_up" : [null, null]#[InputMap.action_get_events("move_up")[0], InputMap.action_get_events("move_up")[1]]
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
