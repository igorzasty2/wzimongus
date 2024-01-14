## Klasa reprezentująca minigrę polegającą na zapamiętywaniu sekwencji.
class_name ReactorMemoryMinigame	
extends Node2D

## Emitowany po skończeniu minigry.
signal minigame_end

## Polska nazwa minigry.
@export var polish_name : String



## Tablica przechowująca sekwencję
var _sequence = []

## Licznik naciśniętych przycisków przez gracza
var _player_button_count = 0

## Licznik aktualnie wyświetlanych elementów sekwencji
var _current_displayed = 0

## Licznik rozwiązanych sekwencji
var _current_solved = 0

## Czas trwania błysku i przerwy między błyskami
var flash_length = .5
var flash_pause = .1

## Ładowanie tekstur używanych w grze
var _flash_texture = preload("res://assets/textures/minigames/reactor_memory_answer/flash.png")
var _blank_texture = preload("res://assets/textures/minigames/reactor_memory_answer/transparent_flash.png")
var _unlit = preload("res://assets/textures/minigames/reactor_memory_answer/unlit_indicator.png")
var _lit = preload("res://assets/textures/minigames/reactor_memory_answer/lit_indicator.png")
var _failed = preload("res://assets/textures/minigames/reactor_memory_answer/failed_indicator.png")

## Funkcja wywoływana przy dołączeniu węzła do drzewa sceny
func _ready():
	_create_sequence()
	for b in $PlayerButtons.get_children():
		b.disabled = true


## Funkcja wywoływana co klatkę
func _process(_delta):
	if (Input.is_action_just_pressed("ui_left")):
		$Grid.visible = !$Grid.visible


## Funkcja generująca sekwencję na początku gry
func _create_sequence():
	_current_displayed = 0
	randomize()
	for i in range(0, 4):
		_sequence.append(int(randf_range(0, 16)))

	$StartTimer.set_wait_time(1)
	$StartTimer.start()


## Funkcja obsługująca błyski elementów sekwencji
func _flash():
	if (_current_displayed <= _current_solved):
		get_node("Console").get_children()[_sequence[_current_displayed]].texture = _flash_texture
		$FlashTimer.set_wait_time(flash_length)
		$FlashTimer.start()
	else:
		for b in $PlayerButtons.get_children():
			b.disabled = false

## Funkcja wywoływana po naciśnięciu przycisku przez gracza
func player_pressed(name):
	var button_pressed = int(name.replace("Button", "")) - 1

	if (button_pressed == _sequence[_player_button_count]):
		$ButtonIndicators.get_children()[_player_button_count].texture = _lit
		_player_button_count += 1

		# Sprawdzenie, czy gracz rozwiązał 3 sekwencje (numerowane od 0 do 3)
		if (_current_solved == 3 and _player_button_count == 4):
			minigame_end.emit()

		# Sprawdzenie, czy gracz rozwiązał całą sekwencję
		if (_player_button_count > _current_solved):
			for b in $PlayerButtons.get_children():
				b.disabled = true
			_current_displayed = 0
			_player_button_count = 0
			await get_tree().create_timer(1).timeout
			_increase_solved()
			$ClearIndicatorsTimer.set_wait_time(0.5)
			$ClearIndicatorsTimer.start()
	else:
		for b in $PlayerButtons.get_children():
			b.disabled = true

		for i in $ButtonIndicators.get_children():
			i.texture = _failed
		for i in $ConsoleIndicators.get_children():
			i.texture = _failed

		$FailureTimer.set_wait_time(.5)
		$FailureTimer.start()

## Funkcja resetująca wskaźniki gracza
func _clear_player_indicators():
	for i in $ButtonIndicators.get_children():
		i.texture = _unlit



## Funkcja zwiększająca liczbę rozwiązanych sekwencji
func _increase_solved():
	$ConsoleIndicators.get_children()[_current_solved].texture = _lit
	_current_solved += 1
	# Sprawdzenie, czy gracz rozwiązał wszystkie sekwencje
	if (_current_solved >= 4):
		for b in $PlayerButtons.get_children():
			b.disabled = true
	else:
		_flash()

## Obsługa zdarzenia timeout dla timera powtórzenia sekwencji przez gracza
func _on_SequencePauseTimer_timeout():
	_clear_player_indicators()
	_current_displayed = 0
	_player_button_count = 0
	_flash()
## Obsługa zdarzenia timeout dla timera błysku
func _on_FlashTimer_timeout():
	for c in get_node("Console").get_children():
		c.texture = _blank_texture

	$PauseTimer.set_wait_time(flash_pause)
	$PauseTimer.start()

## Obsługa zdarzenia timeout dla timera przerwy między błyskami
func _on_PauseTimer_timeout():
	_current_displayed += 1
	_flash()

## Obsługa zdarzenia timeout dla timera startowego
func _on_StartTimer_timeout():
	_flash()

## Obsługa zdarzenia timeout dla timera czyszczenia wskaźników gracza
func _on_ClearIndicatorsTimer_timeout():
	_clear_player_indicators()

## Obsługa zdarzenia timeout dla timera informującego o niepowodzeniu
func _on_FailureTimer_timeout():

	for i in $ButtonIndicators.get_children():
		i.texture = _unlit

	for i in $ConsoleIndicators.get_children():
		i.texture = _unlit

	_sequence = []

	_player_button_count = 0

	_current_displayed = 0
	_current_solved = 0

	flash_length = .5
	flash_pause = .1
	_ready()
