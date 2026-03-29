extends Node2D

@onready var inventory: Inventory = $Inventory
@onready var other_inventory: Inventory = $OtherInventory
@onready var simple_inventory_ui: SimpleInventoryUI = $Control/CanvasLayer/HBoxContainer/SimpleInventoryUI
@onready var other_simple_inventory_ui: SimpleInventoryUI = $Control/CanvasLayer/HBoxContainer/OtherSimpleInventoryUI

@export var item_id : String = "wood"

func _process(delta):
	if Input.is_action_just_pressed("interact"):
			print("Inventory Stacks:")
			for item in inventory.stacks:
				if item.item_id != "":
					print(item.item_id," x ", item.amount)
				else:
					print("Empty")
	if Input.is_action_just_pressed("add_item_a"):
		inventory.add(item_id, 1)


func _on_button_left_button_down() -> void:
	var selected_items: Array[int] = simple_inventory_ui.get_selected_inventory_items()
	if selected_items.is_empty():
		return

	for selected_item_index in selected_items:
		inventory.transfer(selected_item_index, other_inventory)


func _on_button_right_button_down() -> void:
	var selected_items: Array[int] = other_simple_inventory_ui.get_selected_inventory_items()
	if selected_items.is_empty():
		return

	for selected_item_index in selected_items:
		other_inventory.transfer(selected_item_index, inventory)
