extends CanvasLayer

var winning_role = null

## Ustawia rolą która wygrała dla tej sceny
func set_winning_role(role: String):
	winning_role = role
	$WinnerText.text = str(winning_role) + " wygrali"


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			queue_free()
