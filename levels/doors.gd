extends AnimatableBody2D
@onready var animation: AnimationPlayer = $animation


var state = "opened"
var direction = -1

func _ready() -> void:
	if rotation < 90 and rotation > -90:
		direction = -1
	else:
		direction = 1


func _physics_process(delta: float) -> void:
	if GameManager.gravity_direction * direction == 1 and not state == "opened":
		state = "opening"
	
	if GameManager.gravity_direction * direction == -1 and not state == "closed":
		state = "closing"
	
	if state == "opening" and not animation.is_playing():
		animation.play("open")
		state = "opened"
	
	if state == "closing" and not animation.is_playing():
		animation.play("close")
		state = "closed"
		
	
