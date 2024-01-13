extends CanvasLayer


func _ready():
	GameManager.game_started.connect(queue_free)


## Ustawia tekst wyświetlany na ekranie.
func set_winning_role(role: GameManager.Role):
	if role == GameManager.Role.LECTURER:
		$Background.texture = load("res://assets/textures/end_screen/lecturers_won_background.png")
		$WinnerText.text = "Wykładowcy wygrali"
	elif role == GameManager.Role.STUDENT:
		$Background.texture = load("res://assets/textures/end_screen/students_won_background.png")
		$WinnerText.text = "Studenci wygrali"


func _input(event):
	if event is InputEventKey && !event.is_echo() && event.is_pressed():
		if GameManager.get_current_game_key("is_paused"):
			return

		queue_free()
