## Klasa odpowiedzialna za ruch telefonu w scenie.
class_name MakeAPhotoPhone
extends CharacterBody2D

var _speed = 0.3
var _rect_size_x = 350
var _rect_size_y = 160
var _papers_x_left = 430
var _papers_x_right = 780
var _papers_y_top = 181
var _papers_y_bottom = 411
var _make_a_photo: Button


## Pokazuje telefon.
func show_the_phone_and_start():
	self.visible = true


func _ready():
	set_process_input(true)


func _input(_event):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var viewport_rect = get_viewport_rect()
		var mouse_pos = get_global_mouse_position()
		if viewport_rect.has_point(mouse_pos):
			if self.visible and _is_mouse_over():
				position = position.lerp(mouse_pos, _speed)
				_papers_in_screen()


func _papers_in_screen():
	var rect_pos = global_position
	if (
		_papers_x_left > rect_pos.x - _rect_size_x
		&& _papers_x_right < rect_pos.x + _rect_size_x
		&& _papers_y_top > rect_pos.y - _rect_size_y
		&& _papers_y_bottom < rect_pos.y + _rect_size_y
	):
		_make_a_photo = get_tree().get_first_node_in_group("to_make_a_photo")
		_make_a_photo.show_and_ready()
	else:
		_make_a_photo = get_tree().get_first_node_in_group("to_make_a_photo")
		_make_a_photo.hide_and_not_ready()


func _is_mouse_over() -> bool:
	var rect_pos = global_position
	var mouse_pos = get_global_mouse_position()

	return (
		mouse_pos.x > rect_pos.x - _rect_size_x
		&& mouse_pos.x < rect_pos.x + _rect_size_x
		&& mouse_pos.y > rect_pos.y - _rect_size_y
		&& mouse_pos.y < rect_pos.y + _rect_size_y
	)
