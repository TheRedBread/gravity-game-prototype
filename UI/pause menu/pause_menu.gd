extends Control


@onready var pause_menu: Control = $"."
@onready var blur_shader: ColorRect = $CanvasLayer/blurShader

const SCENE_TRANSITION_IN = preload("res://global elements/scene transition/scene_transition_in.mp3")
const SCENE_TRANSITION_OUT = preload("res://global elements/scene transition/scene_transition_out.mp3")

var is_paused = false


func _ready() -> void:
	pause_menu.hide()
	blur_shader.hide()


func _process(_delta: float) -> void:
	if is_paused:
		pause_menu.show()
		blur_shader.show()
	else:
		pause_menu.hide()
		blur_shader.hide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("Pause"):
			switch_pause()


func switch_pause():
	if is_paused:
		AudioManager.play_sound(SCENE_TRANSITION_OUT, 0, 0, 4, 0, "sound Effects")
		AudioManager.play_sound(SCENE_TRANSITION_OUT, 0, 0, 3, 0, "sound Effects")
	else:
		AudioManager.play_sound(SCENE_TRANSITION_IN, 0, 0, 4, 0, "sound Effects")
		AudioManager.play_sound(SCENE_TRANSITION_IN, 0, 0, 3, 0, "sound Effects")
	
	is_paused = !is_paused
	get_tree().paused = is_paused


func _on_resume_button_pressed() -> void:
	switch_pause()
	AudioManager.button_click_sound()


func _on_quit_button_pressed() -> void:
	switch_pause()
	SceneTransition.change_scene("res://UI/main menu/main_menu.tscn", "Green1",-1)
	AudioManager.button_click_sound()


func _on_quitto_desktop_pressed() -> void:
	GameSaveSystem.save_game()
	GameManager.close_game()
