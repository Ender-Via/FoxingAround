extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("Da va cham voi: ", body.name)
	if body.has_method("reset_jump"):
		body.reset_jump()
		queue_free()
