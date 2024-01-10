## Klasa jest reprezentacją kamery w świecie gry
class_name SurveilenceCamera
extends Node2D

## Dodaje kamerę do grupy cameras umożliwia jej odpowiednie wyświetlanie świata gry
func _ready():
	add_to_group("cameras")
	$CameraViewport/CameraProper.position = global_position
	$CameraViewport.world_2d = get_viewport().world_2d

## Zmienia widoczność światła kamery aby widać było stojących w jej polu widzenia graczy
func change_light_visibility():
	$Light.visible = !$Light.visible
