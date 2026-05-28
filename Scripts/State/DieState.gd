class_name DieState extends State

var currentPlayer:CharacterBody2D

func enter(player:CharacterBody2D) -> void:
	get_node("Timer").start()
	player.get_node("AnimatedSprite2D").play("die")
	AudioManager.play_sfx("hurt")
	currentPlayer = player 
	currentPlayer.disableInput = true
	currentPlayer.move_and_slide()

func exit() -> void:
	get_node("Timer").stop()


func _on_timer_timeout() -> void:
	currentPlayer.velocity = Vector2.ZERO
	currentPlayer.is_dashing = false
	currentPlayer.can_dash = true
	currentPlayer.global_position = currentPlayer.spawn_position
	currentPlayer.disableInput = false
	transition_requested.emit("Idle")
	exit()
