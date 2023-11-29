extends Area2D

# Ta klasa funkcjonuje jako pole w którym należy umieścić literę składającą się
# na wzór matematyczny

# Zmienna size przechowuje informacje o rozmiarze pola
var size:Vector2
# wanted_letter przechowuje informacje o tym jaką literę należy umieścić w polu
var wanted_letter
# correct_area przechowuje obecną intormacje o położeniu pola, wykorzystywana
# jest w głównym skrypcie
var correct_area:Rect2


func _ready():
	size = $Sprite2D.get_rect().size


# Funkcja służy do uzyskania dokładnego położenia stworzonej już instancji
func set_area():
	correct_area = Rect2(position - size/2, size)
