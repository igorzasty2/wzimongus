extends Control

@onready var avatar = get_node("%Avatar")
@onready var username = get_node("%Username")
@onready var decision = get_node("%Decision")
@onready var voted_by_container = get_node("%VotedBy")
@onready var button = get_node("%Button")

signal player_voted
signal player_selected

var player_key
var display_tween

var voted_by_scene = preload("res://scenes/ui/voting_screen/voted_by/voted_by.tscn")


func init(player_id: int, voted_by: Array):
	var player = GameManager.get_registered_players()[player_id]

	if GameManager.get_registered_player_key(player_id, "is_dead"):
		self.username.text = "[s]" + player.username + "[/s]"
	else:
		self.username.text = player.username
	
	self.player_key = player_id
	self.avatar.texture = _get_skin_texture(player.skin)

	for vote in voted_by:
		var voted_by_instance = voted_by_scene.instantiate()
		voted_by_instance.modulate.a = 0;

		voted_by_instance.texture = _get_skin_texture(GameManager.get_registered_player_key(vote, "skin"))

		display_tween = get_tree().create_tween()
		display_tween.tween_property(voted_by_instance, "modulate:a", 1, 0.25)

		voted_by_container.add_child(voted_by_instance)

func set_voting_status(is_voted: bool):
	if is_voted:
		button.pressed.connect(_on_button_pressed)
	else:
		button.pressed.disconnect(_on_button_pressed)

func _get_skin_texture(skin_id: int) -> AtlasTexture:
	var texture = AtlasTexture.new()
	texture.atlas = load(GameManager.skins[skin_id]["resource"])
	texture.region = Rect2(127.5, 0, 420, 420)
	return texture


func _on_button_pressed():
	if GameManager.get_registered_player_key(player_key, "is_dead"):
		return

	if GameManager.get_current_game_key("is_voted") || GameManager.get_current_game_key("is_vote_preselected"):
		return
	
	if decision.visible:
		decision.visible = false
		GameManager.set_current_game_key("is_vote_preselected", false)
		return
	
	decision.visible = true
	GameManager.set_current_game_key("is_vote_preselected", true)


func _on_decision_no_pressed():
	decision.visible = false
	GameManager.set_current_game_key("is_vote_preselected", false)


func _on_decision_yes_pressed():
	decision.visible = false
	emit_signal("player_voted", player_key)
