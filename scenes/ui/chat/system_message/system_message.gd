class_name SystemMessage
extends HBoxContainer

## Referencja do etykiety z wiadomością
@onready var message = get_node("%Message")

## Inicjalizacja wiadomości
func init(text):
	message.text = text

