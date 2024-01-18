<<<<<<< Updated upstream
extends "res://addons/gdUnit3/src/core/GdUnitTestSuite.gd"
=======
extends GdUnitTestSuite
>>>>>>> Stashed changes

var scene = null

func before():
<<<<<<< Updated upstream
	scene = load("res://scenes/game/maps/main_map/voting_screen/voting_screen.tscn").instance()
	add_child(scene)

	scene.players = Node.new()
	scene.add_child(scene.players)

# Test ID 1
# Sprawdza czy glosowanie dziala poprawnie
func test_on_player_voted():
	var player_key = "test_player_key"
	var unique_id = 12345

	scene._on_player_voted(player_key)

	assert_true(GameManager.get_current_game_key("is_voted"))
	assert_equals(GameManager.get_vote(player_key), unique_id)
=======
	scene = preload("res://scenes/game/maps/main_map/voting_screen/voting_screen.tscn").instantiate()
	add_child(scene)

# Test ID 1
# Sprawdza czy oddanie głosu dziala poprawnie
func test_on_player_voted():
	var unique_id = auto_free(12345)
	var voter_id = auto_free(13789)

	scene._add_player_vote(unique_id, voter_id)
	assert_int(GameManagerSingleton.get_current_game_value("votes").size()).is_greater(0)
	assert_int(GameManagerSingleton.get_current_game_value("votes")[unique_id][0]).is_equal(voter_id)
>>>>>>> Stashed changes

# Test ID 2
# Jeden zwyciezca
func test_get_most_voted_player_id_single_winner():
<<<<<<< Updated upstream
	GameManager.set_current_game_key("votes", {"player1": ["player2", "player3"], "player2": ["player1"]})
	var result = scene.get_most_voted_player_id()
	assert_equals(result, "player1")
=======
	GameManagerSingleton.set_current_game_value("votes", {12345: [54321, 13578], 54321: [12345]})
	var result = scene._get_most_voted_player_id()
	assert_int(result).is_equal(12345)
>>>>>>> Stashed changes

# Test ID 3
# Scenariusz bez glosow
func test_get_most_voted_player_id_no_votes():
<<<<<<< Updated upstream
	GameManager.set_current_game_key("votes", {})
	var result = scene.get_most_voted_player_id()
	assert_equals(result, null)
=======
	GameManagerSingleton.set_current_game_value("votes", {})
	var result = scene._get_most_voted_player_id()
	assert_int(result).is_null()
>>>>>>> Stashed changes

# Test ID 4
# Scenariusz z remisem
func test_get_most_voted_player_id_tie():
<<<<<<< Updated upstream
	GameManager.set_current_game_key("votes", {"player1": ["player2"], "player2": ["player1"]})
	var result = scene.get_most_voted_player_id()
	assert_equals(result, null)

# Test ID 5
# Zakończenie procesu glosowania
# Aktualizacja tekstu informującego o koncu głosowania
# Uruchomienie timera dla wyrzucenia graczami
# Sprawdzamy czy wszystko działa
func test_on_end_voting_timer_timeout_updates_text_and_starts_timer():
	scene.end_vote_text = Label.new()
	scene.eject_player_timer = Timer.new()
	scene.add_child(scene.end_vote_text)
	scene.add_child(scene.eject_player_timer)

	scene._on_end_voting_timer_timeout()

	assert_equals(scene.end_vote_text.text, "[center]Głosowanie zakończone![/center]")
	assert_false(scene.eject_player_timer.is_stopped())

# Test ID 6
func test_on_end_voting_timer_timeout_server_actions():
	if not scene.multiplayer.is_server():
		return

	var mock_votes = {"player1": ["player2", "player3"], "player2": ["player1"]}
	GameManager.set_current_game_key("votes", mock_votes)

	scene._on_end_voting_timer_timeout()

# Test ID 7
# Renderowanie na ekranie boxow z graczami na podstawie danych z GameManagera
# Sprawdzamy czy boxy sa odpowiednio stworzone
func test_render_player_boxes_creates_boxes_for_each_player():
	var mock_players = {"player1": PlayerData.new("Player1"), "player2": PlayerData.new("Player2")}
	GameManager.set_registered_players(mock_players)

	scene._render_player_boxes()

	var child_count = scene.players.get_child_count()
	assert_equals(child_count, 2)

# Test ID 8
# Sprawdzamy czy boxy graczy zawieraja informacje o glosach
func test_render_player_boxes_with_votes():
	var mock_players = {"player1": PlayerData.new("Player1"), "player2": PlayerData.new("Player2")}
	var mock_votes = {"player1": ["player2"], "player2": ["player1"]}
	GameManager.set_registered_players(mock_players)
	GameManager.set_current_game_key("votes", mock_votes)

	scene._render_player_boxes()

	for i in range(scene.players.get_child_count()):
		var player_box = scene.players.get_child(i)
		var expected_votes = mock_votes[player_box.get_player_key()]
		assert_array_equals(player_box.get_votes(), expected_votes)
=======
	GameManagerSingleton.set_current_game_value("votes", {12345: [54321], 54321: [12345]})
	var result = scene._get_most_voted_player_id()
	assert_int(result).is_null()

## Test ID 5
## Zakończenie procesu glosowania
## Aktualizacja tekstu informującego o koncu głosowania
## Uruchomienie timera dla wyrzucenia graczami
## Sprawdzamy czy wszystko działa
func test_on_end_voting_timer_timeout_updates_text_and_starts_timer():
	scene._end_vote_text = Label.new()
	scene._eject_player_timer = Timer.new()
	scene.add_child(scene._end_vote_text)
	scene.add_child(scene._eject_player_timer)

	scene._on_end_voting_timer_timeout()

	assert_str(scene._end_vote_text.text).is_equal("[center]Głosowanie zakończone![/center]")
	assert_bool(scene._eject_player_timer.is_stopped()).is_false()


# Test ID 6
# Renderowanie na ekranie boxow z graczami na podstawie danych z GameManagera
# Sprawdzamy czy boxy sa odpowiednio stworzone
func test_render_player_boxes_creates_boxes_for_each_player():
	GameManagerSingleton.set_current_game_value("registered_players", {12345: {"username": "12345", "is_lecturer": false, "is_dead": false, "skin": 10}, 54321: {"username": "54321", "is_lecturer": false, "is_dead": false, "skin": 9}})

	scene._render_player_boxes()

	var child_count = scene._players.get_child_count()
	assert_int(child_count).is_equal(2)
>>>>>>> Stashed changes
