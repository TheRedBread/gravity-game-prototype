extends ParallaxBackground


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_base_offset = get_viewport().get_mouse_position()
	scroll_offset += Vector2(2, -1) * delta *60

	
	
	
