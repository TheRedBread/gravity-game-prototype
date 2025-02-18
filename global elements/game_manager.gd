extends Node


func close_game():
	GameSaveSystem.save_game()
	get_tree().quit()
