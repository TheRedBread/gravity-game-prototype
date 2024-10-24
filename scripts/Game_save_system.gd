extends Node
const SAVE_PATH: String = "res://save.bin"
var playtime : float = 0
var spawn_checked : int = 0


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()


#####################SAVEGAME#################
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"playtime": str(round(playtime)) + "s",
		"spawn_checked": spawn_checked
		
	}
	
	var jstr = JSON.stringify(data)
	
	file.store_line(jstr)

func load_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file or file == null:
		return
	if FileAccess.file_exists(SAVE_PATH) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				pass

func _physics_process(delta: float) -> void:
	GameSaveSystem.playtime += 1*delta
