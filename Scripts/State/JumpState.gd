class_name JumpState
extends State

func enter(player:CharacterBody2D) -> void:
	player.get_node("AnimatedSprite2D").play("idle")
	player.get_node("AnimatedSprite2D").play("jump")

func process(delta: float, player:CharacterBody2D) -> void:
	var direction = Input.get_axis("ui_left","ui_right")
	if direction > 0:
		player.get_node("AnimatedSprite2D").flip_h = false
	if direction < 0:
		player.get_node("AnimatedSprite2D").flip_h = true
	if player.is_on_floor() and Input.get_axis("ui_right","ui_left"):
		transition_requested.emit("Run")
	if player.is_on_floor() and not Input.get_axis("ui_right","ui_left"):
		transition_requested.emit("Idle")
	if Input.is_action_just_pressed("ui_accept") and player.max_jumps - player.jump_count:
		enter(player)
