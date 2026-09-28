extends LootTableResource

class_name RandomLootTable

@export var items: Array[ItemResource] = []

func get_random_item(..._params: Array) -> ItemResource:
	return items.pick_random()

func get_item(item_id: StringName) -> ItemResource:
	var idx: int = items.find_custom(
		func(item: ItemResource) -> bool:
			return item.id == item_id
	)
	
	if idx == -1:
		return
	
	return items[idx]
