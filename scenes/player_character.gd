extends CharacterBody2D
@onready var player_visual_polygon: Polygon2D = $PlayerVisualPolygon
const SAVE_PATH: String = "res://save.bin"

@export var switch_only_on_floor : bool = false
@export var Jump_allowed : bool = true
@export var Slide_allowed : bool = true
@export var Dash_allowed : bool = true
@export var DASHING_WHILE_SLIDING : bool = false
@export var ONE_DASH_USAGE : bool = true


@export var ACCELERATION : float = 1500
@export var MAX_SPEED : float = 400
@export var MAX_FALLING_SPEED : float = 800
@export var JUMP_STRENGHT : float = 25
@export var DASH_STRENGHT : float = 900
@export var GROUND_FRICTION : float = 0.88
@export var AIR_FRICTION : float = 0.995
@export var SLIDE_FRICTION : float = 0.98


@export var SWITCH_SPEED : float = 0.2

@export var GRAVITY : float = 1200
@export var spawn: Vector2

var dash_used : bool = true
var was_sliding : bool = false
var air_switch_amount : int = 1 



func _ready() -> void:
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
		"ONE_DASH_USAGE" : ONE_DASH_USAGE
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
		



#######OTHER#############
func handle_reset():
	if Input.is_action_just_pressed("reset"):
		position = spawn
		velocity = Vector2(0, 0)

#######MOVEMENT############
##OTHER####
func get_current_friction():
	if is_sliding():
		return SLIDE_FRICTION
	elif is_on_floor() or is_on_ceiling():
		return GROUND_FRICTION
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
	
	if abs(velocity.x) > MAX_SPEED:
		return
	elif ACCELERATION*get_movement_friction_equation()*delta + velocity.x*intDir > MAX_SPEED:
		velocity.x = MAX_SPEED * intDir
	else:
		velocity.x += ACCELERATION*get_movement_friction_equation() * delta *intDir


func handle_vertical_movement(delta):
	
	if (Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right")) and not is_sliding():
		if sign(velocity.x) != -1 or abs(velocity.x) > MAX_SPEED:
			apply_friction(get_current_friction(),delta)
			
		move_to_direction("left", delta)
	elif (Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left")) and not is_sliding():
		if sign(velocity.x) != 1 or abs(velocity.x) > MAX_SPEED:
			apply_friction(get_current_friction(),delta)
			
		move_to_direction("right", delta)
	else:
		apply_friction(get_current_friction(), delta)
	
	
	

func handle_jump(delta):
	if Input.is_action_just_pressed("Jump") and (is_on_floor() or is_on_ceiling()):
		velocity.y -= JUMP_STRENGHT * GRAVITY * delta

func is_sliding():
	if (Slide_allowed and abs(velocity.x)>50.0) and Input.is_action_pressed("slide") and (is_on_ceiling() or is_on_floor()) and not was_sliding:
		
		return true
	else:
		return false

func dash():
	if Input.is_action_pressed("move_left"):
		velocity.x = -DASH_STRENGHT
	if Input.is_action_pressed("move_right"):
		velocity.x = DASH_STRENGHT

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
	if is_on_ceiling() or is_on_floor():
		dash_used = false

func handle_movement(delta):
	handle_vertical_movement(delta)
	if Jump_allowed:
		handle_jump(delta)
	
	usage_update()
	
	handle_dashing()
	handle_sliding_reset()
	
	
	handle_abilities()
	handle_slide()
	handle_reset()

	
	apply_gravity(delta)

func handle_switch_reset():
	if Input.is_action_just_pressed("switch"):
		air_switch_amount = 0
	elif is_on_floor() or is_on_ceiling():
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
	if GRAVITY*delta + velocity.y*(GRAVITY/1000) > MAX_FALLING_SPEED:
		velocity.y = MAX_FALLING_SPEED*(GRAVITY/1000)
	else:
		velocity.y = velocity.y + GRAVITY * delta








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
	velocity.y += SWITCH_SPEED*GRAVITY

func handle_abilities():
	handle_gravity_switch()







func _physics_process(delta):
	handle_movement(delta)
	move_and_slide()
	print(velocity)
