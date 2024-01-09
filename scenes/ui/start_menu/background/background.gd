extends Control

## Timer
@onready var change_background_timer = $TransitionBackground/ChangeBackgroundTimer

## Node z tłem
@onready var background = $Background
## Node z tłem przejścia
@onready var transition_background = $TransitionBackground

## Player aniamcji przejścia
@onready var transition_animation_player = $TransitionBackground/TransitionAnimationPlayer
## Player animacji tła
@onready var background_animation_player = $Background/BackgroundAnimationPlayer

## Tło 1
@onready var background_image1 = preload("res://scenes/ui/start_menu/background/assets/background1.png")
## Tło 2
@onready var background_image2 = preload("res://scenes/ui/start_menu/background/assets/background2.png")
## Tło 3
@onready var background_image3 = preload("res://scenes/ui/start_menu/background/assets/background3.png")
## Tło 4
@onready var background_image4 = preload("res://scenes/ui/start_menu/background/assets/background4.png")


## Tablica z tłami
var background_image_array
## Indeks obecnego tła
var current_background_idx = 0

## Czas pomiędzy początkami zmian animacji tła
var wait_time = 15


func _ready():
	background_image_array = [background_image1, background_image2, background_image3, background_image4]
	GameManager.is_first_time = false
	
	# Przekazuje teksture tła na kolejnej scenie
	if GameManager.current_background_texture != null:
		background.texture = GameManager.current_background_texture
		transition_background.texture = GameManager.transition_background_texture
	else:
		background.texture = randomize_background()
	
	# Puszcza animację w odpowiednim momencie na kolejnej scenie
	if GameManager.is_animation_playing:
		transition_animation_player.play("transition_animation")
		transition_animation_player.advance(GameManager.animation_position)
		background_animation_player.play("move_animation")
		background_animation_player.advance(GameManager.animation_position)
	
	if GameManager.wait_time != null && !GameManager.is_first_time:
		change_background_timer.start(GameManager.wait_time)
		GameManager.wait_time = null
	else:
		change_background_timer.start(wait_time)


## Obsługuje przejście między tłami
func _on_change_background_timer_timeout():
	transition_background.texture = background.texture
	GameManager.transition_background_texture = transition_background.texture
	background.texture = randomize_background()
	print(transition_background.texture, "\n",background.texture,"\n")
	transition_animation_player.play("transition_animation")
	background_animation_player.play("move_animation")
	
	transition_background.material.set_shader_parameter('dissolve_state', 0)
	
	change_background_timer.start(wait_time)


## Zwraca losowe tło inne niż obecne
func randomize_background():
	var background_image_array_duplicate = background_image_array.duplicate(true)
	background_image_array_duplicate.remove_at(current_background_idx)
	
	# Losuje tło
	var current_background = background_image_array_duplicate[randi_range(0, background_image_array_duplicate.size()-1)]
	current_background_idx = background_image_array_duplicate.find(current_background)
	
	# Zapisuje wylosowane tło
	GameManager.current_background_texture = current_background
	return current_background


## Jeżeli animacja gra, to zapisuje jej pozycje podczas wyjścia z drzewa
func _on_tree_exiting():
	GameManager.is_animation_playing = transition_animation_player.is_playing()
	
	if GameManager.is_animation_playing:
		GameManager.animation_position = transition_animation_player.current_animation_position
	else:
		GameManager.wait_time = change_background_timer.time_left
