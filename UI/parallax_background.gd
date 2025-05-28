extends ParallaxBackground


func scroll_parallax(delta):
	scroll_base_offset = get_viewport().get_mouse_position()
	
	
	scroll_offset += Vector2(2, -1) * delta * 60
	


func _process(delta: float) -> void:
	scroll_parallax(delta)
