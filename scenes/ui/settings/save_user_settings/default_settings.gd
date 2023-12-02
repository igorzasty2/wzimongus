# stores all default settings

class_name DefaultSettings
extends Node

const DEFAULT_VOLUME: int = 20
const DEFAULT_FULL_SCREEN: bool = false
const DEFAULT_V_SYNC: bool = true
const DEFAULT_RESOLUTION: Vector2i = Vector2i(1152, 648)

const DEFAULT_CONTROLS_DICTIONARY = {
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
