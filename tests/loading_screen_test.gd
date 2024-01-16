extends "res://addons/gdUnit3/src/GdUnitTestSuite.gd"

var canvas_layer

func setup():
	canvas_layer = preload("res://scenes/game/maps/main_map/loading_screen/loading_screen.tscn").instance()
	add_child(canvas_layer)

	canvas_layer.set_meta("mock_game_manager", GDUnitMock.new())
	canvas_layer.set_meta("mock_animation_player", GDUnitMock.new())
	canvas_layer.animation_player = canvas_layer.get_meta("mock_animation_player")

# Test ID 24
# Test sprawdza funkcje play ktora odpowiada za uruchomienie animacji o nazwie "pop_up"
func test_play():
	canvas_layer.play()
	assert_true(canvas_layer.get_meta("mock_animation_player").verify("play").with_args("pop_up").called_once())

# Test ID 25
# Test sprawdza funkcje display_roles sprawdzajac czy w przypadku gdy gracz jest wykladowca uruchamiana jest odpowiednia animacja ("lecturer_pop_up")
func test_display_roles_lecturer():
	canvas_layer.display_roles(true)
	assert_true(canvas_layer.get_meta("mock_animation_player").verify("play").with_args("lecturer_pop_up").called_once())

# Test ID 26
# Test sprawdza funkcje display_roles sprawdzajac czy w przypadku gdy gracz nie jest wykladowca uruchamiana jest odpowiednia animacja ("crewmate_pop_up")
func test_display_roles_crewmate():
	canvas_layer.display_roles(false)
	assert_true(canvas_layer.get_meta("mock_animation_player").verify("play").with_args("crewmate_pop_up").called_once())

# Test ID 27
# Test sprawdza co sie dzieje po zakonczeniu animacji "pop_up"
func test_on_animation_player_animation_finished_pop_up():
	canvas_layer.role = true
	canvas_layer._on_animation_player_animation_finished("pop_up")
	assert_true(canvas_layer.get_meta("mock_animation_player").verify("play").with_args("lecturer_pop_up").called_once())

# Test ID 28
# Sprawdza reakcje sceny na zakonczenie animacji "lecturer_pop_up". Testuje czy po zakonczeniu tej animacji emitowany jest sygnal finished i czy wywolywana jest odpowiednia metoda w GameManager
func test_on_animation_player_animation_finished_lecturer_pop_up():
	canvas_layer._on_animation_player_animation_finished("lecturer_pop_up")
	assert_signal_emitted(canvas_layer, "finished")
	assert_true(canvas_layer.get_meta("mock_game_manager").verify("main_map_load_finished").called_once())

# Test ID 29
# Sprawdza reakcje sceny na zakonczenie animacji "crewmate_pop_up". Testuje czy po zakonczeniu tej animacji emitowany jest sygnal finished i czy wywolywana jest odpowiednia metoda w GameManager
func test_on_animation_player_animation_finished_crewmate_pop_up():
	canvas_layer._on_animation_player_animation_finished("crewmate_pop_up")
	assert_signal_emitted(canvas_layer, "finished")
	assert_true(canvas_layer.get_meta("mock_game_manager").verify("main_map_load_finished").called_once())
