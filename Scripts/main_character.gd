extends CharacterBody2D

# --- CÔNG TẮC SKILL ---
@export var enable_jump: bool = true
@export var enable_dash: bool = true
@export var enable_swing: bool = true
@export var enable_wall_jump: bool = true

const SPEED = 200.0
const JUMP_VELOCITY = -800.0
var max_jumps: int = 2
var jump_count: int = 0
var can_orb_jump: bool = false

const DASH_SPEED = 500.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 0.5
var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: float = 1.0

const WALL_SLIDE_SPEED = 0 
const WALL_JUMP_VELOCITY = Vector2(400, -350)
var is_wall_jumping: bool = false

var jump_charge_hold_time: float = 0
const CHARGED_JUMP_DURATION = 0.4
var is_charging_jump: bool = false
var is_charged_jump: bool = false

var nearestPoint = null
var input_direction = Vector2.ZERO

var spawn_position: Vector2

@onready var sprite_2d = $AnimatedSprite2D
@onready var line = $Line2D
@onready var wall_check_left = $WallCheckLeft
@onready var wall_check_right = $WallCheckRight

func _ready() -> void:
	spawn_position = global_position
	add_to_group("Player")
	
	# Tự động check Map để khóa/mở skill
	var current_map_name = get_tree().current_scene.name
	if current_map_name == "Map_1":
		enable_jump = true
		max_jumps = 1          # Khóa double jump
		enable_swing = false   # Khóa đu dây
		enable_wall_jump = false # Khóa leo tường
		enable_dash = true     # Cho lướt
	else:
		enable_jump = true
		max_jumps = 2 
		enable_swing = true
		enable_wall_jump = true
		enable_dash = true

func _physics_process(delta: float) -> void:
	if is_charged_jump or is_dashing:
		move_and_slide()
		return
		
	if Input.is_action_just_pressed("charge_jump") and enable_jump:
		is_charging_jump = true
		jump_charge_hold_time = 0.0
	if Input.is_action_pressed("charge_jump") and is_charging_jump:
		jump_charge_hold_time += delta
	if Input.is_action_just_released("charge_jump") and is_charging_jump:
		is_charging_jump = false
		execute_charged_jump()
		
	var direction := Input.get_axis("left", "right")
	input_direction.x = direction
	if direction != 0:
		dash_direction = direction
		
	var touching_left_wall = wall_check_left.is_colliding()
	var touching_right_wall = wall_check_right.is_colliding()
	var is_touching_wall = touching_left_wall or touching_right_wall
	var pressing_into_wall = (touching_left_wall and direction < 0) or (touching_right_wall and direction > 0)
	
	if not is_on_floor():
		if is_touching_wall and pressing_into_wall and enable_wall_jump:
			is_wall_jumping = false
			velocity.y = WALL_SLIDE_SPEED
		else: 
			velocity += get_gravity() * delta
	else: 
		jump_count = 0
		is_wall_jumping = false
		can_orb_jump = false
		
	if Input.is_action_just_pressed("jump") and enable_jump:
		if is_touching_wall and not is_on_floor() and pressing_into_wall and enable_wall_jump:
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
		elif can_orb_jump:
			velocity.y = JUMP_VELOCITY
			can_orb_jump = false
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

	if Input.is_action_just_pressed("dash") and can_dash and enable_dash:
		start_dash()
		
	if Input.is_action_pressed("swing") and enable_swing:
		swing()
	else:
		get_nearest_point()
		if line:
			line.clear_points()
	
	update_animation()
	move_and_slide()

func start_dash() -> void:
	is_dashing = true
	can_dash = false
	velocity.x = dash_direction * DASH_SPEED
	velocity.y = 0
	await get_tree().create_timer(DASH_DURATION).timeout
	end_dash()

func end_dash() -> void:
	is_dashing = false
	velocity.x = 0
	await get_tree().create_timer(DASH_COOLDOWN).timeout
	can_dash = true

func reset_jump() -> void:
	jump_count = 0
	can_orb_jump = true
	
func execute_charged_jump() -> void:
	is_charged_jump = true
	velocity.y = remap(min(jump_charge_hold_time, 3.0), 0.0, 3.0, JUMP_VELOCITY, JUMP_VELOCITY * 2.2)
	await get_tree().create_timer(0.15).timeout
	end_charged_jump()
	
func end_charged_jump() -> void:
	is_charged_jump = false
	
func swing() -> void:
	if nearestPoint == null: 
		return
	var diff = nearestPoint.global_position - global_position
	velocity.x += diff.x * 2
	velocity.y += diff.y / 1.5
	if line:
		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(to_local(nearestPoint.global_position))
	reset_jump()

func get_nearest_point():
	var min_distance = INF
	var previousPoint = nearestPoint
	var area = get_node_or_null("Area2D")
	if area:
		for body in area.get_overlapping_bodies():
			if body.is_in_group("SwingPoint"):
				var dist = global_position.distance_to(body.global_position)
				if dist < min_distance:
					min_distance = dist
					nearestPoint = body
					
	if nearestPoint and nearestPoint.has_node("AnimatedSprite2D"):
		nearestPoint.get_node("AnimatedSprite2D").play("active")
	if previousPoint != nearestPoint and previousPoint and previousPoint.has_node("AnimatedSprite2D"):
		previousPoint.get_node("AnimatedSprite2D").play("inactive")

func update_animation():
	if not sprite_2d: return
	if is_on_floor():
		if input_direction.x != 0:
			sprite_2d.play("run")
		else:
			sprite_2d.play("idle")
	else:
		if sprite_2d.animation != "jump":
			sprite_2d.play("jump")

	if input_direction.x > 0:
		sprite_2d.flip_h = false
	elif input_direction.x < 0:
		sprite_2d.flip_h = true

func die() -> void:
	velocity = Vector2.ZERO
	is_dashing = false
	can_dash = true
	global_position = spawn_position

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == nearestPoint:
		if nearestPoint.has_node("AnimatedSprite2D"):
			nearestPoint.get_node("AnimatedSprite2D").play("inactive")
		nearestPoint = null
		if line:
			line.clear_points()
