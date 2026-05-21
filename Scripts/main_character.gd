extends CharacterBody2D

const SPEED =  200.0
const JUMP_VELOCITY = -800.0
const DASH_SPEED = 500.0
const DASH_DURATION = 0.2
var is_dashing: bool = false
var dash_direction: float = 1.0
var input_direction = Vector2.ZERO

var max_jumps: int = 2
var jump_count: int = 0

const WALL_SLIDE_SPEED = 0 
const WALL_JUMP_VELOCITY = Vector2(400, -350)
var is_wall_jumping: bool = false
var jump_charge_hold_time: float = 0
var maxcharge = 300
var is_charging_jump: bool = false
var is_charged_jump: bool = false
const CHARGED_JUMP_DURATION = 0.4

@onready var wall_check_left = $WallCheckLeft
@onready var wall_check_right = $WallCheckRight

func _physics_process(delta: float) -> void:
	
	if is_charged_jump:
		move_and_slide()
		return
		
	if is_dashing:
		move_and_slide()
		return
	if Input.is_action_just_pressed("charge_jump"):
		is_charging_jump = true
		jump_charge_hold_time = 0.0
	if Input.is_action_pressed("charge_jump") and is_charging_jump:
		jump_charge_hold_time += delta
	if Input.is_action_just_released("charge_jump"):
		is_charging_jump = false
		charged_jump()
		
	var direction := Input.get_axis("left", "right")
	input_direction.x = direction
	if direction:
		dash_direction = direction
		
	var touching_left_wall = wall_check_left.is_colliding()
	var touching_right_wall = wall_check_right.is_colliding()
	var is_touching_wall = touching_left_wall or touching_right_wall
	var pressing_into_wall = (touching_left_wall and direction < 0) or (touching_right_wall and direction > 0)
	
	if not is_on_floor():
		if is_touching_wall and pressing_into_wall:
			is_wall_jumping = false
			velocity.y = WALL_SLIDE_SPEED
		else: 
			velocity += get_gravity() * delta
	else: 
		jump_count = 0
		is_wall_jumping = false
		
	
	
	if Input.is_action_just_pressed("jump"):
		if is_touching_wall and not is_on_floor() and pressing_into_wall:
			velocity.y = WALL_JUMP_VELOCITY.y * 2
			is_wall_jumping = true
			jump_count = 1
			wall_check_left.enabled = false
			wall_check_right.enabled = false
			await get_tree().create_timer(0.1).timeout
			wall_check_left.enabled = true
			wall_check_right.enabled = true
		elif is_on_floor() or jump_count < max_jumps:
			velocity.y = JUMP_VELOCITY
			jump_count += 1
			is_wall_jumping = false
			
			
	if is_on_floor():
		if direction:
			velocity.x = direction * SPEED
		else: 
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else: 
		if is_wall_jumping:
			velocity.x = move_toward(velocity.x, direction * SPEED, SPEED * delta * 2)
			if direction == 0 or (touching_right_wall and direction < 0) or (touching_left_wall and direction > 0):
				is_wall_jumping = false
		else: 
			if direction:
				velocity.x = direction * SPEED
			else: 
				velocity.x = move_toward(velocity.x, 0, SPEED * delta * 4)

	

	if Input.is_action_just_pressed("dash"):
		start_dash()

	update_animation()
	move_and_slide()

func start_dash() -> void:
	is_dashing = true
	velocity.x = dash_direction * DASH_SPEED
	velocity.y = 0
	await get_tree().create_timer(DASH_DURATION).timeout
	end_dash()

func end_dash() -> void:
	is_dashing = false
	velocity.x = 0

func reset_jump() -> void:
	jump_count = 0
	
func charged_jump() -> void:
	is_charged_jump = true
	velocity.y =  remap(min(jump_charge_hold_time, 3.0), 0.0, 3.0, JUMP_VELOCITY, JUMP_VELOCITY * 2.2)
	await get_tree().create_timer(0.15).timeout
	end_charged_jump()
	
func end_charged_jump() -> void:
	is_charged_jump = false
	
func update_animation():
	var ani = get_node("AnimatedSprite2D")

	if is_on_floor() and input_direction.x != 0:
		ani.play("run")
	elif is_on_floor() and input_direction.x == 0:
		ani.play("idle")

	if input_direction.x > 0:
		ani.flip_h = false
	elif input_direction.x < 0:
		ani.flip_h = true

	if not is_on_floor():
		if ani.animation != "jump":
			ani.play("jump")
