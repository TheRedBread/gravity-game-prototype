extends Node


func play_sound(stream : AudioStream, volume_offset : float, volume_range : float, pitch : float, pitch_range : float, bus : StringName):
	var instance = AudioStreamPlayer.new()
	instance.stream = stream
	instance.bus = bus
	instance.volume_db = volume_offset + randf_range(-volume_range, volume_range)
	
	
	instance.pitch_scale = pitch + randf_range(-pitch_range, pitch_range)
	
	
	instance.finished.connect(remove_node.bind(instance))
	add_child(instance)
	instance.play()


func remove_node(instance : AudioStreamPlayer):
	instance.queue_free()
