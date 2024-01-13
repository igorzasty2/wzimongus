extends Control

## Timer
@onready var _change_background_timer = $TransitionBackground/ChangeBackgroundTimer

## Node z tłem
@onready var _background = $Background
## Node z tłem przejścia
@onready var _transition_background = $TransitionBackground

## Player aniamcji przejścia
@onready var _transition_animation_player = $TransitionBackground/TransitionAnimationPlayer
## Player animacji tła
@onready var _background_animation_player = $Background/BackgroundAnimationPlayer

## Tło 1
@onready var _background_image1 = preload("res://assets/textures/background/background1.png")
## Tło 2
@onready var _background_image2 = preload("res://assets/textures/background/background2.png")
## Tło 3
@onready var _background_image3 = preload("res://assets/textures/background/background3.png")
## Tło 4
@onready var _background_image4 = preload("res://assets/textures/background/background4.png")


## Tablica z tłami
var _background_image_array
## Indeks obecnego tła
var _current_background_idx = 0

## Czas pomiędzy początkami zmian animacji tła
var _wait_time = 15


func _ready():
	_background_image_array = [_background_image1, _background_image2, _background_image3, _background_image4]
	GameManagerSingleton.is_first_time = false
	
	# Przekazuje teksture tła na kolejnej scenie
	if GameManagerSingleton.current_background_texture != null:
		_background.texture = GameManagerSingleton.current_background_texture
		_transition_background.texture = GameManagerSingleton.transition_background_texture
	else:
		_background.texture = _randomize_background()
	
	# Puszcza animację w odpowiednim momencie na kolejnej scenie
	if GameManagerSingleton.is_animation_playing:
		_transition_animation_player.play("transition_animation")
		_transition_animation_player.advance(GameManagerSingleton.animation_position)
		_background_animation_player.play("move_animation")
		_background_animation_player.advance(GameManagerSingleton.animation_position)
	
	if GameManagerSingleton.wait_time != null && !GameManagerSingleton.is_first_time:
		_change_background_timer.start(GameManagerSingleton.wait_time)
		GameManagerSingleton.wait_time = null
	else:
		_change_background_timer.start(_wait_time)


## Obsługuje przejście między tłami
func _on_change_background_timer_timeout():
	_transition_background.texture = _background.texture
	GameManagerSingleton.transition_background_texture = _transition_background.texture
	_background.texture = _randomize_background()
	_transition_animation_player.play("transition_animation")
	_background_animation_player.play("move_animation")
	
	_transition_background.material.set_shader_parameter('dissolve_state', 0)
	
	_change_background_timer.start(_wait_time)


## Zwraca losowe tło inne niż obecne
func _randomize_background():
	var background_image_array_duplicate = _background_image_array.duplicate(true)
	background_image_array_duplicate.remove_at(_current_background_idx)
	
	# Losuje tło
	var current_background = background_image_array_duplicate[randi_range(0, background_image_array_duplicate.size()-1)]
	_current_background_idx = background_image_array_duplicate.find(current_background)
	
	# Zapisuje wylosowane tło
	GameManagerSingleton.current_background_texture = current_background
	return current_background


## Jeżeli animacja gra, to zapisuje jej pozycje podczas wyjścia z drzewa
func _on_tree_exiting():
	GameManagerSingleton.is_animation_playing = _transition_animation_player.is_playing()
	
	if GameManagerSingleton.is_animation_playing:
		GameManagerSingleton.animation_position = _transition_animation_player.current_animation_position
	else:
		GameManagerSingleton.wait_time = _change_background_timer.time_left
