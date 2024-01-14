extends CanvasLayer


func _ready():
	GameManagerSingleton.game_started.connect(queue_free)


## Ustawia tekst wyświetlany na ekranie.
func set_winning_role(role: GameManagerSingleton.Role):
	if role == GameManagerSingleton.Role.LECTURER:
		$Background.texture = load("res://assets/textures/end_screen/lecturers_won_background.png")
		$WinnerText.text = "Wykładowcy wygrali"
	elif role == GameManagerSingleton.Role.STUDENT:
		$Background.texture = load("res://assets/textures/end_screen/students_won_background.png")
		$WinnerText.text = "Studenci wygrali"


func _input(event):
	if event is InputEventKey && !event.is_echo() && event.is_pressed():
		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		queue_free()
