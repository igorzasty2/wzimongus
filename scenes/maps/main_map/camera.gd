extends Camera2D

@export var speed: float = 5.0

# Referencja do śledzonego gracza. 
var player: CharacterBody2D

var shake_amount: float = 0
var default_offset: Vector2 = offset

@onready var timer : Timer = $Timer

func _ready():
	randomize()

func _process(delta):
	# Interpoluje pozycję kamery do pozycji gracza.
	if player != null:
		position = position.lerp(player.position, speed * delta)

	# Dodaje drgania do kamery.
	offset = Vector2(randf_range(-1, 1) * shake_amount,randf_range(-1, 1) * shake_amount)

## Trząsa kamerą przez określony czas.
func shake(time: float, amount: float):
	timer.wait_time = time
	shake_amount = amount
	set_process(true)
	timer.start()

func _on_timer_timeout() -> void:
	set_process(false)
	Tween.interpolate_value(self, "offset", 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
