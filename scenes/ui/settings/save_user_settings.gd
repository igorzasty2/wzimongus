class_name SaveUserSettings 
extends Resource

# default values of settings
@export_range(0,100) var volume: int = 20
@export var full_screen: bool = false
@export var v_sync: bool = true
@export_range(0,71) var resolution: int = 2*3 # 1152x648

@export var controls_dictionary = {
	"sabotage" : [InputMap.action_get_events("sabotage")[0], null], 
	"use_vent" : [InputMap.action_get_events("use_vent")[0], null], 
	"interact" : [InputMap.action_get_events("interact")[0], InputMap.action_get_events("interact")[1]], 
	"fail" : [InputMap.action_get_events("fail")[0], null],
	"report" : [InputMap.action_get_events("report")[0], null],
	"pause_menu" : [InputMap.action_get_events("pause_menu")[0], null],
	"move_left" : [InputMap.action_get_events("move_left")[0], InputMap.action_get_events("move_left")[1]],
	"move_right" : [InputMap.action_get_events("move_right")[0], InputMap.action_get_events("move_right")[1]],
	"move_down" : [InputMap.action_get_events("move_down")[0], InputMap.action_get_events("move_down")[1]],
	"move_up" : [InputMap.action_get_events("move_up")[0], InputMap.action_get_events("move_up")[1]]
}

func save():
	ResourceSaver.save(self, "user://user_settings.tres")
	
static func load_or_create():
	var res: SaveUserSettings = load("user://user_settings.tres") as SaveUserSettings
	if res==null:
		res = SaveUserSettings.new()
	return res
