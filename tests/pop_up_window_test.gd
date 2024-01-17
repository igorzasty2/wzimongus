<<<<<<< Updated upstream
extends "res://addons/gdUnit3/src/core/GdUnitTestSuite.gd"

var control

func setup():
	control = preload("res://scenes/ui/pop_up_window/pop_up_window.tscn").instance()
	add_child(control)

# Test ID 18
=======
extends GdUnitTestSuite

var control

func before_test():
	control = preload("res://scenes/ui/pop_up_window/pop_up_window.tscn").instantiate()
	

# Test ID 14
>>>>>>> Stashed changes
# Test sprawdza co się dzieje gdy one_button jest ustawione na true
# Testuje czy po uruchomieniu funkcji _ready() srodkowy przycisk jest widoczny a lewy i prawy przyciski sa ukryte
func test_ready_one_button_mode():
	control.one_button = true
<<<<<<< Updated upstream
	control._ready()

	assert_equals(control.label.text, control.information)
	assert_null(control.get_node_or_null("Panel/MarginContainer/HBoxContainer/LeftButton"))
	assert_null(control.get_node_or_null("Panel/MarginContainer/HBoxContainer/RightButton"))
	assert_not_null(control.get_node_or_null("Panel/MarginContainer/HBoxContainer/MiddleButton"))
	assert_equals(control.middle_button.text, control.middle_button_text)

# Test ID 19
=======
	var runner = scene_runner(control)
	await runner.simulate_frames(10)
	assert_str(runner.get_property("_label").text).is_equal(runner.get_property("information"))
	assert_object(runner.find_child("LeftButton")).is_null()
	assert_object(runner.find_child("RightButton")).is_null()
	assert_object(runner.find_child("MiddleButton")).is_not_null()
	assert_str(runner.invoke("get_node", "Panel/MarginContainer/HBoxContainer/MiddleButton").text).is_equal(runner.get_property("middle_button_text"))

# Test ID 15
>>>>>>> Stashed changes
# Test sprawdza zachowanie sceny gdy one_button jest ustawione na false 
# Lewy i prawy przycisk powinny byc widoczne, a srodkowy przycisk ukryty
func test_ready_two_button_mode():
	control.one_button = false
<<<<<<< Updated upstream
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
=======
	var runner = scene_runner(control)
	await runner.simulate_frames(10)
	assert_str(runner.get_property("_label").text).is_equal(runner.get_property("information"))
	assert_object(runner.find_child("LeftButton")).is_not_null()
	assert_object(runner.find_child("RightButton")).is_not_null()
	assert_object(runner.find_child("MiddleButton")).is_null()
	assert_str(runner.invoke("get_node", "Panel/MarginContainer/HBoxContainer/LeftButton").text).is_equal(runner.get_property("left_button_text"))
	assert_str(runner.invoke("get_node", "Panel/MarginContainer/HBoxContainer/RightButton").text).is_equal(runner.get_property("right_button_text"))


# Test ID 16
# Testuje czy po nacisnieciu lewego przycisku emitowany jest sygnal left_pressed
func test_left_button_signal_emission():
	control.one_button = false
	var runner = scene_runner(control)
	runner.set_mouse_pos(Vector2(450, 420))
	await await_idle_frame()
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	assert_signal(control).is_emitted("left_pressed")

# Test ID 17
# Testuje czy po nacisnieciu prawego przycisku emitowany jest sygnal right_pressed
func test_right_button_signal_emission():
	control.one_button = false
	var runner = scene_runner(control)
	runner.set_mouse_pos(Vector2(600, 420))
	await await_idle_frame()
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	assert_signal(control).is_emitted("right_pressed")

# Test ID 18
# Test sprawdza czy po nacisnieciu srodkowego przycisku w trybie z jednym przyciskiem emitowany jest sygnal middle_pressed
func test_middle_button_signal_emission():
	control.one_button = true
	var runner = scene_runner(control)
	runner.set_mouse_pos(Vector2(500, 420))
	await await_idle_frame()
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	assert_signal(control).is_emitted("middle_pressed")

# Test ID 19
# Testuje funkcje set_information która aktualizuje tekst informacyjny na etykiecie
func test_set_information():
	var new_info = "New information"
	control._ready()
	control.set_information(new_info)
	assert_str(control._label.text).is_equal(new_info)
	control.queue_free()
>>>>>>> Stashed changes
