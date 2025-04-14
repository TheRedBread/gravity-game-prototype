extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("grow")
	$InteractionButton.show()


func _on_interaction_area_body_exited(_body: Node2D) -> void:
	animation_player.play("disappear")
	await animation_player.animation_finished
	
	queue_free()
