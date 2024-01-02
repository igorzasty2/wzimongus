extends Area2D

@export var area_radius = 140

var player_array
var is_player_inside: bool = false

func _ready():
	$CollisionShape2D.shape.set_radius(area_radius)
	player_array = get_parent().get_node("Players").get_children()
	
func _input(event):
	if event.is_action_pressed("report") and is_player_inside:
		print("reported")
		# 1. pokaż ekran z ciałem
		# 2. wyciągnij impostorów z ventów
		# 3. zamknij taski
		# 4. przenieś graczy na start
		# 5. rozpocznij głosowanie


func _on_body_entered(body):
	if body.name.to_int() == GameManager.get_current_player_id():
		is_player_inside = true


func _on_body_exited(body):
	if body.name.to_int() == GameManager.get_current_player_id():
		is_player_inside = false
