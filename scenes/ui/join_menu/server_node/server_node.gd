extends HBoxContainer

var _server_info

signal server_selected(server_info)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init(server_info):
	_server_info = server_info
	$LobbyName.text = server_info.name
	$ServerAddress.text = server_info.ip + ":" + str(server_info.port)

func _on_button_pressed():
	server_selected.emit(_server_info)
