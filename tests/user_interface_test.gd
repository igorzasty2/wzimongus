extends "res://addons/gdUnit3/src/core/GdUnitTestSuite.gd"

var scene

func setup():
	scene = preload("res://scenes/game/maps/main_map/user_interface/user_interface.tscn").instance()

# Test ID 9
# Test sprawdza czy funkcja _ready poprawnie wylacza przyciski kiedy gracz jest impostorem 
# Test ustawia stan gry tak, aby symulowac ze obecny gracz jest impostorem
# a nastepnie wywoluje funkcje _ready. Po jej wykonaniu, test weryfikuje, czy stan przyciskww
# jest taki jak oczekiwano - w tym przypadku czy przyciski są wylaczone.
func test_ready_as_impostor():
	# Ustawienie gracza jako impostora
	mock_game_manager.set_current_player_role("is_lecturer", true)

	scene._ready()

	# Sprawdzenie, czy odpowiednie przyciski są wylaczone
	assert_false(scene.get_node("GridContainer/VentButton").disabled)
	assert_false(scene.get_node("GridContainer/FailButton").disabled)
	assert_false(scene.get_node("GridContainer/SabotageButton").disabled)
	assert_false(scene.get_node("GridContainer/ReportButton").disabled)
	assert_false(scene.get_node("GridContainer/InteractButton").disabled)

	# Sprawdzenie czy zadne przyciski nie zostaly usuniete
	assert_not_null(scene.get_node_or_null("GridContainer/VentButton"))
	assert_not_null(scene.get_node_or_null("GridContainer/FailButton"))
	assert_not_null(scene.get_node_or_null("GridContainer/SabotageButton"))
	assert_not_null(scene.get_node_or_null("GridContainer/ReportButton"))
	assert_not_null(scene.get_node_or_null("GridContainer/InteractButton"))

# Test ID 10
# Test sprawdza czy funkcja _ready poprawnie usuwa przyciski gdy gracz jest crewmatem. 
# Test ustawia stan gry na crewmate'a, wywoluje _ready i nastepnie sprawdza czy odpowiednie przyciski zostally usuniete
func test_ready_as_crewmate():
	# Ustawienie gracza jako crewmate
	mock_game_manager.set_current_player_role("is_lecturer", false)
	
	scene._ready()

	# Sprawdzenie, czy odpowiednie przyciski są usuniete
	assert_null(scene.get_node_or_null("GridContainer/VentButton"))
	assert_null(scene.get_node_or_null("GridContainer/FailButton"))
	assert_null(scene.get_node_or_null("GridContainer/SabotageButton"))
	assert_null(scene.get_node_or_null("GridContainer/ReportButton"))
	assert_null(scene.get_node_or_null("GridContainer/InteractButton"))
