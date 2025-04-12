extends AnimatableBody2D

@export var door_speed : float = 0.1
@export var reversed : bool = false
@export var door_type : DoorType = DoorType.Gravity

@export var power_supply : Power

enum DoorType {
	Gravity,
	Power,
	Off,
}


var opened : bool = false
var direction = -1
var velocity = 0
var door_position


func bool_xor(a : bool, b : bool):
	return (a or b) and not (a and b)



func _ready() -> void:
	if rotation < 90 and rotation > -90:
		direction = -1
	else:
		direction = 1
	
	door_position = position

func _physics_process(_delta: float) -> void:
	position.y = lerpf(position.y, velocity+position.y, 0.3)
	
	var local_door_position = door_position - position
	
	match door_type:
		DoorType.Gravity:
			gravity_steered(local_door_position)
		DoorType.Power:
			power_steered(local_door_position)
		DoorType.Off:
			pass
		
	

func power_steered(local_door_position):
	if (bool_xor(!power_supply.on, reversed)):
		velocity -= door_speed
		
	if (bool_xor(power_supply.on, reversed)):
		velocity += door_speed
	
	
	if local_door_position.y < 0:
		opened = false
		velocity = 0
		position.y = door_position.y - 0
	
	if local_door_position.y > 58:
		opened = true
		velocity = 0
		position.y = door_position.y - 58


func gravity_steered(local_door_position):
	
	var door_dir = GameManager.gravity_direction * direction * (-1 if reversed else 1)
	
	if door_dir == 1 and not opened:
		velocity -= door_speed
		
	if door_dir == -1 and not !opened:
		velocity += door_speed
	
	
	if local_door_position.y < 0:
		opened = false
		velocity = 0
		position.y = door_position.y - 0
	
	if local_door_position.y > 58:
		opened = true
		velocity = 0
		position.y = door_position.y - 58
