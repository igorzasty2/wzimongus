extends Camera2D

@export var speed: float = 5.0

# Referencja do śledzonego gracza. 
var player: CharacterBody2D

var shake_amount: float = 0
var default_offset: Vector2 = offset

var timer = Timer.new()

func _ready():
	randomize()
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	add_child(timer)

func _process(delta):
	# Interpoluje pozycję kamery do pozycji gracza.
	if player != null:
		position = position.lerp(player.position, speed * delta)

	# Dodaje drgania do kamery.
	offset = Vector2(randf_range(-1, 1) * shake_amount,randf_range(-1, 1) * shake_amount)

## Trząsa kamerą przez określony czas.
func shake(time: float, amount: float):
	shake_amount = amount
	timer.wait_time = time
	timer.start()

func _on_timer_timeout():
	shake_amount = 0
