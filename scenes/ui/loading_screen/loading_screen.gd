extends CanvasLayer

var role = GameManager.get_current_player_key("is_lecturer")

func play():
	GameManager.set_input_status(0)
	$AnimationPlayer.play("pop_up")


func display_roles(is_lecturer: bool):
	if is_lecturer:
		$AnimationPlayer.play("lecturer_pop_up")
	else:
		$AnimationPlayer.play("crewmate_pop_up")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "pop_up":
		display_roles(role)

	if anim_name == "lecturer_pop_up" or anim_name == "crewmate_pop_up":
		hide()
		GameManager.set_input_status(1)
