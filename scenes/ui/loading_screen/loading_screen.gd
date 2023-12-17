extends CanvasLayer

var rola = GameManager.get_current_player_key("impostor")

func _ready():
	GameManager.set_input_status(0)
	$AnimationPlayer.play("pop_up")

func _process(delta):
	pass


func display_roles(is_impostor: bool):
	if is_impostor:
		$AnimationPlayer.play("impostor_pop_up")
	else:
		$AnimationPlayer.play("crewmate_pop_up")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "pop_up":
		display_roles(rola)
		
	if anim_name == "impostor_pop_up" or anim_name == "crewmate_pop_up":
		$".".hide()
		GameManager.set_input_status(1)
