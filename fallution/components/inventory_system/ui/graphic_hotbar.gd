@icon("res://addons/at-icons/control/square_brackets.svg")
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

@export var slots_container: Container

@export_group("Testing")

@export var _slots_cantity: int = 0

# Add InventorySlot here
var slots: Array[InventorySlot] = []
var _last_size: int = -1

func _ready() -> void:
	_init_hotbar()

func get_item_selected() -> InventoryItemData:
	return hotbar_component.get_item(selected_slot)

func _init_hotbar() -> void:
	_connect_hotbar()
	_on_resized()

func _connect_hotbar() -> void:
	
	if not hotbar_component:
		return
	
	if not hotbar_component.item_setted.is_connected(_on_item_setted):
		hotbar_component.item_setted.connect(_on_item_setted)
	
	if not hotbar_component.resized.is_connected(_on_resized):
		hotbar_component.resized.connect(_on_resized)

func _on_item_setted(pos: int, value: InventoryItemData) -> void:
	pass

func _on_resized() -> void:
	pass
	

func _clear_slot(idx: int) -> void:
	slots_container.get_child(idx).queue_free()

func _clear_slots() -> void:
	
	if not slots_container:
		return
	
	for child: Node in slots_container.get_children():
		child.queue_free()
	
	slots.clear()

func _get_configuration_warnings() -> PackedStringArray:
	
	var warnings: PackedStringArray = []
	
	if not hotbar_component and _slots_cantity != 0:
		warnings.append(
			"You can change slots cantity to see how it looks into the editor"
		)
	
	return warnings
