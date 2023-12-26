extends OptionButton



func _on_item_selected(index):
	match index:
		0:
			$"../SelectedSkin".frame_coords = Vector2(0,0)
			GameManager.set_player_key("skin",0)
		1:
			$"../SelectedSkin".frame_coords = Vector2(5,0)
			GameManager.set_player_key("skin",1)
