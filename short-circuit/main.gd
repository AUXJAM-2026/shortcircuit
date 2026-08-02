extends Node2D

@export var levels: Array[PackedScene]
@export var player_scene: PackedScene
@onready var bgm = $BackgroundMusic
@onready var cam = $Camera2D

func _ready():
	var level = LevelProgress.current_level
	
	if level > levels.size():
		level = levels.size() - 1
	
	var map = levels[level].instantiate()
	map.name = "Map"
	self.add_child(map)
	
	var player = player_scene.instantiate()
	player.name = "Player"
	self.add_child(player)
	self.remove_child(cam)
	player.add_child(cam)

func _on_background_music_finished() -> void:
	bgm.play()
