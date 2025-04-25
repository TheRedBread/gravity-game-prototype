extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var power_supply : Power
@export var press_speed : float = 1.0
@export var animation_offset : float = 0.0

var was_on : bool 

func _ready() -> void:
	start()

func start():
	animation_player.speed_scale = press_speed
	await get_tree().create_timer(animation_offset).timeout
	animation_player.play("crash")

func _physics_process(delta: float) -> void:
	if !power_supply:
		return
	
	if power_supply and !power_supply.on and was_on:
		
		start()
	was_on = power_supply.on

func crash_finished():
	if power_supply and power_supply.on:
		animation_player.stop()
