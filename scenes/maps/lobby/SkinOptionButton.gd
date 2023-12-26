extends OptionButton



func _on_item_selected(index):
			$"../SelectedSkin".frame_coords.x = index
			GameManager.set_player_key("skin",index)
