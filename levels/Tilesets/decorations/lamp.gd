extends Sprite2D

@onready var lamp_light: PointLight2D = $LampLight
@onready var lights: Sprite2D = $Lights

enum LampType{
	Normal,
	Blinking,
	Overgrown,
	Sparking
}

@export var lamp_type : LampType
var brightness : float = 1
var brightness_target : float = 1

func _physics_process(delta: float) -> void:
	match lamp_type:
		LampType.Normal:
			pass
		LampType.Blinking:
			handle_blinkging()
	lights.material.set_shader_parameter("OPACITY", brightness)
	lamp_light.energy = brightness/1.4
	


func handle_blinkging():
	brightness_target += randf_range(-0.2, 0.2)
	if brightness_target < 0.4:
		brightness_target = 0.4
	if brightness > 0.8:
		brightness_target = 0.8
	
	
	brightness = lerpf(brightness, brightness_target, 1)
