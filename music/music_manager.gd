extends Node

@onready var MSP: AudioStreamPlayer = $MusicStreamPlayer

const music_lib = {
	0 : preload("res://music/drift.mp3"),
	1 : preload("res://music/discovery.mp3"),

}


func _ready() -> void:
	print("MusicManager loaded")
	MSP.stream = music_lib[randi_range(0, len(music_lib)-1)]
	MSP.play()
