extends Resource

class_name ShopInventory

@export var items: Array[ShopItem] = []

#func _init() -> void:
	#
	#for i: int in range(len(items)):
		#
		#if not is_instance_valid(items[i]):
			#items.remove_at(i)
