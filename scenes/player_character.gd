extends CharacterBody2D
@onready var player_visual_polygon: Polygon2D = $PlayerVisualPolygon

const SAVE_PATH: String = "res://save.bin"

@export var switch_only_on_floor : bool = false
@export var Jump_allowed : bool = true
@export var Slide_allowed : bool = true
@export var Dash_allowed : bool = true
@export var DASHING_WHILE_SLIDING : bool = false
@export var ONE_DASH_USAGE : bool = true


@export var ACCELERATION : float = 750
@export var MAX_SPEED : float = 200
@export var MAX_FALLING_SPEED : float = 800
@export var JUMP_STRENGHT : float = 20
@export var DASH_STRENGHT : float = 500
@export var GROUND_FRICTION : float = 0.9
@export var AIR_FRICTION : float = 0.999
@export var SLIDE_FRICTION : float = 0.99
@export var SLOPE_MAX_ANGLE : float = 0.45
@export var SLIDE_STOP_VELOCITY : float = 0
@export var SLOPES_ACCELERATION : float = 20
@export var DASH_ACCELERATION : float = 3000
@export var DASH_MAX_SPEED : float = 500
@export var DASH_TIMER_TIME : float = 0.15

@export var SWITCH_SPEED : float = 0.2

@export var GRAVITY : float = 1200
@export var spawn: Vector2

var time_on_ground : int = 0
var dash_used : bool = true
var was_sliding : bool = false
var air_switch_amount : int = 1 
var current_max_speed : float
var current_acceleration : float


func _ready() -> void:
	current_acceleration = ACCELERATION
	current_max_speed = MAX_SPEED
	Engine.time_scale = 1
	spawn = position
	save_game()
	load_game()



#####################SAVEGAME#################
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"switch_only_on_floor" : switch_only_on_floor,
		"Jump_allowed" : Jump_allowed,
		"Slide_allowed" : Slide_allowed,
		"Dash_allowed" : Dash_allowed,
		"DASHING_WHILE_SLIDING" : DASHING_WHILE_SLIDING,
		"ACCELERATION" : ACCELERATION,
		"MAX_SPEED" : MAX_SPEED,
		"MAX_FALLING_SPEED" : MAX_FALLING_SPEED,
		"JUMP_STRENGHT" : JUMP_STRENGHT,
		"DASH_STRENGHT" : DASH_STRENGHT,
		"GROUND_FRICTION" : GROUND_FRICTION,
		"AIR_FRICTION" : AIR_FRICTION,
		"SLIDE_FRICTION" : SLIDE_FRICTION,
		"SWITCH_SPEED" : SWITCH_SPEED,
		"GRAVITY" : GRAVITY,
		"ONE_DASH_USAGE" : ONE_DASH_USAGE,
		"SLOPE_MAX_ANGLE" : SLOPE_MAX_ANGLE,
		"SLIDE_STOP_VELOCITY" : SLIDE_STOP_VELOCITY,
		"SLOPES_ACCELERATION" : SLOPES_ACCELERATION
	}
	
	var jstr = JSON.stringify(data)
	
	file.store_line(jstr)

func load_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file or file == null:
		return
	if FileAccess.file_exists(SAVE_PATH) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				switch_only_on_floor = current_line["switch_only_on_floor"] 
				Jump_allowed = current_line["Jump_allowed"] 
				Slide_allowed = current_line["Slide_allowed"] 
				Dash_allowed = current_line["Dash_allowed"] 
				DASHING_WHILE_SLIDING = current_line["DASHING_WHILE_SLIDING"] 
				ACCELERATION = current_line["ACCELERATION"] 
				MAX_SPEED = current_line["MAX_SPEED"] 
				MAX_FALLING_SPEED = current_line["MAX_FALLING_SPEED"] 
				JUMP_STRENGHT = current_line["JUMP_STRENGHT"] 
				DASH_STRENGHT = current_line["DASH_STRENGHT"] 
				GROUND_FRICTION = current_line["GROUND_FRICTION"] 
				AIR_FRICTION = current_line["AIR_FRICTION"] 
				SLIDE_FRICTION = current_line["SLIDE_FRICTION"] 
				SWITCH_SPEED = current_line["SWITCH_SPEED"] 
				GRAVITY = current_line["GRAVITY"] 
				ONE_DASH_USAGE = current_line["ONE_DASH_USAGE"]
				SLOPE_MAX_ANGLE = current_line["SLOPE_MAX_ANGLE"]
				SLIDE_STOP_VELOCITY = current_line["SLIDE_STOP_VELOCITY"]
				SLOPES_ACCELERATION = current_line["SLOPES_ACCELERATION"]


#######OTHER#############
func handle_reset():
	if Input.is_action_just_pressed("reset"):
		position = spawn
		velocity = Vector2(0, 0)
		
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
		
func is_floor_wall():
	if not is_on_floor():
		return false
	
	if get_floor_normal().x >= 1 or get_floor_normal().x <= -1:
		return true
	else:
		return false

#######MOVEMENT############
##OTHER####
func get_current_friction():
	if is_sliding():
		return SLIDE_FRICTION
	elif is_on_floor() or is_on_ceiling() and not is_floor_wall():
		if not time_on_ground <= 10 or not abs(velocity.x) > current_max_speed: 
			return GROUND_FRICTION
		else:
			return AIR_FRICTION
	else:
		return AIR_FRICTION
func vDir_to_intDir(dirStr):
	if dirStr == "right":
		return 1
	if dirStr == "left":
		return -1
func get_movement_friction_equation():
	return ((1 - get_current_friction()+0.01)*10)


##PLAYER#CAUSED
func move_to_direction(directionStr, delta):
	if is_sliding():
		return
	var intDir = vDir_to_intDir(directionStr)
	
	if abs(velocity.x)> current_max_speed:
		return
	elif current_acceleration*get_movement_friction_equation()*delta + abs(velocity.x)> current_max_speed:
		velocity.x = current_max_speed * intDir
	else:
		velocity.x += current_acceleration*get_movement_friction_equation() * delta *intDir



func handle_vertical_movement(delta):
	apply_slopes()
	
	if (Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right")) and not is_sliding():
		if sign(velocity.x) != -1 or abs(velocity.x) > current_max_speed:
			apply_friction(get_current_friction(),delta)
		
		if get_floor_normal().x <= SLOPE_MAX_ANGLE:
			move_to_direction("left", delta)
	elif (Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left")) and not is_sliding():
		if sign(velocity.x) != 1 or abs(velocity.x) > current_max_speed:
			apply_friction(get_current_friction(),delta)
		
		if get_floor_normal().x >= -SLOPE_MAX_ANGLE:
			move_to_direction("right", delta)
	else:
		apply_friction(get_current_friction(), delta)
	

	

func handle_jump(delta):
	
	if not is_floor_wall() and is_on_floor() and round(abs(rad_to_deg(get_floor_normal().angle()))) == 90:
		velocity.y = 0
	
	if Input.is_action_just_pressed("Jump") and (is_on_floor() or is_on_ceiling()) and not is_floor_wall():
		velocity -= Vector2(0, JUMP_STRENGHT * abs(GRAVITY) * delta).rotated(deg_to_rad(rad_to_deg(get_floor_normal().angle())+90))
		

func is_sliding():
	var DirSign : int
	if Input.is_action_pressed("move_left"):
		DirSign = vDir_to_intDir("left")
	if Input.is_action_pressed("move_right"):
		DirSign = vDir_to_intDir("right")
	else:
		DirSign = 0
	
	if (Slide_allowed and abs(velocity.x)>SLIDE_STOP_VELOCITY) and Input.is_action_pressed("slide") and (is_on_ceiling() or is_on_floor()) and not was_sliding and (sign(velocity.x) == DirSign or DirSign == 0):
		
		return true
	else:
		return false

func dash_accelerate():
	current_acceleration = DASH_ACCELERATION
	current_max_speed = DASH_MAX_SPEED
	await get_tree().create_timer(DASH_TIMER_TIME).timeout
	current_acceleration = ACCELERATION
	current_max_speed = MAX_SPEED

func count_dash_velocity(sign):
	velocity.x += DASH_STRENGHT * sign(sign)
	
func dash():
	if Input.is_action_pressed("move_left"):
		count_dash_velocity(-1)
		dash_accelerate()
		
	if Input.is_action_pressed("move_right"):
		count_dash_velocity(1)
		dash_accelerate()

func handle_slide():
	if is_sliding():
		player_visual_polygon.scale.y = 0.5
	else:
		player_visual_polygon.scale.y = 1
		
func handle_dashing():
	if Dash_allowed and Input.is_action_just_pressed("dash"):
		if DASHING_WHILE_SLIDING or not is_sliding():
			if dash_used == false or not ONE_DASH_USAGE:
				dash()
				dash_used = true

func usage_update():
	
	if is_on_ceiling() or is_on_floor() and not is_floor_too_steep():
		dash_used = false

func count_time_on_ground():
	if is_on_floor():
		time_on_ground += 1
	else:
		time_on_ground = 0

func handle_movement(delta):
	count_time_on_ground()
		
	handle_vertical_movement(delta)
	if Jump_allowed:
		handle_jump(delta)
	
	usage_update()
	
	handle_dashing()
	handle_sliding_reset()
	
	
	handle_abilities()
	handle_slide()
	handle_reset()

	if is_floor_wall() or not is_on_floor() or is_on_ceiling():
		apply_gravity(delta)

func handle_switch_reset():
	if Input.is_action_just_pressed("switch"):
		air_switch_amount = 0
	elif is_on_floor() or is_on_ceiling() and not is_floor_too_steep():
		air_switch_amount = 1

func handle_sliding_reset():
	if Input.is_action_just_released("slide"):
		was_sliding = false
	if Input.is_action_pressed("slide") and not is_sliding() and (is_on_ceiling() or is_on_floor()):
		was_sliding = true

##NOT#PLAYER#CAUSED####
func apply_friction(friction, delta):
	velocity.x *= friction * delta*60

func apply_gravity(delta):
	if GRAVITY*delta + velocity.y * sign(GRAVITY) > MAX_FALLING_SPEED:
		velocity.y = MAX_FALLING_SPEED*(GRAVITY/1000)
	else:
		velocity.y = velocity.y + GRAVITY * delta

func apply_slopes():
	if is_on_floor() and (not abs(get_floor_normal().y) == 1 and is_sliding()) or is_floor_too_steep():
		
		var inverseY = (1 - get_floor_normal().y) * SLOPES_ACCELERATION
		velocity += Vector2(SLOPES_ACCELERATION, 0).rotated(deg_to_rad(rad_to_deg(Vector2(inverseY * get_floor_normal().x, inverseY * get_floor_normal().y).angle()) - 90  * sign(get_floor_normal().x)*sign(-GRAVITY)))
		
		$Polygon2D.rotation = deg_to_rad(rad_to_deg(Vector2(inverseY * get_floor_normal().x, inverseY * get_floor_normal().y).angle()) - 90  * sign(get_floor_normal().x)*sign(-GRAVITY))
		
		
func is_floor_too_steep():
	if get_floor_normal().x >= SLOPE_MAX_ANGLE or get_floor_normal().x <= -SLOPE_MAX_ANGLE:
		return true
	else:
		return false



#######ABILITIES###########
func handle_gravity_switch():
	
	if Input.is_action_just_pressed("switch"):
		if switch_only_on_floor == false:
			if air_switch_amount == 1:
				gravity_switch()
		elif (is_on_floor() or is_on_ceiling()):
			gravity_switch()
	
	handle_switch_reset()
	

func gravity_switch():
	GRAVITY *= -1
	up_direction *= -1
	velocity.y += SWITCH_SPEED*GRAVITY

func handle_abilities():
	handle_gravity_switch()







func _physics_process(delta):
	handle_movement(delta)
	move_and_slide()
	print(velocity.x)
