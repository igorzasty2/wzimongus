## Klasa ta reprezentuje okno minigry
class_name MinigameWindow
extends CanvasLayer

## Scena minigry jaka ma zostać wyświetlona
var _minigame: PackedScene
## Wyświetlana obecnie minigra
var _minigame_instance: Node2D

## Referencja do Node'a w drzewie reprezentującego całość okna minigry
@onready var _minigame_container = $MinigameContainer
## Referencja do Viewport'a wyświetlającego minigrę
@onready var _viewport = _minigame_container.get_node("ViewportContainer/Viewport")
## Referencja do przycisku aktywującego okno minigry
@onready var _use_button: TextureButton = $UseButton
## Referencja do przycisku zamykającego okno minigry
@onready var _close_button: TextureButton = _minigame_container.get_node("CloseButton")

## Łączy sygnały z odpowiednimi funkcjami
func _ready():
	_use_button.pressed.connect(_on_use_button_pressed)
	_close_button.pressed.connect(close_minigame)

## Pokazuje graczowi przycisk aktywaji minigry
func show_use_button(minigame):
	_minigame = minigame
	_use_button.visible = true
	_use_button.disabled = false

## Ukrywa przycisk aktywacji minigry
func hide_use_button():
	_minigame = null
	_use_button.visible = false
	_use_button.disabled = true

## W chwili naciśnięcia przycisku aktywuje funkcję wyświetlającą okno minigry
func _on_use_button_pressed():
	if _minigame == null:
		return

	if _viewport.get_child_count() != 0:
		return
	
	_summon_window()

## Daje możliwość aktywacji minigry przez wciśnięcie przycisku na klawiaturze
func _input(event):
	if !event.is_action_pressed("interact"):
		return

	if _minigame == null:
		return

	if _use_button.disabled:
		return

	if _viewport.get_child_count() != 0:
		return

	if GameManager.get_current_game_key("is_paused"):
		return

	_summon_window()

## Pokazuje okno minigry
func _summon_window():
	_minigame_container.visible = true

	_viewport.add_child(_minigame.instantiate())
	_minigame_instance = _viewport.get_child(0)

	_use_button.visible = false
	_use_button.disabled = true

	GameManager.set_input_status(false)

	_minigame_instance.minigame_end.connect(_end_minigame)

## Ukrywa okno minigry w chwili jej ukończenia i odznacza zadanie za zakończone
func _end_minigame():
	_minigame_instance.queue_free()

	_minigame_container.visible = false

	GameManager.set_input_status(true)

	TaskManager.mark_task_as_complete()

## Ukrywa okno minigry pomimo nie ukończenia jej w chwili wciśnięcia przycisku
func close_minigame():
	if _minigame_instance != null:
		_minigame_instance.queue_free()

		_minigame_container.visible = false

		GameManager.set_input_status(true)

		show_use_button(_minigame)
