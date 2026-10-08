extends ItemStackMethod

class_name DefaultItemStackMethod

func stack(original: InventoryItemData, new: InventoryItemData) -> void:
	if original.item_data.id != new.item_data.id:
		return
	
	original.current_stack += new.current_stack
	
	# I will add this in the future
	#for id: StringName in actions:
		#pass
