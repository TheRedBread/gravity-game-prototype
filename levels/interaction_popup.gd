extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_interaction_area_body_exited(body: Node2D) -> void:
	animation_player.play("disappear")
	await animation_player.animation_finished
	queue_free()
