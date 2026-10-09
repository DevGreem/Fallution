@tool
extends BaseInventoryComponent

class_name HotbarComponent

signal resized

@export var actor: CanvasItem
@export var slots: int = 1:
	set(value):
		
		value = max(value, 0)
		
		if slots == value:
			return
		
		slots = value
		_update_items_size()
		notify_property_list_changed()

@export var _items: Array[InventoryItemData] = []:
	set(value):
		_items = value
		_update_items_size()

@export var default_item: InventoryItemData = null

func _process(delta: float) -> void:
	
	if Engine.is_editor_hint():
		return
	
	for item: InventoryItemData in _items:
		
		if not item:
			continue
		
		item.process_actions(delta)

## -1 = No free position
func get_first_free_position() -> int:
	
	for i: int in range(_items.size()):
		
		if not is_instance_valid(_items[i]):
			return i
	
	return -1

func get_item(pos: int) -> InventoryItemData:
	
	var value: InventoryItemData = _items.get(pos)
	
	if not is_instance_valid(value) and default_item:
		value = default_item.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	item_getted.emit(pos, value)
	
	return value

func has_item_in_pos(pos: int) -> bool:
	return is_instance_valid(_items.get(pos))

func add_item(pos: int, item: InventoryItemData) -> bool:
	
	var getted := get_item(pos)
	
	if getted.item_data.id != item.item_data.id:
		return false
	
	if not getted:
		_set_item(pos, item)
	else:
		getted.stack(item)
	
	return true

func replace_item(pos: int, item: InventoryItemData) -> InventoryItemData:
	
	var getted := get_item(pos)
	
	if not getted:
		_set_item(pos, item)
		return null
	
	var temp := getted.duplicate(true)
	_set_item(pos, item)
	return temp

func remove_item(pos: int) -> InventoryItemData:
	
	var getted := get_item(pos)
	
	if getted:
		getted = getted.duplicate(true)
	_set_item(pos, null)
	
	return getted

func _set_item(pos: int, new_value: InventoryItemData) -> bool:
	
	_items.set(pos, new_value)
	item_setted.emit(pos, new_value)
	
	return true

func _update_items_size() -> void:
	
	if slots == _items.size():
		return
	
	if slots < _items.size():
		push_warning("Cells cantity changed, Now it is smaller than the size of _items!")
		
		for i: int in range(_items.size(), slots, -1):
			var item := _items[i-1]
			
			if not item:
				remove_item(i-1)
				continue
			
			var action_id := DropItemAction.new().id
			
			var context := ItemAction.Context.new(
				item,
				self,
				actor
			)
			
			if item.actions.has(action_id):
				item.actions[action_id].execute(context)
			
			remove_item(i-1)
	
	_items.resize(slots)
	print("Resized _items array from hotbar component")
	resized.emit()
