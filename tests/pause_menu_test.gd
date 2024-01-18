extends GdUnitTestSuite

var scene

func mock_input_event(action_name):
	var event = InputEventAction.new()
	event.action = action_name
	event.pressed = true
	return event

func before():
	scene = preload("res://scenes/ui/pause_menu/pause_menu.tscn").instantiate()

# Test ID 7
# Sprawdzenie czy po inicjalizacji sceny wlasciwosci visible glownego elementu oraz dwoch jego dzieci 
# sa ustawione na false
func test_ready_initializes_visibility():
	scene._ready()
	assert_bool(scene.visible).is_false()
	assert_bool(scene.get_node("SettingsContainer").visible).is_false()
	assert_bool(scene.get_node("PopUpWindow").visible).is_false()

# Test ID 8
# Sprawdzenie czy nacisniecie przycisku pauzy poprawnie zmienia widocznosc elementow interfejsu uzytkownika
func test_input_toggles_visibility_based_on_pause_menu_action():
	
	var event = mock_input_event("pause_menu")
	scene._input(event)
	# Assuming GameManager.get_current_game_key("is_paused") is mocked or handled
	assert_bool(scene.visible).is_true()
	assert_bool(scene.get_node("SettingsContainer").visible).is_true()
	assert_bool(scene.get_node("PopUpWindow").visible).is_false()

# Test ID 9
# Sprawdzenie czy nacisniecie przycisku wyjscia z gry powoduje wyswietlenie okna PopUpWindow
func test_on_leave_game_button_shows_pop_up_window():
	
	scene._on_leave_game_button_pressed()
	assert_bool(scene.get_node("PopUpWindow").visible).is_true()
	assert_bool(scene.get_node("SettingsContainer").visible).is_false()

# Test ID 10
# Sprawdzenie czy nacisniecie przycisku powrotu do gry ukrywa elementy interfejsu
func test_on_back_to_game_button_hides_elements():
	
	scene._on_back_to_game_button_pressed()
	assert_bool(scene.visible).is_false()
	assert_bool(scene.get_node("SettingsContainer").visible).is_false()

# Test ID 11
# Sprawdzenie czy nacisniecie lewego przycisku w oknie PopUpWindow konczy gre i ukrywa wszystkie elementy
func test_on_pop_up_window_left_ends_game():
	
	scene._on_pop_up_window_left_pressed()
	assert_bool(scene.visible).is_false()
	assert_bool(scene.get_node("SettingsContainer").visible).is_false()
	assert_bool(scene.get_node("PopUpWindow").visible).is_false()

# Test ID 12
# Sprawdzenie czy nacisniecie prawego przycisku w oknie PopUpWindow ukrywa elementy interfejsu
func test_on_pop_up_window_right_hides_elements():
	
	scene._on_pop_up_window_right_pressed()
	assert_bool(scene.visible).is_false()
	assert_bool(scene.get_node("SettingsContainer").visible).is_false()
	assert_bool(scene.get_node("PopUpWindow").visible).is_false()

# Test ID 13
# Sprawdzenie czy funkcja rebind przyciskow w ustawieniach prawidlowo wlacza i wylacza przetwarzanie wejscia
func test_on_settings_button_rebind_toggles_input_processing():
	
	scene._on_settings_button_rebind(true)
	assert_bool(scene.is_processing_input()).is_false()
	scene._on_settings_button_rebind(false)
	assert_bool(scene.is_processing_input()).is_true()
