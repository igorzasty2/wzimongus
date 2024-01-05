extends CanvasLayer

## Okresla czy spotkanie
@export var is_meeting:bool = false
## Tesktura znalezionego ciała
@export var body_texture:Texture

## Tekstura spotkania awaryjnego
var emergency_meeting_texture = preload("res://scenes/maps/main_map/scenes/report/emergency_button/assets/emergency_meeting.png")
var body_found_texture = preload("res://scenes/maps/main_map/assets/objects/sala_1_komp.png") # tymczasowo, pozniej usunac

## Teskst dla spotkania awaryjnego
var emergency_meeting_text = "Spotkanie awaryjne"
## Tekst dla reporta ciała
var body_found_text = "Znaleziono oblanego studenta"

## Odniesienie do Node'a "TextureRect"
@onready var texture_rect = $TextureRect
## Odniesienie do Node'a "Label"
@onready var label = $Label

func _ready():
	if is_meeting:
		label.text = emergency_meeting_text
		texture_rect.texture = emergency_meeting_texture
	else:
		label.text = body_found_text
		texture_rect.texture = body_found_texture # zamienic na body_texture
