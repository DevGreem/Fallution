@tool
extends Control

class_name InventorySlot

signal assigned_item_changed(new: InventoryItemData)

@export var selection_border: TextureRect

var _manager: GraphicHotbar

# Change to get item directly from hotbar_component of manager
# And delete assigned_item_changed to manage InventorySlot update from GraphicHotbar
var assigned_item: InventoryItemData:
	set(value):
		
		if assigned_item == value:
			return
		
		assigned_item = value
		assigned_item_changed.emit(assigned_item)

func select() -> void:
	selection_border.visible = true
	
	if not assigned_item or not _manager:
		return
	
	_execute_hotbar_actions(EquipItemAction.new().id)

func unselect() -> void:
	selection_border.visible = false
	
	if not assigned_item or not _manager:
		return
	
	_execute_hotbar_actions(UnequipItemAction.new().id)

func _execute_hotbar_actions(id: StringName) -> void:

	if not assigned_item.actions.has(id):
		return
	
	var context := ItemAction.Context.new(assigned_item, self, _manager.hotbar_component.actor)
	
	assigned_item.actions[id].execute(context)
