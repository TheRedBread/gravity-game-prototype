extends VBoxContainer
############ AUDIO #################
@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var master_volume_percent: Label = %MasterVolumePercent
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var music_volume_percent: Label = %MusicVolumePercent
@onready var sfx_volume_slider: HSlider = %SfxVolumeSlider
@onready var sfx_volume_percent: Label = %SfxVolumePercent
@onready var ambience_volume_slider: HSlider = %AmbienceVolumeSlider
@onready var ambience_volume_percent: Label = %AmbienceVolumePercent


func set_volume_percent(percentLabel, Vslider):
	percentLabel.text = str(Vslider.value * 100) + "%"

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







# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





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
