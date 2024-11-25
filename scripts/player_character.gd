extends CharacterBody2D
@onready var player_sprite: Sprite2D = $Sprite2D
@onready var player_collision: CollisionShape2D = $PlayerCollision
@onready var player_sprite_animation: AnimationPlayer = $PlayerSpriteAnimation



@export var ACCELERATION : float = 10000
@export var MAX_SPEED : float = 150
@export var MAX_FALLING_SPEED : float = 1500
@export var JUMP_STRENGHT : float = 0.22
@export var DASH_STRENGHT : float = 150
@export var GROUND_FRICTION : float = 0.30
@export var AIR_FRICTION : float = 0.005
@export var SLIDE_FRICTION : float = 0.013
@export var SLOPE_MAX_ANGLE : float = 0.50
@export var SLIDE_STOP_VELOCITY : float = 0
@export var SLOPES_ACCELERATION : float = 15
@export var DASH_ACCELERATION : float = 20000
@export var DASH_MAX_SPEED : float = 400
@export var DASH_TIMER_TIME : float = 0.2
@export var DASH_TIMER : float = 0.4
@export var DASH_INPUT_TIMER : float = 0.2
@export var JUMP_TIMER : float = 0.2
@export var COYOTE_TIME : float = 0.2
@export var SWITCH_TIMER : float = 0.2

@onready var dash_timer: Timer = $DashTimer

@export var SWITCH_SPEED : float = 0.2

@export var GRAVITY : float = 800
@export var spawn: Vector2

var can_dash : bool = true
var time_on_ground : int = 0
var dash_used : bool = true
var was_sliding : bool = false
var air_switch_amount : int = 1 
var current_max_speed : float
var current_acceleration : float
var clicked_jump : bool = false
var clicked_dash : bool = false
var clicked_switch : bool = false
var was_on_floor : bool = false
var spawn_gravity : float = 0
var gravity_direction : int = 1
var was_just_sliding : bool = false

############# STATISTIC ###################





##NOT FUNCTIONAL
#func round_to_dec(num, digit):
	#return round(num * pow(10.0, digit)) / pow(10.0, digit)
#func get_movement_friction_equation():
	#return ((1 - get_current_friction()+0.01)*10)

func _ready() -> void:
	#------------------------ VARIABLES ---------------------------#
	current_acceleration = ACCELERATION
	current_max_speed = MAX_SPEED
	spawn_gravity = gravity_direction
	spawn = position
	Engine.time_scale = 1
	get_viewport().size = DisplayServer.screen_get_size()/2
	SettingsApplier.apply_settings()
	
	
	
	
	#------------------------- METHODS ------------------------------#
	




#------------------------------------------------------------------------------------------#
#-------------------------------GAME-------------------------------------------------------#
#------------------------------------------------------------------------------------------#

#apply forces
func apply_friction(friction, delta):
	velocity.x -= ((velocity.x/1.6) * friction) * delta * 60
func apply_gravity(delta):
	if GRAVITY*gravity_direction*delta + velocity.y * gravity_direction > MAX_FALLING_SPEED:
		velocity.y += (MAX_FALLING_SPEED*(GRAVITY*gravity_direction/1000) - velocity.y)
	else:
		velocity.y = velocity.y + GRAVITY*gravity_direction * delta
func apply_slopes():
	if is_on_floor() and ((not abs(get_floor_normal().y) == 1 and is_sliding()) or is_floor_too_steep()):
		var inverseY = (1 - get_floor_normal().y) * SLOPES_ACCELERATION
		velocity += Vector2(SLOPES_ACCELERATION*abs(get_floor_normal().x*2), 0).rotated(get_slope_rotation(inverseY))


#updates
func dash_input_update():
	if Input.is_action_just_pressed("dash"):
		clicked_dash = true
		await get_tree().create_timer(DASH_INPUT_TIMER).timeout
		clicked_dash = false
func jump_input_update():	
	if Input.is_action_pressed("Jump"):
		clicked_jump = true
		await get_tree().create_timer(JUMP_TIMER).timeout
		clicked_jump = false
func can_dash_update():
	can_dash = false
	await get_tree().create_timer(DASH_TIMER).timeout
	can_dash = true

	
func usage_update():
	if (is_on_ceiling() or is_on_floor()) and not is_floor_too_steep():
		dash_used = false
func update_was_on_floor():
	if is_on_floor():
		was_on_floor = true
	elif was_on_floor:
		await get_tree().create_timer(COYOTE_TIME).timeout
		was_on_floor = false
func handle_snap_change():
	if is_on_floor():
		floor_snap_length = clamp(10+(abs(velocity.x)+abs(velocity.y))/10, 5, 40)
	else:
		floor_snap_length = 2
		
func handle_sliding_reset():
	if Input.is_action_just_released("slide"):
		was_sliding = false
	if Input.is_action_pressed("slide") and not is_sliding() and is_on_floor():
		was_sliding = true
func damp_velocity_to_zero(delta):
	if abs(velocity.x) < 100 and not is_sliding():
		velocity.x /= 1.2
	if abs(velocity.x) < 0.1 and not is_sliding():
		velocity.x = 0
func count_time_on_ground(delta):
	if is_on_floor() and not is_sliding():
		time_on_ground += 1 * delta * 60
	else:
		time_on_ground = 0


#checks
func DashAble():
	return not is_sliding() and (can_dash and dash_used == false)
func GravitySwitchAble():
	return clicked_switch and air_switch_amount == 1
func is_floor_too_steep():
	if abs(get_floor_normal().x) >= abs(SLOPE_MAX_ANGLE):
		return true
	else:
		return false
func get_current_friction():
	if is_sliding():
		return SLIDE_FRICTION
	elif is_on_floor():
		if time_on_ground >= 3 or (not (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")) and not input_direction_is_opposite(get_intDir())):
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
func get_intDir():
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		return 1
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		return -1
	else:
		return 0
func input_direction_is_opposite(intDir):
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_left"):
		return false
	elif (Input.is_action_pressed("move_left") and intDir == -1) or (Input.is_action_pressed("move_left") and intDir == -1):
		return true
	else:
		return false


#maths
func count_dash_velocity(sign):
	if not abs(velocity.x)>5000:
		velocity.x += DASH_STRENGHT * sign(sign) * ((5000 - velocity.x)/5000)
func get_slope_rotation(inverseY):
	return deg_to_rad(rad_to_deg(Vector2(inverseY * get_floor_normal().x, inverseY * get_floor_normal().y).angle()) - 90  * sign(get_floor_normal().x)*-gravity_direction)




##############################
#####NotPlayerCaused##########
func set_spawnpoint():
	GameSaveSystem.spawn_checked += 1
	spawn = position
	spawn_gravity = gravity_direction
func die():
	gravity_direction = spawn_gravity
	velocity = Vector2(0, 0)
	position = spawn + Vector2(0, -10)*gravity_direction
	up_direction = Vector2(0, -gravity_direction)
	air_switch_amount = 1




###########################
#######MOVEMENT############
func handle_movement(delta):
	update_was_on_floor()
	damp_velocity_to_zero(delta)
	count_time_on_ground(delta)
	handle_snap_change()
	jump_input_update()
	dash_input_update()
	usage_update()
	handle_sliding_reset()

	
	
	handle_vertical_movement(delta)
	handle_jump(delta)
	handle_slam()
	handle_dashing()
	handle_abilities()
	handle_slide()
	handle_reset()
	
	
	

	

	

	
	
	

	if not is_on_floor():
		apply_gravity(delta)


#left-right
func move_to_direction(directionStr, delta):
	if is_sliding():
		return
	var intDir = vDir_to_intDir(directionStr)
	
	if abs(velocity.x) > current_max_speed:
		
		if input_direction_is_opposite(intDir):
			velocity.x += current_acceleration * get_current_friction() * delta *intDir
		else:
			return

	elif abs(current_acceleration*get_current_friction()*delta) + abs(velocity.x)> abs(current_max_speed):
		
		velocity.x += clamp(current_acceleration * get_current_friction() * delta, 0, current_max_speed-abs(velocity.x)) *intDir
		
	else:
		velocity.x += current_acceleration * get_current_friction() * delta *intDir
func handle_vertical_movement(delta):
	apply_slopes()
	
	if (Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right")) and not is_sliding():
		if sign(velocity.x) != -1 or abs(velocity.x) > current_max_speed:
			apply_friction(get_current_friction(), delta)
		
		if get_floor_normal().x <= SLOPE_MAX_ANGLE:
			move_to_direction("left", delta)
	elif (Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left")) and not is_sliding():
		if sign(velocity.x) != 1 or abs(velocity.x) > current_max_speed:
			apply_friction(get_current_friction(), delta)
		
		if get_floor_normal().x >= -SLOPE_MAX_ANGLE:
			move_to_direction("right", delta)
	else:
		apply_friction(get_current_friction(), delta)

#jump
func handle_jump(delta):
	if clicked_jump and was_on_floor:
		GRAVITY = 1200
		was_on_floor = false
		if is_on_floor():
			velocity -= Vector2(0, JUMP_STRENGHT * 1200).rotated(deg_to_rad(rad_to_deg(get_floor_normal().angle())+90))
		else:
			velocity.y = -JUMP_STRENGHT*1200
		clicked_jump = false

#dash
func dash_accelerate():
	current_acceleration = DASH_ACCELERATION
	current_max_speed = DASH_MAX_SPEED
	if is_on_floor() and not velocity.y != 0:
		GRAVITY = 0
	
	dash_timer.start()
	await dash_timer.timeout
	current_acceleration = ACCELERATION
	current_max_speed = MAX_SPEED
	GRAVITY = 1200 
func dash():
	if Input.is_action_pressed("move_left"):
		count_dash_velocity(-1)
		dash_accelerate()
		if is_on_floor():
			velocity.y -= 0 * gravity_direction
		
	if Input.is_action_pressed("move_right"):
		count_dash_velocity(1)
		dash_accelerate()
		if is_on_floor():
			velocity.y -= 0 * gravity_direction
func handle_dashing():
	
	if clicked_dash and DashAble():
		clicked_dash = false
		dash()
		can_dash_update()
		dash_used = true

#slide
func handle_slide():
	pass
func is_sliding():
	var DirSign : int
	if Input.is_action_pressed("move_left"):
		DirSign = vDir_to_intDir("left")
	if Input.is_action_pressed("move_right"):
		DirSign = vDir_to_intDir("right")
	else:
		DirSign = 0
	
	if (abs(velocity.x)>=SLIDE_STOP_VELOCITY) and Input.is_action_pressed("slide") and is_on_floor() and not was_sliding:
		return true
	else:
		return false
func handle_slam():
	if Input.is_action_pressed("slide") and not is_on_floor():
		if Input.is_action_just_pressed("slide"):
			velocity.y += 100 * gravity_direction
		velocity.y += 20 * gravity_direction
		MAX_FALLING_SPEED = 3000
	else:
		MAX_FALLING_SPEED = 1500
		

#gravity
func handle_abilities():
	input_switch()
	
	handle_gravity_switch()
func gravity_switch():
	gravity_direction *= -1
	up_direction = Vector2(0, -gravity_direction)
	velocity.y += SWITCH_SPEED*GRAVITY*gravity_direction
	
func input_switch():
	if Input.is_action_just_pressed("switch"):
		clicked_switch = true
		await get_tree().create_timer(SWITCH_TIMER).timeout
		clicked_switch = false
func handle_gravity_switch():
	
	if is_on_floor() and not is_floor_too_steep():
		air_switch_amount = 1
	
	if GravitySwitchAble():
		was_on_floor = false
		clicked_switch = false
		air_switch_amount = 0
		
		gravity_switch()

#reset
func handle_reset():
	if Input.is_action_just_pressed("reset"):
		die()




########################## ANIMATIONS #####################
func sign_to_bool(val):
	if sign(val) == -1:
		return true
	if sign(val) == 1:
		return false
	else:
		return false

func walk_anim():

	
	player_sprite_animation.speed_scale = abs(velocity.x)/80
	player_sprite.flip_h = sign_to_bool(velocity.x)
	player_sprite_animation.play("walk")

func idle_anim():
	player_sprite_animation.stop()
	player_sprite_animation.speed_scale = 1
	player_sprite_animation.play("Idle")

func slide_anim():
	if (gravity_direction == -1 and Input.is_action_just_pressed("slide")):
		was_just_sliding = true
	
	player_sprite_animation.stop()
	player_sprite.flip_h = sign_to_bool(velocity.x)
	player_sprite_animation.play("slide")

func jump_anim():
	player_sprite.flip_h = sign_to_bool(velocity.x)
	player_sprite_animation.stop()
	if (abs(velocity.y) < 100):
		player_sprite.frame = 16
	elif (sign(velocity.y * gravity_direction) == -1):
		player_sprite.frame = 17
	elif (sign(velocity.y * gravity_direction) == 1):
		player_sprite.frame = 18

func dash_anim():
	player_sprite.flip_h = sign_to_bool(velocity.x)
	player_sprite_animation.play("dash")

func handle_player_animation():
	if (!velocity.x) and velocity.x != 0:
		return
	if (was_just_sliding):
		position.y += 32
	
	player_sprite.scale.y = gravity_direction
	if dash_timer.time_left == 0:
		if is_on_floor():
			if abs(velocity.x) > 5:
				if is_sliding():
					slide_anim()
				else:
					walk_anim()
			else:
				idle_anim()
		else:
			player_sprite_animation.stop()
			jump_anim()
	else:
		
		dash_anim()
	was_just_sliding = false


func handle_animations():
	handle_player_animation()







func _physics_process(delta):
	handle_movement(delta)
	handle_animations()
	move_and_slide()
	Engine.time_scale = 1
	
	
func _on_death_detection_body_entered(body: Node2D) -> void:
	die()
func _on_spawnpoint_detection_body_entered(body: Node2D) -> void:
	set_spawnpoint()
