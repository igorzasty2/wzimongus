extends CharacterBody2D

## Authority ID property is being automatically set on spawn by map.gd.
## This value is used for player syncronization across game instances. 
@export var authority_id : int

## Nickname property is being automatically set on spawn by map.gd.
## This property contains the value of UsernameField from main_menu scene.
@export var nickname : String 
const SPEED = 300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

## Sets player's nickname to diplay above character and sets authority_id
## for syncronization purposes.
func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(authority_id).to_int())
	$NicknameLabel.text = nickname

## Implements top-down view player controls with arrow keys. Syncronizes
## players accross game instances via MultiplayerSyncronizer.
func _physics_process(delta):
	# Syncronisation logic, if changes in player's physics are required
	# please enter them inside an if-statement body.
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		
		var direction_y = Input.get_axis("ui_up", "ui_down")
		if direction_y:
			velocity.y = direction_y * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
		
		var direction_x = Input.get_axis("ui_left", "ui_right")
		if direction_x:
			velocity.x = direction_x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
