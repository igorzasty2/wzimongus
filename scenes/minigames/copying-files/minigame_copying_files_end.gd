extends Node2D

## Ustawienia początkowe sceny - ustawienie koloru paska kopiowania, ukrycie wyświetlania procentów wypełnienia paska, ustawienie wartości startowej paska w scenie na 100% 
func _ready():
	## Ustawienie koloru paska kopiowania na zielony (RGBA: (0, 1, 0, 1))
	$KopiowanieZakonczone/ProgressBar.modulate = Color(0, 1, 0, 1)
	## Ukrycie wyświetlania procentów na pasku kopiowania
	$KopiowanieZakonczone/ProgressBar.show_percentage = false
	## Ustawienie wartości startowej paska w scenie na 100%
	$KopiowanieZakonczone/ProgressBar.value =  100
	
## Obsługa przycisku 'end' kończącego minigrę
func _on_end_button_down():
	# Wyślij potwierdzenie wykonania minigry
	print("Task sucessfull")
