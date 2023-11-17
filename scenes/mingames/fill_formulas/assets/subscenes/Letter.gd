extends StaticBody2D

var mouse_on_object = false
var original_position = position
var id = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(mouse_on_object)
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && mouse_on_object):
		position = 	get_viewport().get_mouse_position()


func return_to_orig_pos():
	position = original_position

func _on_mouse_entered():
	if (!get_parent().isMoving):
		mouse_on_object = true
		get_parent().isMoving = true
		get_parent().isMovingId = id


func _on_mouse_exited():
	if (get_parent().isMoving && get_parent().isMovingId == id):
		mouse_on_object = false
		get_parent().isMoving = false
