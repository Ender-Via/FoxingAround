extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("reset_jump"):
		body.reset_jump()
		
		# 1. Ẩn quả cầu đi ngay lập tức
		visible = false
		
		# 2. Khóa vùng va chạm lại để nhân vật không bị ăn đúp khi bay ngang qua
		$CollisionShape2D.set_deferred("disabled", true)
		
		# 3. Chờ đúng 2 giây
		await get_tree().create_timer(2.0).timeout
		
		# 4. Hiện quả cầu lại và mở lại va chạm để dùng cho lượt sau
		visible = true
		$CollisionShape2D.set_deferred("disabled", false)
