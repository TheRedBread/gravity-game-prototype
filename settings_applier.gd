extends Node

var user_prefs = UserSettings.load_or_create()

func apply_max_fps(value):
	value = str(value)
	if value != "no limit":
		Engine.max_fps = int(value)
	else:
		Engine.max_fps = 0
	user_prefs.max_fps = Engine.max_fps
	user_prefs.save()

func set_volume(bus, value):
	
	var volume_bus = 0
	
	####################
	match bus:
		0:
			user_prefs.master_audio_level = value
		1:
			user_prefs.sfx_audio_level = value
		2:
			user_prefs.music_audio_level = value
		3:
			user_prefs.ambience_audio_level = value
	##########################
	
	
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	AudioServer.set_bus_mute(bus, value < 0.01)
	user_prefs.save()

func apply_audio_settings():
	set_volume(0, user_prefs.master_audio_level)
	set_volume(1, user_prefs.sfx_audio_level)
	set_volume(2, user_prefs.music_audio_level)
	set_volume(3, user_prefs.ambience_audio_level)

func apply_video_settings():
	apply_max_fps(user_prefs.max_fps)

func apply_settings():
	apply_audio_settings()
	apply_video_settings()



func _ready() -> void:
	user_prefs
	apply_settings()
	
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
