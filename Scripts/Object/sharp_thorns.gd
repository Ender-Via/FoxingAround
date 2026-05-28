extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_node("State"):
		body.get_node("State")._transition_requested("Die")
