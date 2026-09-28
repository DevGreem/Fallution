@abstract
extends Resource

class_name LootTableResource

@export var id: StringName

@abstract
func get_random_item(...params: Array) -> ItemResource

@abstract
func get_item(item_id: StringName) -> ItemResource
