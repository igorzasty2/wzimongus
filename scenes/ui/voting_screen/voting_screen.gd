extends Control

@onready var players = get_node("%Players")
@onready var end_vote_text = get_node("%EndVoteText")
@onready var skip_decision = get_node("%Decision")
@onready var skip_button = get_node("%SkipButton")
@onready var chat_container = get_node("%ChatContainer")
@onready var chat = get_node("%ChatContainer/Chat")
@onready var chat_background = get_node("%ChatContainer/ChatBackground")
@onready var chat_input = %ChatContainer/Chat/ChatContainer/InputText

@export var VOTING_TIME = 10
@onready var voting_timer = Timer.new()

@export var EJECT_PLAYER_TIME = 5
@onready var eject_player_timer = Timer.new()

var player_box = preload("res://scenes/ui/voting_screen/player_box/player_box.tscn")
var ejection_screen = preload("res://scenes/ui/ejection_screen/ejection_screen.tscn")

var time = 0

var is_selected = false

## Określa czy czat jest otwarty
var is_chat_open:bool = false

## Zmienna na UserSettingsManager
var user_sett: UserSettingsManager

## Początkowa skaka siatki z przyciskami
var initial_grid_container_scale

func _ready():
	visible = false
	initial_grid_container_scale = $GridContainer.scale
	user_sett = UserSettingsManager.load_or_create()
	user_sett.interface_scale_value_changed.connect(on_interface_scale_changed)
	on_interface_scale_changed(user_sett.interface_scale)
	
	set_process(false)

## Zaczyna głosowanie
func start_voting():
	visible = true
	
	# Renderuje boxy z graczami (bez głosów)
	_render_player_boxes()

	chat_container.visible = false

	# END VOTING TIMER
	add_child(voting_timer)
	voting_timer.autostart = true
	voting_timer.one_shot = true
	voting_timer.connect("timeout", _on_end_voting_timer_timeout)
	voting_timer.start(VOTING_TIME)

	# EJECT PLAYER TIMER
	add_child(eject_player_timer)
	eject_player_timer.connect("timeout", _on_eject_player_timer_timeout)
	
	set_process(true)


func _process(delta):
	if time < VOTING_TIME:
		time += delta
		var time_remaining = VOTING_TIME - time
		end_vote_text.text = "Głosowanie kończy się za %02d sekund" % time_remaining


func _on_player_voted(voted_player_key):
	skip_button.disabled = true
	GameManager.set_current_game_key("is_voted", true)

	# Dodaje głos do listy głosów na serwerze
	if multiplayer.is_server():
		_add_player_vote(voted_player_key, multiplayer.get_unique_id())
	else:
		_add_player_vote.rpc_id(1, voted_player_key, multiplayer.get_unique_id())


@rpc("any_peer", "call_remote", "reliable")
func _add_player_vote(player_key, voted_by):
	GameManager.add_vote(player_key, voted_by)


## Wyświetla decyzję o skipowaniu
func _on_skip_button_pressed():
	if GameManager.get_current_game_key("is_voted") || GameManager.get_current_game_key("is_vote_preselected"):
		return
	
	skip_decision.visible = true
	GameManager.set_current_game_key("is_vote_preselected", true)


## Zamyka decyzję o skipowaniu
func _on_decision_yes_pressed():
	GameManager.set_current_game_key("is_voted", true)
	skip_decision.visible = false
	skip_button.disabled = true


func _on_decision_no_pressed():
	GameManager.set_current_game_key("is_vote_preselected", false)
	skip_decision.visible = false


@rpc("call_local", "reliable")
## Renderuje boxy z graczami
func _render_player_boxes():
	for i in players.get_children():
		i.queue_free()

	var votes = GameManager.get_current_game_key("votes")

	for i in GameManager.get_registered_players().keys():
		var new_player_box = player_box.instantiate()

		players.add_child(new_player_box)

		new_player_box.init(i, votes[i] if i in votes else [])
		new_player_box.connect("player_voted", _on_player_voted)


## Zamyka głosowanie
func _on_end_voting_timer_timeout():
	GameManager.set_current_game_key("is_voted", true)

	end_vote_text.text = "[center]Głosowanie zakończone![/center]"
	
	eject_player_timer.start(EJECT_PLAYER_TIME)

	# Serwer wysyła głosy do graczy, wynik głosowania i renderuje boxy z graczami
	if multiplayer.is_server():
		var most_voted_player_id = get_most_voted_player_id()

		for player_id in GameManager.get_current_game_key("votes").keys():
			var voted_by_players = GameManager.get_current_game_key("votes")[player_id]
			for voted_by in voted_by_players:
				_add_player_vote.rpc(player_id, voted_by)

		_render_player_boxes.rpc()

		GameManager.set_most_voted_player.rpc(GameManager.get_registered_players()[most_voted_player_id] if most_voted_player_id != null else null)

		#GameManager.kill_player(most_voted_player_id)


## Zmienia scene na ekran wyrzucenia
func _on_eject_player_timer_timeout():
	_change_scene_to_ejection_screen.rpc()


@rpc("any_peer", "call_local", "reliable")
func _change_scene_to_ejection_screen():
	self.get_parent().add_child(ejection_screen.instantiate())
	self.queue_free()


## Zwraca id gracza z największą ilością głosów, jeśli jest remis zwraca null
func get_most_voted_player_id():
	var most_voted_players = []
	var max_vote = 0

	for vote_key in GameManager.get_current_game_key("votes").keys():
		var votes_count = GameManager.get_current_game_key("votes")[vote_key].size()
		if votes_count > max_vote:
			max_vote = votes_count
			most_voted_players = [vote_key]
		elif votes_count == max_vote:
			most_voted_players.append(vote_key)

	if most_voted_players.size() > 1 || most_voted_players.size() == 0:
		return null
	else:
		return most_voted_players[0]


## Obsługuje otwarcie/zamknięcie czatu
func _on_chat_button_button_down():
	if is_chat_open:
		chat_container.visible = false
		chat._close_chat()
		chat.visible = false
		is_chat_open = false
	else:
		chat_container.visible = true
		chat._open_chat()
		chat.visible = true
		is_chat_open = true


## Obsługuje naciśnięcie przycisku menu pauzy
func _on_pause_menu_button_button_down():
	var event = InputEventAction.new()
	event.action = "pause_menu"
	event.pressed = true
	Input.parse_input_event(event)


## Obsługuje zmianę skali nakładki
func on_interface_scale_changed(value:float):
	$GridContainer.scale = initial_grid_container_scale * value
