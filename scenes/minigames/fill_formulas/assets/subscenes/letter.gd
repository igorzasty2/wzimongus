## Klasa reprezentuje przesuwalny myszką kafelek z literą
class_name LetterBlock
extends StaticBody2D

## Informacje o oryginalnym położeniu pola
var _original_position
## Litera jaką reprezentuje pole
var id = ""
## Informuje o tym, czy pole zostało wstawione we wzór
var placed = false
## oryginalna warstwa rysowania pola
var _orig_z_index = z_index
## Rozmiar pola
var size 
## Dokładne położenie pola
var rect

## Ustawia wartości zmiennych size i rect
func _ready():
	size = $Sprite2D.get_rect().size
	rect = Rect2(position - size/2, size)

## Odpowiada za obsługę poruszania pola myszką
func _process(delta):
	if GameManager.get_current_game_key("is_paused") && !placed:
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
		&& (position != _original_position || get_parent().is_moving)
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
		

## Przywraca pole do pozycji oryginalnej
func return_to_orig_pos():
	position = _original_position

## Zdarzenie wykonywane gdy myszka znajdzie się w obszarze pola
func _on_mouse_entered():
	# instrukcja warunkowa konieczna aby niemożliwe było podniesienie 
	# jednocześnie więcej niż jednego pola
	if (!get_parent().is_moving && placed == false && !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		get_parent().is_moving = true
		get_parent().moving = self
		z_index = 20

## Zdarzenie wykonywane gdy myszka opuści obszar pola
func _on_mouse_exited():
	# Przywraca możliwość podnoszenia innych pól z literami
	if (get_parent().is_moving && get_parent().moving == self && !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		get_parent().is_moving = false
		z_index = _orig_z_index
