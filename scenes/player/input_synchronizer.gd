# Ten skrypt odpowiada za synchronizację wejścia gracza w sieci.

extends MultiplayerSynchronizer

# Kierunek gracza dla bieżącego frame'u.
@export var direction = Vector2()
#@export var is_open_task_button_pressed = false

# Aktualizuje kierunek ruchu gracza dla beżącego frame'u.
func _process(delta):
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
