extends Area2D

@export var audio_dir_string : String
@export var change_speed : float = 1


func _on_body_entered(body: Node2D) -> void:
	var audio_stream : AudioStream = load(audio_dir_string)
	
	if MusicManager.MSP.stream != audio_stream:
		MusicManager.fade_change_music(audio_stream, change_speed)
