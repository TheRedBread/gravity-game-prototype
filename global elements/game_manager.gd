extends Node

const BASIC_POST_PROCESS = preload("res://global elements/basic_post_process.tscn")
@export var gravity_direction : int = 1



func _ready():
	pass
	add_child(BASIC_POST_PROCESS.instantiate())


func close_game():
	GameSaveSystem.save_game()
	get_tree().quit()
