extends Sprite2D		

func init(password):
	$PageText.text = password

func _on_button_pressed():
	visible = false
