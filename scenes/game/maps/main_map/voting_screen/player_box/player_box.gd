class_name PlayerBox
extends Control

## Referencja do awatara gracza
@onready var avatar = get_node("%Avatar")
## Referencja do nazwy gracza
@onready var username = get_node("%Username")
## Referencja do decyzji gracza
@onready var decision = get_node("%Decision")
## Referencja do kontenera z głosującymi
@onready var voted_by_container = get_node("%VotedBy")
## Referencja do przycisku odpalającego potwierdzenie głosu
@onready var button = get_node("%Button")

## Sygnał emitowany gdy gracz zagłosuje
signal player_voted
## Sygnał emitowany gdy gracz zostanie wybrany
signal player_selected

## Klucz gracza
var player_key
## Tween do animacji
var display_tween

## Scena z głosującymi
var voted_by_scene = preload("res://scenes/game/maps/main_map/voting_screen/voted_by/voted_by.tscn")

## Funkcja inicjalizująca box gracza
func init(player_id: int, voted_by: Array):
	var player = GameManagerSingleton.get_registered_players()[player_id]

	if GameManagerSingleton.get_registered_player_value(player_id, "is_dead"):
		self.username.text = "[s]" + player.username + "[/s]"
	else:
		self.username.text = player.username
	
	self.player_key = player_id
	self.avatar.texture = _get_skin_texture(player.skin)

	for vote in voted_by:
		var voted_by_instance = voted_by_scene.instantiate()
		voted_by_instance.modulate.a = 0;

		voted_by_instance.texture = _get_skin_texture(GameManagerSingleton.get_registered_player_value(vote, "skin"))

		display_tween = get_tree().create_tween()
		display_tween.tween_property(voted_by_instance, "modulate:a", 1, 0.25)

		voted_by_container.add_child(voted_by_instance)
	


func _get_skin_texture(skin_id: int) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = load(GameManagerSingleton.SKINS[skin_id]["resource"])
	texture.region = Rect2(127.5, 0, 420, 420)
	return texture


func _on_button_pressed():
	if GameManagerSingleton.get_registered_player_value(player_key, "is_dead"):
		return

	if GameManagerSingleton.get_current_game_value("is_voted") || GameManagerSingleton.get_current_game_value("is_vote_preselected"):
		return
	
	if decision.visible:
		decision.visible = false
		GameManagerSingleton.set_current_game_value("is_vote_preselected", false)
		return
	
	decision.visible = true
	GameManagerSingleton.set_current_game_value("is_vote_preselected", true)


func _on_decision_no_pressed():
	decision.visible = false
	GameManagerSingleton.set_current_game_value("is_vote_preselected", false)


func _on_decision_yes_pressed():
	decision.visible = false
	emit_signal("player_voted", player_key)

## Funkcja ustawiająca status głosowania
func set_voting_status(is_voted: bool):
	if is_voted:
		button.pressed.connect(_on_button_pressed)
	else:
		button.pressed.disconnect(_on_button_pressed)