extends Sprite2D

@onready var lamp_light: PointLight2D = $LampLight
@onready var lights: Sprite2D = $Lights
@onready var sparking_particles: CPUParticles2D = $sparkingParticles

@export var power_supply : Power


enum LightningType{
	Normal,
	Blinking,
	Off,
}

@export var light_type : LightningType
@export_range(0, 4) var lamp_sprite_variation : int = 0
@export var sparking : bool = false
@export var brightness_scale : float = 1


var brightness : float = 1
var brightness_target : float = 1
var is_visible : bool = false

func _ready() -> void:
	handle_sprite_variations()


func _physics_process(_delta: float) -> void:
	if !is_visible:
		lamp_light.enabled = false
		return
	
	
	lamp_light.enabled = true
	
	if power_supply:
		lamp_light.enabled = power_supply.on
		
	
	
	if light_type == LightningType.Blinking:
		handle_blinkging()
	elif light_type == LightningType.Off:
		brightness = 0
	
	sparking_particles.emitting = sparking
	
	lights.material.set_shader_parameter("OPACITY", brightness * brightness_scale)
	
	lamp_light.energy = brightness/2*brightness_scale
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
	lights.frame = clamp(lamp_sprite_variation, 0, 3)
	frame = lights.frame


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_visible = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	is_visible = false
