extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -600.0
const DASH_SPEED = 500.0
const DASH_DURATION = 0.2
var is_dashing: bool = false
var dash_direction: float = 1.0
var input_direction = Vector2.ZERO

var nearestPoint = null
@onready var line = get_node("Line2D")

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
		
	if Input.is_action_pressed("swing"):
		swing()
	else:
		get_nearest_point()
		line.clear_points()
	
	
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
	
func swing() -> void:
	if nearestPoint == null: 
		return
	var diff = nearestPoint.global_position - global_position
	velocity.x += diff.x * 2
	velocity.y += diff.y / 1.5
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(to_local(nearestPoint.global_position))
	reset_jump()

func get_nearest_point():
	var min_distance = INF
	var previousPoint = nearestPoint
	for body in get_node("Area2D").get_overlapping_bodies():
		if body.is_in_group("SwingPoint"):
			var dist = global_position.distance_to(body.global_position)
			if dist < min_distance:
				min_distance = dist
				nearestPoint = body
	if nearestPoint:
		nearestPoint.get_node("AnimatedSprite2D").play("active")
	if previousPoint != nearestPoint and previousPoint:
		previousPoint.get_node("AnimatedSprite2D").play("inactive")

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


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == nearestPoint:
		nearestPoint.get_node("AnimatedSprite2D").play("inactive")
		nearestPoint = null
		line.clear_points()
