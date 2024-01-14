extends CanvasLayer


@onready var skin_texture_rect = $Panel/MarginContainer/VBoxContainer/SkinTextureRect
@onready var skin_option_button = $Panel/MarginContainer/VBoxContainer/SkinOptionButton


func _ready():
	_update_skin_texture_rect(GameManagerSingleton.get_current_player_value("skin"))
	_populate_skins()

	GameManagerSingleton.player_registered.connect(_populate_skins)
	GameManagerSingleton.player_deregistered.connect(_populate_skins)
	GameManagerSingleton.skin_changed.connect(_on_skin_changed)


func _input(event):
	if event.is_action_pressed("pause_menu"):
		if !visible:
			return

		hide()
		$WindowCloseSound.play()
		get_viewport().set_input_as_handled()


func _on_skin_changed(id: int, skin: int):
	if id == GameManagerSingleton.get_current_player_id():
		_update_skin_texture_rect(skin)
	_populate_skins()


func _update_skin_texture_rect(index):
	var texture = AtlasTexture.new()
	texture.atlas = load(GameManagerSingleton.SKINS[index]["resource"])
	texture.region = Rect2(0, 0, 675, 675)
	skin_texture_rect.texture = texture


func _populate_skins(_id: int = -1, _player: Dictionary = {}):
	var available_skins = GameManagerSingleton.SKINS.duplicate()

	for i in GameManagerSingleton.get_registered_players():
		if i != GameManagerSingleton.get_current_player_id():
			available_skins.erase(GameManagerSingleton.get_registered_player_value(i, "skin"))

	skin_option_button.clear()

	var idx = 0

	for i in available_skins:
		skin_option_button.add_item(available_skins[i]["name"], i)

		if i == GameManagerSingleton.get_current_player_value("skin"):
			skin_option_button.select(idx)

		idx += 1


func _on_skin_option_button_item_selected(index):
	GameManagerSingleton.change_skin(skin_option_button.get_item_id(index))


func _on_visibility_changed():
	if visible:
		$WindowOpenSound.play()
	$Panel.visible = visible
