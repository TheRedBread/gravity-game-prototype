extends Node2D

@onready var tack_audio_player: AudioStreamPlayer2D = $tackAudioPlayer
@onready var stomp_audio_player: AudioStreamPlayer2D = $StompAudioPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var compress_audio_player: AudioStreamPlayer2D = $CompressAudioPlayer

@export var power_supply : Power
@export var press_speed : float = 1.0
@export var animation_offset : float = 0.0

var was_on : bool 

func _ready() -> void:
	start()

func start():
	animation_player.speed_scale = press_speed
	await get_tree().create_timer(animation_offset).timeout
	animation_player.play("crash")

func _physics_process(delta: float) -> void:
	if !power_supply:
		return
	
	if power_supply and !power_supply.on and was_on:
		
		start()
	was_on = power_supply.on


func stomp():
	stomp_audio_player.volume_db = randf_range(-4, 4)
	stomp_audio_player.pitch_scale = randf_range(0.8, 1.2)
	stomp_audio_player.play()


func compress():
	compress_audio_player.volume_db = randf_range(-4, 4)
	compress_audio_player.pitch_scale = randf_range(0.8, 1.2)
	compress_audio_player.play()

func tack():
	tack_audio_player.volume_db = randf_range(-4, 4)
	tack_audio_player.pitch_scale = randf_range(0.8, 1.2)
	tack_audio_player.play()





func crash_finished():
	if power_supply and power_supply.on:
		animation_player.stop()
