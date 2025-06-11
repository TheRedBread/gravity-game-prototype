extends Area2D
@onready var access_delay_timer: Timer = $AccessDelayTimer

@export var door_level : String
@export_range(0, 8, 1) var door_id = 0
@export var door_target_id : int = 0
@export var gravity_direction_target : int = 0


func _on_body_entered(body: Node2D) -> void:
	if access_delay_timer.time_left != 0:
		return
	
	if door_level:
		print("doors entered to: ", door_level)
		SceneTransition.change_scene(door_level, "Blue1", door_target_id)
	else:
		print("couldn't load scene: ", door_level)
	
	var player : Player = get_tree().get_nodes_in_group("player")[0]
	player.player_controls = false
	
	if gravity_direction_target != 0:
		GameManager.gravity_direction = gravity_direction_target
		player.up_direction = Vector2(0, -GameManager.gravity_direction)
