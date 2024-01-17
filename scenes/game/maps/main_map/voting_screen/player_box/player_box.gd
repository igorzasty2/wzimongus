## Klasa odpowiadająca za box gracza w ekranie głosowania.
class_name VotingScreenPlayerBox
extends Control

## Referencja do awatara gracza.
@onready var _avatar = get_node("%Avatar")
## Referencja do nazwy gracza.
@onready var _username = get_node("%Username")
## Referencja do decyzji gracza.
@onready var _decision = get_node("%Decision")
## Referencja do kontenera z głosującymi.
@onready var _voted_by_container = get_node("%VotedBy")
## Referencja do przycisku odpalającego potwierdzenie głosu.
@onready var _button = get_node("%Button")
## Referencja do ikony reporta.
@onready var report = $VBoxContainer/Panel/Player/Report

## Sygnał emitowany gdy gracz zagłosuje.
signal player_voted
## Sygnał emitowany gdy gracz zostanie wybrany.
signal player_selected

## Klucz gracza.
var _player_key
## Tween do animacji.
var _display_tween

## Scena z głosującymi.
var _voted_by_scene = preload("res://scenes/game/maps/main_map/voting_screen/voted_by/voted_by.tscn")


## Funkcja inicjalizująca box gracza.
func init(player_id: int, voted_by: Array):
	var player = GameManagerSingleton.get_registered_players()[player_id]

	if GameManagerSingleton.get_registered_player_value(player_id, "is_dead"):
		_username.text = "[s][color=red]" + player.username + "[/color][/s]"
		modulate.a8 = 128
	else:
		_username.text = player.username

	_player_key = player_id
	_avatar.texture = _get_skin_texture(player.skin)
	
	report.visible = false

	for vote in voted_by:
		var voted_by_instance = _voted_by_scene.instantiate()
		voted_by_instance.modulate.a = 0

		voted_by_instance.texture = _get_skin_texture(GameManagerSingleton.get_registered_player_value(vote, "skin"))

		_display_tween = get_tree().create_tween()
		_display_tween.tween_property(voted_by_instance, "modulate:a", 1, 0.25)

		_voted_by_container.add_child(voted_by_instance)


func _get_skin_texture(skin_id: int) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = load(GameManagerSingleton.SKINS[skin_id]["resource"])
	texture.region = Rect2(127.5, 0, 420, 420)
	return texture


func _on_button_pressed():
	if GameManagerSingleton.get_registered_player_value(_player_key, "is_dead"):
		return

	if (
		GameManagerSingleton.get_current_game_value("is_voted")
		|| GameManagerSingleton.get_current_game_value("is_vote_preselected")
	):
		return

	if _decision.visible:
		_decision.visible = false
		GameManagerSingleton.set_current_game_value("is_vote_preselected", false)
		return

	_decision.visible = true
	GameManagerSingleton.set_current_game_value("is_vote_preselected", true)


func _on_decision_no_pressed():
	_decision.visible = false
	GameManagerSingleton.set_current_game_value("is_vote_preselected", false)


func _on_decision_yes_pressed():
	_decision.visible = false
	emit_signal("player_voted", _player_key)


## Funkcja ustawiająca status głosowania.
func set_voting_status(is_voted: bool):
	if is_voted:
		_button.pressed.connect(_on_button_pressed)
		if !GameManagerSingleton.get_registered_player_value(_player_key, "is_dead"):
			modulate.a8 = 255
	else:
		_button.pressed.disconnect(_on_button_pressed)
		modulate.a8 = 128
