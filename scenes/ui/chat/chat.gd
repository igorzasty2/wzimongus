extends Control


@onready var inputNickname = get_node("%InputNickname")
@onready var inputGroup = get_node("%InputGroup")
@onready var inputText = get_node("%InputText")
@onready var inputContainer = get_node("%InputContainer")
@onready var timer = get_node("%ChatDisappearTimer")
@onready var chatLogsScrollContainer = get_node("%ChatLogsScrollbar")
@onready var chatLogsContainer = get_node("%ChatLogsContainer")

var chatLogsScrollbar
var max_scroll_length = 0

#* send_message - Wysyła wiadomość do wszystkich graczy
#* send_system_message - Wysyła systemową wiadomość do wszystkich graczy


var chatGroups = [
	{"name": "Global", "color": "blue"},
	{"name": "Impostor", "color": "red"},
	{"name": "System", "color": "FF0000"},
]
var currentGroup = 0
var nickname
var isImpostor

var messageScene = preload("res://scenes/ui/chat/message/message.tscn")


func _ready():

	chatLogsScrollbar = chatLogsScrollContainer.get_v_scroll_bar()
	chatLogsScrollbar.changed.connect(_handle_scrollbar_changed)



	# TODO: Get nickname from server
	nickname = "Valcast"

	# TODO: Get impostor status from server
	isImpostor = true

	inputNickname.text = nickname
	inputGroup.text = "[%s]" % chatGroups[currentGroup]["name"]

	inputContainer.hide()


func _process(_delta):
	if Input.is_action_just_pressed("chat_open"):
		inputText.grab_focus()
		inputContainer.show()
		

	if Input.is_action_just_pressed("chat_close"):
		inputText.release_focus()
		inputContainer.hide()
		timer.start()
		inputText.text = ""

	if Input.is_action_just_pressed("chat_change_group"):
		if isImpostor:
			currentGroup = 0 if currentGroup == 1 else 1
			inputGroup.text = "[%s]" % chatGroups[currentGroup]["name"]
		else:
			currentGroup = 0


@rpc("any_peer", "call_local")
func send_message(message, group):
	if group < 0 or group >= len(chatGroups):
		return

	if group == 1 and not isImpostor:
		return

	if group == 2:
		_create_message(message, nickname)
		
		timer.start()

	else:
		_create_message(message, nickname)

		timer.start()


func send_system_message(message):
	send_message.rpc(message, 2)


func _create_message(message, username):
	var messageInstance = messageScene.instantiate()
	chatLogsContainer.add_child(messageInstance)
	messageInstance.init(username, message)


func _on_input_text_text_submitted(new_text):
	new_text = new_text.strip_edges()

	if new_text == "":
		return

	# TODO: Replace with rpc when server is implemented
	send_message(new_text, currentGroup)
	# send_message.rpc(new_text, currentGroup)

	inputText.text = ""


func _on_timer_timeout():
	if inputText.has_focus():
		return

func _handle_scrollbar_changed():
	if max_scroll_length != chatLogsScrollbar.max_value:
		max_scroll_length = chatLogsScrollbar.get_max()
		chatLogsScrollContainer.scroll_vertical = max_scroll_length
