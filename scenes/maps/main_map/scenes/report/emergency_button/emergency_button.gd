extends Node2D

## Timer
@onready var emergency_timer = Timer.new()
## Label pozostałego czasu
@onready var time_left_label = $TimeLeftLabel
## Tekstura przycisku
@onready var sprite_2d = $Sprite2D

# Czas oczekiwania od początku rundy na aktywację przycisku
var wait_time = GameManager.get_server_settings()["emergency_cooldown"]
# Określa czy czas oczekiwania się skończył
var is_wait_time_over: bool = false

## Kolor podświetlenia przycisku w zasięgu
var in_range_color = [255, 255, 255, 255]
## Kolor podświetlenia przycisku poza zasięgiem
var out_of_range_color = [0, 0, 0, 0]

## Sygnał informujący o zakończeniu czasu oczekiwania
signal emergency_timer_timeout(is_over:bool)


func _ready():
	GameManager.next_round_started.connect(on_next_round_started)
	$ReportArea.toggle_button_highlight.connect(toggle_button_highlight)

	toggle_button_highlight(false)
	
	add_child(emergency_timer)
	emergency_timer.autostart = true
	emergency_timer.one_shot = true
	emergency_timer.timeout.connect(_on_end_emergency_timer_timeout)
	emergency_timer.start(wait_time)


func _process(_delta):
	# Wyświetla pozostały czas do możliwości użycia przycisku
	var time_left = int(emergency_timer.get_time_left())
	time_left_label.text = str(time_left)


## Obsługuje zakończenie emergeny_timer
func _on_end_emergency_timer_timeout():
	is_wait_time_over = true
	set_process(false)
	time_left_label.text = ""
	emergency_timer_timeout.emit(true)


## Na początku rundy restartuje timer z czasem oczekiwania na aktywację przycisku
func on_next_round_started():
	set_process(true)
	is_wait_time_over = false
	
	emergency_timer.start(wait_time)
	emergency_timer_timeout.emit(false)
	
	toggle_button_highlight(false)


## Włącza i wyłącza podświetlenie przycisku awaryjnego
func toggle_button_highlight(is_on: bool):
	if is_on:
		sprite_2d.material.set_shader_parameter('color', in_range_color)
	else:
		sprite_2d.material.set_shader_parameter('color', out_of_range_color)
