extends StaticBody2D

var mouse_on_object = false
var original_position = position
var carrying_another = false
var id = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.connect('moved', _on_moved)
	Signals.connect('no_longer_moved', _on_no_longer_moved)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(mouse_on_object)
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && mouse_on_object):
		position = 	get_viewport().get_mouse_position()


func return_to_orig_pos():
	position = original_position

func _on_mouse_entered():
	if(!carrying_another):
		mouse_on_object = true
		Signals.emit_signal('moved', id)
	return


func _on_mouse_exited():
	
	mouse_on_object = false
	if(carrying_another == false):
		print("c")
		Signals.no_longer_moved.emit()


func _on_moved(e):
	if e != id:
		print(id)
		carrying_another = true


func _on_no_longer_moved():
	print("b")
	carrying_another = false
