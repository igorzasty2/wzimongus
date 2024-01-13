## Klasa reprezuntuje instancję minigry Fill Formulas
class_name FillFormulas
extends Node2D


## Lista możliwych do wylosowania wzorów

# Scena ta przechowuje główną logikę minigry oraz główne jej skrypty wymagane
# do jej działania

@export var polish_name : String

# FORMULAS przechowuje listę możliwych do wylosowania wzorów do uzupełnienia

const FORMULAS = {
	0:"F=m*v",
	1:"v=s/t",
	2:"a=v/t",
	3:"P=a²",
	4:"P=a*h",
	5:"P=π*r²",
	6:"P=a*h½",
	}
@export
## Ilość losowanych wzorów
var how_many_formulas = 3
## Sygnał emitowany w momencie ukończenia minigry
signal minigame_end

## Informacja czy pole jest obecnie przesuwane
var is_moving = false
## Referencja do przesuwanego pola
var moving
## Wcześniej wylosowane wzory
var generated = []
## Informacja ile wzorów zostało uzupełnionych
var _times_generated = 0
## Liczba uzupełnonych luk we wzorze
var _point = 0
## Liczba luk w uzupełnianym wzorze
var _wanted_points = 0
## Informuje czy minigra została ukończona
var _finished = false


func _ready():
	_random_generate()

## Kontroluje przebieg minigry
func _process(delta):
	var letters = _get_letters()
	var spaces = _get_spaces()
	var mouse_clicked = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	# Pętla na bieżąco kontrolująca położenie pól z literami
	for l in letters:
		if moving != null && moving.placed == false:
			var correct_space = _get_correct_space(moving.id, spaces)
			if correct_space != null:
				# Umieszcza literę w pustym polu jeżeli litera zostanie "upuszczona"
				# nad odpowiednim polem
				if correct_space.correct_area.has_point(moving.position):
					if !mouse_clicked:
						moving.position = correct_space.position
						moving.placed = true
						# Po umieszczeniu litery na odpowiednim polu pole to jest
						# usuwane aby niemożliwym było umieszczenie tam kolejnej
						# litery
						correct_space.queue_free()
						_point += 1
				elif (
						(l != moving || !mouse_clicked)
						&& !l.placed
						&& l.position != l.original_position
					):
					# Przywraca do originalnej pozycji pole które jest na nieprawidłowym
					# miejscu, nie jest to poruszane obecnie pole lub myszka nie jest wciśnięta,
					# i nie jest na oryginalniej pozycji
					l.return_to_orig_pos()
			elif (
						(l != moving || !mouse_clicked)
						&& !l.placed
						&& l.position != l.original_position
					):
					# Przywraca do originalnej pozycji pole które nie posiada
					# odpowiadającego pustego pola
					l.return_to_orig_pos()
	if _point == _wanted_points && _times_generated != how_many_formulas:
		_wanted_points = 0
		_point = 0
		# Usuwa stary hałas
		for i in letters:
			if i.placed != true:
				i.queue_free()
		_random_generate()
	if _point == _wanted_points && _times_generated == how_many_formulas:
		if !_finished:
			minigame_end.emit()
			_finished = true


## Generuje pola z literami
func _generate_letters(formula:String):
	# number_of_letters przechowuje liczbę liter które muszą zostać wygenerowane
	var number_of_letters = ceil(formula.length()/2.0)
	# Tabela definiujące w jakiej losowej sekwencji wygenerowane mają być litery
	var sequence = []
	# inner_text jest to pole tekstowe wygenerowanego objektu Letter potrzebne
	# do tego aby pole wyświetlało odpowiednią literę
	var inner_text:RichTextLabel
	# Pętla generująca losową sekwencję liczb według której generowane będą
	# elementy wzoru
	while sequence.size() < number_of_letters:
		var rand = randi_range(0, number_of_letters-1) * 2
		if !sequence.has(rand):
			sequence.append(rand)
	sequence = _add_noise(sequence)
	for i in range(sequence.size()):
		var Letter = preload("assets/subscenes/letter.tscn").instantiate()
		# Losowy znak między 'A' i 'z' wykorzystywany jeśli w tym miejscu
		# sekwencji pojawić ma się hałas
		var rand_letter = char(randi_range(65, 122))
		# Przesunięcie w osi x pozycji wygenerowanych pól z literami
		const SHIFT = Vector2(130, 0)
		Letter.position = $FirstLetter.position + i * SHIFT
		inner_text = Letter.get_node("./LetterInBox")
		inner_text.text = "[center][font_size={56}][color=black]"
		if(sequence[i] == 20):
			inner_text.text += rand_letter
		else:
			inner_text.text += formula[int(sequence[i])]
		inner_text.text += "[/color][/font_size][/center]"
		Letter.original_position = Letter.position
		if(sequence[i] == 20):
			Letter.id = rand_letter
		else:
			Letter.id = formula[int(sequence[i])]
		add_child(Letter)


## Dodaje niepotrzebne litery do wygenerowanych
func _add_noise(sequence:Array):
	var count_of_noise = 6 - sequence.size()
	var noise_indexes = []
	while noise_indexes.size() < count_of_noise:
		var rand = randi_range(0, sequence.size()+count_of_noise-1)
		if !noise_indexes.has(rand):
			noise_indexes.append(rand)
	var new_sequence = []
	for i in range(sequence.size()+count_of_noise):
		new_sequence.append(-1)
	for i in range(noise_indexes.size()):
		new_sequence[noise_indexes[i]] = 20
	for i in range(sequence.size()):
		var j = 0
		while new_sequence[j] != -1:
			j += 1
		new_sequence[j] = sequence[i]
	return new_sequence


## Generuje wzór który należy uzupełnić
func _generate_formula(formula:String):
	# X_SHIFT odpowiada za stałe przesunięcie w osi x przy generowaniu kolejnych
	# elementów wzoru, Y_SHIFT odpowiada za przesunięcie w osi y przy generowaniu
	# kolejnych równań
	const X_SHIFT = Vector2(80, 0)
	const Y_SHIFT = Vector2(0, 120)
	for i in range(0, formula.length()):
		if i % 2 == 0:
			# W tym fragmencie kodu tworzone jest puste pole reprezentujące
			# miejsce w którym umieścić należy odpowiednią literę
			var Space = preload("assets/subscenes/space.tscn").instantiate()
			Space.position = $StartOfFormula.position + X_SHIFT * i + Y_SHIFT * _times_generated
			Space.wanted_letter = formula[i]
			add_child(Space)
			# Definiowane jest położenie instancji obiektu
			Space.set_area()
			_wanted_points += 1
		else:
			# W tym fragmencie kodu tworzony jest TextBox który reprezentował
			# będzie uzupełniony fragment wzoru
			var text:RichTextLabel = RichTextLabel.new()
			text.position =\
				($StartOfFormula.position - Vector2(40, 40)) + X_SHIFT *\
				i + Y_SHIFT * _times_generated
			text.size = Vector2(80, 80)
			text.bbcode_enabled = true
			# Dostosowywanie koloru tekstu zależnie od wybranego gui
			text.text = "[center][font_size={56}][color=black]" +\
			formula[i] + "[/color][/font_size][/center]"
			add_child(text)
	# TextBox uzupełniany jest o podpowiedź do obecnie uzupełnianego wzoru
	$Hint.text += "[center][font_size={24}][color=white]" + formula + "[/color][/font_size][/center]\n"


## Zwraca tablicę wygenerowanych pól z literami
func _get_letters():
	var children = []
	for child in get_children():
		if child is StaticBody2D:
			children.append(child)
	return children


## Zwraca tablicę pustych pól
func _get_spaces():
	var spaces = []
	for child in get_children():
		if child is Area2D:
			spaces.append(child)
	return spaces


## Zwraca referencję do pustego pola wymagającego danej litery
func _get_correct_space(letter, spaces):
	for space in spaces:
		if space.wanted_letter == letter:
			return space


## Losuje wcześniej nie wylosowany wzór
func _random_generate():
	var r = randi_range(0, FORMULAS.size()-1)
	if !generated.has(FORMULAS[r]):
		_generate_formula(FORMULAS[r])
		_generate_letters(FORMULAS[r])
		generated.append(FORMULAS[r])
		_times_generated += 1
