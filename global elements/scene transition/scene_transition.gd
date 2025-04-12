extends CanvasLayer
@onready var transition_player: AnimationPlayer = $transitionPlayer
@export var Blue1 : Color = Color("#4694a8")
@export var Green1 : Color = Color("#379648")

const SCENE_TRANSITION_IN = preload("res://global elements/scene transition/scene_transition_in.mp3")
const SCENE_TRANSITION_OUT = preload("res://global elements/scene transition/scene_transition_out.mp3")

func change_scene(target : String, colorStr : String, door : int) -> void:
	var color : Color
	match colorStr:
		"Blue1":
			color = Blue1
		"Green1":
			color = Green1
	
	$transitionShader.color = color
	
	transition_player.speed_scale = 1
	
	transition_player.play("fadeOut")
	AudioManager.play_sound(SCENE_TRANSITION_IN, 0, 0, 1, 0, "Sound effects")
	await transition_player.animation_finished
	get_tree().change_scene_to_file(target)
	await get_tree().create_timer(0.1).timeout
	
	if door >= 0:
		for d in get_tree().get_nodes_in_group("doors"):
			if d.door_id == door:
				print("teleported to doors with id: ", door)
				get_tree().get_nodes_in_group("player")[0].position = d.position
	
	AudioManager.play_sound(SCENE_TRANSITION_OUT, 0, 0, 1, 0, "Sound effects")
	transition_player.play("fadeIn")
