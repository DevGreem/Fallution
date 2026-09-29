extends ItemAction

class_name DropItemAction2D

@export var world_item: WorldItemData

func get_id() -> StringName:
	return &"drop_item_action"

func get_action_title() -> String:
	return "Drop"

func _execute(context: Context) -> Node2D:
	
	var item: Node2D = world_item.scene.instantiate()
	
	return item
	
