extends Node2D

func _on_interactable_area_area_entered(area: Area2D) -> void:
	LevelProgress.current_level += 1
	get_tree().change_scene_to_file("res://main.tscn")
