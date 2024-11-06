extends Control
@onready var pause_menu: Control = $"."

var is_paused = false

func _ready() -> void:
	pause_menu.hide()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_paused:
		pause_menu.show()
		
	else:
		pause_menu.hide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("Pause"):
			switch_pause()


func switch_pause():
	
	is_paused = !is_paused
	get_tree().paused = is_paused



func _on_resume_button_pressed() -> void:
	switch_pause()


func _on_quit_button_pressed() -> void:
	switch_pause()
	get_tree().change_scene_to_file("res://scenes/UI/main_menu.tscn")
