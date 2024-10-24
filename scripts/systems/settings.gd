extends Control
@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var master_volume_percent: Label = %MasterVolumePercent
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var music_volume_percent: Label = %MusicVolumePercent
@onready var sfx_volume_slider: HSlider = %SfxVolumeSlider
@onready var sfx_volume_percent: Label = %SfxVolumePercent
@onready var ambience_volume_slider: HSlider = %AmbienceVolumeSlider
@onready var ambience_volume_percent: Label = %AmbienceVolumePercent
@onready var fps_option_button: OptionButton = %fpsOptionButton

func _ready() -> void:
	display_settings()

func get_option_by_string(item_to_select : String, oButton : OptionButton):
	if item_to_select == "0":
		return 5
	
	for i in oButton.get_item_count():
		var cur_text = oButton.get_item_text(i)
		
		if cur_text == item_to_select:
			return i
	
	
	return -1
	

###################### DISPLAY ######################################
func display_video_settings():
	fps_option_button.select(get_option_by_string(str(SettingsApplier.user_prefs.max_fps), fps_option_button))

func display_audio_settings():
	if master_volume_slider:
		master_volume_slider.value = SettingsApplier.user_prefs.master_audio_level
		if master_volume_percent:
			set_volume_percent(master_volume_percent, master_volume_slider)
	
	if music_volume_slider:
		music_volume_slider.value = SettingsApplier.user_prefs.music_audio_level
		if music_volume_percent:
			set_volume_percent(music_volume_percent, music_volume_slider)
	
	if sfx_volume_slider:
		sfx_volume_slider.value = SettingsApplier.user_prefs.sfx_audio_level
		if sfx_volume_percent:
			set_volume_percent(sfx_volume_percent, sfx_volume_slider)
	if ambience_volume_slider:
		ambience_volume_slider.value = SettingsApplier.user_prefs.ambience_audio_level
		if ambience_volume_percent:
			set_volume_percent(ambience_volume_percent, ambience_volume_slider)
func display_settings():
	display_audio_settings()
	display_video_settings()
func set_volume_percent(percentLabel, Vslider):
	percentLabel.text = str(Vslider.value * 100) + "%"



### Quit to menu
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")

################ Volume changes ############################
func _on_master_volume_slider_value_changed(value: float) -> void:
	SettingsApplier.set_volume(0, master_volume_slider.value)
	set_volume_percent(master_volume_percent, master_volume_slider)
func _on_sfx_volume_slider_value_changed(value: float) -> void:
	SettingsApplier.set_volume(1, sfx_volume_slider.value)
	set_volume_percent(sfx_volume_percent, sfx_volume_slider)
func _on_music_volume_slider_value_changed(value: float) -> void:
	SettingsApplier.set_volume(2, music_volume_slider.value)
	set_volume_percent(music_volume_percent, music_volume_slider)
func _on_ambience_volume_slider_value_changed(value: float) -> void:
	SettingsApplier.set_volume(3, ambience_volume_slider.value)
	set_volume_percent(ambience_volume_percent, ambience_volume_slider)

################### Video Settings #############
func _on_fps_option_button_item_selected(index: int) -> void:
	SettingsApplier.apply_max_fps(fps_option_button.get_item_text(index))
	

func _on_vsync_check_box_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
