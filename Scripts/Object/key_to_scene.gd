extends Area2D

@export var map:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("ChangeScene")
