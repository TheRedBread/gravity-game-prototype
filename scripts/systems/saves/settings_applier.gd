extends Node

var user_prefs = UserSettings.load_or_create()

func str_to_Vectori(VecString):
	var x = int(VecString.left(VecString.find("x")))
	var y = int(VecString.right(VecString.find("x")))
	return Vector2i(x,y)



	

func center_window() -> void:
	# Get the current window
	var window = get_window()
	# And get the current screen the window's in
	var screen = window.current_screen
	# Get the usable rect for that screen
	var screen_rect = DisplayServer.screen_get_usable_rect(screen)
	# Get the window's size
	var window_size = window.get_size_with_decorations()
	# Set its position to the middle
	window.position = screen_rect.position + (screen_rect.size / 2 - window_size / 2)
	




func set_screen_mode(modeString):
	match modeString:
		"Windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			
			
		"Fullscreen":
			var veciStr = str(DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())).left(-1).right(-1).replace(", ", "x")
			user_prefs.resolution = veciStr
			set_resolution(veciStr)
			
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			
		"Maximized":
			var veciStr = str(DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())).left(-1).right(-1).replace(", ", "x")
			user_prefs.resolution = veciStr
			set_resolution(veciStr)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			
			
	
	
	
	user_prefs.screen_mode = modeString
	user_prefs.save()
	center_window()

func set_resolution(resString : String):
	user_prefs.resolution = resString
	
	var cords = str_to_Vectori(resString)
	print(cords)
	get_window().size = cords
	center_window()
	user_prefs.save()
	get_viewport().size = cords
	print(user_prefs.resolution)

func apply_vsync(value : bool):
	if value == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		user_prefs.vsync_on = true
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		user_prefs.vsync_on = false
	user_prefs.save()

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
	apply_vsync(user_prefs.vsync_on)
	set_resolution(user_prefs.resolution)
	set_screen_mode(user_prefs.screen_mode)

func apply_settings():
	apply_audio_settings()
	apply_video_settings()



func _ready() -> void:
	apply_settings()
	print("wat")
	
	
