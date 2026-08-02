extends Node2D

@export var levels: Array[PackedScene]
@export var player_scene: PackedScene
@onready var bgm = $BackgroundMusic

func _ready():
	summon_level_and_player(0)

func load_level(level_id) -> void:
	var children = self.get_children()
	
	for child in children:
		if child.name == "Map" or child.name == "Player":
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


func _on_background_music_finished() -> void:
	bgm.play()
