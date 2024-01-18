extends GdUnitTestSuite

var lobby_name_tester
var username_tester


func before():
	lobby_name_tester = preload("res://globals/game_manager/game_manager.gd").new()
	username_tester = preload("res://globals/game_manager/game_manager.gd").new()

# Test ID 20
# Test sprawdza poprawne nazwy lobby
func test_lobby_name_valid_length():
	assert_bool(lobby_name_tester._verify_lobby_name_length("ValidLobby")).is_true()
	assert_bool(lobby_name_tester._verify_lobby_name_length("123")).is_true()

# Test ID 21
# Test sprawdza za krotka nazwe lobby
func test_lobby_name_too_short():
	assert_bool(lobby_name_tester._verify_lobby_name_length("ab")).is_false()

# Test ID 22
# Test sprawdza za dluga nazwe lobby
func test_lobby_name_too_long():
	assert_bool(lobby_name_tester._verify_lobby_name_length("ThisIsALongLobbyName")).is_false()

# Test ID 23
# Test sprawdza poprawne nazwy usera
func test_username_valid_length():
	assert_bool(username_tester._verify_username_length("ValidUser")).is_true()
	assert_bool(username_tester._verify_username_length("123")).is_true()

# Test ID 24
# Test sprawdzza za krotka nazwe usera
func test_username_too_short():
	assert_bool(username_tester._verify_username_length("ab")).is_false()

# Test ID 25
# Test sprawdza za dlugha nazwe usera
func test_username_too_long():
	assert_bool(username_tester._verify_username_length("ThisIsALongUsername")).is_false()

