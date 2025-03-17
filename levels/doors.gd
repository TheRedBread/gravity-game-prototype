extends AnimatableBody2D
@onready var animation: AnimationPlayer = $animation
@export var door_speed : float = 0.1

var state = "opened"
var direction = -1
var velocity = 0
var door_position


func _ready() -> void:
	if rotation < 90 and rotation > -90:
		direction = -1
	else:
		direction = 1
	
	door_position = position

func _physics_process(delta: float) -> void:
	position.y += velocity
	
	var local_door_position = door_position - position
	
	
	if GameManager.gravity_direction * direction == 1 and not state == "opened":
		state = "opening"
		velocity -= door_speed
		
	
	if GameManager.gravity_direction * direction == -1 and not state == "closed":
		state = "closing"
		velocity += door_speed
	
	
	
	if local_door_position.y < 0:
		state = "closed"
		velocity = 0
		position.y = door_position.y - 0
	
	
	if local_door_position.y > 58:
		state = "opened"
		velocity = 0
		position.y = door_position.y - 58
	
	

		
		
	

		
	
	
	
