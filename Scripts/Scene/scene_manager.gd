extends CanvasLayer

var scenes = {
	"mainmenu": "res://Scenes/main_menu.tscn",
	"map1": "res://Scenes/Map/Map_1.tscn",
	"map2": "res://Scenes/Map/Map_2.tscn",
	"map3": "res://Scenes/Map/Map_3.tscn",
	"endscene": "res://Scenes/EndScene.tscn"
}

func change_scene(target_scene_path: String):
	if scenes.has(target_scene_path):
		get_tree().change_scene_to_file(scenes.get(target_scene_path))
		AudioManager.play_music(target_scene_path)
		return
	get_tree().change_scene_to_file(target_scene_path)
