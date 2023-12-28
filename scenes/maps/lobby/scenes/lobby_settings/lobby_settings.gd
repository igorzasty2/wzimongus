extends CanvasLayer


func _ready():
	hide()


func _input(event):
	if event.is_action_pressed("pause_menu") && visible:
		hide()
		get_viewport().set_input_as_handled()


func _on_save_button_pressed():
	hide()


func _on_visibility_changed():
	get_parent().update_input()
