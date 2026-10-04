extends Control

class_name ShopUI

@export var inventory: ShopInventory
@export var items_container: Control
@export var shop_item_ui: PackedScene

var interactor: Node

func _ready() -> void:
	update_shop_ui()

func update_shop_ui() -> void:
	
	_remove_items_ui()
	
	if not inventory:
		return
	
	for item: ShopItem in inventory.items:
		var scene: ShopItemNode = shop_item_ui.instantiate()
		scene.item = item
		scene.ui_invoker = self
		items_container.add_child(scene)

func _remove_items_ui() -> void:
	
	for child: Node in items_container.get_children():
		
		if not is_instance_valid(child):
			continue
		
		if is_instance_of(child, ShopItem):
			child.free()
