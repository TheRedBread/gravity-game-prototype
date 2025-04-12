extends Sprite2D

@onready var console_light: PointLight2D = $ConsoleLight
@onready var console_animation_player: AnimationPlayer = $ConsoleAnimationPlayer
@export_range(0, 1, 1) var variation : int = 0

const green_light = preload("res://levels/Tilesets/decorations/console/green_console_light.tres")
const blue_light = preload("res://levels/Tilesets/decorations/console/blue_console_light.tres")


func _ready() -> void:
	match variation:
		0:
			console_animation_player.play("greenblink")
			console_light.texture.set("gradient", green_light)
		1:
			console_animation_player.play("blueblink")
			console_light.texture.set("gradient", blue_light)
			
