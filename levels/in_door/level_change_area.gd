extends Area2D

@export var door_level : String
@export_range(0, 8, 1) var door_id = 0





func _on_body_entered(body: Node2D) -> void:
	if door_level:
		print("doors entered to: ", door_level)
		SceneTransition.change_scene(door_level, "Blue1", 0)
	else:
		print("couldn't load scene: ", door_level)
