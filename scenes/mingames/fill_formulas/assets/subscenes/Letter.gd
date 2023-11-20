extends StaticBody2D

# Klasa funkcjonuje jako przesuwalne myszką pole z literą które umieścić należy
# w odpowiednim polu

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
	# sprawdza czy pole powinno być w danym momencie poruszane, zwraca true jeśli
	# myszka znajduje się nad polem, wciśnięty jest lewy przycisk myszy i pole
	# nie zostało ustawione na odpowiednim miejscu
	if(
		Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) 
		&& get_parent().moving == self
		&& placed == false
		&& (position != original_position || get_parent().is_moving)
	):
		position = get_viewport().get_mouse_position()
	# Służy do poprawnej zmiany wybranego pola z literą
	if(
		rect.has_point(get_viewport().get_mouse_position()) 
		&& get_parent().is_moving == false
		):
		_on_mouse_entered()
		

# funkcja przywraca pole do pozycji oryginalnej
func return_to_orig_pos():
	position = original_position


func _on_mouse_entered():
	# instrukcja warunkowa konieczna aby niemożliwe było podniesienie 
	# jednocześnie więcej niż jednego pola
	if (!get_parent().is_moving && placed == false):
		get_parent().is_moving = true
		get_parent().moving = self
		z_index = 20


func _on_mouse_exited():
	# Przywraca możliwość podnoszenia innych pól z literami
	if (get_parent().is_moving && get_parent().moving == self):
		get_parent().is_moving = false
		z_index = orig_z_index
