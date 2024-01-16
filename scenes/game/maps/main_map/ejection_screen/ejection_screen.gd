## Klasa odpowiedzialna za wyświetlenie wiadomości po wyrzuceniu gracza.
class_name EjectionMessage
extends Control

## Czas do następnej rundy
@export var next_round_time = 5

## Referencja do wiadomości, która wyświetla się po wyrzuceniu gracza
@onready var _ejection_message = %EjectionMessage

## Referencja do najczęściej głosowanego gracza
var _most_voted_player = GameManagerSingleton.get_current_game_value("most_voted_player")
## Timer do następnej rundy
var _next_round_timer = Timer.new()


func _ready():
	var _ejected_one = Sprite2D.new()
	
	var texture = AtlasTexture.new()
	if _most_voted_player != null:
		texture.atlas = load(GameManagerSingleton.SKINS[_most_voted_player["skin"]]["resource"])
		texture.region = Rect2(0, 0, 675, 675)
		_ejected_one.texture = texture
	
	_ejected_one.position = Vector2(640, -100)
	
	texture = Sprite2D.new()
	texture.texture = load("res://assets/textures/ejection_screen/ejection_emergency_umbrella.png")
	texture.z_index = -1
	texture.position = Vector2(15, -380)
	texture.rotate(PI/18)
	_ejected_one.add_child(texture)
	_ejected_one.z_index = 1
	_ejected_one.scale = Vector2(0.3, 0.3)
	add_child(_ejected_one)
	
	var fall_tween = get_tree().create_tween()
	fall_tween.tween_property(_ejected_one, "position:y", 900, 3)
	fall_tween.play()
	
	GameManagerSingleton.teleport_players()
	if _most_voted_player == null:
		_ejection_message.text = "[center]Nikt nie został usunięty z grupy[/center]"
	elif _most_voted_player["is_lecturer"]:
		_ejection_message.text = "[center]" + _most_voted_player['username'] + " był wykładowcą[/center]"
	else:
		_ejection_message.text = "[center]" + _most_voted_player['username'] + " nie był wykładowcą[/center]"

	add_child(_next_round_timer)
	_next_round_timer.autostart = true
	_next_round_timer.one_shot = true
	_next_round_timer.connect("timeout", _on_next_round_timer_timeout)
	_next_round_timer.start(next_round_time)


func _on_next_round_timer_timeout():
	self.queue_free()
	GameManagerSingleton.new_round()
