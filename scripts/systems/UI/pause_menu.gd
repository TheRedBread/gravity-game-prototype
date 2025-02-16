extends Control


@onready var pause_menu: Control = $"."
@onready var blur_shader: ColorRect = $CanvasLayer/blurShader

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
	is_paused = !is_paused
	get_tree().paused = is_paused


func _on_resume_button_pressed() -> void:
	switch_pause()
	AudioManager.button_click_sound()


func _on_quit_button_pressed() -> void:
	switch_pause()
	SceneTransition.change_scene("res://scenes/UI/main_menu.tscn", "Green1")
	AudioManager.button_click_sound()


func _on_quitto_desktop_pressed() -> void:
	GameSaveSystem.save_game()
	GameManager.close_game()
