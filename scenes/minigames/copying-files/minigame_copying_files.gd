extends Button


func _on_confirm_button_down():
	# Załaduj grafikę
	var texture = preload("res://scenes/minigames/copying-files/assets/kopiowanie1.png")

	# Ustaw grafikę w węźle tekstury
	var texture_rect = TextureRect.new()
	texture_rect.texture = texture

	# Dodaj węzeł do sceny
	add_child(texture_rect)

	# Ustaw globalną pozycję tekstury
	texture_rect.global_position = Vector2(222, 55)  # Dostosuj te współrzędne do pożądanej pozycji

	# Oczekaj przez 0.5 sekundy
	await get_tree().create_timer(0.6).timeout
	# Załaduj drugą grafikę
	var texture2 = preload("res://scenes/minigames/copying-files/assets/kopiowanie2.png")
	# Zmień teksturę na drugą grafikę
	texture_rect.texture = texture2
	
	# kolejny etap ładowania (3/9)
	await get_tree().create_timer(0.6).timeout
	var texture3 = preload("res://scenes/minigames/copying-files/assets/kopiowanie3.png")
	texture_rect.texture = texture3
	
	# kolejny etap ładowania (4/9)
	await get_tree().create_timer(0.6).timeout
	var texture4 = preload("res://scenes/minigames/copying-files/assets/kopiowanie4.png")
	texture_rect.texture = texture4
	
	# kolejny etap ładowania (5/9)
	await get_tree().create_timer(0.6).timeout
	var texture5 = preload("res://scenes/minigames/copying-files/assets/kopiowanie5.png")
	texture_rect.texture = texture5
	
	# kolejny etap ładowania (6/9)
	await get_tree().create_timer(0.6).timeout
	var texture6 = preload("res://scenes/minigames/copying-files/assets/kopiowanie6.png")
	texture_rect.texture = texture6
	
	# kolejny etap ładowania (7/9)
	await get_tree().create_timer(0.6).timeout
	var texture7 = preload("res://scenes/minigames/copying-files/assets/kopiowanie7.png")
	texture_rect.texture = texture7
	
	# kolejny etap ładowania (8/9)
	await get_tree().create_timer(0.6).timeout
	var texture8 = preload("res://scenes/minigames/copying-files/assets/kopiowanie8.png")
	texture_rect.texture = texture8
	
	# kolejny etap ładowania (9/9)
	await get_tree().create_timer(0.6).timeout
	var texture9 = preload("res://scenes/minigames/copying-files/assets/kopiowanie9.png")
	texture_rect.texture = texture9
	
	#kończymy ładowanie przechodząc do sceny końcowej
	await get_tree().create_timer(0.6).timeout
	# Przełącz do sceny minigame_copying_files_end.tscn
	get_tree().change_scene_to_file("res://scenes/minigames/copying-files/minigame_copying_files_end.tscn")
	


