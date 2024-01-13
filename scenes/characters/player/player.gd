## Główna klasa gracza.
class_name Player
extends CharacterBody2D


signal vent_entered()

signal vent_exited()

## Prędkość poruszania się.
@export var walking_speed: float = 600.0
## Prędkość teleportacji do venta.
@export var venting_speed: float = 1500.0

## Ostatni kierunek poziomego ruchu gracza.
var direction_last_x: float = -1

## Czy może używać venta.
var can_use_vent: bool = false
## Czy jest w vencie.
var is_in_vent: bool = false
## Czy jest w trakcie poruszania się przez venta lub do venta.
var is_moving_through_vent: bool = false

## Czy gracz właśnie wszedł do venta
var _has_entered_vent: bool = false

## Kolor gracza do zabicia
var in_range_color = [180, 0, 0, 255]
## Kolor gracza, którego nie możemy zabić
var out_of_range_color = [0, 0, 0, 0]
## Kolor nicku martwego gracza
var dead_username_color = Color.DARK_GOLDENROD
## Przechowuje informację o możliwości użycia funkcji zabicia.
var can_kill_cooldown: bool = false
## Przechowuje informację o możliwości użycia funkcji sabotage. 
var can_sabotage_cooldown: bool = false

## Czy jest teleport
var is_teleport: bool = false
## Pozycja docelowa teleportacji
var teleport_position = null


## Referencja do wejścia gracza.
@onready var input: InputSynchronizer = $Input
## Referencja do synchronizatora rollbacku.
@onready var rollback_synchronizer: RollbackSynchronizer = $RollbackSynchronizer
## Referencja do etykiety z nazwą gracza.
@onready var username_label: Label = $UsernameLabel
## Referencja do drzewa animacji postaci.
@onready var animation_tree: AnimationTree = $Skins/AnimationTree
## Referencja do sprite'a postaci.
@onready var player_sprite = $Skins/Control/PlayerSprite
## Referencja do node'a postaci.
@onready var player_node = $"."

## Referencja do node'a światła.
@onready var light = $LightsContainer/Light
## Referencja do kontenera node'a światła.
@onready var lights_container = $LightsContainer

## Player animacji ventowania
@onready var venting_animation_player = $Skins/Control/PlayerSprite/VentingAnimationPlayer

## Początkowa maska kolizji.
@onready var initial_collision_mask: int = collision_mask

## Interfejs
var user_interface
## Emitowany gdy przycisk powinien być włączony/wyłączony
signal button_active(button_name:String, is_active:bool)
## Timer z czasem do oblania
var timer
## Timer z czasem do sabotażu
var sabotage_timer
## Timer z czasem do włączenia światła u studenta.
var no_light_timer
## Określa czy gracz może reportować
var can_report: bool = false


## Zwraca najbliższy vent.
func get_nearest_vent() -> Vent:
	var vent_systems = get_tree().root.get_node("Game/Maps/MainMap/InteractionPoints/Vents").get_children()

	for i in vent_systems:
		var vents = i.get_children()

		for j in vents:
			if position.distance_to(j.global_position) < 300:
				return j

	return null


## Zwraca czy gracz może używać ventów.
func has_vent_permission(vent: Vent) -> bool:
	if GameManagerSingleton.get_registered_player_value(name.to_int(), "is_dead"):
		return false

	if !GameManagerSingleton.get_registered_player_value(name.to_int(), "is_lecturer") && !vent.allow_student_venting:
		return false

	return true


@rpc("call_local", "reliable")
## Zmienia widoczność gracza.
func toggle_visibility(is_enabled: bool):
	visible = is_enabled


func _ready():
	# Gracz jest własnością serwera.
	set_multiplayer_authority(1)

	# Wejście gracza jest własnością gracza.
	input.set_multiplayer_authority(name.to_int())

	# Konfiguruje synchronizator rollbacku.
	rollback_synchronizer.process_settings()

	# Ustawia etykietę z nazwą gracza.
	username_label.text = GameManagerSingleton.get_registered_player_value(name.to_int(), "username")

	# Aktywuje drzewo animacji postaci.
	animation_tree.active = true
	
	# Aktualizuje parametry animacji postaci.
	animation_tree["parameters/idle/blend_position"] = Vector2(direction_last_x, 0)
	animation_tree["parameters/walk/blend_position"] = Vector2(direction_last_x, 0)
	
	# Łączy sygnał zabicia postaci z funkcją _on_killed_player
	GameManagerSingleton.player_killed.connect(_on_killed_player)

	if name.to_int() == GameManagerSingleton.get_current_player_id():
		GameManagerSingleton.sabotage_occured.connect(_on_sabotage_occured)
	
	GameManagerSingleton.map_load_finished.connect(_on_map_load_finished)
	GameManagerSingleton.next_round_started.connect(_on_next_round_started)


func _process(_delta):
	var direction = input.direction.normalized()

	# Aktualizuje parametry animacji postaci.
	_update_animation_parameters(direction)
	
	# Aktualizuje czas pozostały do kolejnej możliwości oblania
	if user_interface!=null && timer!=null && timer.time_left!=0:
		user_interface.update_time_left("FailLabel", str(int(timer.time_left)))
		
	# Aktualizuje czas pozostały do kolejnej możliwości sabotażu.
	if user_interface!=null && sabotage_timer!=null && sabotage_timer.time_left>0:
		user_interface.update_time_left("SabotageLabel", str(int(sabotage_timer.time_left)))


func _rollback_tick(delta, _tick, is_fresh):
	# Odpowiada za poruszanie się przez venta.
	if is_moving_through_vent && is_fresh:
		# Jeśli gracz wchodzi do venta.
		if input.is_walking_to_destination:
			# Jeśli gracz jest w granicy błędu wejścia do venta.
			if global_position.distance_to(input.destination_position) <= walking_speed / NetworkTime.tickrate:
				# Przesuwa gracza do środka venta.
				global_position = input.destination_position
				input.direction = Vector2.ZERO

				_has_entered_vent = true

				if multiplayer.is_server():
					_play_venting_animation.rpc(false)

					var vent = get_nearest_vent()

					if vent != null:
						vent.play_vent_animation.rpc()

				input.is_walking_to_destination = false
				is_moving_through_vent = false

		# Jeśli gracz przemieszcza się między ventami.
		else:
			# Przesuwa gracza w kierunku docelowego venta.
			global_position = global_position.move_toward(input.destination_position, delta * venting_speed * NetworkTime.physics_factor)

			# Jeśli gracz dotarł do docelowego venta.
			if global_position == input.destination_position:
				# Włącza widoczność przycisków kierunkowych venta.
				if name.to_int() == GameManagerSingleton.get_current_player_id():
					_toggle_vent_buttons(true)

				is_moving_through_vent = false
				can_use_vent = true

	# Gracz jest przenoszony na miejsce awaryjnego spotkania
	elif is_teleport && is_fresh:
		# Wyciąga impostora z venta
		if multiplayer.is_server():
			if is_in_vent:
				if name.to_int() != 1:
					_exit_vent()

				_exit_vent.rpc_id(name.to_int())

		global_position = teleport_position
		is_teleport = false
		teleport_position = null


	# Oblicza kierunek ruchu na podstawie wejścia użytkownika.
	velocity = input.direction.normalized() * walking_speed

	# Porusza postacią i obsługuje kolizje.
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
	
	# Podświetla najbliższego gracza jako potencjalną ofiarę do oblania jeśli jestem impostorem,
	# żyje i cooldown na funkcji zabij nie jest aktywny.
	if name.to_int() == GameManagerSingleton.get_current_player_id():
		if GameManagerSingleton.get_current_player_value("is_lecturer") && !is_in_vent:
			if !GameManagerSingleton.get_current_player_value("is_dead"):
				if can_kill_cooldown && !GameManagerSingleton.is_meeting_called:
					_update_highlight(closest_player(GameManagerSingleton.get_current_player_id()))
				else:
					_update_highlight(0)


## Sprawdza, czy nie naciśnięto fail button. Jeśli tak to sprawdza, czy jesteśmy lecturerem
## i prosi serwer o oblanie najbliższego gracza w promieniu oblania.
func _input(event):
	# Obsługuje używanie venta.
	if event.is_action_pressed("use_vent"):
		if name.to_int() != GameManagerSingleton.get_current_player_id():
			return

		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		if !can_use_vent:
			return

		if !is_in_vent && GameManagerSingleton.get_current_game_value("is_input_disabled"):
			return
		
		if venting_animation_player.is_playing():
			return

		_use_vent()

	# Obsługuje zabijanie graczy.
	if event.is_action("fail") && !event.is_echo() && event.is_pressed():
		if name.to_int() != GameManagerSingleton.get_current_player_id():
			return

		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		if GameManagerSingleton.get_current_game_value("is_input_disabled"):
			return

		if !GameManagerSingleton.get_current_player_value("is_lecturer"):
			return

		if !can_kill_cooldown:
			return

		var victim = closest_player(GameManagerSingleton.get_current_player_id())

		if !victim:
			return

		GameManagerSingleton.kill_victim(victim)
		_handle_kill_timer()
		button_active.emit("FailButton", false)

	# Obsługuje sabotaż.
	if event.is_action_pressed("sabotage"):
		if name.to_int() != GameManagerSingleton.get_current_player_id():
			return

		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		if GameManagerSingleton.get_current_game_value("is_input_disabled") && !is_in_vent:
			return

		if !GameManagerSingleton.get_current_player_value("is_lecturer"):
			return

		if !can_sabotage_cooldown:
			return
		
		GameManagerSingleton.emit_sabotage_started.rpc(true)
		GameManagerSingleton.request_light_sabotage.rpc_id(1)
		button_active.emit("SabotageButton", false)


## Aktualizuje parametry animacji postaci.
func _update_animation_parameters(direction: Vector2) -> void:
	# Ustawia parametry animacji w zależności od stanu ruchu.
	if direction == Vector2.ZERO:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
		if direction.x != 0:
			animation_tree["parameters/idle/blend_position"] = direction
			animation_tree["parameters/walk/blend_position"] = direction
			direction_last_x = direction.x
		else:
			animation_tree["parameters/idle/blend_position"] = Vector2(direction_last_x, direction.y)
			animation_tree["parameters/walk/blend_position"] = Vector2(direction_last_x, direction.y)


## W momencie zakończenia wczytywania mapyt przypisuje user_interface i łączy sygnał
func _on_map_load_finished():
	user_interface = get_tree().root.get_node("Game/Maps/MainMap/UserInterface")
	button_active.connect(user_interface.toggle_button_active)
	
	# Na początku gry po załadowaniu mapy restartuje kill cooldown
	_on_next_round_started()


## W momencie zaczęcia kolejnej rundy restartuje kill cooldown gracza
func _on_next_round_started():
	if name.to_int() == GameManagerSingleton.get_current_player_id() && GameManagerSingleton.get_registered_player_value(name.to_int(),"is_lecturer"):
		_handle_kill_timer()
		button_active.emit("FailButton", false)
		_handle_sabotage_timer()
		button_active.emit("SabotageButton", false)


## Obsługuje timer zabicia
func _handle_kill_timer():
	can_kill_cooldown = false
	timer = Timer.new()
	timer.set_name("KillCooldownTimer")
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = true
	timer.wait_time = GameManagerSingleton.get_server_settings()["kill_cooldown"]
	add_child(timer)
	timer.start()


## Włącza i wyłącza podświetlenie możliwości zabicia gracza
func _toggle_highlight(player: int, is_on: bool) -> void:
	var player_material = get_parent().get_node(str(player) + "/Skins/Control/PlayerSprite").material
	
	if player_material:
		player_material.set_shader_parameter('line_color', in_range_color if is_on else out_of_range_color)


func _update_highlight(player: int) -> void:
		var all_players = GameManagerSingleton.get_registered_players().keys()
		all_players.erase(GameManagerSingleton.get_current_player_id())
		
		for i in all_players:
			_toggle_highlight(i, i == player)


## Zwraca id: int najbliższego gracza do "to_who", który nie jest impostorem i żyje.
func closest_player(to_who: int) -> int:
	# Tablica graczy do przeszukiwania najbliższego gracza.
	var players: Array = GameManagerSingleton.get_registered_players().keys()
	players.erase(to_who)

	for i in players:
		if GameManagerSingleton.get_registered_player_value(i, "is_lecturer") or GameManagerSingleton.get_registered_player_value(i, "is_dead"):
			players.erase(i)

	if players.size() > 0:
		# Pobiera promień zabicia z serwera.
		var kill_radius = GameManagerSingleton.get_server_settings()["kill_radius"]

		# Przechowuje wektor pozycji gracza, względem którego szukamy najbliższego gracza.
		var my_position: Vector2 = get_tree().root.get_node("Game/Maps/MainMap/Players/" + str(to_who)).global_position

		# Przechowuje node najbliższego gracza.
		var curr_closest = null

		# Przechowuje odległość najbliższego gracza od pozycji 'my_position'.
		var curr_closest_dist = kill_radius**2 + 1

		for i in range(players.size()):
			# Pozycja gracza tymczasowego
			var temp_position: Vector2 = get_tree().root.get_node("Game/Maps/MainMap/Players/" + str(players[i])).global_position
			# Dystans gracza tymczasowego od pozycji 'my_position'.
			var temp_dist = my_position.distance_squared_to(temp_position)

			if (temp_dist < curr_closest_dist):
				curr_closest = players[i]
				curr_closest_dist = temp_dist

		if curr_closest_dist < (kill_radius**2):
			button_active.emit("FailButton", true)
			return curr_closest
		button_active.emit("FailButton", false)
		return 0
	button_active.emit("FailButton", false)
	return 0


func _on_killed_player(player_id: int, is_victim: bool) -> void:
	if name.to_int() == player_id:
		_update_dead_player(player_id)

		# Wyłącza widoczność gracza.
		if GameManagerSingleton.get_current_player_id() != player_id:
			get_parent().get_node(str(player_id)).visible = false

		# Włącza widoczność wszystkich martwych graczy u marwtch graczy.
		if GameManagerSingleton.get_current_player_value("is_dead"):
			for i in GameManagerSingleton.get_registered_players().keys():
				get_parent().get_node(str(i)).visible = true

		if is_victim:
			var dead_body = preload("res://scenes/characters/dead_body/dead_body.tscn").instantiate()
			get_parent().get_parent().get_node("DeadBodies").add_child(dead_body)
			dead_body.set_dead_player(player_id)


func _on_timer_timeout() -> void:
	if name.to_int() == GameManagerSingleton.get_current_player_id():
		if GameManagerSingleton.get_current_player_value("is_lecturer"):
			can_kill_cooldown = true

			for i in range(player_node.get_child_count()):
				var child: Node = player_node.get_child(i)
				if child.name == "KillCooldownTimer":
					child.queue_free()

					user_interface.update_time_left("FailLabel", "")

					return


func _update_dead_player(player_id: int):
	var victim_node: CharacterBody2D = get_tree().root.get_node("Game/Maps/MainMap/Players/" + str(player_id))
	victim_node.get_node("UsernameLabel").add_theme_color_override("font_color", dead_username_color)
	victim_node.get_node("Skins/Control/PlayerSprite").use_parent_material = true
	victim_node.get_node("Skins/Control/PlayerSprite").modulate = Color(1,1,1,0.35)
	victim_node.collision_mask = 8
	victim_node.collision_layer = 16
	victim_node.z_index += 1
	victim_node.get_node("LightsContainer/Light").shadow_item_cull_mask = 0
	victim_node.get_node("LightsContainer/Light").texture_scale = 10000


## Używa venta.
func _use_vent():
	button_active.emit("ReportButton", !is_in_vent && can_report)
	
	if !is_in_vent:
		button_active.emit("FailButton", false)
		button_active.emit("InteractButton", false)

		_request_vent_entering.rpc_id(1)
	else:
		_request_vent_exiting.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
## Obsługuje żądanie wejścia do venta.
func _request_vent_entering():
	var id = multiplayer.get_remote_sender_id()

	if !name.to_int() == id:
		return

	var vent = get_nearest_vent()

	if vent == null:
		return

	if !has_vent_permission(vent):
		return

	if name.to_int() != 1:
		_enter_vent(vent.global_position)

	_enter_vent.rpc_id(name.to_int(), vent.global_position)


@rpc("call_local", "reliable")
## Wchodzi do venta.
func _enter_vent(vent_position):
	is_in_vent = true
	collision_mask = 0
	is_moving_through_vent = true
	input.destination_position = vent_position
	input.is_walking_to_destination = true
	vent_entered.emit()


@rpc("any_peer", "call_local", "reliable")
## Obsługuje żądanie wyjścia z venta.
func _request_vent_exiting():
	if !multiplayer.is_server():
		return

	var id = multiplayer.get_remote_sender_id()

	if !name.to_int() == id:
		return

	var vent = get_nearest_vent()

	if vent == null:
		return

	if !has_vent_permission(vent):
		return

	if position != vent.global_position:
		return

	if name.to_int() != 1:
		_exit_vent()

	_exit_vent.rpc_id(name.to_int())


@rpc("call_local", "reliable")
## Obsługuje wyjście z venta.
func _exit_vent():
	var vent = get_nearest_vent()

	if vent == null:
		return

	if name.to_int() == GameManagerSingleton.get_current_player_id():
		vent.set_direction_buttons_visibility(false)
		vent.set_vent_light_visibility_for(name.to_int(), false)

	_has_entered_vent = false
	is_in_vent = false
	collision_mask = initial_collision_mask

	if multiplayer.is_server():
		toggle_visibility.rpc(true)

		_play_venting_animation.rpc(true)
		vent.play_vent_animation.rpc()


## Zmienia widoczność przycisków kierunkowych venta.
func _toggle_vent_buttons(is_enabled: bool):
	var vent = get_nearest_vent()

	if vent == null:
		return

	vent.set_direction_buttons_visibility(is_enabled)

## Zmienia widoczność światła venta.
func _toggle_vent_light(value: bool):
	var vent = get_nearest_vent()

	if vent == null:
		return

	vent.set_vent_light_visibility_for(name.to_int(), value)


## Włącza światło graczowi.
func activate_lights():
	if GameManagerSingleton.get_current_player_value("is_lecturer"):
		set_light_texture_scale(GameManagerSingleton.get_server_settings()["lecturer_light_radius"])
	else:
		set_light_texture_scale(GameManagerSingleton.get_server_settings()["student_light_radius"])
	
	lights_container.show()


## Wyłącza światło graczowi.
func deactivate_lights():
	lights_container.hide()


## Włącza shadery graczowi.
func activate_player_shaders():
	# Domyślnie shadery są wyłaczone w menu bo jeżeli włączyć ich to nie będzie widać graczowi
	var shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://assets/shaders/outline_light.gdshader")
	
	player_sprite.material = shader_material
	player_sprite.material.set_shader_parameter("line_thickness", 12.0)
	
	username_label.material = load("res://assets/shaders/light.tres")


## Wyłącza shadery graczowi.
func deactivate_player_shaders():
	player_sprite.material = null
	username_label.material = null


## Ustawia wartość promienia światła graczowi.
func set_light_texture_scale(texture_scale: float):
	light.texture_scale = texture_scale / player_node.global_scale.x


## Obsługuje timer sabotage
func _handle_sabotage_timer():
	can_sabotage_cooldown = false
	sabotage_timer = Timer.new()
	sabotage_timer.set_name("SabotageCooldownTimer")
	sabotage_timer.timeout.connect(_on_sabotage_timer_timeout)
	sabotage_timer.one_shot = true
	sabotage_timer.wait_time = GameManagerSingleton.get_server_settings()["sabotage_cooldown"]
	add_child(sabotage_timer)
	sabotage_timer.start()


## Usuwa timer sabotażu oraz udostępnia sabotaż u wykładowcy.
func _on_sabotage_timer_timeout() -> void:
	if name.to_int() == GameManagerSingleton.get_current_player_id():
		if GameManagerSingleton.get_current_player_value("is_lecturer"):
			can_sabotage_cooldown = true

			for i in range(player_node.get_child_count()):
				var child: Node = player_node.get_child(i)
				if child.name == "SabotageCooldownTimer":
					child.queue_free()

					user_interface.update_time_left("SabotageLabel", "")
					button_active.emit("SabotageButton", true)

					return


## Aktywuje sabotaż u studentów oraz blokuje na jakiś czas przecisk sabotażu u wykładowców.
func _on_sabotage_occured():
	if GameManagerSingleton.get_current_player_value("is_lecturer"):
		button_active.emit("SabotageButton", false)
		_handle_sabotage_timer()
	else:
		decrease_light_range_sabotage()

		no_light_timer = Timer.new()
		no_light_timer.set_name("NoLightTimer")
		no_light_timer.timeout.connect(cancel_decrease_light_range_sabotage)
		no_light_timer.one_shot = true
		no_light_timer.wait_time = GameManagerSingleton.get_server_settings()["sabotage_cooldown"] if GameManagerSingleton.get_server_settings()["sabotage_cooldown"] <= 10 else 10
		add_child(no_light_timer)
		no_light_timer.start()


## Zmniejsza promień swiatła podczas sabotage.
func decrease_light_range_sabotage() -> void:
	if not GameManagerSingleton.get_current_player_value("is_lecturer"):
		var tween = get_tree().create_tween()
		tween.tween_property(light, "texture_scale", light.texture_scale / 6, 1).set_trans(Tween.TRANS_CUBIC)


## Wraca promień swiatła na normalny po sabotage.
func cancel_decrease_light_range_sabotage() -> void:
	GameManagerSingleton.emit_sabotage_started.rpc(false)
	if not GameManagerSingleton.get_current_player_value("is_lecturer"):
		var tween = get_tree().create_tween()
		tween.tween_property(light, "texture_scale", light.texture_scale * 6, 1).set_trans(Tween.TRANS_CUBIC)


func _on_venting_animation_player_animation_finished(anim_name):
	if anim_name == "venting_animation":
		# Gracz wchodzi do venta
		if _has_entered_vent:
			button_active.emit("ReportButton", !is_in_vent && can_report)
			button_active.emit("FailButton", !is_in_vent)

			# Wyłącza widoczność gracza.
			if multiplayer.is_server():
				toggle_visibility.rpc(false)

			# Włącza widoczność przycisków kierunkowych venta.
			if name.to_int() == GameManagerSingleton.get_current_player_id():
				_toggle_vent_buttons(true)
				_toggle_vent_light(true)
		# Gracz wychodzi z venta
		else:
			_handle_vent_exit()


## Obsługuje wyjście z venta po zakończeniu animacji
func _handle_vent_exit():
	_has_entered_vent = false
	vent_exited.emit()


@rpc("call_local", "reliable")
## Puszcza animacje ventowania
func _play_venting_animation(is_backwards:bool):
	if !is_backwards:
		venting_animation_player.play("venting_animation")
	else: 
		venting_animation_player.play_backwards("venting_animation")