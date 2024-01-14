extends "res://addons/gdUnit3/src/core/GdUnitTestCase.gd"

func mock_input_event(action_name):
    var event = InputEventAction.new()
    event.action = action_name
    event.pressed = true
    return event

func get_test_instance():
    var scene = preload("res://scenes/ui/pause_menu/pause_menu.tscn").instance()
    return scene

# Test ID 11
# Sprawdzenie czy po inicjalizacji sceny wlasciwosci visible glownego elementu oraz dwoch jego dzieci 
# sa ustawione na false
func test_ready_initializes_visibility():
    var layer = get_test_instance()
    layer._ready()
    assert_equals(layer.visible, false)
    assert_equals(layer.settings_container.visible, false)
    assert_equals(layer.pop_up_window.visible, false)

# Test ID 12
# Sprawdzenie czy nacisniecie przycisku pauzy poprawnie zmienia widocznosc elementow interfejsu uzytkownika
func test_input_toggles_visibility_based_on_pause_menu_action():
    var layer = get_test_instance()
    var event = mock_input_event("pause_menu")
    layer._input(event)
    # Assuming GameManager.get_current_game_key("is_paused") is mocked or handled
    assert_equals(layer.visible, true)
    assert_equals(layer.settings_container.visible, true)
    assert_equals(layer.pop_up_window.visible, false)

# Test ID 13
# Sprawdzenie czy nacisniecie przycisku wyjscia z gry powoduje wyswietlenie okna pop_up_window
func test_on_leave_game_button_shows_pop_up_window():
    var layer = get_test_instance()
    layer._on_leave_game_button_pressed()
    assert_equals(layer.pop_up_window.visible, true)
    assert_equals(layer.settings_container.visible, false)

# Test ID 14
# Sprawdzenie czy nacisniecie przycisku powrotu do gry ukrywa elementy interfejsu
func test_on_back_to_game_button_hides_elements():
    var layer = get_test_instance()
    layer._on_back_to_game_button_pressed()
    assert_equals(layer.visible, false)
    assert_equals(layer.settings_container.visible, false)

# Test ID 15
# Sprawdzenie czy nacisniecie lewego przycisku w oknie pop_up_window konczy gre i ukrywa wszystkie elementy
func test_on_pop_up_window_left_ends_game():
    var layer = get_test_instance()
    layer._on_pop_up_window_left_pressed()
    assert_equals(layer.visible, false)
    assert_equals(layer.settings_container.visible, false)
    assert_equals(layer.pop_up_window.visible, false)

# Test ID 16
# Sprawdzenie czy nacisniecie prawego przycisku w oknie pop_up_window ukrywa elementy interfejsu
func test_on_pop_up_window_right_hides_elements():
    var layer = get_test_instance()
    layer._on_pop_up_window_right_pressed()
    assert_equals(layer.visible, false)
    assert_equals(layer.settings_container.visible, false)
    assert_equals(layer.pop_up_window.visible, false)

# Test ID 17
# Sprawdzenie czy funkcja rebind przyciskow w ustawieniach prawidlowo wlacza i wylacza przetwarzanie wejscia
func test_on_settings_button_rebind_toggles_input_processing():
    var layer = get_test_instance()
    layer._on_settings_button_rebind(true)
    assert_equals(layer.is_processing_input(), false)
    layer._on_settings_button_rebind(false)
    assert_equals(layer.is_processing_input(), true)
