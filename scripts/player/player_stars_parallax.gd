extends ParallaxBackground
var scroll_direction : float = 0
var scroll_change_direction : float = 0

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	scroll_change_direction += randf_range(-0.001, 0.001)*delta
	if abs(scroll_change_direction) > 0.0001:
		scroll_change_direction = 0.00099 * sign(scroll_change_direction)
	
	
	scroll_direction += scroll_change_direction
	scroll_base_offset += Vector2(50, 0).rotated(scroll_direction)*delta
