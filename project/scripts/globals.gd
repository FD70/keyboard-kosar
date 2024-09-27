extends Node

signal game_state_changed_to(state : GAME_STATE)

# var ad_timer : Timer
# const AD_TIMER_TIME : float = 70.0
var master_bus = AudioServer.get_bus_index("Master")

var WORD_LIST : Array
var WOCAB_FILE_PATH : String = "res://assets/wocab/woc_json.json"

# var LEADERBOARD_NAME = "avg409"

signal changed_current_type_index
signal swing_with_index

enum GAME_STATE {
	IDLE,
	TYPING_PROCESS,
}
var CURRENT_GAME_STATE : GAME_STATE

## UI
const UI_FONT_SIZE : int = 32

func _ready() -> void:
	game_state_changed_to.connect(_set_game_state)

	# YandexSDK.game_ready()
	# YandexSDK.init_player()
	# YandexSDK.init_leaderboard()
	
	WORD_LIST = get_array_from_file(WOCAB_FILE_PATH)
	
	# ad_timer = Timer.new()
	# ad_timer.one_shot = true
	# add_child(ad_timer)
	# ad_timer.start(0.1)


func get_array_from_file(file_path : String) -> Array:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	
	var result = json.parse(json_string)
	if result != OK:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return ["косить"]
	
	var _arr = json.data["word"]
	file.close()
	return _arr

func _set_game_state(state : GAME_STATE) -> void:
	CURRENT_GAME_STATE = state

## IF POSSIBLE
#func show_interstitial_ad_IP() -> void:
	#if ad_timer.time_left == 0:
		#ad_timer.start(AD_TIMER_TIME)
		#YandexSDK.show_interstitial_ad()
	#else:
		#return
		#

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			AudioServer.set_bus_mute(master_bus, true)
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			AudioServer.set_bus_mute(master_bus, true)

		NOTIFICATION_APPLICATION_FOCUS_IN:
			AudioServer.set_bus_mute(master_bus, false)
		NOTIFICATION_WM_WINDOW_FOCUS_IN:
			AudioServer.set_bus_mute(master_bus, false)
