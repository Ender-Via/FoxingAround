extends Node

func _ready():
	# Dùng call_deferred để chắc chắn Player đã spawn ra đàng hoàng rồi mới tác động
	call_deferred("setup_player_skills")

func setup_player_skills():
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		# 1. Quản lý việc Nhảy
		player.enable_jump = true   # Vẫn cho bấm nhảy thường để khỏi kẹt map
		player.max_jumps = 1        # NHƯNG ÉP XUỐNG CHỈ ĐƯỢC NHẢY 1 LẦN (Khóa double jump)
		
		# 2. Khóa mỏ các skill khác
		player.enable_swing = true
		player.enable_wall_jump = false
		
		# 3. Mở khóa kỹ năng lướt (Dash)
		player.enable_dash = true
		
