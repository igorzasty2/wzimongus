extends Sprite2D

func _input(event):
	if event.is_action_pressed("pause_menu"):
		visible = false
		

func init(password):
	$PageText.text = password


