extends ItemAction

class_name EquipItemAction

func get_id() -> StringName:
	return "equip"

func get_action_title() -> String:
	return "Equip"

func _execute(context: Context) -> Variant:
	push_warning("Assigned equip action to an item that don't have a method")
	return
