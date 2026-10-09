extends ItemAction

class_name DropItemAction

func get_id() -> StringName:
	return &"drop"

func get_action_title() -> String:
	return "Drop"

func _execute(context: Context) -> Variant:
	push_warning("Assigned drop action to an item that don't have a method")
	return
