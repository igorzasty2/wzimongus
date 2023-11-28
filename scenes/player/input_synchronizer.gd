# Ten skrypt odpowiada za synchronizację wejścia gracza w sieci.

extends MultiplayerSynchronizer

# Kierunek gracza dla bieżącego frame'u.
@export var direction = Vector2()

# Aktualizuje kierunek ruchu gracza dla beżącego frame'u.
func _process(delta):
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
