extends Camera2D

# Prędkość kamery, określająca szybkość śledzenia obiektu gracza.
var camera_speed = 5.0

# Referencja do postaci śledzonego gracza.
var player = CharacterBody2D

var shake_amount : float = 0
var default_offset : Vector2 = offset

@onready var timer : Timer = $Timer
@onready var tween : Tween = create_tween()

func _ready():
	randomize()

func _process(delta):
	if player:
		# Interpolacja pozycji kamery w kierunku pozycji gracza.
		position = position.lerp(player.position, camera_speed * delta)
		
	offset = Vector2(randf_range(-1,1) * shake_amount,randf_range(-1,1) * shake_amount)

func shake(time : float, amount : float):
	timer.wait_time = time
	shake_amount = amount
	set_process(true)
	timer.start()
	

func _on_timer_timeout() -> void:
	set_process(false)
	tween.interpolate_value(self, "offset", 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
