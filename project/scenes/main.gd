extends CanvasLayer


# 64 символа (количество) примерно в длину
var active_word : THE_WORD
var active_letter = null

var cloud1 : Material
var ground_road_material : Material
var ground_material : Material
var ground2_material : Material


var COUNT_OF_TYPED_SYMBS : int = 0
var STORE_TYPED_SYMBS : int = 0
var STORE_GAME_SCORE = null # int

# shift_speeds
const LENGH_ONE_SYMB_PIXEL : int = 20
const GROUND_SPEED_SHIFT = 0.03
var GAME_TIMER : Timer
const START_INV_TIME : int = 10

var SKY_COLOR_CLEAR = Color.html("6478a1")
var SKY_COLOR_RAINY = Color.DARK_SLATE_BLUE # or Color.html("6478a1")
## samples
var SAMPLE_CROP = preload("res://scenes/crop_unit.tscn")
const PLAYER_SPRITE_SIZE : Vector2 = Vector2(180, 200)


func _ready() -> void:
	GAME_TIMER = %Game_timer
	Globals.game_state_changed_to.connect(_on_game_state_changed_to)
	Globals.game_state_changed_to.emit(Globals.GAME_STATE.IDLE)
	cloud1 = $MarginContainer/OVERFLOW/Control/cloud1.material
	ground_road_material = $MarginContainer/OVERFLOW/Control/ground_road.material
	ground_material = $MarginContainer/OVERFLOW/Control/ground.material
	ground2_material = $MarginContainer/OVERFLOW/Control/ground2.material
	
	## поменять шрифты кнопок
	$MarginContainer/OVERFLOW/UI/VBoxContainer/result_frame.add_theme_font_size_override("font_size", Globals.UI_FONT_SIZE)
	$MarginContainer/OVERFLOW/UI/VBoxContainer/result_frame/ColorRect/result_label.add_theme_font_size_override("font_size", Globals.UI_FONT_SIZE)
	%play_button.add_theme_font_size_override("font_size", Globals.UI_FONT_SIZE)
	
	## Заполнить полосу для покоса
	for i in range(30):
		var _c = SAMPLE_CROP.instantiate()
		%crop_line.add_child(_c)
	
	%text_line.position.x = _get_center().x
	%crop_line.position.x = _get_center().x
	var _xforce = %crop_line.get_begin().x - 90
	var _yforce = -45
	%Player.set_force_position(Vector2(_xforce, _yforce))


func _process(_delta: float) -> void:
	# print("av: %s" % _get_average_speed())
	# print("time: %s, hn: %s" % [GAME_TIMER.current_time_seconds(), _get_typing_hardeness()])
	if Globals.CURRENT_GAME_STATE == Globals.GAME_STATE.IDLE:
		if Input.is_action_just_pressed("M_KEY_ENTER"):
			%play_button.emit_signal("pressed")


func _physics_process(delta: float) -> void:
	_shift_all_graphics(delta)
	if Globals.CURRENT_GAME_STATE == Globals.GAME_STATE.TYPING_PROCESS:
		var T_SPEED_OFFSET = 30
		var _speed_diff = _get_typing_hardeness() - _get_average_speed()
		
		var _max_weight = 1.0
		var weight : float = min(max(0, (_speed_diff + T_SPEED_OFFSET) / (T_SPEED_OFFSET*2)), _max_weight)
		_rain_control(weight)
		
		if weight == _max_weight:
			_stop_game()


func _unhandled_input(event):
	if Globals.CURRENT_GAME_STATE == Globals.GAME_STATE.TYPING_PROCESS:
		if event is InputEventKey and event.is_pressed():
			var typed_event = event as InputEventKey
			## символ набран правильно
			if typed_event.unicode == active_letter.unicode_at(0):
				COUNT_OF_TYPED_SYMBS += 1
				_set_next_letter()


func _start_new_game():
	GAME_TIMER.reset()
	GAME_TIMER.start()
	
	STORE_TYPED_SYMBS = COUNT_OF_TYPED_SYMBS
	active_word = null
	_clean_text_line()
	
	## Заполнить текстовую полову
	for i in range(10):
		_put_next_word(_create_THE_word())
		_put_next_word(THE_WORD.new(" "))
	
	_set_next_letter()
	
	
func _stop_game():
	Globals.swing_with_index.emit(active_word.current_type_index)
	Globals.changed_current_type_index.emit(0)
	
	STORE_GAME_SCORE = _get_average_speed()
	GAME_TIMER.stop()
	Globals.game_state_changed_to.emit(Globals.GAME_STATE.IDLE)
	_clean_text_line()
	
	## Отправить результат в лидерборды
	# var send_score : float = float(int(STORE_GAME_SCORE * 10))
	# YandexSDK.save_leaderboard_score(Globals.LEADERBOARD_NAME, send_score)
	
	$MarginContainer/OVERFLOW/UI/VBoxContainer/result_frame/ColorRect/result_label.text = "Ваш результат: %.1f" % STORE_GAME_SCORE
	$MarginContainer/OVERFLOW/UI/VBoxContainer/result_frame.visible = true


### Установить следующий символ для печати
func _set_next_letter() -> void:
	if active_word == null:
		active_word = _get_next_active_word()

	if active_word.has_next_char():
		active_letter = active_word.set_next_char()
	else:
		if active_word.type_text == " ":
			_put_next_word(_create_THE_word())
			_put_next_word(THE_WORD.new(" "))
		
		# получение координаты для сдвига слова
		var _x_shift = %text_line/HBoxContainer.get_child(1).get_global_x_position()\
		- %text_line.global_position.x
		%text_line/HBoxContainer.position.x = _x_shift

		%text_line/HBoxContainer.remove_child(active_word)
		active_word.destroy_the_word()
		active_word = _get_next_active_word()
		active_letter = active_word.set_next_char()

func _get_next_active_word() -> THE_WORD:
	# if %text_line/HBoxContainer.get_child_count() > 0:
	return %text_line/HBoxContainer.get_child(0)

### Добавить Слово в полосу для набора
func _put_next_word(next_word: THE_WORD) -> void:
	%text_line/HBoxContainer.add_child(next_word)

### Выбрать случайное слово из случайного словаря
func _create_THE_word() -> THE_WORD:
	var _word = randi_range(0, len(Globals.WORD_LIST) - 1)
	return THE_WORD.new(Globals.WORD_LIST[_word])

## Очистить полосу набора
func _clean_text_line() -> void:
	var _all_childrens = %text_line/HBoxContainer.get_children()
	for i in _all_childrens:
		%text_line/HBoxContainer.remove_child(i)
		i.queue_free()

## handel graphix shift
func _shift_all_graphics(delta : float) -> void:
	
	# облако фон
	_static_shift_shader_texture(cloud1, 4, -delta/10)
	# _shift_shader_texture(cloud1, 4, GROUND_SPEED_SHIFT/10)
	
	# травка на переднем фоне
	_shift_shader_texture(ground_road_material, 4, GROUND_SPEED_SHIFT/3)
	_shift_shader_texture(ground_material, 4, GROUND_SPEED_SHIFT)
	_shift_shader_texture(ground2_material, 4, GROUND_SPEED_SHIFT/1.2)
	
	# Смещение Player при наборе текста
	
	# if active_word != null:
	if Globals.CURRENT_GAME_STATE == Globals.GAME_STATE.TYPING_PROCESS:
		%Player.set_x_shift(-(active_word.current_type_index + 1) * LENGH_ONE_SYMB_PIXEL)
		if active_word.current_type_index == 0:
			$%Player.set_y_shift(abs(sin(COUNT_OF_TYPED_SYMBS) * LENGH_ONE_SYMB_PIXEL))
	
		# text_line
		# %text_line.position.x = _get_center().x + 60
		# TODO: сделать плавное перемещение
		var _before = %text_line/HBoxContainer.position.x
		var _temp = lerpf(_before, -active_word.current_type_index * LENGH_ONE_SYMB_PIXEL, float(4)/100)
		%text_line/HBoxContainer.position.x = _temp

		# Смещение травы для скоса
		%crop_line.position.x = _get_center().x - active_word.current_type_index * 30

func _shift_shader_texture(m_material : Material, smoothing_distance : int, speed_weight : float) -> void:
	var weight : float = float(smoothing_distance) / 100
	var _before = m_material.get("shader_parameter/texture_shift")
	var _after = speed_weight * COUNT_OF_TYPED_SYMBS
	var _temp_shift : float = lerpf(_before, _after, weight)
	m_material.set_shader_parameter("texture_shift", _temp_shift)

func _static_shift_shader_texture(m_material : Material, smoothing_distance : int, shift_distance : float) -> void:
	var _temp_shift : float
	
	var weight : float = float(smoothing_distance) / 100
	var _before = m_material.get("shader_parameter/texture_shift")
	var _after = _before + shift_distance
	_temp_shift = lerpf(_before, _after, weight)
	
	m_material.set_shader_parameter("texture_shift", _temp_shift)

func _rain_control(rainy_weight : float) -> void:
	$MarginContainer/OVERFLOW/Control/sky.color = lerp(SKY_COLOR_CLEAR, SKY_COLOR_RAINY, rainy_weight)
	$MarginContainer/OVERFLOW/Control/rain_box.material.set_shader_parameter("count", lerpf(0, 300, rainy_weight)) # 0..2000
	# rain_material.set_shader_parameter("slant", 1000) # -0.1 <--> 0.1

## Центр экрана
func _get_center() -> Vector2:
	# return get_viewport().size / 2
	return $MarginContainer.size / 2

## Нарастание сложности:
## 120s --> 700kpm # x(t) = 35/6 
func _get_typing_hardeness() -> float:
	if GAME_TIMER.is_stopped():
		return -1.0
	# первые {START_INV_TIME} сложность не растет
	return (GAME_TIMER.current_time_seconds() - START_INV_TIME) * 6
	
func _get_average_speed() -> float:
	var _run_symbs = COUNT_OF_TYPED_SYMBS - STORE_TYPED_SYMBS
	return _run_symbs / GAME_TIMER.current_time_seconds() * 60


func _on_play_button_pressed() -> void:
	# Globals.show_interstitial_ad_IP()
	
	$animation/AnimationPlayer.play("before_start")
	## animation time
	$MarginContainer/OVERFLOW/UI/VBoxContainer.visible = false
	await get_tree().create_timer(2).timeout
	Globals.game_state_changed_to.emit(Globals.GAME_STATE.TYPING_PROCESS)
	# $MarginContainer/OVERFLOW/UI/VBoxContainer.visible = false
	
func _on_game_state_changed_to(state : Globals.GAME_STATE):
	#print("state: %s" % state)
	match state:
		Globals.GAME_STATE.IDLE:
			$MarginContainer/OVERFLOW/UI/VBoxContainer.visible = true
		Globals.GAME_STATE.TYPING_PROCESS:
			$MarginContainer/OVERFLOW/UI/VBoxContainer.visible = false
			_start_new_game()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			$focus_hover.visible = true
			get_tree().paused = true
			# show_interstitial_ad_IP()
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			# show_interstitial_ad_IP()
			$focus_hover.visible = true
			get_tree().paused = true

		NOTIFICATION_APPLICATION_FOCUS_IN:
			$focus_hover.visible = false
			get_tree().paused = false
		NOTIFICATION_WM_WINDOW_FOCUS_IN:
			$focus_hover.visible = false
			get_tree().paused = false


func _on_margin_container_resized() -> void:
	%text_line.position.x = _get_center().x
	%crop_line.position.x = _get_center().x
	var _xforce = %crop_line.get_begin().x - 90
	var _yforce = -45
	%Player.set_force_position(Vector2(_xforce, _yforce))
