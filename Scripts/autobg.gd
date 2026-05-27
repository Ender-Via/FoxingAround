extends ParallaxBackground
@export var scroll_speed: float = 100.0 
@export var x: float = 0
@export var y: float = 0
func _process(delta) -> void: 
	scroll_offset.x += scroll_speed * delta * x
	scroll_offset.y += scroll_speed * delta * y
