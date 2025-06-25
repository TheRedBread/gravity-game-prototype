## Used to apply settings from file or directly from settings menu
extends Node

const DEFAULT_RESOLUTION : String = "1280x720"

var user_prefs : UserSettings = UserSettings.load_or_create()


func _ready() -> void:
	apply_settings()

func str_to_Vectori(res_string: String) -> Vector2i:
	# Split the resolution string, defaulting to DEFAULT_RESOLUTION if invalid
	var res_components = res_string.split("x")
	var width = res_components[0]
	var height = res_components[1]
	if res_components.size() != 2 or int(width) <= 0 or int(height) <= 0:
		print("Invalid resolution, using default: ", DEFAULT_RESOLUTION)
		return Vector2i(1920, 1080)
		

	# Return parsed resolution
	return Vector2i(int(width), int(height))


func center_window() -> void:
	var window = get_window()
	var screen = window.current_screen
	var screen_rect = DisplayServer.screen_get_usable_rect(screen)
	var window_size = window.get_size_with_decorations()
	
	# Set its position to the middle
	window.position = screen_rect.position + (screen_rect.size / 2 - window_size / 2)
	print("window centered")

func set_screen_mode(modeString):
	print("setting screen mode on: ", modeString)
	match modeString:
		"Windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		"Fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		
		"Maximized":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		
		_:
			print_rich("[b][color=red]Screen mode is incorrect: " + modeString + "[/color][/b]")
	
	# saves screen mode to file
	user_prefs.screen_mode = modeString
	user_prefs.save()
	center_window()


func set_resolution(resString : String):
	user_prefs.resolution = resString
	var cords = str_to_Vectori(resString)
	get_window().size = cords
	center_window()
	user_prefs.save()
	get_viewport().size = cords
	
	print("resolution set to: ", resString)


func apply_vsync(value : bool):
	if value == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		user_prefs.vsync_on = true
	
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		user_prefs.vsync_on = false
	user_prefs.save()
	print("V-Sync on: ", value)


func apply_max_fps(value):
	value = str(value)
	if value != "no limit":
		Engine.max_fps = int(value)
	else:
		Engine.max_fps = 0
	user_prefs.max_fps = Engine.max_fps
	user_prefs.save()


func set_volume(bus, value):

	
	match bus:
		0:
			user_prefs.master_audio_level = value
		1:
			user_prefs.sfx_audio_level = value
		2:
			user_prefs.music_audio_level = value
		3:
			user_prefs.ambience_audio_level = value
	
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
	apply_vsync(user_prefs.vsync_on)
	set_resolution(user_prefs.resolution)
	set_screen_mode(user_prefs.screen_mode)
	

# apply all settings
func apply_settings():
	apply_audio_settings()
	apply_video_settings()
