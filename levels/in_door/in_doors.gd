extends Node2D

@export var door_level : String
@export_range(0, 8, 1) var door_id = 0
var is_player_in_area : bool = false


func get_in():
	if door_level != null:
		print("doors entered to: ", door_level)
		is_player_in_area = false
		
		SceneTransition.change_scene(door_level, "Blue1", 0)
		
		
	else:
		print("couldn't load scene: ", door_level)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and is_player_in_area:
		get_in()


func _on_doors_area_body_entered(body: Node2D) -> void:
	is_player_in_area = true


func _on_doors_area_body_exited(body: Node2D) -> void:
	is_player_in_area = false
