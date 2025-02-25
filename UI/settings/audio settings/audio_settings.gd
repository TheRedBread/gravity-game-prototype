## Audio section in options menu
extends VBoxContainer

@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var master_volume_percent: Label = %MasterVolumePercent
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var music_volume_percent: Label = %MusicVolumePercent
@onready var sfx_volume_slider: HSlider = %SfxVolumeSlider
@onready var sfx_volume_percent: Label = %SfxVolumePercent
@onready var ambience_volume_slider: HSlider = %AmbienceVolumeSlider
@onready var ambience_volume_percent: Label = %AmbienceVolumePercent

const SLIDER_CLICK = preload("res://UI/settings/slider_click.mp3")


func set_volume_display_percent(percentLabel, Vslider):
	percentLabel.text = str(Vslider.value * 100) + "%"

func display_audio_settings():
	# master display
	if master_volume_slider:
		master_volume_slider.value = SettingsApplier.user_prefs.master_audio_level
	if master_volume_percent:
		set_volume_display_percent(master_volume_percent, master_volume_slider)
	
	# music display
	if music_volume_slider:
		music_volume_slider.value = SettingsApplier.user_prefs.music_audio_level
	if music_volume_percent:
		set_volume_display_percent(music_volume_percent, music_volume_slider)
	
	# Sound effects display
	if sfx_volume_slider:
		sfx_volume_slider.value = SettingsApplier.user_prefs.sfx_audio_level
	if sfx_volume_percent:
		set_volume_display_percent(sfx_volume_percent, sfx_volume_slider)
	
	# ambience display
	if ambience_volume_slider:
		ambience_volume_slider.value = SettingsApplier.user_prefs.ambience_audio_level
	if ambience_volume_percent:
		set_volume_display_percent(ambience_volume_percent, ambience_volume_slider)


func _ready() -> void:
	display_audio_settings()


func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioManager.play_sound(SLIDER_CLICK, 0, 0.02, 2.5, 0.01, "Sound effects")
	SettingsApplier.set_volume(0, master_volume_slider.value)
	set_volume_display_percent(master_volume_percent, master_volume_slider)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	AudioManager.play_sound(SLIDER_CLICK, 0, 0.02, 2.5, 0.01, "Sound effects")
	SettingsApplier.set_volume(1, sfx_volume_slider.value)
	set_volume_display_percent(sfx_volume_percent, sfx_volume_slider)


func _on_music_volume_slider_value_changed(value: float) -> void:
	AudioManager.play_sound(SLIDER_CLICK, 0, 0.02, 2.5, 0.01, "Sound effects")
	SettingsApplier.set_volume(2, music_volume_slider.value)
	set_volume_display_percent(music_volume_percent, music_volume_slider)


func _on_ambience_volume_slider_value_changed(value: float) -> void:
	AudioManager.play_sound(SLIDER_CLICK, 0, 0.02, 2.5, 0.01, "Sound effects")
	SettingsApplier.set_volume(3, ambience_volume_slider.value)
	set_volume_display_percent(ambience_volume_percent, ambience_volume_slider)
