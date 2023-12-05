extends Camera2D

# Prędkość kamery, określająca szybkość śledzenia obiektu gracza.
var camera_speed = 5.0

# Referencja do postaci śledzonego gracza.
var player = CharacterBody2D


func _process(delta):
	if player:
		# Interpolacja pozycji kamery w kierunku pozycji gracza.
		position = position.lerp(player.position, camera_speed * delta)
