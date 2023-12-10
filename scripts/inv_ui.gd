extends Control

@onready var inv: Inv = preload("res://inventories/player_inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false

func _ready():
	update_slots()
	close()
	
func update_slots():
	print(inv)
	for i in range(min(inv.items.size(), slots.size())):
		if slots[i]:
			slots[i].update(inv.items[i])
	
func _process(_delta):
	if Input.is_action_just_pressed("open_inventory"):
		if is_open:
			close()
		else:
			open()

func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false
