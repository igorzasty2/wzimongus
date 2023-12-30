extends CanvasLayer


const skins = {
	0: {
		"name": "Alternatywka",
		"texture": "alt_spritesheet.png"
	},
	1: {
		"name": "Nerd",
		"texture": "nerd_spritesheet.png"
	},
	2: {
		"name": "3",
		"texture": "alt_spritesheet.png"
	},
	3: {
		"name": "4",
		"texture": "nerd_spritesheet.png"
	},
	4: {
		"name": "5",
		"texture": "alt_spritesheet.png"
	},
	5: {
		"name": "6",
		"texture": "nerd_spritesheet.png"
	},
	6: {
		"name": "7",
		"texture": "alt_spritesheet.png"
	},
	7: {
		"name": "8",
		"texture": "nerd_spritesheet.png"
	},
	8: {
		"name": "9",
		"texture": "alt_spritesheet.png"
	},
	9: {
		"name": "10",
		"texture": "nerd_spritesheet.png"
	},
	10: {
		"name": "11",
		"texture": "alt_spritesheet.png"
	},
	11: {
		"name": "12",
		"texture": "nerd_spritesheet.png"
	}
}

@onready var skin_texture_rect = $Panel/MarginContainer/VBoxContainer/SkinTextureRect
@onready var skin_option_button = $Panel/MarginContainer/VBoxContainer/SkinOptionButton


func _ready():
	hide()
	_update_skin_texture_rect(GameManager.get_current_player_key("skin"))
	_populate_skins()


func _input(event):
	if event.is_action_pressed("pause_menu") && visible:
		hide()
		get_viewport().set_input_as_handled()


func _update_skin_texture_rect(index):
	var texture = AtlasTexture.new()
	texture.atlas = load("res://scenes/player/assets/skins/" + skins[index]["texture"])
	texture.region = Rect2(0, 0, 675, 675)
	skin_texture_rect.texture = texture


func _populate_skins():
	skin_option_button.clear()

	for i in skins:
		skin_option_button.add_item(skins[i]["name"], i)

	skin_option_button.select(GameManager.get_current_player_key("skin"))


func _on_skin_option_button_item_selected(index):
	_update_skin_texture_rect(index)


func _on_visibility_changed():
	get_parent().update_input()
