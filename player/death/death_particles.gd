extends Node2D


func _on_head_particles_finished() -> void:
	queue_free()
