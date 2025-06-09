extends Label

@export var power_supply : Power

func _physics_process(_delta: float) -> void:
	if power_supply.on:
		text = "Generators on"
	else:
		text = "Generators off"
		
