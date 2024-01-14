## Minigra odgadnij hasło.
class_name FindPasswordMinigame
extends Node2D

## Sygnał końca minigry
signal minigame_end

## Nazwa polska minigry
@export var polish_name : String
## Referencja do wejścia na hasło
@onready var _password_input = get_node("%PasswordInput")
## Generuje hasła
@onready var _passwords = _generate_passwords()
## Referencja do sceny strony
@onready var _page_scene = preload("res://scenes/minigames/find_password/page_scene/page_scene.tscn")

## Hasło do odgadnięcia
var _correct_password

## Referencje do scen stron
var _page_scenes = []

func _ready():
	_correct_password = _passwords[randi() % 5]
	for i in range(5):
		var page_scene_instance = _page_scene.instantiate()
		page_scene_instance.init(_passwords[i])
		_page_scenes.append(page_scene_instance)
		add_child(page_scene_instance)
		page_scene_instance.visible = false
		page_scene_instance.position = Vector2(650, 500)

func _generate_passwords():
	var passwords = []
	for i in range(5):
		var password = ""
		for j in range(10):  # Generate a 10-character password
			var ascii = randi() % 26 + 97  # Generate a random lowercase letter
			password += char(ascii)
		passwords.append(password)
	return passwords

func _on_password_input_text_submitted(new_text):
	if new_text == _correct_password:
		minigame_end.emit()
	else:
		_password_input.clear()
		_password_input.set_placeholder("Niepoprawne Hasło!")

func _on_page_1_pressed():
	if not _any_page_visible():
		_page_scenes[0].visible = true

func _on_page_2_pressed():
	if not _any_page_visible():
		_page_scenes[1].visible = true

func _on_page_3_pressed():
	if not _any_page_visible():
		_page_scenes[2].visible = true

func _on_page_4_pressed():
	if not _any_page_visible():
		_page_scenes[3].visible = true

func _on_page_5_pressed():
	if not _any_page_visible():
		_page_scenes[4].visible = true

func _any_page_visible():
	for page_scene in _page_scenes:
		if page_scene.visible:
			return true
	return false
