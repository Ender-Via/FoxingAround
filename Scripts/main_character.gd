extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -1200.0
const DASH_SPEED = 500.0
const DASH_DURATION = 0.2
@onready var sprite_2d = $Sprite2D
var is_dashing: bool = false
var dash_direction: float = 1.0

var max_jumps: int = 1
var jump_count: int = 0

func _physics_process(delta: float) -> void:
	if is_dashing:
		move_and_slide()
		return
	if (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = "walk"
	else:
		sprite_2d.animation = "default"
	if not is_on_floor():
		velocity += get_gravity() * delta
		sprite_2d.animation = "jump"
	else:
		jump_count = 0

	if Input.is_action_just_pressed("jump") and (is_on_floor() or jump_count < max_jumps):
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	var direction := Input.get_axis("left", "right")
	
	if direction:
		velocity.x = direction * SPEED
		dash_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("dash"):
		start_dash()

	move_and_slide()
	
	var isLeft = velocity.x < 0
	sprite_2d.flip_h = isLeft

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
