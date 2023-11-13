extends MultiplayerSynchronizer

@export var direction = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
