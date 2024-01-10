## Klasa reprezentuje pusty kafelek na literę
class_name EmptyBlock
extends Area2D

## Informacje o rozmiarze pola
var size:Vector2
## Litera jakiej oczekuje pole
var wanted_letter
## Przechowuje informacje o położeniu pola
var correct_area:Rect2

## Ustawia wartość zmiennej size
func _ready():
	size = $Sprite2D.get_rect().size


## Uzyskuje dokładne położenie stworzonej instancji
func set_area():
	correct_area = Rect2(position - size/2, size)
