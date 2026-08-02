extends Node2D

@export var switch_pos: Vector2i
@export var barrier_layer: TileMapLayer
@export var barrier_pos: Vector2i

@onready var sfx_activate = $activate

var activated := false

func _ready():
	add_to_group("switches")

func activate():
	if activated:
		return
	
	activated = true
	
	sfx_activate.play()
	
	_remove_barrier()

func _remove_barrier():
	barrier_layer.erase_cell(barrier_pos)
