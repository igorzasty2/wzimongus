class_name KillScreen
extends CanvasLayer
## Reprezentuje ekran na którym odgrywana jest animacja oblania

## Id oblanego gracza
var victim_id = null
## Id oblewającego wykładowcy
var failer_id = null

var _fail_tween: Tween = null
var _victim = null
var _failer = null

@onready var _victim_sprite = $Victim
@onready var _failer_sprite = $Failer
## Timer czasu trwania animacji
var _animation_timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	visibility_changed.connect(get_parent()._update_player_input)
	
	_victim_sprite = get_node("Victim")
	_failer_sprite = get_node("Failer")
	_victim = GameManagerSingleton.get_registered_players()[victim_id]
	_failer = GameManagerSingleton.get_registered_players()[failer_id]
	
	var victim_skin : AtlasTexture = AtlasTexture.new()
	victim_skin.atlas = load(GameManagerSingleton.SKINS[_victim["skin"]]["resource"])
	victim_skin.region = Rect2(0, 675, 675, 675)
	_victim_sprite.texture = victim_skin
	
	var failer_skin : AtlasTexture = AtlasTexture.new()
	failer_skin.atlas = load(GameManagerSingleton.SKINS[_failer["skin"]]["resource"])
	failer_skin.region = Rect2(0, 0, 675, 675)
	_failer_sprite.texture = failer_skin
	
	_fail_tween = get_tree().create_tween()
	_fail_tween.tween_property($Fail1, "modulate:a", 1, 0.6)
	_fail_tween.tween_property($Fail2, "modulate:a", 1, 0.6)
	_fail_tween.tween_property($Victim/Sweat, "modulate:a", 1, 0.3)
	_fail_tween.tween_property(_victim_sprite, "rotation", -PI/2, 0.3)
	_fail_tween.tween_property(_victim_sprite, "position:y", 520, 0.2)
	
	add_child(_animation_timer)
	_animation_timer.one_shot = true
	_animation_timer.connect("timeout", _animation_timer_timeout)
	_animation_timer.start(3)

func _process(_delta):
	if _animation_timer.wait_time > 0.5:
		_fail_tween.play()

func _animation_timer_timeout():
	self.queue_free()
	hide()
