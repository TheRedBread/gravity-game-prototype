extends Node

const BASIC_POST_PROCESS = preload("res://global elements/basic_post_process.tscn")

func _ready():
	
	add_child(BASIC_POST_PROCESS.instantiate())

func close_game():
	GameSaveSystem.save_game()
	get_tree().quit()
