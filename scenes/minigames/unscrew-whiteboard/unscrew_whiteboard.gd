extends Node2D

signal minigame_end

@onready var screws = [%Screw, %Screw2, %Screw3, %Screw4, %Screw5, %Screw6, %Screw7, %Screw8]
@onready var whiteboard = %Whiteboard

var is_rotating = [false, false, false, false, false, false, false, false]
var rotation_angles = [0, 0, 0, 0, 0, 0, 0, 0]
var is_unscrewed = [false, false, false, false, false, false, false, false]

var tween


func _process(delta):
	var rotation_speed = 8 * delta
	for i in range(screws.size()):
		if is_rotating[i]:
			screws[i].get_child(0).rotate(rotation_speed)
			rotation_angles[i] += rotation_speed
			if rotation_angles[i] >= 2 * PI:  # 2*PI radians is 360 degrees
				screws[i].visible = false
				is_rotating[i] = false
				rotation_angles[i] = 0
				is_unscrewed[i] = true

	var minigame_ended = false
	var all_unscrewed = true
	for unscrewed in is_unscrewed:
		if not unscrewed:
			all_unscrewed = false
			break

	if all_unscrewed and not minigame_ended:
		minigame_ended = true
		tween = create_tween()
		tween.tween_property(whiteboard, "position:y", 483, 0.2)
		tween.finished.connect(_on_tween_completed)

		
func _on_tween_completed():
	emit_signal("minigame_end")
	queue_free()

func _on_screw_button_down(index):
	is_rotating[index] = true

func _on_screw_button_up(index):
	is_rotating[index] = false

func _on_screw_1_button_down():
	_on_screw_button_down(0)

func _on_screw_1_button_up():
	_on_screw_button_up(0)

func _on_screw_2_button_down():
	_on_screw_button_down(1)

func _on_screw_2_button_up():
	_on_screw_button_up(1)

func _on_screw_3_button_down():
	_on_screw_button_down(2)

func _on_screw_3_button_up():
	_on_screw_button_up(2)

func _on_screw_4_button_down():
	_on_screw_button_down(3)

func _on_screw_4_button_up():
	_on_screw_button_up(3)

func _on_screw_5_button_down():
	_on_screw_button_down(4)

func _on_screw_5_button_up():
	_on_screw_button_up(4)

func _on_screw_6_button_down():
	_on_screw_button_down(5)

func _on_screw_6_button_up():
	_on_screw_button_up(5)

func _on_screw_7_button_down():
	_on_screw_button_down(6)

func _on_screw_7_button_up():
	_on_screw_button_up(6)

func _on_screw_8_button_down():
	_on_screw_button_down(7)

func _on_screw_8_button_up():
	_on_screw_button_up(7)
