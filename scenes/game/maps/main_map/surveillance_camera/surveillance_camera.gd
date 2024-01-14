## Klasa jest reprezentacją kamery monitoringu.
class_name SurveillanceCamera
extends Node2D


func _ready():
	add_to_group("SurveillanceCameras")
	$CameraViewport/CameraProper.position = global_position
	$CameraViewport.world_2d = get_viewport().world_2d


## Zmienia widoczność światła kamery.
func change_light_visibility():
	if $Light.visible:
		$Light.visible = !$Light.visible
	else:
		$LightTimer.start()


func _on_light_timer_timeout():
	$Light.visible = !$Light.visible
