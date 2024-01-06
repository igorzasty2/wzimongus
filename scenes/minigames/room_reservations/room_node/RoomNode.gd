extends HBoxContainer



signal button_down
signal button_up

var room_name = ""

func init(room_name, room_color):
	$RoomName.text = "[color=" + room_color + "]" + room_name
	self.room_name = room_name

func get_room_name():
	return room_name

func _on_button_down_pressed():
	button_down.emit(self)

func _on_button_up_pressed():
	button_up.emit(self)
