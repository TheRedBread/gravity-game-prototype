extends CanvasLayer
@onready var transition_player: AnimationPlayer = $transitionPlayer
@export var Blue1 : Color = Color("#4694a8")
@export var Green1 : Color = Color("#379648")

func change_scene(target : String, colorStr : String) -> void:
	var color : Color
	match colorStr:
		"Blue1":
			color = Blue1
		"Green1":
			color = Green1
	
	$transitionShader.color = color
	
	transition_player.speed_scale = 1
	
	transition_player.play("fadeOut")
	await transition_player.animation_finished
	get_tree().change_scene_to_file(target)
	transition_player.play("fadeIn")
	
