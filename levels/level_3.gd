extends Node2D

func _ready() -> void:
	MusicManager.fade_change_music(MusicManager.DRIFT)
