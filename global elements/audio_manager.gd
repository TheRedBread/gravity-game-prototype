## Manages Global sound effects
extends Node

# -------------- MUSIC ------------------ #
const DISCOVERY = preload("res://music/discovery.mp3")
const BITE = preload("res://music/bite.mp3")
const DRIFT = preload("res://music/drift.mp3")

# -------------- SOUNDS ------------------ #
@export var click1_sound : AudioStream = preload("res://UI/sfx/click.mp3")
@export var click2_sound : AudioStream = preload("res://UI/sfx/click2.mp3")


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		play_sound(click1_sound, -15, 1, 1, 0.05, "Sound effects")


func play_sound(stream : AudioStream, base_volume : float, volume_variation : float, base_pitch : float, pitch_variation : float, bus : StringName):
	var instance = AudioStreamPlayer.new()
	
	instance.stream = stream
	instance.bus = bus
	instance.volume_db = base_volume + randf_range(-volume_variation, volume_variation)
	instance.pitch_scale = base_pitch + randf_range(-pitch_variation, pitch_variation)
	instance.finished.connect(_on_sound_finished.bind(instance))
	
	add_child(instance)
	instance.play()


func button_click_sound():
	play_sound(click2_sound, -10, 1, 1, 0.05, "Sound effects")


func _on_sound_finished(instance : AudioStreamPlayer):
	instance.queue_free()
