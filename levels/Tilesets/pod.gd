extends Node2D

@onready var pod_animated_sprite: AnimatedSprite2D = $podAnimatedSprite
@export_range(-1, 1, 2) var direction : int

func _ready() -> void:
	if direction == -1:
		pod_animated_sprite.flip_h = true
	else:
		pod_animated_sprite.flip_h = false
		
