## Minigra polegająca na wciśnięciu poprawnych przycisków.
class_name CorrectCombinationMinigame
extends Control

## Sygnał emitowany, gdy gracz poprawnie rozwiąże minigrę
signal minigame_end

## Nazwa polska minigry
@export var polish_name : String

## Kontrolka oznaczająca 0%
@onready var _zero = get_node("%0")
## Kontrolka oznaczająca 30%
@onready var _thirty = get_node("%30")
## Kontrolka oznaczająca 50%
@onready var _fifty = get_node("%50")
## Kontrolka oznaczająca 80%
@onready var _eighty = get_node("%80")
## Kontrolka oznaczająca 100%
@onready var _hundred = get_node("%100")

## Tekstura włączonego przełącznika
@onready var _switch_on_sprite = preload("res://assets/textures/minigames/correct_combination/switch_on.png")

## Kontener na przyciski
@onready var _buttons_container = get_node("%Buttons")

## Lista wszystkich przycisków
var _all_buttons = []

## Lista poprawnych przycisków
var _correct_buttons = []
## Lista niepoprawnych przycisków
var _incorrect_buttons = []

## Liczba poprawnie wciśniętych przycisków
var _correct_pressed_count = 0

## Lista progów dla każdej kontrolki
var _thresholds = [[1, 2, 3, 4]]

## Liczba wszystkich przycisków
const _TOTAL_BUTTONS = 12

## Liczba poprawnych przycisków
const _CORRECT_BUTTONS_COUNT = 5

## Zmienna przechowująca próg dla 0%
var _zero_threshold = 0
## Zmienna przechowująca próg dla 30%
var _thirty_threshold = 0
## Zmienna przechowująca próg dla 50%
var _fifty_threshold = 0
## Zmienna przechowująca próg dla 80%
var _eighty_threshold = 0


func _ready():
	_zero.visible = false
	_thirty.visible = false
	_fifty.visible = false
	_eighty.visible = false
	_hundred.visible = false

	_all_buttons = []

	##Generuje 12 przycisków
	for i in range(_TOTAL_BUTTONS):
		var check_button = CheckButton.new()

		check_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

		var switch = TextureRect.new()
		switch.texture = _switch_on_sprite

		check_button.add_child(switch)

		switch.position.y = -20


		_buttons_container.add_child(check_button)
		_all_buttons.append(check_button)
		check_button.pressed.connect(_on_button_toggled)

	##Losuje 5 przycisków, które będą poprawne (dodaje do listy _correct_buttons)
	##Reszta przycisków będzie niepoprawna (dodaje do listy _incorrect_buttons)
	_all_buttons.shuffle()

	for i in range(_CORRECT_BUTTONS_COUNT):
		_correct_buttons.append(_all_buttons[i])

	for i in range(_CORRECT_BUTTONS_COUNT, _TOTAL_BUTTONS):
		_incorrect_buttons.append(_all_buttons[i])

	##Losuje progi dla każdej kontrolki, a nastepnie przypisuje go do odpowiednich zmiennych
	var chosen_threshold = _thresholds[randi() % _thresholds.size()]

	_zero_threshold = chosen_threshold[0]
	_thirty_threshold = chosen_threshold[1]
	_fifty_threshold = chosen_threshold[2]
	_eighty_threshold = chosen_threshold[3]


func _on_button_toggled():
	_update_button_sprite()

	_correct_pressed_count = 0

	for button in _correct_buttons:
		if button.button_pressed:
			_correct_pressed_count += 1

	_update_indicators()

##Aktualizuje widoczność wskaźników
func _update_indicators():
	_zero.visible = _correct_pressed_count >= _zero_threshold
	_thirty.visible = _correct_pressed_count >= _thirty_threshold
	_fifty.visible = _correct_pressed_count >= _fifty_threshold
	_eighty.visible = _correct_pressed_count >= _eighty_threshold

	var all_correct_pressed = true

	for button in _correct_buttons:
		if not button.button_pressed:
			all_correct_pressed = false
			break

	for button in _incorrect_buttons:
		if button.button_pressed:
			all_correct_pressed = false
			break

	if all_correct_pressed:
		_hundred.visible = true

		for button in _correct_buttons:
			button.disabled = true

		for button in _incorrect_buttons:
			button.disabled = true
		minigame_end.emit()

func _update_button_sprite():
	for button in _all_buttons:
		button.get_child(0).flip_v = button.button_pressed
		button.get_child(0).position.y = -1 if button.button_pressed else -20
