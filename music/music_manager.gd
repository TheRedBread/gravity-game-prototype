extends Node

@onready var MSP: AudioStreamPlayer = $MusicStreamPlayer
@onready var fade_music: AnimationPlayer = $FadeMusic

const BITE = preload("res://music/bite.mp3")
const DISCOVERY = preload("res://music/discovery.mp3")
const DRIFT = preload("res://music/drift.mp3")
const HAZEY = preload("res://music/hazey.mp3")
const HEIGHTS = preload("res://music/heights.mp3")

const music_lib = {
	0 : DRIFT,
	1 : DISCOVERY,

}


func _ready() -> void:
	print("MusicManager loaded")
	MSP.volume_db = 0



func play_music(music : AudioStream):
	MSP.stream = music
	MSP.play()

func fade_change_music(music : AudioStream, speed : float):
	fade_music.speed_scale = speed
	fade_music.play("fade_out")
	await fade_music.animation_finished
	play_music(music)
	fade_music.play("fade_in")
	
