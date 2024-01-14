## Ekran ładowania głównej mapy.
class_name LoadingScreen
extends CanvasLayer

## Emitowany po skończeniu wyświetlania ekranu ładowania.
signal finished

var _role = GameManagerSingleton.get_current_player_value("is_lecturer")

@onready var _animation_player = $AnimationPlayer

## Rozpoczyna wyświetlanie ekranu ładowania.
func play():
	_animation_player.play("pop_up")


func _display_roles(is_lecturer: bool):
	if is_lecturer:
		_animation_player.play("lecturer_pop_up")
	else:
		_animation_player.play("crewmate_pop_up")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "pop_up":
		_display_roles(_role)

	if anim_name == "lecturer_pop_up" or anim_name == "crewmate_pop_up":
		finished.emit()
		GameManagerSingleton.main_map_load_finished()
