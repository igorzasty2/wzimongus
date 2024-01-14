class_name PageNode
extends Sprite2D		

## Funkcja inicjalizująca scenę strony
func init(password):
	$PageText.text = password

func _on_button_pressed():
	visible = false
