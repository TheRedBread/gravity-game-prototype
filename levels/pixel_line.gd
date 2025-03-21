extends Node2D

@export var line_color : Color = Color.RED


func _process(_delta):
	queue_redraw()


func _draw():
	var target = get_local_mouse_position()

	if target.x == 0 || target.y == 0:
		# draw a single straight line
		draw_line(Vector2.ZERO, target, line_color)
	elif abs(target.x) > abs(target.y):
		_draw_horizontal_segments(target)
	else:
		_draw_vertical_segments(target)


func _draw_horizontal_segments(target: Vector2):
	# should be negative ONLY if target.x is negative
	var width : float = abs(target.x / target.y) * sign(target.x)

	var float_x := 0.0

	var sign_y = sign(target.y)
	for int_y in abs(target.y):
		# make y negative if required
		var y: int = int_y * sign_y
		# only convert to int when drawing
		var ax := int(float_x)
		var bx := int(float_x + width)

		var a := Vector2(ax, y)
		var b := Vector2(bx, y)
		draw_line(a, b, line_color)

		float_x += width


func _draw_vertical_segments(target: Vector2):
	# should be negative ONLY if target.y is negative
	var height : float = abs(target.y / target.x) * sign(target.y)

	var float_y := 0.0

	var sign_x = sign(target.x)
	for int_x in abs(target.x):
		# make x negative if required
		var x: int = int_x * sign_x
		# only convert to int when drawing
		var ay := int(float_y)
		var by := int(float_y + height)

		var a := Vector2(x, ay)
		var b := Vector2(x, by)
		draw_line(a, b, line_color)

		float_y += height
