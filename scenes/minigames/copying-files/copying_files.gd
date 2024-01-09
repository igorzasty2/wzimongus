extends Control

signal minigame_end

@export var polish_name : String

func _on_confirm_button_down():
	$Confirm.disabled = true
	$Confirm.visible = false
	$ProgressBar.visible = true
	$Timer.start()

func _on_end_button_down():
	# Wyślij potwierdzenie wykonania minigry
	minigame_end.emit()

## Obsługa timera współdziałającego z paskiem kopiowania - zwiększanie o 1% procent wypełnienia co czas ustawiony na timerze (0.09s), przejście do kolejnej sceny po wypełnieniu paska w 100%
func _on_timer_timeout():
	## zwiększanie o 1% procent wypełnienia paska kopiowania co czas ustawiony na timerze (0.09s)
	$ProgressBar.value+=1

	## instrukcja warunkowa zmieniająca scenę na 'minigame_copying_files_end.tscn' gdy pasek kopiowania zostanie wypełniony w 100%
	if $ProgressBar.value == 100:
		$Timer.stop()
		$PromptLabel.visible = false
		$SuccessMessageLabel.visible = true
		$EndButton.visible = true
