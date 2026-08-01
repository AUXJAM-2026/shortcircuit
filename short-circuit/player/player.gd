extends Node2D

@onready var map = $"/root/Main/Map"
@onready var body = $Body_Anim

@export var max_charges := 3
@export var max_length := 8
var charge = max_charges
var length = max_length
var wire_path := []

var facing := 0
var current_pos: Vector2i

var is_moving = false

func _ready():
	position = map.cell_to_world(Vector2i(0, 0))
	_update_anim(facing)

func _physics_process(delta: float) -> void:
	var desired_pos := current_pos

	if Input.is_action_just_pressed("move_down"):
		desired_pos = desired_pos + Vector2i(0, 1)
		facing = 0
	if Input.is_action_just_pressed("move_up"):
		desired_pos = desired_pos + Vector2i(0, -1)
		facing = 2
	if Input.is_action_just_pressed("move_left"):
		desired_pos = desired_pos + Vector2i(-1, 0)
		facing = 1
	if Input.is_action_just_pressed("move_right"):
		desired_pos = desired_pos + Vector2i(1, 0)
		facing = 3
		
	_update_anim(facing)
	
	if _is_valid_move(desired_pos):
		_move_to_cell(desired_pos)

func _is_valid_move(cell: Vector2i) -> bool:
	return map.is_moveable(cell)

func _move_to_cell(cell: Vector2i) -> void:
	position = map.cell_to_world(cell)
	current_pos = map.world_to_cell(position)

func _update_anim(facing) -> void:
	match facing:
		0:
			body.play("down")
		1:
			body.play("left")
		2:
			body.play("up")
		3:
			body.play("right")
