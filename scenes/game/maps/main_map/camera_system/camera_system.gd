## Klasa jest reprezentacją okna systemu kamer.
class_name SurveilenceCameraSystem
extends Control


## Nigdy nie wysyłany, dodany w celu umożliwienia dodania tej klasy do okna minigry.
signal minigame_end

## Tablica kamer obecnych na mapie.
@onready var cameras = get_parent().get_parent().get_tree().get_nodes_in_group("SurveilenceCameras")

## Przyporządkowuje kamery ich wyświetlaczą.
func _ready():
	$CameraPanel/camera1.texture = cameras[0].get_child(0).get_texture()
	$CameraPanel/camera2.texture = cameras[1].get_child(0).get_texture()
	$CameraPanel/camera5.texture = cameras[2].get_child(0).get_texture()
	$CameraPanel/camera6.texture = cameras[3].get_child(0).get_texture()
	$CameraPanel/camera7.texture = cameras[4].get_child(0).get_texture()
