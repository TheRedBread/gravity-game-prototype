extends Camera2D
@export var camera_desired_position_lerp : float = 2
@export var lerp_amount : float = 0.3


# sets camera position depending on player velocity
func get_camera_desired_position3():
	var desired_position : Vector2 = Vector2($"..".velocity.x/10, 0)
	return desired_position

## moves came to left or right depending on input
func get_camera_desired_position1():
	var desired_position : Vector2 = Vector2(0, 0)
	if Input.is_action_pressed("move_left"):
		desired_position = Vector2(-100, 0)
	if Input.is_action_pressed("move_right"):
		desired_position = Vector2(100, 0)
	return desired_position


func get_camera_desired_position2():
	var desired_position : Vector2 = $"..".velocity * lerp_amount
	return desired_position


func _process(delta: float) -> void:
	position = position.lerp((get_camera_desired_position1()+get_camera_desired_position3())/2, delta * camera_desired_position_lerp)
