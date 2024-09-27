extends AnimatedSprite2D

var FORCE_POSITION : Vector2
var pos_shift : Vector2 = Vector2(0.0, 0.0)

func _ready() -> void:
	Globals.changed_current_type_index.connect(_play_char_index_animation)
	Globals.swing_with_index.connect(_play_swing_animation)
	
	# FORCE_POSITION = Vector2(580, 370)
	FORCE_POSITION = Vector2(580, 0)

func _physics_process(_delta: float) -> void:
	var smoothing_distance : int = 3
	
	var weight : float = float(smoothing_distance) / 100
	# var _before = global_position
	var _before = position
	var _after = FORCE_POSITION + pos_shift
	# global_position = lerp(_before, _after, weight)
	position = lerp(_before, _after, weight)


func set_force_position(_pos : Vector2) -> void:
	FORCE_POSITION = _pos
	
#func _set_force_postion_via_win_resize() -> void:
	#print("love_you")
	

func set_x_shift(x_pos : float) -> void:
	pos_shift.x = x_pos
	
func set_y_shift(y_pos : float) -> void:
	pos_shift.y = y_pos
	
func _play_char_index_animation(_index : int) -> void:
	# print("k: %s" % _index)
	if _index == 0:
		# idle, after "swing" animation
		await get_tree().create_timer(0.2).timeout
		play("idle")
	else:
		# only 1..4
		play("k%s" % max(1, min(_index, 4)))

func _play_swing_animation(_swing_index : int) -> void:
	# print("sw: %s" % _swing_index)
	play("sw%s" % max(1, min(_swing_index, 4)))
