extends GdUnitTestSuite

var scene = null

func before():
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

# Test ID 2
# Jeden zwyciezca
func test_get_most_voted_player_id_single_winner():
	GameManagerSingleton.set_current_game_value("votes", {12345: [54321, 13578], 54321: [12345]})
	var result = scene._get_most_voted_player_id()
	assert_int(result).is_equal(12345)

# Test ID 3
# Scenariusz bez glosow
func test_get_most_voted_player_id_no_votes():
	GameManagerSingleton.set_current_game_value("votes", {})
	var result = scene._get_most_voted_player_id()
	assert_int(result).is_null()

# Test ID 4
# Scenariusz z remisem
func test_get_most_voted_player_id_tie():
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
