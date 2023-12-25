extends Camera2D

# Referencja do śledzonego gracza.
var player: CharacterBody2D

var timer = Timer.new()
var shake_amount: float = 0

func _ready():
	NetworkTime.on_tick.connect(_on_tick)

	set_process(false)
	randomize()

	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	add_child(timer)


func _on_tick(_delta, _tick):
	if not player:
		return

	# Ustawia pozycję kamery na pozycję gracza.
	global_position = player.global_position


func _process(_delta):
	# Dodaje drgania do kamery.
	offset = Vector2(randf_range(-1, 1) * shake_amount,randf_range(-1, 1) * shake_amount)


## Trząsa kamerą przez określony czas.
func shake(time: float, amount: float):
	set_process(true)
	shake_amount = amount
	timer.wait_time = time
	timer.start()


func _on_timer_timeout():
	set_process(false)
	shake_amount = 0
	offset = Vector2.ZERO
