extends VBoxContainer
## Controls section in options menu

############ VIDEO ##################
@onready var fps_option_button: OptionButton = %fpsOptionButton
@onready var vsync_check_box: CheckBox = %vsyncCheckBox
@onready var resolution_option_button: OptionButton = %ResolutionOptionButton
@onready var settings: Control = $"../../../../../../../.."
@onready var screen_mode_option_button: OptionButton = %ScreenModeOptionButton


func _ready() -> void:
	display_video_settings()
	update_resolution_button()
	
	# makes popup button's windows transparent
	fps_option_button.get_popup().transparent = true
	resolution_option_button.get_popup().transparent = true
	screen_mode_option_button.get_popup().transparent = true
	
	fps_option_button.get_popup().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	resolution_option_button.get_popup().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	screen_mode_option_button.get_popup().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	


func update_resolution_button():
	# Disable the resolution option button for fullscreen or maximized modes
	if DisplayServer.window_get_mode(DisplayServer.window_get_current_screen()) == 4 || DisplayServer.window_get_mode(DisplayServer.window_get_current_screen()) == 2:
		resolution_option_button.disabled = true
		resolution_option_button.select(settings.get_option_by_string(get_current_screen_resolution_string(), resolution_option_button))
	
	else:
		resolution_option_button.disabled = false


func get_current_screen_resolution_string() -> String:
	var veciStr = str(DisplayServer.screen_get_size(DisplayServer.window_get_current_screen()))
	return veciStr.left(-1).right(-1).replace(", ", "x")


###################### DISPLAY ######################################
func display_video_settings():
	# Display saved video settings
	vsync_check_box.button_pressed = SettingsApplier.user_prefs.vsync_on
	fps_option_button.select(settings.get_option_by_string(str(SettingsApplier.user_prefs.max_fps), fps_option_button))
	resolution_option_button.select(settings.get_option_by_string(SettingsApplier.user_prefs.resolution, resolution_option_button))
	screen_mode_option_button.select(settings.get_option_by_string(SettingsApplier.user_prefs.screen_mode, screen_mode_option_button))
	
	

################### Video Settings #############
func _on_fps_option_button_item_selected(index: int) -> void:
	SettingsApplier.apply_max_fps(fps_option_button.get_item_text(index))
	AudioManager.button_click_sound()

func _on_vsync_check_box_toggled(toggled_on: bool) -> void:
	SettingsApplier.apply_vsync(toggled_on)
	AudioManager.button_click_sound()

func _on_resolution_option_button_item_selected(index: int) -> void:
	SettingsApplier.set_resolution(resolution_option_button.get_item_text(index))
	AudioManager.button_click_sound()

func _on_screen_mode_option_button_item_selected(index: int) -> void:
	SettingsApplier.set_screen_mode(screen_mode_option_button.get_item_text(index))
	update_resolution_button()
	AudioManager.button_click_sound()
