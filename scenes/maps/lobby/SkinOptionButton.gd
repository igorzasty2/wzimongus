extends OptionButton



func _on_item_selected(index):
	match index:
		0:
			$"../SelectedSkin".frame_coords.x = 0
			GameManager.set_player_key("skin",0)
		1:
			$"../SelectedSkin".frame_coords.x = 1
			GameManager.set_player_key("skin",1)
		2:
			$"../SelectedSkin".frame_coords.x = 2
			GameManager.set_player_key("skin",2)
		3:
			$"../SelectedSkin".frame_coords.x = 3
			GameManager.set_player_key("skin",3)
		4:
			$"../SelectedSkin".frame_coords.x = 4
			GameManager.set_player_key("skin",4)
		5:
			$"../SelectedSkin".frame_coords.x = 5
			GameManager.set_player_key("skin",5)
		6:
			$"../SelectedSkin".frame_coords.x = 6
			GameManager.set_player_key("skin",6)
		7:
			$"../SelectedSkin".frame_coords.x = 7
			GameManager.set_player_key("skin",7)
		8:
			$"../SelectedSkin".frame_coords.x = 8
			GameManager.set_player_key("skin",8)
		9:
			$"../SelectedSkin".frame_coords.x = 9
			GameManager.set_player_key("skin",9)
