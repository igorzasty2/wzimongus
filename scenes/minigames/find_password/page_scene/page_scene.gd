## Klasa karty strony z hasłem.
class_name FindPasswordPageNode
extends Sprite2D


## Inicjalizuje scenę karty strony z hasłem.
func init(password):
	$PageText.text = password


func _on_button_pressed():
	visible = false
