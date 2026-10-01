extends LootTableResource

class_name WeightLootTable

@export var _items: Dictionary[ItemResource, float] = {}
var items: Dictionary[ItemResource, float]:
	get: return _items.duplicate(true)
	set(value):
		push_error("You can't change directly the items of a LootTable")

func get_random_item(..._params: Array) -> ItemResource:
	
	var total_weight := get_total_weight()
	
	var to_search := randi_range(1, total_weight)
	
	var total_sum: float = 0.0
	for item: ItemResource in _items:
		total_sum += _items[item]
		
		if total_sum > to_search:
			return item
	
	return null

func get_item(item_id: StringName) -> ItemResource:
	
	for item: ItemResource in _items:
		
		if item.id == item_id:
			return item
	
	return null

var _weight_cache: float = -1.0

func get_total_weight() -> float:
	
	if _weight_cache != -1.0:
		return _weight_cache
	
	var total: float = 0
	
	for val: float in _items.values():
		total += val
	
	_weight_cache = total
	return total

func add_item(item: ItemResource, weight: float) -> void:
	_items[item] = weight
	_reset_weight_cache()

func remove_item_by_id(item_id: StringName) -> bool:
	
	for item: ItemResource in _items:
		
		if item.id == item_id:
			_items.erase(item)
			return true
	
	return false

func remove_item(item: ItemResource) -> bool:
	
	var result := _items.erase(item)
	
	if result:
		_reset_weight_cache()
		
	return result

func _reset_weight_cache() -> void:
	_weight_cache = -1.0
