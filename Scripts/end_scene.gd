extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music("endscene")


func _on_button_pressed() -> void:
	SceneManager.change_scene("mainmenu")
	pass # Replace with function body.
