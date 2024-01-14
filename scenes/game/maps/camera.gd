## Klasa kamery, śledzącej gracza.
class_name Camera
extends Camera2D

## Referencja do śledzonego gracza.
var target: CharacterBody2D

var _shake_timer = Timer.new()
var _shake_amount: float = 0

func _ready():
	NetworkTime.on_tick.connect(_on_tick)

	set_process(false)
	randomize()

	_shake_timer.timeout.connect(_on_timer_timeout)
	_shake_timer.one_shot = true
	add_child(_shake_timer)


func _on_tick(_delta, _tick):
	if not target:
		return

	# Ustawia pozycję kamery na pozycję gracza.
	global_position = target.global_position


func _process(_delta):
	# Dodaje drgania do kamery.
	offset = Vector2(randf_range(-1, 1) * _shake_amount,randf_range(-1, 1) * _shake_amount)


## Trząsa kamerą przez określony czas.
func shake(time: float, amount: float):
	set_process(true)
	_shake_amount = amount
	_shake_timer.wait_time = time
	_shake_timer.start()


func _on_timer_timeout():
	set_process(false)
	_shake_amount = 0
	offset = Vector2.ZERO
