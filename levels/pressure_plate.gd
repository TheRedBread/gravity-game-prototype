extends Sprite2D
@onready var pressure_plate: Sprite2D = $"."
@onready var pressure_plate_glow: Sprite2D = $PressurePlateGlow

var player_on : bool = false
var box_on : bool = false

var pressed : bool = false

func _physics_process(delta: float) -> void:
	
	if player_on or box_on:
		pressed = true
	else:
		pressed = false
	
	
	if pressed:
		frame = 1
		pressure_plate_glow.frame = 1
	else:
		frame = 0
		pressure_plate_glow.frame = 0
		



func _on_pressure_area_player_detector_body_entered(body: Node2D) -> void:
	player_on = true


func _on_pressure_area_player_detector_body_exited(body: Node2D) -> void:
	player_on = false


func _on_pressure_area_box_detector_body_entered(body: Node2D) -> void:
	box_on = true


func _on_pressure_area_box_detector_body_exited(body: Node2D) -> void:
	box_on = false
