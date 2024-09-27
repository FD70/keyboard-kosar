extends Timer

const INIT_WAIT_TIME : int = 1000


func _ready() -> void:
	wait_time = INIT_WAIT_TIME


func reset() -> void:
	stop()
	wait_time = INIT_WAIT_TIME


func current_time_seconds() -> float:
	if is_stopped():
		return -1.0
	return INIT_WAIT_TIME - time_left
