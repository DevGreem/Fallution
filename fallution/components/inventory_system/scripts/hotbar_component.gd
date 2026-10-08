@tool
extends BaseInventoryComponent

class_name HotbarComponent

@export var cells: int = 1:
	set(value):
		
		if cells == value:
			return
		
		cells = max(value, 0)
		_update_items_size()

@export var _items: Array[InventoryItemData] = []:
	set(value):
		_items = value
		_update_items_size()

@export var crash_on_invalid_position: bool = false

func _process(delta: float) -> void:
	for item: InventoryItemData in _items:
		item.process_actions(delta)

## -1 = No free position
func get_first_free_position() -> int:
	
	for i: int in range(_items.size()):
		
		if not is_instance_valid(_items[i]):
			return i
	
	return -1

func get_item(pos: int) -> InventoryItemData:
	
	var value: InventoryItemData = _items.get(pos)
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
		getted.current_stack += item.current_stack
		getted.stack(item)
	
	return true

func replace_item(pos: int, item: InventoryItemData) -> InventoryItemData:
	
	var getted := get_item(pos)
	
	if not getted:
		_set_item(pos, item)
		return null
	
	if item:
		if getted.item_data.id == item.item_data.id:
			getted.stack(item)
			return null
			
	var temp := getted.duplicate(true)
	_set_item(pos, item)
	return temp
	

func remove_item(pos: int) -> InventoryItemData:
	
	var getted := get_item(pos).duplicate(true)
	_set_item(pos, null)
	
	return getted

func _set_item(pos: int, new_value: InventoryItemData) -> bool:
	
	_items.set(pos, new_value)
	item_setted.emit(pos, new_value)
	
	return true

func _update_items_size() -> void:
	
	if cells == _items.size():
		return
	
	if cells < _items.size():
		push_warning("Cells cantity changed, Now it is smaller than the size of _items!")
		
		for i: int in range(cells+1, _items.size()):
			var item := _items[i]
			
			
			
			#! Here, I need to add the logic so that when an object is deleted, the "drop" action is executed if it has one.
	
	_items.resize(cells)
