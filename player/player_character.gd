extends CharacterBody2D

@onready var player_sprite: Sprite2D = $playerSprite
@onready var player_collision: CollisionShape2D = $PlayerCollision
@onready var player_sprite_animation: AnimationPlayer = $PlayerSpriteAnimation
@onready var eye_sprite: Sprite2D = $playerEyeSprite
@onready var slide_audio_player: AudioStreamPlayer = $SlideAudioPlayer


# ----------- PARTICLES ------------ #
@onready var sliding_particles: CPUParticles2D = $SlidingParticles
@onready var jumping_particles: CPUParticles2D = $JumpingParticles
@onready var landing_particles: CPUParticles2D = $LandingParticles

# -------------- Physics variables and player stats -------------- #
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
@export var DASH_INPUT_TIMER : float = 0.1
@export var JUMP_TIMER : float = 0.1
@export var COYOTE_TIME : float = 0.15
@export var SWITCH_TIMER : float = 0.1
@export var SWITCH_SPEED : float = 0.2
@export var GRAVITY : float = 800


#------------------------- PRELOADS ------------------------------#
const eyes_blue = preload("res://player/sprites/gravityPlayerSprite_EyesTrue.png")
const eyes_red = preload("res://player/sprites/gravityPlayerSprite_EyesFalse.png")
const STABLE_PARTICLE = preload("res://player/StableParticles/stable_particle.tscn")
const DEATH_PARTICLES = preload("res://player/death/death_particles.tscn")
const CHECKPOINT_PARTICLES = preload("res://player/spawnpoint/checkpoint_particles.tscn")

# ------------------------ SOUNDS -------------------------------#
const STEP_SOUND : AudioStream = preload("res://player/step.ogg")
const LAND_SOUND : AudioStream = preload("res://player/land.ogg")
const DASH_SOUND : AudioStream = preload("res://player/dash.mp3")
const JUMP_AUDIO : AudioStream = preload("res://player/jump.mp3")
const DESTROYED : AudioStream = preload("res://player/destroyed.mp3")
const SPAWNPOINT_CHECKED : AudioStream = preload("res://player/spawnpoint/spawnpoint_checked.mp3")
const GRAVITY_CHANGE : AudioStream = preload("res://player/gravity_change.mp3")
const SWITCH_FAIL : AudioStream = preload("res://player/switch_fail.mp3")



@export var spawn: Vector2

@onready var dash_timer: Timer = $DashTimer


enum PlayerState {
	IDLE,
	SLIDING,
	WALKING,
	DASHING,
	FALLING,
	FLYING,
	
}


var spawn_gravity : int = 0
var can_dash : bool = true

var air_switch_amount : int = 1
var dash_used : bool = true
var time_on_ground : int = 0
var land_force : float = 0
 

var current_max_speed : float
var current_acceleration : float

var clicked_jump : bool = false
var clicked_dash : bool = false
var clicked_switch : bool = false

var was_sliding : bool = false
var was_on_floor : bool = false
var was_just_sliding : bool = false
var was_falling : bool = false 

var player_state : PlayerState = PlayerState.IDLE
var no_clip : bool = false
var player_controls : bool = true


func _ready() -> void:
	current_acceleration = ACCELERATION
	current_max_speed = MAX_SPEED
	spawn_gravity = GameManager.gravity_direction
	spawn = position


#apply forces
func apply_friction(friction, delta):
	velocity.x -= ((velocity.x/1.6) * friction) * delta * 60


func apply_gravity(delta):
	if GRAVITY*GameManager.gravity_direction*delta + velocity.y * GameManager.gravity_direction > MAX_FALLING_SPEED:
		velocity.y += (MAX_FALLING_SPEED*(GRAVITY*GameManager.gravity_direction/1000) - velocity.y)
	else:
		velocity.y = velocity.y + GRAVITY*GameManager.gravity_direction * delta

## generates force to player while being on a slope
func apply_slopes():
	if is_on_floor() and ((not abs(get_floor_normal().y) == 1 and player_state == PlayerState.SLIDING) or is_floor_too_steep()):
		var inverseY = (1 - get_floor_normal().y) * SLOPES_ACCELERATION
		velocity += Vector2(SLOPES_ACCELERATION*abs(get_floor_normal().x*2), 0).rotated(get_slope_rotation(inverseY))


# --------------- updates ------------ #
func dash_input_update():
	if not Input.is_action_just_pressed("dash"):
		return
	
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


# --------------- checks -------------- #
func DashAble():
	return not player_state == PlayerState.SLIDING and (can_dash and dash_used == false)

func GravitySwitchAble():
	return clicked_switch and air_switch_amount == 1

func is_floor_too_steep():
	if abs(get_floor_normal().x) >= abs(SLOPE_MAX_ANGLE):
		return true
	else:
		return false

func get_current_friction():
	if player_state == PlayerState.SLIDING:
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
	else:
		print("ERROR! could not covert to int Direction")
		return 0

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

# ------------------ maths ------------------#
func count_dash_velocity(vsign):
	if not abs(velocity.x)>5000:
		velocity.x += DASH_STRENGHT * sign(vsign) * ((5000 - velocity.x)/5000)

func get_slope_rotation(inverseY):
	return deg_to_rad(rad_to_deg(Vector2(inverseY * get_floor_normal().x, inverseY * get_floor_normal().y).angle()) - 90  * sign(get_floor_normal().x)*-GameManager.gravity_direction)

func handle_snap_change():
	if is_on_floor() && player_state == PlayerState.SLIDING:
		floor_snap_length = clamp(10+(abs(velocity.x)+abs(velocity.y))/10, 5, 40)
	else:
		floor_snap_length = 2



# ----------------- MOVEMENT -------------------- #
func handle_movement(delta):
	if player_controls:
		if player_state == PlayerState.FLYING:
			$PlayerCollision.disabled = true
			$DeathDetection/DeathDetectionCollision.disabled = true
			handle_flying()
			
		else:
			$PlayerCollision.disabled = false
			$DeathDetection/DeathDetectionCollision.disabled = false
			
			update_was_on_floor()
			damp_velocity_to_zero()
			count_time_on_ground(delta)
			jump_input_update()
			dash_input_update()
			usage_update()
			handle_vertical_movement(delta)
			handle_jump()
			handle_slam()
			handle_dashing()
			handle_abilities()
			handle_reset()
			if not is_on_floor():
				apply_gravity(delta)
				
		
		handle_state()
		handle_sliding_reset()
		handle_snap_change()
	

#left-right
func move_to_direction(directionStr, delta):
	if player_state == PlayerState.SLIDING:
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
	
	if (Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right")) and not player_state == PlayerState.SLIDING:
		if sign(velocity.x) != -1 or abs(velocity.x) > current_max_speed:
			apply_friction(get_current_friction(), delta)
		
		if get_floor_normal().x <= SLOPE_MAX_ANGLE:
			move_to_direction("left", delta)
	elif (Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left")) and not player_state == PlayerState.SLIDING:
		if sign(velocity.x) != 1 or abs(velocity.x) > current_max_speed:
			apply_friction(get_current_friction(), delta)
		
		if get_floor_normal().x >= -SLOPE_MAX_ANGLE:
			move_to_direction("right", delta)
	else:
		apply_friction(get_current_friction(), delta)

#jump
func handle_jump():
	if clicked_jump and was_on_floor:
		spawn_stable_particle("jump")
		GRAVITY = 1200
		was_on_floor = false
		AudioManager.play_sound(JUMP_AUDIO, -5, 0.1, 1, 0.08, "sound Effects")
		jumping_particles.restart()
		jumping_particles.emitting = true
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
	$WhitenAnimation.play("dash")
	if Input.is_action_pressed("move_left"):
		count_dash_velocity(-1)
		dash_accelerate()
		if is_on_floor():
			velocity.y -= 0 * GameManager.gravity_direction
		
	if Input.is_action_pressed("move_right"):
		count_dash_velocity(1)
		dash_accelerate()
		if is_on_floor():
			velocity.y -= 0 * GameManager.gravity_direction
	AudioManager.play_sound(DASH_SOUND, -20, 1, 1.1, 0.05, "Sound effects")

func handle_dashing():
	if clicked_dash and DashAble() and (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")):
		clicked_dash = false
		dash()
		can_dash_update()
		dash_used = true
	
	if dash_timer.time_left != 0:
		spawn_stable_particle("dash")
		if is_on_floor() and int(dash_timer.time_left*1000) % 5 == 0:
			spawn_stable_particle("dash_step")
		


func handle_slam():
	if Input.is_action_pressed("slide") and not is_on_floor():
		if Input.is_action_just_pressed("slide"):
			velocity.y += 100 * GameManager.gravity_direction
		velocity.y += 20 * GameManager.gravity_direction
		MAX_FALLING_SPEED = 3000
	else:
		MAX_FALLING_SPEED = 1500


#gravity
func handle_abilities():
	input_switch()
	
	handle_gravity_switch()
func gravity_switch():
	AudioManager.play_sound(GRAVITY_CHANGE, -5, 0.02, 1, 0.2, "Sound effects")
	GameManager.gravity_direction *= -1
	up_direction = Vector2(0, -GameManager.gravity_direction)
	velocity.y += SWITCH_SPEED*GRAVITY*GameManager.gravity_direction
	
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
		if !is_on_floor():
			air_switch_amount = 0
		
		gravity_switch()
	elif Input.is_action_just_pressed("switch"):
		AudioManager.play_sound(SWITCH_FAIL, 0, 0.02, 1, 0.01, "Sound effects")


#reset
func handle_reset():
	if Input.is_action_just_pressed("reset"):
		die()

func handle_state():
	no_clip = !no_clip if Input.is_action_just_pressed("debug_mode") else no_clip
	
	if dash_timer.time_left == 0:
		if is_on_floor():
			if abs(velocity.x) > 5:
				

				if (abs(velocity.x)>=SLIDE_STOP_VELOCITY) and Input.is_action_pressed("slide") and not was_sliding:
					player_state = PlayerState.SLIDING
					
					if is_on_floor():
						velocity.y += 100 * GameManager.gravity_direction
					
				else:
					player_state = PlayerState.WALKING
					
			else:
				player_state = PlayerState.IDLE
		else:
			player_state = PlayerState.FALLING
	else:
		player_state = PlayerState.DASHING
		
	was_just_sliding = false
	
	if no_clip:
		player_state = PlayerState.FLYING


func handle_flying():
	if Input.is_action_pressed("ui_left"):
		position.x -= 10
		
	if Input.is_action_pressed("ui_right"):
		position.x += 10
		
	if Input.is_action_pressed("ui_down"):
		position.y += 10
		
	if Input.is_action_pressed("ui_up"):
		position.y -= 10

# ----------------------- ANIMATIONS ------------------------- #
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
	eye_sprite.flip_h = sign_to_bool(velocity.x)
	
	player_sprite_animation.play("walk")

func idle_anim():
	player_sprite_animation.stop()
	
	player_sprite_animation.speed_scale = 1
	
	player_sprite_animation.play("Idle")

func slide_anim():

	
	if (GameManager.gravity_direction == -1 and Input.is_action_just_pressed("slide")):
		was_just_sliding = true
	
	player_sprite_animation.stop()
	player_sprite.flip_h = sign_to_bool(velocity.x)
	eye_sprite.flip_h = sign_to_bool(velocity.x)
	
	player_sprite_animation.play("slide")

func moving_jump_anim():
	if (abs(velocity.y) < 100):
		player_sprite.frame = 16
		eye_sprite.frame = 16
	
	elif (sign(velocity.y * GameManager.gravity_direction) == -1):
		player_sprite.frame = 17
		eye_sprite.frame = 17
	
	elif (sign(velocity.y * GameManager.gravity_direction) == 1):
		player_sprite.frame = 18
		eye_sprite.frame = 18

func standing_jump_anim():
	if (abs(velocity.y) < 100):
		player_sprite.frame = 41
		eye_sprite.frame = 41
		
	elif (sign(velocity.y * GameManager.gravity_direction) == -1):
		player_sprite.frame = 40
		eye_sprite.frame = 40
		
	elif (sign(velocity.y * GameManager.gravity_direction) == 1):
		player_sprite.frame = 42
		eye_sprite.frame = 42

func jump_anim():
	if abs(velocity.x) > 0:
		player_sprite.flip_h = sign_to_bool(velocity.x)
		eye_sprite.flip_h = sign_to_bool(velocity.x)
	
	player_sprite_animation.stop()
	
	if (abs(velocity.x) > 50):
		moving_jump_anim()
	else:
		standing_jump_anim()

func eye_anim():
	if air_switch_amount > 0:
		eye_sprite.texture = eyes_blue
	else:
		eye_sprite.texture = eyes_red

func dash_anim():
	player_sprite.flip_h = sign_to_bool(velocity.x)
	eye_sprite.flip_h = sign_to_bool(velocity.x)
	
	player_sprite_animation.play("dash")

func handle_player_animation():
	eye_anim()
	if (was_just_sliding):
		position.y += 32
	
	player_sprite.scale.y = GameManager.gravity_direction
	eye_sprite.scale.y = GameManager.gravity_direction
	
	match player_state:
		PlayerState.IDLE:
			sliding_particles.emitting = false
			idle_anim()
		
		PlayerState.FALLING:
			sliding_particles.emitting = false
			player_sprite_animation.stop()
			jump_anim()
		
		PlayerState.DASHING:
			sliding_particles.emitting = false
			dash_anim()
		
		PlayerState.SLIDING:
			sliding_particles.emitting = true
			slide_anim()
		
		PlayerState.WALKING:
			sliding_particles.emitting = false
			walk_anim()


func handle_animations():
	handle_player_animation()
	handle_particles()
	
	player_sprite.scale.x = lerp(player_sprite.scale.x, 1 /clamp(1+abs(velocity.y)/2000, 1, 1.3), 0.15)
	
	eye_sprite.scale.x = lerp(eye_sprite.scale.x, 1 /clamp(1+abs(velocity.y)/2000, 1, 1.3), 0.15)
	
	
	

func handle_particles():
	var absolute_velocity = abs(velocity.x) + abs(velocity.y)
	
	if GameManager.gravity_direction == 1:
		sliding_particles.position.y = -2
		jumping_particles.position.y = -2
		landing_particles.position.y = -2
		
		
	else:
		sliding_particles.position.y = -24
		landing_particles.position.y = -10
		jumping_particles.position.y = -24
		
		
		
	
	
	sliding_particles.direction.y = -GameManager.gravity_direction
	jumping_particles.direction.y = GameManager.gravity_direction
	landing_particles.direction.y = -GameManager.gravity_direction
	
	sliding_particles.gravity.y = 50 * GameManager.gravity_direction
	jumping_particles.gravity.y = 200 * GameManager.gravity_direction
	landing_particles.gravity.y = 100 * GameManager.gravity_direction
	
	
	
	sliding_particles.initial_velocity_max = absolute_velocity/3
	sliding_particles.initial_velocity_min = absolute_velocity/5
	
	sliding_particles.gravity.y = 100 * GameManager.gravity_direction
	
	if is_on_floor() and was_falling:
		landing_particles.amount = int(land_force*5+1)
		landing_particles.initial_velocity_max = land_force*6+1
		landing_particles.initial_velocity_min = land_force*3+1
		landing_particles.emitting = true
		spawn_stable_particle("land")


func spawn_stable_particle(type):
	var particle = STABLE_PARTICLE.instantiate()
	particle.position = position + Vector2(0, -10)
	particle.scale.y = GameManager.gravity_direction
	
	if not velocity.x == 0:
		particle.scale.x = sign(velocity.x)
	
	if GameManager.gravity_direction == -1:
		particle.position += Vector2(0, -6)
	
	match type:
		"jump":
			if abs(velocity.x) > 10:
				particle.selected_animation = particle.ParticleAnimations.MOVING_JUMP
			else:
				particle.selected_animation = particle.ParticleAnimations.STAYING_JUMP
				
		"land":
			particle.selected_animation = particle.ParticleAnimations.LANDING
			particle.position = position + Vector2(0, -9)
			if GameManager.gravity_direction == -1:
				particle.position += Vector2(0, -8)
			
		"step":
			particle.selected_animation = particle.ParticleAnimations.STEP
		
		"dash":
			particle.position = position + Vector2(0, -9)
			particle.selected_animation = particle.ParticleAnimations.DASH
			if GameManager.gravity_direction == 1:
				particle.position += Vector2(0, -8)
		
		"dash_step":
			particle.selected_animation = particle.ParticleAnimations.DASH_STEP
	
	get_parent().add_child(particle)



# --------- UNSORTED METHODS ---------------#
func handle_sliding_reset():
	if Input.is_action_just_released("slide"):
		was_sliding = false
	if Input.is_action_pressed("slide") and not player_state == PlayerState.SLIDING and is_on_floor():
		was_sliding = true

func damp_velocity_to_zero():
	if  not (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		if abs(velocity.x) < 100 and not player_state == PlayerState.SLIDING:
			velocity.x /= 1.2
		if abs(velocity.x) < 0.1 and not player_state == PlayerState.SLIDING:
			velocity.x = 0

func count_time_on_ground(delta):
	if is_on_floor() and not player_state == PlayerState.SLIDING:
		time_on_ground += 1 * delta * 60
	else:
		time_on_ground = 0

func set_spawnpoint():
	AudioManager.play_sound(SPAWNPOINT_CHECKED, -20, 0.02, 2, 0.1, "Sound effects")
	GameSaveSystem.spawn_checked_count += 1
	spawn = position
	spawn_gravity = GameManager.gravity_direction

func spawn_limbs():
	var limbs = DEATH_PARTICLES.instantiate()
	limbs.position = position
	limbs.get_child(0).emitting = true
	limbs.get_child(1).emitting = true
	limbs.get_child(2).emitting = true
	var particle_gravity = Vector3(0, 250*GameManager.gravity_direction, 0)
	limbs.get_child(0).process_material.set("gravity", particle_gravity)
	limbs.get_child(1).process_material.set("gravity", particle_gravity)
	limbs.get_child(2).process_material.set("gravity", particle_gravity)
	
	get_parent().add_child(limbs)

func death_variable_reset():
	velocity = Vector2(0, 0)
	
	can_dash = true
	time_on_ground = 0
	dash_used = true
	was_sliding = false
	air_switch_amount = 1
	clicked_jump = false
	clicked_dash = false
	clicked_switch = false
	was_on_floor = false
	was_just_sliding = false
	
	air_switch_amount = 1
	
	eye_sprite.visible = false
	player_sprite.visible = false
	player_controls = false


func die():
	spawn_limbs()
	AudioManager.play_sound(DESTROYED, -15, 0.01, 1, 0.5, "Sound effects")
	death_variable_reset()
	await get_tree().create_timer(1).timeout
	GameManager.gravity_direction = spawn_gravity
	
	position = spawn + Vector2(0, -10)*GameManager.gravity_direction
	player_controls = true
	player_sprite.visible = true
	eye_sprite.visible = true
	
	up_direction = Vector2(0, -GameManager.gravity_direction)
	



# ---------------------- SOUNDS -------------------------- #
func handle_audio():
	handle_land_audio()
	handle_sliding_audio()

func step_audio(foot : String):
	# when foot is left it lowers the pitch
	var step_pitch = 1
	
	match foot:
		"left":
			step_pitch = 1.05
		"right":
			step_pitch = 0.95
	
	AudioManager.play_sound(STEP_SOUND, -25, 1, step_pitch, 0.05, "Sound effects")
	
	spawn_stable_particle("step")

func handle_land_audio():
	if is_on_floor() and was_falling:
		land_audio()
	
	if velocity.y * GameManager.gravity_direction > 0 and !is_on_floor():
		was_falling = true
		land_force += 0.15
	
	else:
		land_force = 0
		was_falling = false

func handle_sliding_audio():
	slide_audio_player.volume_db = ((abs(velocity.x) + abs(velocity.y))/60)-12 
	slide_audio_player.pitch_scale = ((abs(velocity.x) + abs(velocity.y))/1500)+0.5
	
	if player_state == PlayerState.SLIDING and not slide_audio_player.playing:
		slide_audio_player.play()
	
	if not player_state == PlayerState.SLIDING or abs(velocity.x) < 5:
		slide_audio_player.stop()


func land_audio():
	AudioManager.play_sound(LAND_SOUND, land_force - 25, 1, 1, 0.05, "Sound effects")




func _physics_process(delta):
	handle_movement(delta)
	handle_animations()
	handle_audio()
	move_and_slide()



func _on_death_detection_body_entered(_body: Node2D) -> void:
	die()

func _on_spawnpoint_detection_body_entered(_body: Node2D) -> void:
	set_spawnpoint()
	var checkpoint_particles = CHECKPOINT_PARTICLES.instantiate()
	checkpoint_particles.get_child(0).emitting = true
	checkpoint_particles.get_child(0).gravity = Vector2(0, 60 * GameManager.gravity_direction)
	
	checkpoint_particles.position = position + Vector2(0, -5 * GameManager.gravity_direction)
	if GameManager.gravity_direction == 1:
		checkpoint_particles.position = position + Vector2(0, -30 * GameManager.gravity_direction)
		
	
	get_parent().add_child(checkpoint_particles)
	
