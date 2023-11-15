extends Control


@onready var inputText = get_node("%InputText")
@onready var timer = get_node("%ChatDisappearTimer")
@onready var chatLogsScrollContainer = get_node("%ChatLogsScrollbar")
@onready var chatLogsContainer = get_node("%ChatLogsContainer")
@onready var chatLogsScrollbar = chatLogsScrollContainer.get_v_scroll_bar()


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

var currentGroup = 0
var messageScene = preload("res://scenes/ui/chat/message/message.tscn")
var systemMessageScene = preload("res://scenes/ui/chat/system_message/system_message.tscn")
var tween 

func _ready():

	chatLogsScrollbar.changed.connect(_handle_scrollbar_changed)


	# TODO: Get impostor status from game manager
	# if isImpostor:
	#   currentGroup = 1

	inputText.hide()

	# TODO: If dead, change group to 2
	# currentGroup = 2


	

func _process(_delta):
	if Input.is_action_just_pressed("chat_open"):
		inputText.grab_focus()
		inputText.show()
		chatLogsScrollContainer.modulate.a = 1
		

	if Input.is_action_just_pressed("chat_close"):
		inputText.release_focus()
		inputText.hide()
		timer.start()
		inputText.text = ""


@rpc("any_peer", "call_local")
func send_message(message, group, id):

	if group == 2:
		if currentGroup == 2:
			_create_message(MultiplayerManager.players[id].username, message, 2)
			return
		return
	
	if group == 1:
		if currentGroup == 1:
			_create_message(MultiplayerManager.players[id].username, message, 1)
			return
		else:
			_create_message(MultiplayerManager.players[id].username, message, 0)
			return
	
	if group == 3:
		var systemMessageInstance = systemMessageScene.instantiate()
		chatLogsContainer.add_child(systemMessageInstance)
		systemMessageInstance.init(message)
		return


	_create_message(MultiplayerManager.players[id].username, message, currentGroup)
	

@rpc("authority", "call_local")
func send_system_message(message):
	send_message.rpc(message, 3, 1)


func _create_message(username, message, group):
	chatLogsScrollContainer.modulate.a = 1
	var messageInstance = messageScene.instantiate()
	chatLogsContainer.add_child(messageInstance)
	messageInstance.init(username, message, chatGroups[group]["color"])

	timer.start()


func _on_input_text_text_submitted(new_text):
	new_text = new_text.strip_edges()

	if new_text == "":
		return

	send_message.rpc(new_text, currentGroup, multiplayer.get_unique_id())

	inputText.text = ""


func _on_timer_timeout():
	if inputText.has_focus():
		return
	tween = get_tree().create_tween()
	tween.tween_property(chatLogsScrollContainer, "modulate:a", 0, 0.25)


func _handle_scrollbar_changed():
	if max_scroll_length != chatLogsScrollbar.max_value:
		max_scroll_length = chatLogsScrollbar.get_max()
		chatLogsScrollContainer.scroll_vertical = max_scroll_length
