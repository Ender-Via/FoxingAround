extends Node

@onready var MusicPlayer = AudioStreamPlayer.new()
@onready var SFXPlayer = AudioStreamPlayer.new()

var musics = {
	"mainmenu": preload("res://Assets/audio/music/intro.ogg"),
	"tutorial": preload("res://Assets/audio/music/tutorial.ogg"),
	"map1": preload("res://Assets/audio/music/music1.ogg"),
	"map2": preload("res://Assets/audio/music/music2.ogg"),
	"map3": preload("res://Assets/audio/music/music3.ogg"),
	"endscene": preload("res://Assets/audio/music/endscene.ogg")
}
var sfx = {
	"jump": preload("res://Assets/audio/sfx/jump.wav"),
	"dash": preload("res://Assets/audio/sfx/dash.mp3"),
	"run": preload("res://Assets/audio/sfx/run.mp3"),
	"swing": preload("res://Assets/audio/sfx/swing.mp3"),
	"hurt": preload("res://Assets/audio/sfx/hurt.wav")
}

func _ready() -> void:
	MusicPlayer.bus = "Music"
	SFXPlayer.bus = "SFX"
	add_child(MusicPlayer)
	add_child(SFXPlayer)
	
func play_music(music:String):
	if not musics.has(music):
		print_debug("Không tìm thấy âm thanh: ", music)
		return
	var newMusic = musics[music]
	if MusicPlayer.stream == newMusic and MusicPlayer.playing:
		return
	MusicPlayer.stop()
	MusicPlayer.stream = newMusic
	MusicPlayer.play()

func play_sfx(sound: String):
	if not sfx.has(sound):
		print("Không tìm thấy âm thanh: ", sound)
		return
	var newSFX = sfx[sound]
	if SFXPlayer.stream == newSFX and SFXPlayer.playing:
		return
	SFXPlayer.stop()
	SFXPlayer.stream = newSFX
	SFXPlayer.play()
