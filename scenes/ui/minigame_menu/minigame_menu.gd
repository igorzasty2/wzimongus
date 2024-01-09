extends CanvasLayer


var _minigame: PackedScene
var _minigame_instance: Node
var use_button_disabled: bool = true

@onready var minigame_container = $MinigameContainer
@onready var viewport = minigame_container.get_node("ViewportContainer/Viewport")
@onready var close_button: TextureButton = minigame_container.get_node("CloseButton")

# Zmienne do obsługi interface gracza
@onready var user_interface = get_parent().get_node("UserInterface")
signal use_button_active(is_active:bool)


func _ready():
	close_button.pressed.connect(close_minigame)
	use_button_active.connect(user_interface.toggle_button_active)


func show_use_button(minigame):
	_minigame = minigame
	emit_signal("use_button_active", "InteractButton", true)
	use_button_disabled = false


func hide_use_button():
	_minigame = null
	emit_signal("use_button_active", "InteractButton", false)
	use_button_disabled = false


# connect in user interface to this
func _on_use_button_pressed():
	if _minigame == null:
		return

	if viewport.get_child_count() != 0:
		return
	
	summon_window()


func _input(event):
	if GameManager.get_current_game_key("is_paused"):
		return

	if GameManager.get_current_game_key("is_input_disabled"):
		return

	if event.is_action_pressed("interact"):
		if _minigame == null:
			return

		if viewport.get_child_count() != 0:
			return

		if use_button_disabled:
			return

		summon_window()

		return


func summon_window():
	show()

	viewport.add_child(_minigame.instantiate())
	_minigame_instance = viewport.get_child(0)
	
	emit_signal("use_button_active", "InteractButton", false)
	use_button_disabled = true

	_minigame_instance.minigame_end.connect(end_minigame)


func end_minigame():
	_minigame_instance.queue_free()

	hide()


	TaskManager.mark_task_as_complete()


func close_minigame():
	if _minigame_instance != null:
		_minigame_instance.queue_free()

		hide()

		show_use_button(_minigame)
