extends Control


@onready var input_text = get_node("%InputText")
@onready var timer = get_node("%ChatDisappearTimer")
@onready var chat_logs_scroll_container = get_node("%ChatLogsScrollbar")
@onready var chat_logs_container = get_node("%ChatLogsContainer")
@onready var chat_logs_scrollbar = chat_logs_scroll_container.get_v_scroll_bar()


var max_scroll_length = 0

#* send_message - Wysyła wiadomość do wszystkich graczy
#* send_system_message - Wysyła systemową wiadomość do wszystkich graczy


var chatGroups = [
	{"name": "Global", "color": "white"},
	{"name": "Impostor", "color": "red"},
	{"name": "Dead", "color": "gray"},
	{"name": "System", "color": "yellow"},
]

@onready var username = MultiplayerManager.player_info.username

var current_group = 0
var message_scene = preload("res://scenes/ui/chat/message/message.tscn")
var system_message_scene = preload("res://scenes/ui/chat/system_message/system_message.tscn")
var tween 

func _ready():

	chat_logs_scrollbar.changed.connect(_handle_scrollbar_changed)


	# TODO: Get impostor status from game manager
	# if isImpostor:
	#   current_group = 1

	input_text.hide()

	# TODO: If dead, change group to 2
	# current_group = 2


	

func _process(_delta):
	if Input.is_action_just_pressed("chat_open"):
		input_text.grab_focus()
		input_text.show()
		chat_logs_scroll_container.modulate.a = 1
		

	if Input.is_action_just_pressed("chat_close"):
		input_text.release_focus()
		input_text.hide()
		timer.start()
		input_text.text = ""


@rpc("any_peer", "call_local")
func send_message(message, group, id):

	if group == 2:
		if current_group == 2:
			_create_message(MultiplayerManager.players[id].username, message, 2)
			return
		return
	
	if group == 1:
		if current_group == 1:
			_create_message(MultiplayerManager.players[id].username, message, 1)
			return
		else:
			_create_message(MultiplayerManager.players[id].username, message, 0)
			return
	
	if group == 3:
		var system_message_instane = system_message_scene.instantiate()
		chat_logs_container.add_child(system_message_instane)
		system_message_instane.init(message)
		return


	_create_message(MultiplayerManager.players[id].username, message, current_group)
	

@rpc("authority", "call_local")
func send_system_message(message):
	send_message.rpc(message, 3, 1)


func _create_message(username, message, group):
	chat_logs_scroll_container.modulate.a = 1
	var message_instance = message_scene.instantiate()
	chat_logs_container.add_child(message_instance)
	message_instance.init(username, message, chatGroups[group]["color"])

	timer.start()


func _on_input_text_text_submitted(new_text):
	new_text = new_text.strip_edges()

	if new_text == "":
		return

	send_message.rpc(new_text, current_group, multiplayer.get_unique_id())

	input_text.text = ""


func _on_timer_timeout():
	if input_text.has_focus():
		return
	tween = get_tree().create_tween()
	tween.tween_property(chat_logs_scroll_container, "modulate:a", 0, 0.25)


func _handle_scrollbar_changed():
	if max_scroll_length != chat_logs_scrollbar.max_value:
		max_scroll_length = chat_logs_scrollbar.get_max()
		chat_logs_scroll_container.scroll_vertical = max_scroll_length
