class_name THE_WORD
extends RichTextLabel

var FONT_SIZE : int = 34
var type_text : String
var current_type_index = -1

var HIGHLIGHT_COLOR = Color.DARK_SALMON.to_html()
var BB_HIGHLIGHT_COLOR_START = "[color=%s]" % HIGHLIGHT_COLOR
var BB_HIGHLIGHT_COLOR_END = "[/color]"

func _init(n_text: String):
	type_text = n_text
	text = n_text

func _ready() -> void:
	bbcode_enabled = true
	scroll_active = false
	fit_content = true
	autowrap_mode = 0
	# add_theme_font_override("normal_font", )
	# set_texture_filter(CanvasItem.TEXTURE_FILTER_LINEAR)
	add_theme_font_size_override("normal_font_size", FONT_SIZE)

func has_next_char() -> bool:
	if current_type_index < len(type_text) -1:
		return true
	return false


func set_next_char() -> String:
	if has_next_char():
		current_type_index += 1
		Globals.changed_current_type_index.emit(current_type_index)
	_highligh_char()
	return type_text.substr(current_type_index, 1)
	
func get_type_text() -> String:
	return type_text
	
func destroy_the_word() -> void:
	Globals.swing_with_index.emit(len(type_text))
	queue_free()
	
func _highligh_char() -> void:
	text = type_text.substr(0, current_type_index)\
		+ BB_HIGHLIGHT_COLOR_START\
		+ type_text.substr(current_type_index, 1)\
		+ BB_HIGHLIGHT_COLOR_END\
		+ type_text.substr(current_type_index + 1)
		
func get_global_x_position() -> int:
	return int(global_position.x)
