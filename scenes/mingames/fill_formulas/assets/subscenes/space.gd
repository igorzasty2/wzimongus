extends Area2D

var base_area:Rect2
var wanted_letter
var correct_area:Rect2

# Called when the node enters the scene tree for the first time.
func _ready():
	base_area = $Sprite2D.get_rect()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _set_area():
	correct_area = Rect2(position - base_area.size/2, base_area.size)
