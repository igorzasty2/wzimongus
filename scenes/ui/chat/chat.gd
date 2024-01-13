class_name Chat
extends CanvasLayer

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
@onready var input_text = $%InputText
## Referencja do timera
@onready var timer = $%ChatDisappearTimer
## Referencja do kontenera z logami czatu
@onready var chat_logs_scroll_container = $%ChatLogsScrollbar
## Referencja do kontenera z logami czatu
@onready var chat_logs_container = $%ChatLogsContainer
## Referencja do suwaka
@onready var chat_logs_scrollbar = chat_logs_scroll_container.get_v_scroll_bar()
## Referencja do nazwy gracza, przechowywana
@onready var username = GameManagerSingleton.get_current_player_value("username")

## Referencja do kontenera przycisku zmiany grupy
@onready var group_container = %GroupContainer

## Referencja do etykiety grupy
@onready var group_label = %GroupLabel

## Scena wiadomości
var message_scene = preload("res://scenes/ui/chat/message/message.tscn")
## Scena wiadomości systemowej
var system_message_scene = preload("res://scenes/ui/chat/system_message/system_message.tscn")

## Zmienna przechowująca ostatnią wartość suwaka
var last_known_scroll_max = 0
## Zmienna przechowująca aktualną grupę
var current_group = Group.GLOBAL
## Zmienna przechowująca tweena
var fade_out_tween


func _ready():
	chat_logs_scrollbar.changed.connect(_update_scrollbar_position)
	input_text.hide()
	group_container.hide()

	if GameManagerSingleton.get_current_player_value("is_dead"):
		current_group = Group.DEAD

	_update_group_label()


func _input(event):
	if event.is_action_pressed("chat_open"):
		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		if input_text.visible:
			return

		open_chat()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("change_group"):
		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		if !input_text.visible:
			return

		_switch_chat_group()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("pause_menu"):
		if !input_text.visible:
			return

		close_chat()
		get_viewport().set_input_as_handled()


func _switch_chat_group():
	if GameManagerSingleton.get_current_player_value("is_lecturer"):
		current_group = Group.LECTURER if current_group == Group.GLOBAL else Group.GLOBAL
		_update_group_label()


func _update_group_label():
	if GameManagerSingleton.get_current_player_value("is_dead"):
		group_label.text = "Uczestniczysz w grupie: Martwi"
	elif GameManagerSingleton.get_current_player_value("is_lecturer"):
		group_label.text = "Uczestniczysz w grupie: Wykładowcy" if current_group == Group.LECTURER else "Uczestniczysz w grupie: Studenci"
	else:
		group_label.text = "Uczestniczysz w grupie: Studenci"



@rpc("any_peer", "call_local", "reliable")
## Funkcja wysyłająca wiadomość
func send_message(message, group, id):
	match group:
		Group.DEAD:
			if current_group == Group.DEAD:
				_create_message(GameManagerSingleton.get_registered_players()[id], message, Group.DEAD)
		Group.LECTURER:
			if current_group == Group.LECTURER or current_group == Group.DEAD:
				_create_message(GameManagerSingleton.get_registered_players()[id], message, Group.LECTURER)
		Group.SYSTEM:
			var system_message_instance = system_message_scene.instantiate()
			chat_logs_container.add_child(system_message_instance)
			system_message_instance.init(message)
			chat_logs_scroll_container.modulate.a = 1

			if get_parent().name != "VotingScreen":
				timer.start()
		_:
			_create_message(GameManagerSingleton.get_registered_players()[id], message, Group.GLOBAL)

	if multiplayer.is_server():
		for peer_id in GameManagerSingleton.get_registered_players().keys():
			if peer_id != 1:
				send_message.rpc_id(peer_id, message, group, id)

## Funkcja wysyłająca wiadomość systemową
func send_system_message(message):
	const SYSTEM_MESSAGE_ID = 1
	send_message(message, Group.SYSTEM, SYSTEM_MESSAGE_ID)


func _create_message(player: Dictionary, message: String, group: Group):
	chat_logs_scroll_container.modulate.a = 1

	var new_message = message_scene.instantiate()
	chat_logs_container.add_child(new_message)

	new_message.init(player, message, GROUP_COLORS[group])

	if get_parent().get_parent().name != "VotingScreen":
		timer.start()


func _on_input_text_visibility_changed():
	input_visibility_changed.emit()


func _on_input_text_text_submitted(submitted_text):
	submitted_text = submitted_text.strip_edges()

	if submitted_text == "":
		return

	send_message.rpc_id(1, submitted_text, current_group, GameManagerSingleton.get_current_player_id())

	if get_parent().get_parent().name != "VotingScreen":
		close_chat()
	else:
		input_text.text = ""



func _on_timer_timeout():
	if input_text.has_focus():
		return

	fade_out_tween = get_tree().create_tween()
	fade_out_tween.tween_property(chat_logs_scroll_container, "modulate:a", 0, FADE_OUT_TIME)


func _update_scrollbar_position():
	if last_known_scroll_max != chat_logs_scrollbar.max_value:
		last_known_scroll_max = chat_logs_scrollbar.max_value
		chat_logs_scroll_container.scroll_vertical = last_known_scroll_max


func open_chat():
	input_text.grab_focus()
	input_text.show()
	group_container.show()
	chat_logs_scroll_container.modulate.a = 1


func close_chat():
	input_text.text = ""
	input_text.release_focus()

	input_text.hide()
	group_container.hide()

	if get_parent().get_parent().name != "VotingScreen":
		timer.start()


func _on_group_change_button_pressed():
	GameManagerSingleton.execute_action("change_group")
	input_text.grab_focus()
