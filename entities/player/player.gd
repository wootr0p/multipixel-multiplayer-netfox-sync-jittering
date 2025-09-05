class_name Player
extends CharacterBody2D

@export var player_id: int = 1:
	set(id):
		player_id = id
		%PlayerInput.set_multiplayer_authority(id)

const TILE_SIZE := 32
const GRAVITY := 4000.0
const FALL_GRAVITY: float = 4800.0
const JUMP_HEIGHT := TILE_SIZE * 10
const DASH_HEIGHT := TILE_SIZE * 10
const WALL_JUMP_HEIGHT := TILE_SIZE * 12

const JUMP_VELOCITY := sqrt(2.0 * GRAVITY * JUMP_HEIGHT)
const WALL_JUMP_VELOCITY := sqrt(2.0 * GRAVITY * WALL_JUMP_HEIGHT)
const DASH_TIME := 0.2
const DASH_VELOCITY := DASH_HEIGHT / DASH_TIME

const MOVE_VELOCITY: float = 640.0
const ACCELERATION: float = 8000.0
const DECCELERATION: float = 12000.0

const WALL_JUMP_SLIPPERY := 0.85
const WALL_JUMP_BOUNCE_SPEED := 1400

const JUMP_BUFFER_TIMER := 0.2
const JUMP_COOLDOWN_TIMER := 0.1
const DASH_BUFFER_TIMER := 0.2
const COYOTE_TIMER := 0.1
const DASH_COOLDOWN_TIMER := 0.2
const MIN_JUMP_TIME := 0.06  # secondi minimi di salto

@onready var player_input: PlayerInput = %PlayerInput
@onready var rollback_synchronizer: RollbackSynchronizer = $RollbackSynchronizer
@onready var trail_effect: TrailEffect = %TrailEffect
@onready var visual: Node2D = $Visual

var is_owner: bool = false
var is_server: bool = false
var current_spawn_point: Vector2
var target_position: Vector2

# --- Timers ---
#var jump_buffer_t := 0.0
#var dash_buffer_t := 0.0
#var coyote_t := 0.0
#var min_jump_t := 0.0
#var dash_cooldown_t := 0.0
#var dash_duration_t := 0.0

#var jump_just_pressed: bool = false
#var jump_prev_value: float = 0.0
#var dash_just_pressed: bool = false
#var dash_prev_value: float = 0.0

#var can_dash: bool = false
#var wall_jump_left: bool = false
#var wall_jump_right: bool = false
var camera: LevelCamera

func _ready() -> void:
	rollback_synchronizer.process_settings()
	is_server = multiplayer.is_server()
	is_owner = multiplayer.get_unique_id() == player_id
	current_spawn_point = global_position
	local_reset_player()

	if is_owner:
		camera = get_tree().get_nodes_in_group("Camera")[0] as LevelCamera
		camera.enabled = true
		camera.make_current()
		camera.follow = self

func _rollback_tick(delta, tick, is_fresh):
	#_tick_timers(delta)
	
	#jump_just_pressed = (player_input.input_jump >= 0.5 and jump_prev_value < 0.5)
	#jump_prev_value = player_input.input_jump
	#dash_just_pressed = (player_input.input_dash >= 0.5 and dash_prev_value < 0.5)
	#dash_prev_value = player_input.input_dash
	
	apply_input(player_input.input_dir, player_input.input_jump >= 0.5, player_input.input_jump < 0.5, player_input.input_dash >= 0.5, delta)
	
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor

func _tick_timers(delta: float) -> void:
	#jump_buffer_t = max(0.0, jump_buffer_t - delta)
	#dash_buffer_t = max(0.0, dash_buffer_t - delta)
	#coyote_t = max(0.0, coyote_t - delta)
	#dash_cooldown_t = max(0.0, dash_cooldown_t - delta)
	#dash_duration_t = max(0.0, dash_duration_t - delta)
	#min_jump_t += delta
	pass

func apply_input(input_direction: Vector2, want_jump: bool, jump_release: bool, want_dash: bool, delta: float) -> void:
	#trail_effect.is_active = dash_duration_t > 0.0
	
	#if want_dash:
		#dash_buffer_t = DASH_BUFFER_TIMER
	#if want_jump:
		#jump_buffer_t = JUMP_BUFFER_TIMER
	
	#if jump_release and min_jump_t >= MIN_JUMP_TIME:
	if jump_release:
		if velocity.y < 0:
			velocity.y *= 0.4

	
	#if is_on_ground():
		#can_dash = true
		#coyote_t = COYOTE_TIMER

	#if dash_duration_t <= 0.0:
		# not dash state
		
	var target_velocity_x = input_direction.x * MOVE_VELOCITY
	if input_direction.x != 0:
		velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECCELERATION * delta)

	if not is_on_ground():
		if velocity.y < 0:
			velocity.y += GRAVITY * delta
		else:
			velocity.y += FALL_GRAVITY * delta

	#if jump_buffer_t > 0.0 and (is_on_ground() or coyote_t > 0.0):
	if want_jump && is_on_ground():
		velocity.y = -JUMP_VELOCITY
		#jump_buffer_t = 0.0
		#coyote_t = 0.0
		#min_jump_t = 0.0
	#else:
		## dash state
		#
		#if input_direction == Vector2.ZERO:
			#velocity = Vector2.UP * DASH_VELOCITY
		#else:
			#velocity = input_direction.normalized() * DASH_VELOCITY

	#if dash_buffer_t > 0.0:
	if want_dash:
		pass
		#handle_dash(input_direction)
		#dash_buffer_t = 0.0

	handle_walljump(want_jump)

func handle_dash(input_direction: Vector2) -> void:
	#if dash_cooldown_t > 0.0 or not can_dash:
	#if !can_dash:
		#return
		
	#dash_cooldown_t = DASH_COOLDOWN_TIMER
	#dash_duration_t = DASH_TIME
	var dash_dir = input_direction
	if dash_dir == Vector2.ZERO:
		dash_dir = Vector2.UP
	velocity = dash_dir.normalized() * DASH_VELOCITY
	#can_dash = false

func handle_walljump(want_jump: bool) -> void:
	if is_on_ground():
		pass
		#wall_jump_left = false
		#wall_jump_right = false

	if is_on_wall_left():
		velocity.y *= WALL_JUMP_SLIPPERY
		#if want_jump and not wall_jump_left:
		if want_jump:
			velocity.y = -WALL_JUMP_VELOCITY
			velocity.x = WALL_JUMP_BOUNCE_SPEED
			#wall_jump_left = true
			#wall_jump_right = false
			return

	if is_on_wall_right():
		velocity.y *= WALL_JUMP_SLIPPERY
		#if want_jump and not wall_jump_right:
		if want_jump:
			velocity.y = -WALL_JUMP_VELOCITY
			velocity.x = -WALL_JUMP_BOUNCE_SPEED
			#wall_jump_right = true
			#wall_jump_left = false
			return
	

func local_reset_player():
	#dash_buffer_t = 0.0
	#jump_buffer_t = 0.0
	#dash_duration_t = 0.0
	trail_effect.is_active = false
	velocity = Vector2.ZERO
	set_physics_process(false)
	global_position = current_spawn_point
	set_physics_process(true)

func is_on_ground() -> bool:
	_force_update_is_on_floor()
	return is_on_floor()

func is_on_wall_left() -> bool:
	_force_update_is_on_floor()
	return is_on_wall() and get_wall_normal().x == 1 #and velocity.x < 0.0

func is_on_wall_right() -> bool:
	_force_update_is_on_floor()
	return is_on_wall() and get_wall_normal().x == -1 #and velocity.x > 0.0

func _force_update_is_on_floor():
	var old_velocity = velocity
	velocity = Vector2.ZERO
	move_and_slide()
	velocity = old_velocity
