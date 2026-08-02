extends Node2D

@onready var map = $"/root/Main/Map"
@onready var body = $Body_Anim
@onready var ui = $"/root/Main/UI"

@onready var sfx_move = $move
@onready var sfx_noBattery = $no_move
@onready var sfx_plugIn = $plug_in
@onready var sfx_plugOut = $plug_out
@onready var sfx_retractCable = $retract
@onready var sfx_doioing = $doioing
@onready var sfx_batteryCharging = $charging

var max_charges
var max_wire_length

var charge
var length
var wire_path : Array[Vector2i]
var facing_path := []

var facing := 0
var current_cell: Vector2i

var is_plugged = true
var is_on_charger = false
var is_moving = false

func _ready():
	max_charges = map.get_max_charges()
	max_wire_length = map.get_max_wire_length()
	
	charge = max_charges
	length = max_wire_length
	
	_move_to_cell(map.get_spawn_cell())
	_update_anim(facing)
	


func _physics_process(delta: float) -> void:
	ui.update_charge(charge)
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
	
	if desired_cell != current_cell and _is_valid_move(desired_cell) and charge > 0:
		_move_to_cell(desired_cell)
		_update_anim(facing)
		is_on_charger = map.is_on_charger(current_cell)
		
		if is_plugged:
			charge = max_charges
		elif is_on_charger:
			pass
		else:
			charge -= 1
	
	if desired_cell != current_cell and _is_valid_move(desired_cell) == false and charge != 0:
		sfx_doioing.pitch_scale = randf_range(0.8, 1.2)
		sfx_doioing.play()
		
	if desired_cell != current_cell and charge == 0:
		sfx_noBattery.pitch_scale = randf_range(0.9, 1.1)
		sfx_noBattery.play()
		
	if Input.is_action_just_pressed("retract"):
		_pull_wire()
		
		_check_plugged_change()
			
		sfx_retractCable.pitch_scale = randf_range(0.75, 1.25)
		sfx_retractCable.play()
		
		if is_plugged:
			charge = max_charges
	

func _is_valid_move(cell: Vector2i) -> bool:
	return map.is_moveable(cell) and !wire_path.has(cell)

func _move_to_cell(cell: Vector2i) -> void:
	_update_wire(cell, current_cell)
	
	sfx_move.pitch_scale = randf_range(0.9, 1.1)
	sfx_move.play()
	
	position = map.cell_to_world(cell)
	current_cell = map.world_to_cell(position)

func _check_plugged_change():
	var is_pluggedNew = map.is_plugged(wire_path)
	
	if (is_pluggedNew != is_plugged):
		if (is_plugged == false):
			sfx_plugIn.play()
		else:
			sfx_plugOut.play()
		is_plugged = is_pluggedNew

func _update_wire(cell: Vector2i, current_cell: Vector2i) -> void:
	
	_check_plugged_change()
	
	if wire_path.size() > max_wire_length or !is_plugged:
		_drag_wire(cell, facing)
	else:
		_add_wire(cell, facing)

	_check_plugged_change()

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
	if wire_path.size() > 1:
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
