## Klasa jest reprezentacją kamery w świecie gry
class_name SurveilenceCamera
extends Node2D

## Dodaję kamerę do grupy cameras umożliwia jej odpowiednie wyświetlanie świata gry
func _ready():
	add_to_group("cameras")
	$CameraViewport/CameraProper.position = global_position
	$CameraViewport.world_2d = get_viewport().world_2d
