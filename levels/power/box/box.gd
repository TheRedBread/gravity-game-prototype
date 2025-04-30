extends RigidBody2D

func _physics_process(_delta: float) -> void:
	if GameManager.gravity_direction != gravity_scale:
		position.y += 1 * GameManager.gravity_direction
		linear_velocity.y += 2 * GameManager.gravity_direction
	gravity_scale = GameManager.gravity_direction
