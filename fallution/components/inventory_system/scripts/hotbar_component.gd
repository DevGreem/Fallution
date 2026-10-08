@tool
extends BaseInventoryComponent

class_name HotbarComponent

@export var cells: int = 1:
	set(value):
		
		if cells == value:
			return
		
		cells = max(value, 0)

@export var _items: Array[InventoryItemData] = []

@export var crash_on_invalid_position: bool = false

func _process(delta: float) -> void:
	for item: InventoryItemData in _items:
		item.process_actions(delta)

func get_first_free_position() -> int:
	return 0
