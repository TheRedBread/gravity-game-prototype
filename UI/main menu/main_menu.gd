extends Control

var previous_position : Vector2 = Vector2(0, 0)
var input_focus_mode = "mouse"

func _ready() -> void:
	GameSaveSystem.load_game()
	%ContinueButton.disabled = !FileAccess.file_exists(GameSaveSystem.SAVE_PATH)
	
	MusicManager.play_music(MusicManager.DISCOVERY)
	

func _process(delta: float) -> void:
	if FileAccess.file_exists(GameSaveSystem.SAVE_PATH):
		%TimeDateSaveButton.text = "Last save: " + GameSaveSystem.date


## Checks how you select buttons: mouse/arrows. 
## if you move mouse it switches to mouse, else switches to keyboard/controller mode 
func focus_update():
	if (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")
			or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up")):
		
		if input_focus_mode == "mouse":
			print("Focus Grabbed")
			%ContinueButton.grab_focus()
		
		input_focus_mode = "keys"
		
	elif get_global_mouse_position() - previous_position != Vector2(0,0):
		
		if input_focus_mode == "keys":
			%ContinueButton.release_focus()
			%NewGameButton.release_focus()
			%OptionsButton.release_focus()
			%QuitButton.release_focus()
		
		input_focus_mode = "mouse"
	
	previous_position = get_global_mouse_position()


func _input(_event: InputEvent) -> void:
	focus_update()

func _on_quit_button_pressed() -> void:
	AudioManager.button_click_sound()
	GameManager.close_game()

func _on_options_button_pressed() -> void:
	SceneTransition.change_scene("res://UI/settings/Settings.tscn", "Blue1", -1)
	AudioManager.button_click_sound()

func delete_save():
	if not FileAccess.file_exists(GameSaveSystem.SAVE_PATH):
		return
	
	DirAccess.remove_absolute(GameSaveSystem.SAVE_PATH)
	print("save file deleted at: ", GameSaveSystem.SAVE_PATH)


func _on_continue_button_pressed() -> void:
	AudioManager.button_click_sound()
	GameManager.load_last_save()

func _on_new_game_button_pressed() -> void:
	delete_save()
	SceneTransition.change_scene("res://levels/level_1.tscn", "Blue1", -1)
	GameSaveSystem.save_game()
