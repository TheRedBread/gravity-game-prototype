extends Control
var previous_position : Vector2 = Vector2(0, 0)
var input_focus_mode = "mouse"


func _ready() -> void:
	pass
	

func focus_update():
	if (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up")):
		if input_focus_mode == "mouse":
			print("aaa")
			%ContinueButton.grab_focus()
		input_focus_mode = "keys"

	elif get_global_mouse_position() - previous_position	 != Vector2(0,0):
		
		if input_focus_mode == "keys":
			%ContinueButton.release_focus()
			%NewGameButton.release_focus()
			%OptionsButton.release_focus()
			%QuitButton.release_focus()
		
		input_focus_mode = "mouse"
	
	previous_position = get_global_mouse_position()
	




func _process(delta: float) -> void:
	focus_update()








func _on_quit_button_pressed() -> void:
	GameSaveSystem.save_game()
	get_tree().quit()


func _on_options_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/UI/settings UI/Settings.tscn", "Blue1")


func _on_continue_button_pressed() -> void:
	SceneTransition.change_scene("res://scenes/levels/test_scene.tscn", "Green1")
