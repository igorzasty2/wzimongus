extends StaticBody2D

# Klasa funkcjonuje jako przesuwalne myszką pole z literą które umieścić należy
# w odpowiednim polu we wzorze

# original_position przetrzymuje informacje o początkowym położeniu pola, daje
# możliwość przywrócenia tej pozycji po nieprawidłowym przesunięciu pola
var original_position
# id służy do przetrzymania litery która znajduje się wewnątrz pola,
# wykorzystywane przede wszystkim przez główny skrypt minigry
var id = ""
# placed informuje o tym, czy pole zostało już "położone" na odpowiednim miejscu
# wzoru, służy do wyłączenia możliwości poruszania polem
var placed = false
# zmienna przetrzymująca oryginalną warstwę rysowania pola
var orig_z_index = z_index
# zmienna przechowująca wektor rozmiaru pola
var size
# zmienna przechowująca dokładne położenie pola (obszar przez niego zajmowany)
var rect


func _ready():
	size = $Sprite2D.get_rect().size
	rect = Rect2(position - size/2, size)


func _process(delta):
	if GameManager.get_current_game_key("paused") && !placed:
		return_to_orig_pos()
		return
	# Przypisanie często używanej funkcji do zmiennej w celu skrócenia kodu
	var mouse_position:Vector2 = get_viewport().get_mouse_position()
	# sprawdza czy pole powinno być w danym momencie poruszane, zwraca true jeśli
	# myszka znajduje się nad polem, wciśnięty jest lewy przycisk myszy i pole
	# nie zostało ustawione na odpowiednim miejscu
	if(
		Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) 
		&& get_parent().moving == self
		&& placed == false
		&& (position != original_position || get_parent().is_moving)
	):
		# Przypisanie zmiennych w celu uodpornienia kodu na zmiany wymiarów gui
		# minigry
		var gui:Sprite2D = get_parent().get_child(0)
		var minigame_scale:Vector2 = get_parent().scale
		var gui_rect:Rect2 = Rect2(
			Vector2(gui.global_position - gui.get_rect().size/2 * minigame_scale), 
			gui.get_rect().size * minigame_scale
			)
		# Instrukcja warunkowa pozwala na swobodne poruszanie się litery tylko w
		# obrębie pola minigry
		if gui_rect.has_point(mouse_position):
			global_position = mouse_position
		# Przypisanie często wykorzystywanych zmiennych w celu skrócenia dalszego
		# kodu i uodpornienia kodu na zmiany wymiarów gui minigry
		var letter_boundry_shift = $Sprite2D.get_rect().size.x
		var right = gui_rect.position.x + gui_rect.size.x - letter_boundry_shift/3
		var left = gui_rect.position.x + letter_boundry_shift/3
		var top = gui_rect.position.y + letter_boundry_shift/3
		var bottom = gui_rect.position.y + gui_rect.size.y - letter_boundry_shift/3
		# Instrukcja pozwala na poruszanie literą wzdłuż granic prostopadłych
		# do osi x
		if(mouse_position.x >= right || mouse_position.x <= left):
			global_position.y = mouse_position.y
			# Następne dwie instrukcje warunkowe odpowiadają za wyeliminowanie
			# sytuacji gdy myszka opuści pole minigry i pole z literą znajduje
			# się na środku pola minigry i ma ograniczone ruchy do tylko jednej
			# osi
			if mouse_position.x >= right && global_position.x < right:
				global_position.x = right
			if mouse_position.x <= left && global_position.x > left:
				global_position.x = left
			# Instrukcja uniemożliwia opuszczenie górnej i dolnej krawędzi
			# pola minigry
			if(global_position.y < top || global_position.y > bottom):
				if global_position.y < top:
					global_position.y = top
				else:
					global_position.y = bottom
		# Instrukcja pozwala na poruszanie literą wzdłuż granic prostopadłych
		# do osi y
		if mouse_position.y <= top || mouse_position.y >= bottom:
			global_position.x = mouse_position.x
			# Następne dwie instrukcje warunkowe odpowiadają za wyeliminowanie
			# sytuacji gdy myszka opuści pole minigry i pole z literą znajduje
			# się na środku pola minigry i ma ograniczone ruchy do tylko jednej
			# osi
			if mouse_position.y >= bottom && global_position.y < bottom:
				global_position.y = bottom
			if mouse_position.y <= top && global_position.y > top:
				global_position.y = top
			# Instrukcja uniemożliwia opuszczenie lewej i prawej krawędzi
			# pola minigry
			if global_position.x > right || global_position.x < left:
				if global_position.x < left:
					global_position.x = left
				else:
					global_position.x = right
	# Służy do poprawnej zmiany wybranego pola z literą
	if(
		rect.has_point(mouse_position) 
		&& get_parent().is_moving == false
	):
		_on_mouse_entered()
		

# funkcja przywraca pole do pozycji oryginalnej
func return_to_orig_pos():
	position = original_position


func _on_mouse_entered():
	# instrukcja warunkowa konieczna aby niemożliwe było podniesienie 
	# jednocześnie więcej niż jednego pola
	if (!get_parent().is_moving && placed == false && !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		get_parent().is_moving = true
		get_parent().moving = self
		z_index = 20


func _on_mouse_exited():
	# Przywraca możliwość podnoszenia innych pól z literami
	if (get_parent().is_moving && get_parent().moving == self && !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		get_parent().is_moving = false
		z_index = orig_z_index
