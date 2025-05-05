## used to save data to bin file (uncoded)
extends Node

const SAVE_PATH: String = "user://save.bin"

@export var current_level : String = "res://levels/level_1.tscn"
@export var current_door : int = -1
@export var date : String = "00.00.0000 00:00"




func _notification(notification: int) -> void:
	if notification == NOTIFICATION_WM_CLOSE_REQUEST:
		GameManager.close_game()


func get_current_level_scene():
	if get_tree().get_node_count_in_group("level") == 0:
		return "level_1"
	
	var level_name := get_tree().get_nodes_in_group("level")[0].name
	var level_number = level_name.right(level_name.length()-5).to_int()
	return "level_" + str(level_number)

func format_with_zero(number : int):
	var text = str(number)
	if len(text) > 1:
		return text
	
	return "0" + text


func get_cdate_string() -> String:
	var dt = Time.get_datetime_dict_from_system()
	
	var date = format_with_zero(dt.day) + "." + format_with_zero(dt.month) + "." + str(dt.year)
	var time = format_with_zero(dt.hour) + ":" + format_with_zero(dt.minute)
	
	var dt_string : String = date + " " + time
	return dt_string
	

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data : Dictionary = {
		"current_level" : "res://levels/" + get_current_level_scene() + ".tscn",
		"current_door" : current_door,
		"date" : get_cdate_string(),
	}
	
	
	
	file.store_line(JSON.stringify(data))
	print("Saving to: ", ProjectSettings.globalize_path(SAVE_PATH))

func load_game():
	
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file.eof_reached():
		return
	
	var data = JSON.parse_string(file.get_line())
	
	if typeof(data) == TYPE_DICTIONARY:
		current_level = data.get("current_level", current_level)
		current_door = data.get("current_door", -1)
		date = data.get("date", date)
	
	print("Loading save from: ", ProjectSettings.globalize_path(SAVE_PATH))
