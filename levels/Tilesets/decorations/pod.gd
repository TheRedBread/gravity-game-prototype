extends Node2D

@onready var bubbles_animated_sprite: AnimatedSprite2D = $bubblesAnimatedSprite
@onready var robot_sprite: Sprite2D = $robotSprite

@export_range(-1, 1, 2) var direction : int
@export_range(-1, 10, 1) var robot_variation : int = -1

func _ready() -> void:
	if direction == -1:
		bubbles_animated_sprite.flip_h = true
	else:
		bubbles_animated_sprite.flip_h = false
	
	if robot_variation == -1:
		robot_sprite.frame = randi_range(0, 9)
	else:
		robot_sprite.frame = robot_variation
		
