# Zarządza synchronizacją wejścia gracza w sieciowym środowisku gry.
extends MultiplayerSynchronizer

# Przechowuje kierunek ruchu gracza w aktualnej klatce.
@export var direction = Vector2()

# Aktualizuje kierunek ruchu gracza w każdej klatce gry.
func _process(delta):
	# Odczytuje wektor ruchu na podstawie danych wejściowych gracza.
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
