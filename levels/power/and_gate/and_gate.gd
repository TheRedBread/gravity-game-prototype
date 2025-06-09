extends Power

@export var power_supply1 : Power
@export var power_supply2 : Power

func _physics_process(delta: float) -> void:
	on = (power_supply1.on and power_supply2.on)
