extends Node

@onready var MSP: AudioStreamPlayer = $MusicStreamPlayer
const BITE = preload("res://music/bite.mp3")
const DISCOVERY = preload("res://music/discovery.mp3")
const DRIFT = preload("res://music/drift.mp3")

const music_lib = {
	0 : DRIFT,
	1 : DISCOVERY,

}


func _ready() -> void:
	print("MusicManager loaded")
	MSP.stream = DISCOVERY
	MSP.play()
