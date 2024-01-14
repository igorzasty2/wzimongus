## Systemowa wiadomość w czacie.
class_name ChatSystemMessage
extends HBoxContainer

## Referencja do etykiety z wiadomością.
@onready var _message = get_node("%Message")

## Inicjalizacja wiadomości.
func init(text):
	_message.text = text
