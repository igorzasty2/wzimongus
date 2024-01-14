## Klasa okna minigier.
class_name MinigameWindow
extends CanvasLayer

var _minigame: PackedScene
var _minigame_instance: Node
var _use_button_disabled: bool = true

## Referencja do Node'a w drzewie reprezentującego całość okna minigry.
@onready var _minigame_container = $MinigameContainer
## Referencja do subviewport'a wyświetlającego minigrę.
@onready var _subviewport = _minigame_container.get_node("SubviewportContainer/MinigameViewport")
## Referencja do przycisku zamykającego okno minigry.
@onready var _close_button: TextureButton = _minigame_container.get_node("CloseButton")

## Zmienne do obsługi interface gracza.
@onready var _user_interface = get_parent().get_node("UserInterface")

## Emitowany, gdy przycisk aktywacji minigry ma być aktywny lub nie.
signal use_button_active(is_active: bool)


func _ready():
	_close_button.pressed.connect(close_minigame)
	use_button_active.connect(_user_interface.toggle_button_active)


## Aktywuje przycisk aktywacji minigry.
func show_use_button(minigame):
	_minigame = minigame
	emit_signal("use_button_active", "InteractButton", true)
	_use_button_disabled = false


## Wyłącza przycisk aktywacji minigry.
func hide_use_button():
	_minigame = null
	emit_signal("use_button_active", "InteractButton", false)
	_use_button_disabled = false


## W chwili naciśnięcia przycisku aktywuje funkcję wyświetlającą okno minigry.
func _on_use_button_pressed():
	if _minigame == null:
		return

	if _subviewport.get_child_count() != 0:
		return

	_summon_window()


## Daje możliwość aktywacji minigry przez wciśnięcie przycisku na klawiaturze.
func _input(event):
	if event.is_action_pressed("pause_menu"):
		if !visible:
			return

		close_minigame()
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("interact"):
		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		if GameManagerSingleton.get_current_game_value("is_input_disabled"):
			return

		if _minigame == null:
			return

		if _subviewport.get_child_count() != 0:
			return

		if _use_button_disabled:
			return

		_summon_window()


## Pokazuje okno minigry.
func _summon_window():
	show()

	_subviewport.add_child(_minigame.instantiate())
	_minigame_instance = _subviewport.get_child(0)

	emit_signal("use_button_active", "InteractButton", false)
	_use_button_disabled = true

	_minigame_instance.minigame_end.connect(_end_minigame)

	if _minigame == load("res://scenes/game/maps/main_map/camera_system/camera_system.tscn"):
		for camera in get_tree().get_nodes_in_group("SurveillanceCameras"):
			camera.change_light_visibility()


## Ukrywa okno minigry w chwili jej ukończenia i odznacza zadanie za zakończone.
func _end_minigame():
	_minigame_instance.queue_free()

	hide()

	TaskManagerSingleton.mark_task_as_complete()


## Ukrywa okno minigry pomimo nie ukończenia jej w chwili wciśnięcia przycisku.
func close_minigame():
	if _minigame_instance != null:
		_minigame_instance.queue_free()

		hide()

		show_use_button(_minigame)

	if _minigame == load("res://scenes/game/maps/main_map/camera_system/camera_system.tscn"):
		for camera in get_tree().get_nodes_in_group("SurveillanceCameras"):
			camera.change_light_visibility()
