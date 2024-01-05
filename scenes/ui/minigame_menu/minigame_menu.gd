extends CanvasLayer

var _minigame: PackedScene
var _minigame_instance: Node

@onready var minigame_container = $MinigameContainer
@onready var viewport = minigame_container.get_node("ViewportContainer/Viewport")
@onready var use_button: TextureButton = $UseButton
@onready var close_button: TextureButton = minigame_container.get_node("CloseButton")

func _ready():
	use_button.pressed.connect(_on_use_button_pressed)
	close_button.pressed.connect(close_minigame)

func show_use_button(minigame):
	_minigame = minigame
	use_button.visible = true
	use_button.disabled = false

func hide_use_button():
	_minigame = null
	use_button.visible = false
	use_button.disabled = true

func _on_use_button_pressed():
	if _minigame == null:
		return

	if viewport.get_child_count() != 0:
		return
	
	summon_window()

func _input(event):
	if !event.is_action_pressed("interact"):
		return

	if _minigame == null:
		return

	if use_button.disabled:
		return

	if viewport.get_child_count() != 0:
		return

	if GameManager.get_current_game_key("is_paused"):
		return

	summon_window()

func summon_window():
	minigame_container.visible = true

	viewport.add_child(_minigame.instantiate())
	_minigame_instance = viewport.get_child(0)

	use_button.visible = false
	use_button.disabled = true

	GameManager.set_input_status(false)

	_minigame_instance.minigame_end.connect(end_minigame)

func end_minigame():
	_minigame_instance.queue_free()

	minigame_container.visible = false

	GameManager.set_input_status(true)

	TaskManager.mark_task_as_complete()

func close_minigame():
	if _minigame_instance != null:
		_minigame_instance.queue_free()

		minigame_container.visible = false

		GameManager.set_input_status(true)

		show_use_button(_minigame)
