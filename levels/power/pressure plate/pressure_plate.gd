extends Power
@onready var pressure_plate_glow: Sprite2D = $PressurePlate/PressurePlateGlow
@onready var pressure_plate: Sprite2D = $PressurePlate

var player_on : bool = false
var box_on : bool = false


func _physics_process(_delta: float) -> void:
	
	if player_on or box_on:
		on = true
	else:
		on = false
	
	
	if on:
		pressure_plate.frame = 1
		pressure_plate_glow.frame = 1
	else:
		pressure_plate.frame = 0
		pressure_plate_glow.frame = 0
		



func _on_pressure_area_player_detector_body_entered(_body: Node2D) -> void:
	player_on = true


func _on_pressure_area_player_detector_body_exited(_body: Node2D) -> void:
	player_on = false


func _on_pressure_area_box_detector_body_entered(_body: Node2D) -> void:
	box_on = true


func _on_pressure_area_box_detector_body_exited(_body: Node2D) -> void:
	box_on = false
