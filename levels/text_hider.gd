extends Node2D

@export var hide_rate : float = 2.6
var opacity : float
var is_player_in_area


func _physics_process(delta: float) -> void:
	
	if !is_player_in_area:
		opacity = 0
		modulate.a = opacity
		return
	
	var player_position = get_tree().get_nodes_in_group("player")[0].position
	var distance = clamp(10000/pow(position.distance_to(player_position), hide_rate), 0, 1)
	opacity = distance
	
	modulate.a = opacity

func _on_area_limiter_body_entered(body: Node2D) -> void:
	is_player_in_area = true


func _on_area_limiter_body_exited(body: Node2D) -> void:
	is_player_in_area = false
