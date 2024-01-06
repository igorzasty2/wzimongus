extends Control

## Timer
@onready var change_background_timer = $TransitionBackground/ChangeBackgroundTimer

## Tło
@onready var background = $Background
## Tło przejścia
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
## Identyfikator następnego tła
var next_background_id = 1

## Czas pomiędzy zmianami tła
var wait_time = 30

func _ready():
	background_image_array = [background_image1, background_image2, background_image3, background_image4]
	background.texture = background_image_array[0]
	
	change_background_timer.start(wait_time)

## Obsługuje przejście między tłami
func _on_change_background_timer_timeout():
	next_background_id += 1
	if next_background_id > background_image_array.size()-1:
		next_background_id = 1
	
	transition_background.texture = background.texture
	background.texture = background_image_array[next_background_id]
	transition_animation_player.play("background_animation")
	
	background_animation_player.play("move_animation")
	
	transition_background.material.set_shader_parameter('dissolve_state', 0)
	
	change_background_timer.start(wait_time)
