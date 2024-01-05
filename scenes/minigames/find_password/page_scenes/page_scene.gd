extends Sprite2D

func _input(event):
	if event.is_action_pressed("pause_menu"):
		queue_free()
		

func init(password):
	$PageText.text = password


