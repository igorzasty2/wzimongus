extends TabContainer


# Ustawia nazwy zakładek
func _ready():
	set_tab_title(0, "Dźwięk i grafika")
	set_tab_title(1, "Sterowanie")
	set_tab_title(2, "Domyślne")


# Ustawia pierwszą zakładkę jako domyślną
func _on_hidden():
	current_tab = 0
