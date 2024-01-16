extends "res://addons/gdUnit3/src/core/GdUnitTestSuite.gd"

var control

func setup():
	control = preload("res://scenes/ui/pop_up_window/pop_up_window.tscn").instance()
	add_child(control)

# Test ID 18
# Test sprawdza co się dzieje gdy one_button jest ustawione na true
# Testuje czy po uruchomieniu funkcji _ready() srodkowy przycisk jest widoczny a lewy i prawy przyciski sa ukryte
func test_ready_one_button_mode():
	control.one_button = true
	control._ready()

	assert_equals(control.label.text, control.information)
	assert_null(control.get_node_or_null("Panel/MarginContainer/HBoxContainer/LeftButton"))
	assert_null(control.get_node_or_null("Panel/MarginContainer/HBoxContainer/RightButton"))
	assert_not_null(control.get_node_or_null("Panel/MarginContainer/HBoxContainer/MiddleButton"))
	assert_equals(control.middle_button.text, control.middle_button_text)

# Test ID 19
# Test sprawdza zachowanie sceny gdy one_button jest ustawione na false 
# Lewy i prawy przycisk powinny byc widoczne, a srodkowy przycisk ukryty
func test_ready_two_button_mode():
	control.one_button = false
	control._ready()

	assert_equals(control.label.text, control.information)
	assert_not_null(control.get_node_or_null("Panel/MarginContainer/HBoxContainer/LeftButton"))
	assert_not_null(control.get_node_or_null("Panel/MarginContainer/HBoxContainer/RightButton"))
	assert_null(control.get_node_or_null("Panel/MarginContainer/HBoxContainer/MiddleButton"))
	assert_equals(control.left_button.text, control.left_button_text)
	assert_equals(control.right_button.text, control.right_button_text)

# Test ID 20
# Testuje czy po nacisnieciu lewego przycisku emitowany jest sygnal left_pressed
func test_left_button_signal_emission():
	control.one_button = false
	control._ready()
	yield(control.left_button, "pressed")
	assert_signal_emitted(control, "left_pressed")

# Test ID 21
# Testuje czy po nacisnieciu lewego przycisku emitowany jest sygnal left_pressed
func test_right_button_signal_emission():
	control.one_button = false
	control._ready()
	yield(control.right_button, "pressed")
	assert_signal_emitted(control, "right_pressed")

# Test ID 22
# Test sprawdza czy po nacisnieciu srodkowego przycisku w trybie z jednym przyciskiem emitowany jest sygnal middle_pressed
func test_middle_button_signal_emission():
	control.one_button = true
	control._ready()
	yield(control.middle_button, "pressed")
	assert_signal_emitted(control, "middle_pressed")

# Test ID 23
# Testuje funkcje set_information która aktualizuje tekst informacyjny na etykiecie
func test_set_information():
	var new_info = "New information"
	control.set_information(new_info)
	assert_equals(control.label.text, new_info)
