extends CanvasLayer

var winning_role = null

## Ustawia rolą która wygrała dla tej sceny
func set_winning_role(role: GameManager.Role):
	if role == GameManager.Role.LECTURER:
		$WinnerText.text = "Wykładowcy wygrali"
	elif role == GameManager.Role.STUDENT:
		$WinnerText.text = "Studenci wygrali"


func _input(event):
	if event is InputEventKey && !event.is_echo() && event.is_pressed():
		if GameManager.get_current_game_key("is_paused"):
			return

		queue_free()
