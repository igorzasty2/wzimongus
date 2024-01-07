extends Node2D



## Tablica przechowująca sekwencję
var sequence = []

## Licznik naciśniętych przycisków przez gracza
var player_button_count = 0

## Licznik aktualnie wyświetlanych elementów sekwencji
var current_displayed = 0

## Licznik rozwiązanych sekwencji
var current_solved = 0

## Czas trwania błysku i przerwy między błyskami
var flash_length = .5
var flash_pause = .1

## Ładowanie tekstur używanych w grze
var flash_texture = preload("res://scenes/minigames/reactor_memory_answer/assets/flash.png")
var blank_texture = preload("res://scenes/minigames/reactor_memory_answer/assets/transparent_flash.png")
var unlit = preload("res://scenes/minigames/reactor_memory_answer/assets/unlit_indicator.png")
var lit = preload("res://scenes/minigames/reactor_memory_answer/assets/lit_indicator.png")
var failed = preload("res://scenes/minigames/reactor_memory_answer/assets/failed_indicator.png")

## Funkcja wywoływana przy dołączeniu węzła do drzewa sceny
func _ready():
	create_sequence()
	for b in $PlayerButtons.get_children():
		b.disabled = true
		
		
## Funkcja wywoływana co klatkę
func _process(delta):
	if (Input.is_action_just_pressed("ui_left")):
		$Grid.visible = !$Grid.visible
		

## Funkcja generująca sekwencję na początku gry
func create_sequence():
	current_displayed = 0
	randomize()
	for i in range(0, 4):
		sequence.append(int(randf_range(0, 16)))
		
	$StartTimer.set_wait_time(1)
	$StartTimer.start()
	

## Funkcja obsługująca błyski elementów sekwencji
func flash():
	if (current_displayed <= current_solved):
		get_node("Console").get_children()[sequence[current_displayed]].texture = flash_texture
		$FlashTimer.set_wait_time(flash_length)
		$FlashTimer.start()
	else:
		for b in $PlayerButtons.get_children():
			b.disabled = false

## Funkcja wywoływana po naciśnięciu przycisku przez gracza
func player_pressed(name):
	var button_pressed = int(name.replace("Button", "")) - 1
	
	if (button_pressed == sequence[player_button_count]):
		$ButtonIndicators.get_children()[player_button_count].texture = lit
		player_button_count += 1
		
		# Sprawdzenie, czy gracz rozwiązał 3 sekwencje (numerowane od 0 do 3)
		if (current_solved == 3 and player_button_count == 4):
			print("task completed")
		
		# Sprawdzenie, czy gracz rozwiązał całą sekwencję
		if (player_button_count > current_solved):
			for b in $PlayerButtons.get_children():
				b.disabled = true
			current_displayed = 0
			player_button_count = 0
			await get_tree().create_timer(1).timeout
			increase_solved()
			$ClearIndicatorsTimer.set_wait_time(0.5)
			$ClearIndicatorsTimer.start()
	else:
		for b in $PlayerButtons.get_children():
			b.disabled = true
		
		for i in $ButtonIndicators.get_children():
			i.texture = failed
		for i in $ConsoleIndicators.get_children():
			i.texture = failed
			
		$FailureTimer.set_wait_time(.5)
		$FailureTimer.start()

## Funkcja resetująca wskaźniki gracza
func clear_player_indicators():
	for i in $ButtonIndicators.get_children():
		i.texture = unlit
		
		

## Funkcja zwiększająca liczbę rozwiązanych sekwencji
func increase_solved():
	$ConsoleIndicators.get_children()[current_solved].texture = lit
	current_solved += 1
	# Sprawdzenie, czy gracz rozwiązał wszystkie sekwencje
	if (current_solved >= 4):
		for b in $PlayerButtons.get_children():
			b.disabled = true
	else:
		flash()
	
## Obsługa zdarzenia timeout dla timera powtórzenia sekwencji przez gracza
func _on_SequencePauseTimer_timeout():
	clear_player_indicators()
	current_displayed = 0
	player_button_count = 0
	flash()
## Obsługa zdarzenia timeout dla timera błysku
func _on_FlashTimer_timeout():
	for c in get_node("Console").get_children(): 
		c.texture = blank_texture
		
	$PauseTimer.set_wait_time(flash_pause)
	$PauseTimer.start()

## Obsługa zdarzenia timeout dla timera przerwy między błyskami
func _on_PauseTimer_timeout():
	current_displayed += 1
	flash()

## Obsługa zdarzenia timeout dla timera startowego
func _on_StartTimer_timeout():
	flash()
	
## Obsługa zdarzenia timeout dla timera czyszczenia wskaźników gracza
func _on_ClearIndicatorsTimer_timeout():
	clear_player_indicators()

## Obsługa zdarzenia timeout dla timera informującego o niepowodzeniu
func _on_FailureTimer_timeout():
	
	for i in $ButtonIndicators.get_children():
		i.texture = unlit
		
	for i in $ConsoleIndicators.get_children():
		i.texture = unlit
		
	sequence = []

	player_button_count = 0

	current_displayed = 0
	current_solved = 0

	flash_length = .5
	flash_pause = .1
	_ready()
