extends Node

const BASIC_POST_PROCESS = preload("res://global elements/basic_post_process.tscn")

@export var gravity_direction : int = 1



func load_last_save():
	GameSaveSystem.load_game()
	SceneTransition.change_scene(GameSaveSystem.current_level, "Blue1", GameSaveSystem.current_door)

func close_game():
	get_tree().quit()
