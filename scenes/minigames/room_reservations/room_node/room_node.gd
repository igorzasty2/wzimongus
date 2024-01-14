## Klasa reprezentująca pokój w minigrze rezerwacji pokoi.
class_name RoomReservationsRoomNode
extends HBoxContainer

## Sygnał oznaczajacy kliknięcie w przycisk w dół
signal button_down
## Sygnał oznaczajacy kliknięcie w przycisk w górę
signal button_up

## Label z nazwą pokoju
var room_name = ""

## Funkcja inicjalizująca węzeł pokoju
func init(room_name, room_color):
	$RoomName.text = "[color=" + room_color + "]" + room_name
	self.room_name = room_name

## Funkcja zwracająca nazwę pokoju
func get_room_name():
	return room_name

func _on_button_down_pressed():
	button_down.emit(self)

func _on_button_up_pressed():
	button_up.emit(self)
