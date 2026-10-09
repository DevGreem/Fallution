@tool
extends Control

class_name GraphicHotbar

signal selected_slot_changed(new: int)

@export var selected_slot: int = 0:
	set(value):
		
		if selected_slot == value:
			return
		
		selected_slot = clampi(value, 0, hotbar_component.slots-1)
		selected_slot_changed.emit(selected_slot)

@export_group("Configuration")

@export var hotbar_component: HotbarComponent:
	set(value):
		
		if hotbar_component == value:
			return
		
		hotbar_component = value
		_connect_hotbar()

@export var slot_scene: PackedScene:
	set(value):
		
		if slot_scene == value:
			return
		
		slot_scene = value

# Add InventorySlot here
var slots: Array[Control] = []

func _init() -> void:
	
	pass

func get_item_selected() -> InventoryItemData:
	return hotbar_component.get_item(selected_slot)

func _connect_hotbar() -> void:
	
	if not hotbar_component:
		return
	
	if not hotbar_component.item_setted.is_connected(_on_item_setted):
		hotbar_component.item_setted.connect(_on_item_setted)

func _on_item_setted(pos: int, value: InventoryItemData) -> void:
	pass
