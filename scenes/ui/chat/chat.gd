extends Control

enum Group { GLOBAL, IMPOSTOR, DEAD, SYSTEM }

const GROUP_COLORS = {
	Group.GLOBAL: "white",
	Group.IMPOSTOR: "red",
	Group.DEAD: "gray",
	Group.SYSTEM: "yellow"
}

const FADE_OUT_TIME = 0.25

@onready var input_text = $%InputText
@onready var timer = $%ChatDisappearTimer
@onready var chat_logs_scroll_container = $%ChatLogsScrollbar
@onready var chat_logs_container = $%ChatLogsContainer
@onready var chat_logs_scrollbar = chat_logs_scroll_container.get_v_scroll_bar()
@onready var username = GameManager.get_current_player_info("username")

var message_scene = preload("res://scenes/ui/chat/message/message.tscn")
var system_message_scene = preload("res://scenes/ui/chat/system_message/system_message.tscn")


var last_known_scroll_max = 0
var current_group = Group.IMPOSTOR
var fade_out_tween 

func _ready():

	chat_logs_scrollbar.changed.connect(_update_scrollbar_position)
	input_text.hide()


func _process(_delta):
	if Input.is_action_just_pressed("chat_open"):
		_open_chat()
	if Input.is_action_just_pressed("chat_close"):
		_close_chat()


@rpc("any_peer", "call_local")
func send_message(message, group, id):
	match group:
		Group.DEAD:
			if current_group == Group.DEAD:
				_create_message(GameManager.get_registered_player_info(id, "username"), message, Group.DEAD)
		Group.IMPOSTOR:
			if current_group == Group.IMPOSTOR:
				_create_message(GameManager.get_registered_player_info(id, "username"), message, Group.IMPOSTOR)
			else:
				_create_message(GameManager.get_registered_player_info(id, "username"), message, Group.GLOBAL)
		Group.SYSTEM:
			var system_message_instance = system_message_scene.instantiate()
			chat_logs_container.add_child(system_message_instance)
			system_message_instance.init(message)
		_:
			_create_message(GameManager.get_registered_player_info(id, "username"), message, current_group)
	
	if multiplayer.is_server():
		for peer_id in GameManager.get_registered_players().keys():
			if peer_id != 1:
				send_message.rpc_id(peer_id, message, group, id)

@rpc("authority", "call_local")
func send_system_message(message):
	const SYSTEM_MESSAGE_ID = 1
	send_message.rpc(message, Group.SYSTEM, SYSTEM_MESSAGE_ID)


func _create_message(username, message, group):
	chat_logs_scroll_container.modulate.a = 1

	var new_message = message_scene.instantiate()
	chat_logs_container.add_child(new_message)

	new_message.init(username, message, GROUP_COLORS[group])

	timer.start()


func _on_input_text_text_submitted(submitted_text):
	submitted_text = submitted_text.strip_edges()

	if submitted_text == "":
		return

	send_message.rpc_id(1, submitted_text, current_group, multiplayer.get_unique_id())	

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

func _open_chat():
	input_text.grab_focus()
	input_text.show()
	chat_logs_scroll_container.modulate.a = 1

func _close_chat():
	input_text.release_focus()
	input_text.hide()
	timer.start()
	input_text.text = ""
