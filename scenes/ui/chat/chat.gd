extends Control


@onready var chatLogs = get_node("%ChatLog")
@onready var inputNickname = get_node("%InputNickname")
@onready var inputGroup = get_node("%InputGroup")
@onready var inputText = get_node("%InputText")
@onready var inputContainer = get_node("%InputContainer")
@onready var timer = get_node("%ChatDisappearTimer")

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
var tween


func _ready():
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
		chatLogs.modulate = Color(1, 1, 1, 1)

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
		chatLogs.modulate = Color(1, 1, 1, 1)
		chatLogs.text += "%s \n" % message
		timer.start()

	else:
		chatLogs.text += "[color=%s]%s:[/color] %s \n" % [chatGroups[currentGroup]["color"], nickname, message]
		chatLogs.modulate = Color(1, 1, 1, 1)
		timer.start()


func send_system_message(message):
	send_message.rpc(message, 2)


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

	tween = create_tween()
	
	tween.tween_property(chatLogs, "modulate:a", 0, 0.25).set_trans(Tween.TRANS_SINE)


