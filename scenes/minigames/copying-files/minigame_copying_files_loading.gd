extends Node2D

## Ustawienia początkowe sceny - ustawienie koloru paska kopiowania, ukrycie wyświetlania procentów 
func _ready():
	## ustawienie koloru paska kopiowania na zielony (RGBA: (0, 1, 0, 1))
	$Kopiowanie/ProgressBar.modulate = Color(0, 1, 0, 1)
	## ukrycie wyświetlania procentów na pasku kopiowania
	$Kopiowanie/ProgressBar.show_percentage = false
	

## Obsługa timera współdziałającego z paskiem kopiowania - zwiększanie o 1% procent wypełnienia co czas ustawiony na timerze (0.09s), przejście do kolejnej sceny po wypełnieniu paska w 100%
func _on_timer_timeout():
	## zwiększanie o 1% procent wypełnienia paska kopiowania co czas ustawiony na timerze (0.09s)
	$Kopiowanie/ProgressBar.value+=1

	## instrukcja warunkowa zmieniająca scenę na 'minigame_copying_files_end.tscn' gdy pasek kopiowania zostanie wypełniony w 100%
	if $Kopiowanie/ProgressBar.value == 100:
		get_tree().change_scene_to_file("res://scenes/minigames/copying-files/minigame_copying_files_end.tscn")
