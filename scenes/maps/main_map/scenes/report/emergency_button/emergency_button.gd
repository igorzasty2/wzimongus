extends Node2D

## Timer
@onready var emergency_timer = Timer.new()
## Label pozostałego czasu
@onready var time_left_label = $TimeLeftLabel
## Tekstura przycisku
@onready var sprite_2d = $Sprite2D
## Label wyświetlający pozostałą ilość użyć
@onready var uses_left_label = $UsesLeftLabel
@onready var report_area = $ReportArea

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


## Tablica wszystkich graczy
var players
## Tablica wszystkich tasków
var tasks
## Tablica wszystkich ciał
var dead_bodies
## Tablica z pozycjami do spotkania podczas głosowania
var meeting_positions
## System kamer
var camera_system
## Odniesienie do UserInterface
var user_interface
## Odniesienie to TaskListDisplay
var task_list






func _ready():
	GameManager.next_round_started.connect(on_next_round_started)
	GameManager.map_load_finished.connect(_on_map_load_finished)
	GameManager.player_killed.connect(_on_player_killed)
	$ReportArea.toggle_button_highlight.connect(toggle_button_highlight)
	
	uses_left_label.text = "Pozostało użyć: 1"
	
	toggle_button_highlight(false)


func _process(_delta):
	# Wyświetla pozostały czas do możliwości użycia przycisku
	var time_left = int(emergency_timer.get_time_left())
	time_left_label.text = str(time_left)


## Wywoływane po oblaniu gracza
func _on_player_killed(id:int):
	if multiplayer.get_unique_id() == id:
		uses_left_label.text = ""
		toggle_button_highlight(false)


## Wywoływane po zakończeniu ładowania mapy
func _on_map_load_finished():
	add_child(emergency_timer)
	emergency_timer.autostart = true
	emergency_timer.one_shot = true
	emergency_timer.timeout.connect(_on_end_emergency_timer_timeout)
	emergency_timer.start(wait_time)


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


## Wywoływane po naciśnięciu przycisku, wyłącza możliwość ponownego użycia
func on_button_used():
	uses_left_label.text = "Pozostało użyć: 0"
	$ReportArea.monitoring = false
	$ReportArea.monitorable = false


## Obsługuje report/zebranie awaryjne
func handle_report(is_button: bool):
	GameManager.is_meeting_called = true
	
	report_area.update_arrays()
	
	# Chowa przyciski z interfejsu i liste tasków
	report_area.user_interface.toggle_visiblity.rpc(false)
	report_area.toggle_task_list_visibility.rpc(false)
	
	# Zamyka taski i kamery
	report_area.close_tasks.rpc()
	report_area.close_camera_system.rpc()
	
	# Instancjonuje ekran głosowania
	report_area.instantiate_voting_screen.rpc()
	
	# Pokazuje ekran z ciałem/spotkaniem, po czym rozpoczyna głosowanie
	report_area.show_hide_report_screen.rpc()
