extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -600.0
const DASH_SPEED = 500.0
const DASH_DURATION = 0.2
var is_dashing: bool = false
var dash_direction: float = 1.0
var input_direction = Vector2.ZERO

var max_jumps: int = 2
var jump_count: int = 0

func _physics_process(delta: float) -> void:
	
	if is_dashing:
		move_and_slide()
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0

	if Input.is_action_just_pressed("jump") and (is_on_floor() or jump_count < max_jumps):
		get_node("AnimatedSprite2D").play("idle")
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	var direction := Input.get_axis("left", "right")
	input_direction.x = direction
	
	if direction:
		velocity.x = direction * SPEED
		dash_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

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
