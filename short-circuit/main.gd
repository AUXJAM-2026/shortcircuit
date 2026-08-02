extends Node2D

@export var levels: Array[PackedScene]
@export var player_scene: PackedScene
@onready var bgm = $BackgroundMusic
@onready var cam = $Camera2D

func _ready():
	summon_level_and_player(0)

func load_level(level_id) -> void:
	var children = self.get_children()
	
	for child in children:
		if child.name == "Map":
			self.remove_child(child)
		if child.name == "Player":
			child.remove_child(cam)
			self.add_child(cam)
			self.remove_child(child)
	
	summon_level_and_player(level_id)

func summon_level_and_player(level_id) -> void:
	var level = level_id
	
	if level > levels.size():
		level = levels.size() - 1
	
	var map = levels[0].instantiate()
	map.name = "Map"
	self.add_child(map)
	
	var player = player_scene.instantiate()
	player.name = "Player"
	self.add_child(player)
	self.remove_child(cam)
	player.add_child(cam)


func _on_background_music_finished() -> void:
	bgm.play()
