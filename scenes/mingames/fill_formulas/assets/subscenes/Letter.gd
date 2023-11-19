extends StaticBody2D

# Klasa funkcjonuje jako przesuwalne myszką pole z literą które umieścić należy
# w odpowiednim polu

# Zmienna przechowujące informacje o tym, czy gracz przytrzymuje myszę nad polem
# z literą, konieczne do przmieszczania pola
var mouse_on_object = false
# original_position przetrzymuje informacje o początkowym położeniu pola, daje
# możliwość przywrócenia tej pozycji po nieprawidłowym przesunięciu pola
var original_position
# id służy do przetrzymania litery która znajduje się wewnątrz pola,
# wykorzystywane przede wszystkim przez główny skrypt minigry
var id = ""
# placed informuje o tym, czy pole zostało już "położone" na odpowiednim miejscu
# wzoru, służy do wyłączenia możliwości poruszania polem
var placed = false


func _process(delta):
	# sprawdza czy pole powinno być w danym momencie poruszane, zwraca true jeśli
	# myszka znajduje się nad polem, wciśnięty jest lewy przycisk myszy i pole
	# nie zostało ustawione na odpowiednim miejscu
	if(
		Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) 
		&& mouse_on_object 
		&& placed == false
	):
		position = get_viewport().get_mouse_position()

# funkcja przywraca pole do pozycji oryginalnej
func return_to_orig_pos():
	position = original_position


func _on_mouse_entered():
	# instrukcja warunkowa konieczna aby niemożliwe było podniesienie 
	# jednocześnie więcej niż jednego pola
	if (!get_parent().is_moving && placed == false):
		mouse_on_object = true
		get_parent().is_moving = true
		get_parent().moving = self


func _on_mouse_exited():
	# Przywraca możliwość podnoszenia innych pól z literami
	if (get_parent().is_moving && get_parent().moving == self):
		mouse_on_object = false
		get_parent().is_moving = false
