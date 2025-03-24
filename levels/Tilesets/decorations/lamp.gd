extends Sprite2D

@onready var lamp_light: PointLight2D = $LampLight
@onready var lights: Sprite2D = $Lights
@onready var sparking_particles: CPUParticles2D = $sparkingParticles


enum LightningType{
	Normal,
	Blinking,
	Off,
}

@export var light_type : LightningType
@export var lamp_sprite_variation : int = 0
@export var sparking : bool = false

var brightness : float = 1
var brightness_target : float = 1

func _ready() -> void:
	handle_sprite_variations()


func _physics_process(delta: float) -> void:
	if light_type == LightningType.Blinking:
		handle_blinkging()
	elif light_type == LightningType.Off:
		brightness = 0
	
	sparking_particles.emitting = sparking
	
	lights.material.set_shader_parameter("OPACITY", brightness)
	
	lamp_light.energy = brightness/1.4
	if brightness == 0:
		lights.material.set_shader_parameter("OPACITY", 0)
		lamp_light.energy = 0


func handle_blinkging():
	brightness_target += randf_range(-0.2, 0.2)
	if brightness_target < 0.4:
		brightness_target = 0.4
	if brightness > 0.8:
		brightness_target = 0.8
	
	
	brightness = lerpf(brightness, brightness_target, 1)

func handle_sprite_variations():
	lights.frame = lamp_sprite_variation
	frame = lamp_sprite_variation
