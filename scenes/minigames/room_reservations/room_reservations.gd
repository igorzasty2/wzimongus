class_name RoomReservationsMiniGame
extends Control

## Sygnał końca minigry
signal minigame_end

## Polska nazwa minigry
@export var polish_name : String

## Referencja do kontenera z prowadzącymi
@onready var lecturers_containers = get_node("%Lecturers")
## Referencja do kontenera z salami
@onready var rooms_container = get_node("%Rooms")
## Referencja do konta
@onready var account = get_node("%Account")

## Referencja do tła
@onready var background = get_node("%Background")

## Lista prowadzących
var LECTURERS = ["dr inż. Marcin Bator", "dr Marcin Dudziński", "dr inż. Diana Dziewa-Dawidczyk", "dr inż. Alina Jóźwikowska", "dr hab. inż. Arkadiusz Orłowski", "dr inż. Maciej Pankiewicz", "dr hab. Alexander Prokopenya", "dr Piotr Stachura", "dr inż. Robert Stępień", "dr hab. Aleksander Strasburger", "dr Tomasz Świsłocki", "dr inż. Artur Wiliński", "dr inż. Piotr Wrzeciono", "dr Andrzej Zembrzuski", ]
## Lista sal
var ROOMS = ["Aula 4", "Aula 3", "Aula 2", "Aula 1", "Sala 3/82", "Sala 3/40", "Sala 3/42", "Sala 3/14", "Sala 3/19"]
## Lista kolorów
var COLORS = ["#00a436", "#076db5", "#b80400", "#5e4943"]

## Scena węzła sali
var room_node_scene = preload("res://scenes/minigames/room_reservations/room_node/room_node.tscn")

## Przypisane sale
var assigned_rooms = {}
## Przypisane kolory
var assigned_colors = {}

func _ready():
	account.text = GameManagerSingleton.get_current_player_key("username") + " (" + str(GameManagerSingleton.get_current_player_id()).get_slice("", 6) + ")" 

	LECTURERS.shuffle()
	ROOMS.shuffle()
	COLORS.shuffle()

	assigned_rooms = {}
	assigned_colors = {}

	for i in range(4):
		var lecturer = LECTURERS[i]
		var room = ROOMS[i]
		var color = COLORS[i]
		assigned_rooms[lecturer] = room
		assigned_colors[lecturer] = color
	
	for lecturer in assigned_rooms.keys():
		var lecturer_node = RichTextLabel.new()
		lecturer_node.bbcode_enabled = true
		lecturer_node.bbcode_text = "[color=\"" + assigned_colors[lecturer] + "\"]" + lecturer
		lecturer_node.fit_content = true
		lecturers_containers.add_child(lecturer_node)
		
	var random_rooms = assigned_rooms.keys()
	random_rooms.shuffle()
	for lecturer in random_rooms:
		var room_node = room_node_scene.instantiate()
		room_node.init(assigned_rooms[lecturer], assigned_colors[lecturer])
		rooms_container.add_child(room_node)
		room_node.button_up.connect(_on_button_up_pressed)
		room_node.button_down.connect(_on_button_down_pressed)

func _on_button_down_pressed(child):
	if child.get_index() < rooms_container.get_child_count() - 1:
		rooms_container.move_child(child, child.get_index() + 1)

func _on_button_up_pressed(child):
	if child.get_index() > 0:
		rooms_container.move_child(child, child.get_index() - 1)


func _on_save_button_pressed():
	for index in range(4):
		var lecturer = assigned_rooms.keys()[index]
		var room = rooms_container.get_child(index).get_room_name()

		if room != assigned_rooms[lecturer]:
			return
	_close()

func _close():
	minigame_end.emit()


