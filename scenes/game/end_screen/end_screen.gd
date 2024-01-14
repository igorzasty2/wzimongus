## Klasa odpowiedzialna za wyświetlanie ekranu końcowego.
class_name EndScreen
extends CanvasLayer


func _ready():
	GameManagerSingleton.game_started.connect(queue_free)


## Ustawia tekst wyświetlany na ekranie.
func set_winning_role(role: GameManagerSingleton.Role, is_lecturer : bool):
	if role == GameManagerSingleton.Role.LECTURER:
		$Background.texture = load("res://assets/textures/end_screen/lecturers_won_background.png")
		$WinnerText.text = "Wykładowcy wygrali"
		if is_lecturer:
			print("Victoria")
			#$VictorySound.play()
		else:
			print("Delenda")
			#$DefeatSound.play()
	elif role == GameManagerSingleton.Role.STUDENT:
		$Background.texture = load("res://assets/textures/end_screen/students_won_background.png")
		$WinnerText.text = "Studenci wygrali"
		if !is_lecturer:
			print("Victoria")
			#$VictorySound.play()
		else:
			print("Delenda")
			#$DefeatSound.play()


func _input(event):
	if event is InputEventKey && !event.is_echo() && event.is_pressed():
		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		queue_free()
