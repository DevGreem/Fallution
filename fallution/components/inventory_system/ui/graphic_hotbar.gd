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

@export_group("Preview")

@export var _slots_cantity: int = 0:
	set(value):
		
		if _slots_cantity == value:
			return
		
		_slots_cantity = value
		_on_resized()

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
	
	if Engine.is_editor_hint():
		return
	
	if not hotbar_component:
		return
	
	if not hotbar_component.item_setted.is_connected(_on_item_setted):
		hotbar_component.item_setted.connect(_on_item_setted)
	
	if not hotbar_component.resized.is_connected(_on_resized):
		hotbar_component.resized.connect(_on_resized)

func _on_item_setted(pos: int, value: InventoryItemData) -> void:
	pass

func _add_slot() -> void:
	
	var slot: InventorySlot = slot_scene.instantiate()
	slots_container.add_child(slot)
	slots.append(slot)

func _on_resized() -> void:
	
	if not slots_container:
		return
	
	if not hotbar_component and not Engine.is_editor_hint():
		return
	
	var real_slots := slots_container.get_child_count()
	var slots_cantity := hotbar_component.slots if not Engine.is_editor_hint() else _slots_cantity
	
	if slots_cantity == real_slots:
		return
	
	if slots_cantity > real_slots:
		for i: int in range(slots_cantity - real_slots):
			_add_slot()
		
		return
	
	if slots_cantity < real_slots:
		
		for i: int in range(slots_cantity, real_slots):
			_clear_slot(i)

func _clear_slot(idx: int) -> void:
	slots_container.get_child(idx).queue_free()
	slots.remove_at(idx)

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
