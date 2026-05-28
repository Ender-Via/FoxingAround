class_name RunState
extends State

func enter(player:CharacterBody2D) -> void:
	get_node("Timer").start()
	player.get_node("AnimatedSprite2D").play("run")

func process(delta: float, player:CharacterBody2D) -> void:
	var direction = Input.get_axis("ui_left","ui_right")
	if direction > 0:
		player.get_node("AnimatedSprite2D").flip_h = false
	if direction < 0:
		player.get_node("AnimatedSprite2D").flip_h = true
	if direction == 0:
		transition_requested.emit("Idle")
	if Input.is_action_just_pressed("ui_accept") or not player.is_on_floor():
		transition_requested.emit("Jump")

func exit() -> void:
	get_node("Timer").stop()

func _on_timer_timeout() -> void:
	AudioManager.play_sfx("run")
