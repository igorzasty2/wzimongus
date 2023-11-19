extends Area2D

# Ta klasa funkcjonuje jako pole w którym należy umieścić literę składającą się
# na wzór matematyczny

# Zmienna base_area przechowuje informacje o rozmiarze pola
var base_area:Rect2
# wanted_letter przechowuje informacje o tym jaką literę należy umieścić w polu
var wanted_letter
# correct_area przechowuje obecną intormacje o położeniu pola, wykorzystywana
# jest w głównym skrypcie
var correct_area:Rect2


func _ready():
	base_area = $Sprite2D.get_rect()

# Funkcja służy do uzyskania dokładnego położenia stworzonej już instancji
func set_area():
	correct_area = Rect2(position - base_area.size/2, base_area.size)
