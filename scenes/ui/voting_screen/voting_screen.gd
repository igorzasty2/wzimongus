class_name VotingScreen
extends Control


## Referencja do kontenera na graczy
@onready var players = get_node("%Players")
## Referencja do tekstu końca głosowania
@onready var end_vote_text = get_node("%EndVoteText")
## Referencja do przycisku o potwierdzeniu skipowaniu głosowania
@onready var skip_decision = get_node("%Decision")
## Referencja do przycisku skipowania
@onready var skip_button = get_node("%SkipButton")
## Referencja do kontenera na czat
@onready var chat_container = get_node("%ChatContainer")
## Referencja do czatu
@onready var chat = get_node("%Chat")
## Referencja do wejścia czati
@onready var chat_input = %ChatContainer/Chat/ChatContainer/InputText

## Czas głosowania
var VOTING_TIME = GameManager.get_server_settings()["voting_time"]
## Timer głosowania
@onready var voting_timer = Timer.new()

## Czas przejścia do ekranu wyrzucenia
var EJECT_PLAYER_TIME = 5
## Timer przejścia do ekranu wyrzucenia
@onready var eject_player_timer = Timer.new()

## Czas dyskusji
var DISCUSSION_TIME = GameManager.get_server_settings()["discussion_time"]
## Timer dyskusji
@onready var discussion_timer = Timer.new()

## Referencja do konkretnego boxa z graczem
var player_box = preload("res://scenes/ui/voting_screen/player_box/player_box.tscn")
## Referencja do ekranu wyrzucenia
var ejection_screen = preload("res://scenes/ui/ejection_screen/ejection_screen.tscn")

## Czas głosowania aktualnie
var time = 0

## Zmienna na czy gracz jest wybrany
var is_selected = false

var is_voting_ended = false

## Zmienna na UserSettingsManager
var user_sett: UserSettingsManager

## Początkowa skaka siatki z przyciskami
var initial_grid_container_scale

func _ready():
	visible = false
	chat.visible = false
	initial_grid_container_scale = $GridContainer.scale
	user_sett = UserSettingsManager.load_or_create()
	user_sett.interface_scale_value_changed.connect(on_interface_scale_changed)
	on_interface_scale_changed(user_sett.interface_scale)

	GameManager.player_deregistered.connect(_on_player_deregistered)

	set_process(false)

## Zaczyna głosowanie
func start_voting():
	visible = true

	# Renderuje boxy z graczami (bez głosów)
	_render_player_boxes()

	for player in players.get_children():
		player.set_voting_status(false)

	chat_container.visible = false
	skip_button.disabled = true


	# END VOTING TIMER
	add_child(voting_timer)
	voting_timer.autostart = true
	voting_timer.one_shot = true
	voting_timer.connect("timeout", _on_end_voting_timer_timeout)

	# EJECT PLAYER TIMER
	add_child(eject_player_timer)
	eject_player_timer.connect("timeout", _on_eject_player_timer_timeout)

	# DISCUSSION TIMER
	add_child(discussion_timer)
	discussion_timer.autostart = true
	discussion_timer.one_shot = true
	discussion_timer.connect("timeout", _on_discussion_timer_timeout)
	discussion_timer.start(DISCUSSION_TIME)


	set_process(true)


func _process(delta):
	if not is_voting_ended:
		_count_time(delta)


func _count_time(delta):
	if time < DISCUSSION_TIME:
		time += delta
		var time_remaining = DISCUSSION_TIME - time
		end_vote_text.text = "[right]Dyskusja kończy się za %02d sekund[/right]" % time_remaining
	elif time < DISCUSSION_TIME + VOTING_TIME:
		time += delta
		var time_remaining = DISCUSSION_TIME + VOTING_TIME - time
		end_vote_text.text = "[right]Głosowanie kończy się za %02d sekund[/right]" % time_remaining

func _on_player_voted(voted_player_key):
	skip_button.disabled = true
	GameManager.set_current_game_key("is_voted", true)

	# Dodaje głos do listy głosów na serwerze
	if multiplayer.is_server():
		_add_player_vote(voted_player_key, multiplayer.get_unique_id())
	else:
		_add_player_vote.rpc_id(1, voted_player_key, multiplayer.get_unique_id())

func _on_player_deregistered(player_id, _player):
	_render_player_boxes()

	if multiplayer.is_server():
		_remove_player_vote(player_id)

func _remove_player_vote(player_key):
	var votes = GameManager.get_current_game_key("votes")

	# Usuń głosy, które były na gracza
	if votes.has(player_key):
		votes.erase(player_key)

	# Usuń głosy, które gracz oddał
	for vote_key in votes.keys():
		votes[vote_key].erase(player_key)

	if _count_all_votes() == _count_alive_players():
		_on_end_voting_timer_timeout.rpc()
		_stop_voting_timer.rpc()

@rpc("any_peer", "call_remote", "reliable")
func _add_player_vote(player_key, voted_by):
	GameManager.add_vote(player_key, voted_by)

	if multiplayer.is_server():
		if _count_all_votes() == _count_alive_players():
			_on_end_voting_timer_timeout.rpc()
			_stop_voting_timer.rpc()

func _count_alive_players():
	var alive_count = 0
	for player_key in GameManager.get_registered_players().keys():
		if GameManager.get_registered_player_key(player_key, "is_dead") == false:
			alive_count += 1
	return alive_count

func _count_all_votes():
	var total_votes = 0
	var votes = GameManager.get_current_game_key("votes")
	for player_key in votes.keys():
		total_votes += votes[player_key].size()
	return total_votes

@rpc("any_peer", "call_local", "reliable")
func _stop_voting_timer():
	voting_timer.stop()

func _on_skip_button_pressed():
	if GameManager.get_current_game_key("is_voted") || GameManager.get_current_game_key("is_vote_preselected"):
		return

	skip_decision.visible = true
	GameManager.set_current_game_key("is_vote_preselected", true)


func _on_decision_yes_pressed():
	GameManager.set_current_game_key("is_voted", true)
	skip_decision.visible = false
	skip_button.disabled = true


func _on_decision_no_pressed():
	GameManager.set_current_game_key("is_vote_preselected", false)
	skip_decision.visible = false


@rpc("call_local", "reliable")
func _render_player_boxes():
	for i in players.get_children():
		i.queue_free()

	var votes = GameManager.get_current_game_key("votes")

	for i in GameManager.get_registered_players().keys():
		var new_player_box = player_box.instantiate()

		players.add_child(new_player_box)

		new_player_box.init(i, votes[i] if i in votes else [])
		new_player_box.connect("player_voted", _on_player_voted)


@rpc("any_peer", "call_local", "reliable")
func _on_end_voting_timer_timeout():
	is_voting_ended = true
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

		GameManager.kill_player(most_voted_player_id)


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


func _on_chat_button_button_down():
	if chat_container.visible:
		GameManager.execute_action("pause_menu")
	else:
		GameManager.execute_action("chat_open")


func _on_pause_menu_button_button_down():
	GameManager.execute_action("pause_menu")


## Obsługuje zmianę skali nakładki
func on_interface_scale_changed(value:float):
	$GridContainer.scale = initial_grid_container_scale * value


func _on_discussion_timer_timeout():
	voting_timer.start(VOTING_TIME)

	if GameManager.get_current_player_key("is_dead"):
		return

	skip_button.disabled = false

	for player in players.get_children():
		player.set_voting_status(true)


func _on_chat_input_visibility_changed():
	if chat_container == null:
		return

	if chat_container.visible:
		chat._close_chat()
		chat.visible = false
		chat_container.visible = false
	else:
		chat._open_chat()
		chat.visible = true
		chat_container.visible = true
