## used to save data to bin file (uncoded)
extends Node

const SAVE_PATH: String = "user://save.bin"

var playtime : float = 0
var spawn_checked_count : int = 0

func _ready() -> void:
	load_game()


func _notification(notification: int) -> void:
	if notification == NOTIFICATION_WM_CLOSE_REQUEST:
		GameManager.close_game()


func save_game():
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data : Dictionary = {
		"playtime": round(playtime),
		"spawn_checked_count": spawn_checked_count
		
	}
	
	
	file.store_line(JSON.stringify(data))
	print("Saving stats to: ", ProjectSettings.globalize_path(SAVE_PATH))

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file.eof_reached():
		return
	
	var data = JSON.parse_string(file.get_line())
	
	if typeof(data) == TYPE_DICTIONARY:
		playtime = data.get("playtime", 0)  # Default to 0 if missing
		spawn_checked_count = data.get("spawn_checked_count", 0)
	
	print("Loading stats From: ", ProjectSettings.globalize_path(SAVE_PATH))


func _physics_process(delta: float) -> void:
	# updates play time every frame
	playtime += 1 * delta
