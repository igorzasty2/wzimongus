extends "res://addons/gdUnit3/src/GdUnitTestSuite.gd"

var lobby_name_tester
var username_tester

func before_each():
    lobby_name_tester = preload("res://globals/game_manager/game_manager.gd").new()
    username_tester = preload("res://globals/game_manager/game_manager.gd").new()

# Test ID 30
# Test sprawdza poprawne nazwy lobby
func test_lobby_name_valid_length():
    assert_true(lobby_name_tester._verify_lobby_name_length("ValidLobby"))
    assert_true(lobby_name_tester._verify_lobby_name_length("123"))

# Test ID 31
# Test sprawdza za krotka nazwe lobby
func test_lobby_name_too_short():
    assert_false(lobby_name_tester._verify_lobby_name_length("ab"))

# Test ID 32
# Test sprawdza za dluga nazwe lobby
func test_lobby_name_too_long():
    assert_false(lobby_name_tester._verify_lobby_name_length("ThisIsALongLobbyName"))

# Test ID 33
# Test sprawdza poprawne nazwy usera
func test_username_valid_length():
    assert_true(username_tester._verify_username_length("ValidUser"))
    assert_true(username_tester._verify_username_length("123"))

# Test ID 34
# Test sprawdzza za krotka nazwe usera
func test_username_too_short():
    assert_false(username_tester._verify_username_length("ab"))

# Test ID 35
# Test sprawdza za dlugha nazwe usera
func test_username_too_long():
    assert_false(username_tester._verify_username_length("ThisIsALongUsername"))
