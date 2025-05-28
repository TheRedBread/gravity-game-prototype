extends Area2D
@onready var access_delay_timer: Timer = $AccessDelayTimer

@export var door_level : String
@export_range(0, 8, 1) var door_id = 0
@export var door_target_id : int = 0




func _on_body_entered(body: Node2D) -> void:
	if access_delay_timer.time_left != 0:
		return
	
	if door_level:
		print("doors entered to: ", door_level)
		SceneTransition.change_scene(door_level, "Blue1", door_target_id)
	else:
		print("couldn't load scene: ", door_level)
	
	get_tree().get_nodes_in_group("player")[0].player_controls = false
