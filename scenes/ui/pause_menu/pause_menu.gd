extends CanvasLayer

var esc_pressed: bool = false

func _ready():
	visible = false

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE) && !esc_pressed:
		visible=!visible
		esc_pressed = true
	elif !Input.is_key_pressed(KEY_ESCAPE):
		esc_pressed = false
	
		
func _on_leave_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/start_menu/start_menu.tscn")


func _on_back_to_game_button_pressed():
	visible=false
