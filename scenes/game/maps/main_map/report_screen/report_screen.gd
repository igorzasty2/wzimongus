## Ekran reporta
class_name ReportScreen
extends Control

## Okresla czy spotkanie
@export var is_emergency_meeting:bool = false
## Id tekstury znalezionego ciała
@export var body_texture_id: int

## Odniesienie do Node'a "TextureRect"
@onready var _texture_rect = $TextureRect
## Odniesienie do Node'a "Label"
@onready var _label = $Label
## Odniesienie do Node'a "BodySprite"
@onready var _body_sprite = $BodySprite
## Player animacji
@onready var _animation_player = $AnimationPlayer

## Teskst dla spotkania awaryjnego
var _emergency_meeting_text = "Spotkanie awaryjne!"
## Tekst dla reporta ciała
var _body_found_text = "Znaleziono oblanego studenta!"


func _ready():
	if is_emergency_meeting:
		_label.text = _emergency_meeting_text
		_body_sprite.visible = false
		_animation_player.play("shake_animation")
	else:
		_label.text = _body_found_text
		_texture_rect.visible = false
		
		var dead_body = get_tree().root.get_node("Game/Maps/MainMap/DeadBodies/DeadBody"+str(body_texture_id)).get_node("DeadBodySprite")
		if dead_body!=null:
			_body_sprite.texture = dead_body.texture

		_animation_player.play("pulse_animation")
		
		_body_sprite.hframes = 5
		_body_sprite.vframes = 2
		_body_sprite.frame = 0

		_body_sprite.modulate = Color(0, 0.275, 1)
		_body_sprite.rotation = PI/2 - PI/12
		_body_sprite.scale *= 0.7
