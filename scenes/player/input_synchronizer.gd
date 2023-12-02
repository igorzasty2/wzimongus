# Odpowiada za synchronizację wejścia gracza.

extends MultiplayerSynchronizer

# Kierunek gracza dla bieżącego frame'u.
@export var direction = Vector2()

# Aktualizuje kierunek ruchu gracza dla bieżącego frame'u.
func _process(delta):
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
