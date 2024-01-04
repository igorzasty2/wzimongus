extends CanvasLayer

@export var is_meeting:bool = false

var emergency_meeting_texture = preload("res://scenes/maps/main_map/assets/objects/aula_projektor.png")
var body_found_texture = preload("res://scenes/maps/main_map/assets/objects/sala_1_komp.png")

var emergency_meeting_text = "Spotkanie awaryjne"
var body_found_text = "Znaleziono oblanego studenta"

@onready var texture_rect = $TextureRect
@onready var label = $Label

func _ready():
	if is_meeting:
		label.text = emergency_meeting_text
		texture_rect.texture = emergency_meeting_texture
	else:
		label.text = body_found_text
		texture_rect.texture = body_found_texture
