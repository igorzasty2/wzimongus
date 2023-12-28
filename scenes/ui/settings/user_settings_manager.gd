class_name UserSettingsManager 
extends Resource

# Domyślne ustawienia
const DEFAULT_VOLUME: int = 20
const DEFAULT_FULL_SCREEN: bool = false
const DEFAULT_V_SYNC: bool = true
const DEFAULT_RESOLUTION: Vector2i = Vector2i(1280, 720)
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

# Ustawienia użytkownika, początkowo ustawione na domyślne
@export_range(0,100) var volume: int = DEFAULT_VOLUME
@export var full_screen: bool = DEFAULT_FULL_SCREEN
@export var v_sync: bool = DEFAULT_V_SYNC
@export var resolution: Vector2i = DEFAULT_RESOLUTION
@export var controls_dictionary = DEFAULT_CONTROLS_DICTIONARY.duplicate(true)

# Zapisuje ustawienia
func save():
	ResourceSaver.save(self, "user://user_settings.tres")

# Zwraca zapisane ustawienia z pliku lub tworzy nowy plik z domyślnymi ustawieniami i je zwraca
static func load_or_create():
	var res : UserSettingsManager
	if FileAccess.file_exists("user://user_settings.tres"):
		res = load("user://user_settings.tres") as UserSettingsManager
	else:
		res = UserSettingsManager.new()
	return res

# Przywraca domyślne ustawienia dźwięku i grafiki
func restore_default_sound_and_graphics():
	volume = DEFAULT_VOLUME
	full_screen = DEFAULT_FULL_SCREEN
	v_sync = DEFAULT_V_SYNC
	resolution= DEFAULT_RESOLUTION
	save()

# Przywraca domyślne ustawienia sterowania
func restore_default_controls():
	controls_dictionary = DEFAULT_CONTROLS_DICTIONARY.duplicate(true)
	save()
