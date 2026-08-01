extends Control

@onready var battery_middle = $Battery/Middle
@export var battery_middle_piece_scene = TextureRect

@onready var sprite_charged = preload("res://sprites/sprite_battery_charged.png")
@onready var sprite_uncharged = preload("res://sprites/sprite_battery_uncharged.png")

func _ready():
	return

func update_charge_cell_amount(amount: int) -> void:
	for i in range(amount):
		var new_piece := battery_middle_piece_scene.new()
		new_piece.name = str(battery_middle.get_child_count() + 1)
		new_piece.texture = sprite_charged

		battery_middle.add_child(new_piece)

func update_charge(charge: int) -> void:
	if charge > battery_middle.get_child_count():
		update_charge_cell_amount(charge)
	else:
		var battery_modules = battery_middle.get_children()
		for i in range(charge):
			battery_modules[i].texture = sprite_charged
		
		for i in range(charge, battery_middle.get_child_count()):
			battery_modules[i].texture = sprite_uncharged
