class_name UserSettings extends Resource

@export_range(0, 1, .05) var master_audio_level : float = 1.0
@export_range(0, 1, .05) var music_audio_level : float = 1.0
@export_range(0, 1, .05) var sfx_audio_level : float = 1.0
@export_range(0, 1, .05) var ambience_audio_level : float = 1.0
@export var max_fps : int = 60
@export var vsync_on : bool = false
@export var resolution : String = "960x540"
@export var screen_mode : String = "Windowed"
@export var action_events : Dictionary = {}

static func get_current_screen_resolution_string() -> String:
	var veciStr = str(DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()))
	return veciStr.left(-1).right(-1).replace(", ", "x")









func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")

static func load_or_create() -> UserSettings:
	var res : UserSettings = load("user://user_prefs.tres") as UserSettings
	if !res:
		res = UserSettings.new()
		res.resolution = get_current_screen_resolution_string()
	
	return res
