## Klasa czatu.
class_name Chat
extends CanvasLayer

## Emitowany, gdy zmieni się widoczność pola tekstowego.
signal input_visibility_changed()

## Grupy czatu
enum Group { GLOBAL, LECTURER, DEAD, SYSTEM }

## Kolor grupy
const GROUP_COLORS = {
	Group.GLOBAL: "white",
	Group.LECTURER: "red",
	Group.DEAD: "gray",
	Group.SYSTEM: "yellow"
}

## Czas po którym czat zniknie
const FADE_OUT_TIME = 0.25

## Referencja do pola tekstowego
@onready var _input_text = $%InputText
## Referencja do timera
@onready var _timer = $%ChatDisappearTimer
## Referencja do kontenera z logami czatu
@onready var _chat_logs_scroll_container = $%ChatLogsScrollbar
## Referencja do kontenera z logami czatu
@onready var _chat_logs_container = $%ChatLogsContainer
## Referencja do suwaka
@onready var _chat_logs_scrollbar = _chat_logs_scroll_container.get_v_scroll_bar()

## Referencja do kontenera przycisku zmiany grupy
@onready var _group_container = %GroupContainer

## Referencja do etykiety grupy
@onready var _group_label = %GroupLabel

## Scena wiadomości
var _message_scene = preload("res://scenes/ui/chat/message/message.tscn")
## Scena wiadomości systemowej
var _system_message_scene = preload("res://scenes/ui/chat/system_message/system_message.tscn")

## Zmienna przechowująca ostatnią wartość suwaka
var _last_known_scroll_max = 0
## Zmienna przechowująca aktualną grupę
var _current_group = Group.GLOBAL
## Zmienna przechowująca tweena
var _fade_out_tween


func _ready():
	_chat_logs_scrollbar.changed.connect(_update_scrollbar_position)
	_input_text.hide()
	_group_container.hide()

	if GameManagerSingleton.get_current_player_value("is_dead"):
		_current_group = Group.DEAD

	_update_group_label()


func _input(event):
	if event.is_action_pressed("chat_open"):
		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		if _input_text.visible:
			return

		open_chat()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("change_group"):
		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		if !_input_text.visible:
			return

		_switch_chat_group()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("pause_menu"):
		if !_input_text.visible:
			return

		close_chat()
		get_viewport().set_input_as_handled()


func _switch_chat_group():
	if GameManagerSingleton.get_current_player_value("is_lecturer"):
		_current_group = Group.LECTURER if _current_group == Group.GLOBAL else Group.GLOBAL
		_update_group_label()


func _update_group_label():
	if GameManagerSingleton.get_current_player_value("is_dead"):
		_group_label.text = "Uczestniczysz w grupie: Martwi"
	elif GameManagerSingleton.get_current_player_value("is_lecturer"):
		_group_label.text = "Uczestniczysz w grupie: Wykładowcy" if _current_group == Group.LECTURER else "Uczestniczysz w grupie: Studenci"
	else:
		_group_label.text = "Uczestniczysz w grupie: Studenci"



@rpc("any_peer", "call_local", "reliable")
## Wysyła wiadomość do wszystkich graczy.
func _send_message(message, group, id):
	match group:
		Group.DEAD:
			if _current_group == Group.DEAD:
				_create_message(GameManagerSingleton.get_registered_players()[id], message, Group.DEAD)
		Group.LECTURER:
			if _current_group == Group.LECTURER or _current_group == Group.DEAD:
				_create_message(GameManagerSingleton.get_registered_players()[id], message, Group.LECTURER)
		Group.SYSTEM:
			var system_message_instance = _system_message_scene.instantiate()
			_chat_logs_container.add_child(system_message_instance)
			system_message_instance.init(message)
			_chat_logs_scroll_container.modulate.a = 1

			if get_parent().name != "VotingScreen":
				_timer.start()
		_:
			_create_message(GameManagerSingleton.get_registered_players()[id], message, Group.GLOBAL)

	if multiplayer.is_server():
		for peer_id in GameManagerSingleton.get_registered_players().keys():
			if peer_id != 1:
				_send_message.rpc_id(peer_id, message, group, id)

## Wysyła wiadomość systemową.
func send_system_message(message):
	const SYSTEM_MESSAGE_ID = 1
	_send_message(message, Group.SYSTEM, SYSTEM_MESSAGE_ID)


func _create_message(player: Dictionary, message: String, group: Group):
	_chat_logs_scroll_container.modulate.a = 1

	var new_message = _message_scene.instantiate()
	_chat_logs_container.add_child(new_message)

	new_message.init(player, message, GROUP_COLORS[group])

	if get_parent().get_parent().name != "VotingScreen":
		_timer.start()


func _on_input_text_visibility_changed():
	input_visibility_changed.emit()


func _on_input_text_text_submitted(submitted_text):
	submitted_text = submitted_text.strip_edges()

	if submitted_text == "":
		return

	_send_message.rpc_id(1, submitted_text, _current_group, GameManagerSingleton.get_current_player_id())

	if get_parent().get_parent().name != "VotingScreen":
		close_chat()
	else:
		_input_text.text = ""



func _on_timer_timeout():
	if _input_text.has_focus():
		return

	_fade_out_tween = get_tree().create_tween()
	_fade_out_tween.tween_property(_chat_logs_scroll_container, "modulate:a", 0, FADE_OUT_TIME)


func _update_scrollbar_position():
	if _last_known_scroll_max != _chat_logs_scrollbar.max_value:
		_last_known_scroll_max = _chat_logs_scrollbar.max_value
		_chat_logs_scroll_container.scroll_vertical = _last_known_scroll_max


## Otwiera czat.
func open_chat():
	_input_text.grab_focus()
	_input_text.show()
	_group_container.show()
	_chat_logs_scroll_container.modulate.a = 1


## Zamyka czat.
func close_chat():
	_input_text.text = ""
	_input_text.release_focus()

	_input_text.hide()
	_group_container.hide()

	if get_parent().get_parent().name != "VotingScreen":
		_timer.start()


func _on_group_change_button_pressed():
	GameManagerSingleton.execute_action("change_group")
	_input_text.grab_focus()
