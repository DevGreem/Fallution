@abstract
extends Node

class_name BaseInventoryComponent

@warning_ignore("unused_signal")
signal item_getted(pos: Variant, value: InventoryItemData)

@warning_ignore("unused_signal")
signal item_setted(pos: Variant, value: InventoryItemData)

@abstract
func get_first_free_position() -> Variant
