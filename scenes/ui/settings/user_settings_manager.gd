## Klasa odpowiadająca za zapis ustawień gracza
class_name UserSettingsManager
extends Resource

# Domyślne ustawienia
const _DEFAULT_VOLUME: int = 20
const _DEFAULT_INTERFACE_SCALE: int = 1
const _DEFAULT_FULL_SCREEN: bool = false
const _DEFAULT_V_SYNC: bool = true
const _DEFAULT_CONTROLS_DICTIONARY = {
	"sabotage" : [KEY_TAB, null],
	"use_vent" : [KEY_V, null],
	"interact" : [KEY_E, KEY_SPACE],
	"fail" : [KEY_Q, null],
	"report" : [KEY_R, null],
	"pause_menu" : [KEY_ESCAPE, null],
	"move_left" : [KEY_A, KEY_LEFT],
	"move_right" : [KEY_D, KEY_RIGHT],
	"move_down" : [KEY_S, KEY_DOWN],
	"move_up" : [KEY_W, KEY_UP],
	"chat_open" : [KEY_T, null], 
	"chat_close" : [KEY_TAB, null] 
}

# Ustawienia dźwięku, początkowo ustawione na domyślne
@export_range(0,100) var volume: int = _DEFAULT_VOLUME
# Ustawienia skali interfejsu, początkowo ustawione na domyślne
@export var interface_scale: float = _DEFAULT_INTERFACE_SCALE
# Ustawienia pełnego ekranu, początkowo ustawione na domyślne
@export var full_screen: bool = _DEFAULT_FULL_SCREEN
# Ustawienia v-sync, początkowo ustawione na domyślne
@export var v_sync: bool = _DEFAULT_V_SYNC
# Ustawienia sterowania, początkowo ustawione na domyślne
@export var controls_dictionary = _DEFAULT_CONTROLS_DICTIONARY.duplicate(true)

## Emitowany po zmianie skali interfejsu
signal interface_scale_value_changed(value:float)

## Zapisuje ustawienia
func save():
	ResourceSaver.save(self, "user://user_settings.tres")

## Zwraca zapisane ustawienia z pliku lub tworzy nowy plik z domyślnymi ustawieniami i je zwraca
static func load_or_create():
	var res : UserSettingsManager
	if FileAccess.file_exists("user://user_settings.tres"):
		res = load("user://user_settings.tres") as UserSettingsManager
	else:
		res = UserSettingsManager.new()
	return res

## Przywraca domyślne ustawienia dźwięku i grafiki
func restore_default_sound_and_graphics():
	volume = _DEFAULT_VOLUME
	interface_scale = _DEFAULT_INTERFACE_SCALE
	full_screen = _DEFAULT_FULL_SCREEN
	v_sync = _DEFAULT_V_SYNC
	save()

## Przywraca domyślne ustawienia sterowania
func restore_default_controls():
	controls_dictionary = _DEFAULT_CONTROLS_DICTIONARY.duplicate(true)
	save()


## Zmienia skale interfejsu
func change_interface_scale(value:float):
	interface_scale = value
	interface_scale_value_changed.emit(value)
