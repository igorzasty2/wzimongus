## Przycisk zamykający okno.
class_name CloseButton
extends TextureButton

## Okno, które ma zostać zamknięte.
@export var window : Node = null

# Obsługuje naciśnięcie, przywraca kolor
func _on_pressed():
	modulate = Color8(255, 255, 255, 255)
	window.visible = false


# Przyciemnia kolor
func _on_mouse_entered():
	modulate = Color8(170, 170, 170, 255)


# Przywraca pierwotny kolor
func _on_mouse_exited():
	modulate = Color8(255, 255, 255, 255)
