extends CanvasLayer

signal finished

var role = GameManager.get_current_player_key("is_lecturer")

@onready var animation_player = $AnimationPlayer

func play():
	animation_player.play("pop_up")


func display_roles(is_lecturer: bool):
	if is_lecturer:
		animation_player.play("lecturer_pop_up")
	else:
		animation_player.play("crewmate_pop_up")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "pop_up":
		display_roles(role)

	if anim_name == "lecturer_pop_up" or anim_name == "crewmate_pop_up":
		finished.emit()
	
	GameManager.main_map_load_finished()
