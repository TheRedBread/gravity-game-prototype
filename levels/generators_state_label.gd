extends Label

@export var power_supply : Power
var display_text : String = "Generators off"

func _physics_process(_delta: float) -> void:
	if power_supply.on:
		display_text = "Generators on"
	else:
		display_text = "Generators off"
	
	
	text = display_text
