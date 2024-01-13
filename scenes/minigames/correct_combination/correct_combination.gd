extends Control

signal minigame_end

@export var polish_name : String

@onready var zero = get_node("%0")
@onready var thirty = get_node("%30")
@onready var fifty = get_node("%50")
@onready var eighty = get_node("%80")
@onready var hundred = get_node("%100")

@onready var switch_on_sprite = preload("res://scenes/minigames/correct_combination/assets/switch_on.png")

@onready var buttons_container = get_node("%Buttons")

var all_buttons = []

var correct_buttons = []
var incorrect_buttons = []

var correct_pressed_count = 0

@onready var THRESHOLDS = [[1, 2, 3, 4]]

const TOTAL_BUTTONS = 12
const CORRECT_BUTTONS_COUNT = 5

var zero_threshold = 0
var thirty_threshold = 0
var fifty_threshold = 0
var eighty_threshold = 0


func _ready():
	zero.visible = false
	thirty.visible = false
	fifty.visible = false
	eighty.visible = false
	hundred.visible = false

	all_buttons = []

	##Generuje 12 przycisków
	for i in range(TOTAL_BUTTONS):
		var check_button = CheckButton.new()

		check_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

		var switch = TextureRect.new()
		switch.texture = switch_on_sprite

		check_button.add_child(switch)

		switch.position.y = -20


		buttons_container.add_child(check_button)
		all_buttons.append(check_button)
		check_button.pressed.connect(_on_button_toggled)

	##Losuje 5 przycisków, które będą poprawne (dodaje do listy correct_buttons)
	##Reszta przycisków będzie niepoprawna (dodaje do listy incorrect_buttons)
	all_buttons.shuffle()

	for i in range(CORRECT_BUTTONS_COUNT):
		correct_buttons.append(all_buttons[i])

	for i in range(CORRECT_BUTTONS_COUNT, TOTAL_BUTTONS):
		incorrect_buttons.append(all_buttons[i])
	
	##Losuje progi dla każdej kontrolki, a nastepnie przypisuje go do odpowiednich zmiennych
	var chosen_threshold = THRESHOLDS[randi() % THRESHOLDS.size()]

	zero_threshold = chosen_threshold[0]
	thirty_threshold = chosen_threshold[1]
	fifty_threshold = chosen_threshold[2]
	eighty_threshold = chosen_threshold[3]


func _on_button_toggled():
	_update_button_sprite()

	correct_pressed_count = 0

	for button in correct_buttons:
		if button.button_pressed:
			correct_pressed_count += 1
	
	_update_indicators()
	
##Aktualizuje widoczność wskaźników
func _update_indicators():
	zero.visible = correct_pressed_count >= zero_threshold
	thirty.visible = correct_pressed_count >= thirty_threshold
	fifty.visible = correct_pressed_count >= fifty_threshold
	eighty.visible = correct_pressed_count >= eighty_threshold
	
	var all_correct_pressed = true

	for button in correct_buttons:
		if not button.button_pressed:
			all_correct_pressed = false
			break
	
	for button in incorrect_buttons:
		if button.button_pressed:
			all_correct_pressed = false
			break
	
	if all_correct_pressed:
		hundred.visible = true

		for button in correct_buttons:
			button.disabled = true
		
		for button in incorrect_buttons:
			button.disabled = true
		minigame_end.emit()

func _update_button_sprite():
	for button in all_buttons:
		button.get_child(0).flip_v = button.button_pressed
		button.get_child(0).position.y = -1 if button.button_pressed else -20
