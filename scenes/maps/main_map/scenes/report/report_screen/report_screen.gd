extends CanvasLayer

## Okresla czy spotkanie
@export var is_emergency_meeting:bool = false
## Id tekstury znalezionego ciała
@export var body_texture_id: int

## Odniesienie do Node'a "TextureRect"
@onready var texture_rect = $TextureRect
## Odniesienie do Node'a "Label"
@onready var label = $Label
## Odniesienie do Node'a "BodySprite"
@onready var body_sprite = $BodySprite

## Teskst dla spotkania awaryjnego
var emergency_meeting_text = "Spotkanie awaryjne!"
## Tekst dla reporta ciała
var body_found_text = "Znaleziono oblanego studenta!"


func _ready():
	if is_emergency_meeting:
		label.text = emergency_meeting_text
		body_sprite.visible = false
	else:
		label.text = body_found_text
		texture_rect.visible = false
		
		var player_body = get_tree().root.get_node("Game/Maps/MainMap/Players/"+str(body_texture_id)).get_node("Skins/PlayerSprite")
		body_sprite.texture = player_body.texture
		
		body_sprite.hframes = 5
		body_sprite.vframes = 2
		body_sprite.frame = 0

		body_sprite.modulate = Color(0, 0.275, 1)
		body_sprite.rotation = PI/2 - PI/12
		body_sprite.scale *= 0.7
