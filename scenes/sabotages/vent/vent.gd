class_name Vent
extends Node2D

@export var vent_target_list : Array[Vent] = []

var vent_direction_button = preload("res://scenes/sabotages/vent/vent_direction_button/vent_direction_button.tscn")
var vent_direction_button_list = []

const DIRECTION_BUTTON_DISTANCE_MULTIPLIER = 60

var is_player_in_vent = false

var can_be_used = false
var player_body

func _ready():
	set_process_input(false)
	var dir_id = 0
	# instantiate button for every vent
	for target_vent in vent_target_list:
		# calculate direction of button
		var direction_button_pos : Vector2 = (target_vent.position - position).normalized()
		instantiante_direction_button(direction_button_pos * DIRECTION_BUTTON_DISTANCE_MULTIPLIER)
		vent_direction_button_list[-1].id = dir_id
		dir_id += 1

# handles entering vent
func _input(event):
	if event.is_action_pressed("use_vent"):
		use_vent()

# handles using vent
func use_vent():
	if can_be_used:
		if is_player_in_vent:
			exit_vent()
		elif !is_player_in_vent:
			enter_vent()

# instances direction button
func instantiante_direction_button(pos : Vector2):
	var vent_dir_bttn_instance = vent_direction_button.instantiate()
	# connect direction button instance
	vent_dir_bttn_instance.direction_button_pressed.connect(_on_direction_button_pressed)
	
	# set position of button
	vent_dir_bttn_instance.position = pos
	# set button rotation towards target
	vent_dir_bttn_instance.rotation = pos.angle()
	
	add_child(vent_dir_bttn_instance)
	vent_direction_button_list.append(vent_dir_bttn_instance)

# handles direction button press
func _on_direction_button_pressed(id):
	# prevents moving to another vent and exiting at the same time
	set_process_input(false)
	
	move_to_vent(id)

# handles moving player from one vent to another
func move_to_vent(id):
	# handle start vent
	change_dir_bttns_visibility(false)
	is_player_in_vent = false
	
	# handle target vent
	vent_target_list[id].is_player_in_vent = true
	vent_target_list[id].change_dir_bttns_visibility(true)
	vent_target_list[id].player_body.position = vent_target_list[id].position - Vector2(0,50)

# handles player entering vent
func enter_vent():
	for i in vent_target_list:
		i.player_body = self.player_body

	player_body.position = self.position - Vector2(0,50)
	player_body.visible = false
	player_body.toggle_movement(false)
	
	is_player_in_vent = true
	change_dir_bttns_visibility(true)

# handles player exiting vent
func exit_vent():
	player_body.visible = true
	is_player_in_vent = false
	
	player_body.toggle_movement(true)
	change_dir_bttns_visibility(false)

# changes visibility of vent direction buttons
func change_dir_bttns_visibility(visibility:bool):
	for dir_butt in vent_direction_button_list:
		dir_butt.visible = visibility

# handles player entering venting area
func _on_area_2d_body_entered(body):
	# to do: check if player is impostor, put everything inside if
	set_process_input(true)
	player_body = body
	can_be_used = true

# handles player exiting venting area
func _on_area_2d_body_exited(body):
	set_process_input(false)
	can_be_used = false
