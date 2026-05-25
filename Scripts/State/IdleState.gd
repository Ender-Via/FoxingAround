class_name IdleState
extends State

func enter(player:CharacterBody2D) -> void:
	player.get_node("AnimatedSprite2D").play("idle")

func process(delta: float, player:CharacterBody2D) -> void:
	var direction = Input.get_axis("ui_left","ui_right")
	if direction != 0:
		transition_requested.emit("Run")
	if Input.is_action_just_pressed("ui_accept") or not player.is_on_floor():
		transition_requested.emit("Jump")
