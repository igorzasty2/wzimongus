## Klasa reprezentująca kartę strony z hasłem.
class_name FindPasswordPageNode
extends Sprite2D		

## Funkcja inicjalizująca scenę strony
func init(password):
	$PageText.text = password

func _on_button_pressed():
	visible = false
