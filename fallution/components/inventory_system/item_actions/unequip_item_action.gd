extends ItemAction

class_name UnequipItemAction

func get_id() -> StringName:
	return "unequip"

func get_action_title() -> String:
	return "Unequip"

func _execute(context: Context) -> Variant:
	push_warning("Assigned unequip action to an item that don't have a method")
	return
