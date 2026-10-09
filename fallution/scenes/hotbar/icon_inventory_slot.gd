@tool
extends InventorySlot

class_name IconInventorySlot

@export var icon: TextureRect

func _ready() -> void:
	
	assigned_item_changed.emit(_on_change_assigned)

func _on_change_assigned(new: InventoryItemData) -> void:
	icon.texture = new.icons.get(0)
