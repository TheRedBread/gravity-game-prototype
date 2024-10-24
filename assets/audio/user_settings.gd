class_name UserSettings extends Resource

@export_range(0, 1, .05) var master_audio_level : float = 1.0
@export_range(0, 1, .05) var music_audio_level : float = 1.0
@export_range(0, 1, .05) var sfx_audio_level : float = 1.0
@export_range(0, 1, .05) var ambience_audio_level : float = 1.0
@export var max_fps : int = 60
@export var action_events : Dictionary = {}

func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")

static func load_or_create() -> UserSettings:
	var res : UserSettings = load("user://user_prefs.tres") as UserSettings
	if !res:
		res = UserSettings.new()
	return res
