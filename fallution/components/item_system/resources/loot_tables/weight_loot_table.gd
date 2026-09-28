extends LootTableResource

class_name WeightLootTable

@export var _items: Dictionary[ItemResource, int] = {}
var items: Dictionary[ItemResource, int]:
	get: return _items.duplicate(true)
	set(value):
		push_error("You can't change directly the items of a LootTable")

func get_random_item(...params: Array) -> ItemResource:
	
	return

func get_item(item_id: StringName) -> ItemResource:
	
	for _item: ItemResource in items:
		
		if _item.id == item_id:
			return _item
	
	return null

func get_total_weight() -> int:
	
	var total: int = 0
	
	for val: int in _items.values():
		total += val
	
	return total

func add_item(item: ItemResource, weight: int) -> void:
	_items[item] = weight

func remove_item(item: ItemResource) -> void:
	pass
