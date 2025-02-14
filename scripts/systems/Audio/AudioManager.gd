extends Node
@export var click1_sound : AudioStream = preload("res://assets/audio/tracks/sfx/player actions/click.mp3")
@export var click2_sound : AudioStream = preload("res://assets/audio/tracks/sfx/player actions/click2.mp3")

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS


func play_sound(stream : AudioStream, volume_offset : float, volume_range : float, pitch : float, pitch_range : float, bus : StringName):
	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.bus = bus
	instance.volume_db = volume_offset + randf_range(-volume_range, volume_range)
	
	
	instance.pitch_scale = pitch + randf_range(-pitch_range, pitch_range)
	
	
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	instance.play()


func button_click_sound():
	play_sound(click2_sound, -10, 1, 1, 0.05, "Sound effects")


func remove_node(instance : AudioStreamPlayer):
	instance.queue_free()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		play_sound(click1_sound, -15, 1, 1, 0.05, "Sound effects")
