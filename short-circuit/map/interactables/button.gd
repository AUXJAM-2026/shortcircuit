extends Node2D

@export var id := 0
@export var color : Color = Color(0.4, 0.4, 1)

@onready var button_color = $COLOR

func _ready():
	button_color.modulate = color
