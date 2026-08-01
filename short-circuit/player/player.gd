extends Node2D

@onready var map = $"/root/Main/Map"
@onready var body = $Body_Anim

@export var max_charges := 3
@export var max_wire_length := 15
var charge = max_charges
var length = max_wire_length
var wire_path : Array[Vector2i]
var facing_path := []

var facing := 0
var current_cell: Vector2i

var is_moving = false

func _ready():
	_move_to_cell(Vector2i(0, 0))
	_update_anim(facing)

func _physics_process(delta: float) -> void:
	var desired_cell := current_cell

	if Input.is_action_just_pressed("move_down"):
		desired_cell = desired_cell + Vector2i(0, 1)
		facing = 0
	if Input.is_action_just_pressed("move_up"):
		desired_cell = desired_cell + Vector2i(0, -1)
		facing = 2
	if Input.is_action_just_pressed("move_left"):
		desired_cell = desired_cell + Vector2i(-1, 0)
		facing = 1
	if Input.is_action_just_pressed("move_right"):
		desired_cell = desired_cell + Vector2i(1, 0)
		facing = 3
		
	_update_anim(facing)
	
	if desired_cell != current_cell and _is_valid_move(desired_cell):
		_move_to_cell(desired_cell)
		


func _is_valid_move(cell: Vector2i) -> bool:
	return map.is_moveable(cell) and _is_not_on_wire_path(cell)

func _move_to_cell(cell: Vector2i) -> void:
	_update_wire(cell, current_cell)
	
	position = map.cell_to_world(cell)
	current_cell = map.world_to_cell(position)
	
func _update_wire(cell: Vector2i, current_cell: Vector2i) -> void:
	print(cell)
	print(wire_path)
	if wire_path.size() > 1:

		if cell == wire_path[wire_path.size() -2]:
			print("pull")
			_pull_player()
			print(wire_path)
			return
	
		if wire_path.size() >= max_wire_length:
			_drag_wire(cell, facing)
			print("drag")
			print(wire_path)
			return
	
	_add_wire(cell, facing)
	print("add")
	print(wire_path)

func _undo_move() -> void:
	var desired_cell = wire_path.pop_back()
	position = map.cell_to_world(desired_cell)
	current_cell = map.world_to_cell(position)

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
	

func _add_wire(cell, facing) -> void:
	wire_path.push_back(cell)
	facing_path.push_back(facing)
	
	map.update_wire(wire_path)

func _pull_wire() -> void:
	wire_path.pop_front()
	facing_path.pop_front()
	
	map.update_wire(wire_path)

func _pull_player() -> void:
	wire_path.pop_back()
	facing_path.pop_back()
	
	map.update_wire(wire_path)
	
func _drag_wire(cell, facing) -> void:
	_add_wire(cell, facing)
	_pull_wire()
	
	map.update_wire(wire_path)

func _is_not_on_wire_path(cell: Vector2i) -> bool:
	if wire_path.size() > 1:
		return !(cell != wire_path[wire_path.size() -2] and wire_path.has(cell))
	return true
