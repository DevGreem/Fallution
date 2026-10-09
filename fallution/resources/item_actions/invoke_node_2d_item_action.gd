@tool
extends EquipItemAction

class_name InvokeNode2DItemAction

@export var item_node: PackedScene

func _init() -> void:
	show_in_gui = false

func _execute(context: Context) -> Variant:
	
	var container: ItemContainer2D = ComponentManager.recursive_get_component(
		context.target,
		context.target,
		ItemContainer2D
	)
	
	var node: Node2D = item_node.instantiate()
	
	container.add_child(node)
	
	return

func _validate_property(property: Dictionary) -> void:
	
	if property.name == "show_in_gui":
		property.usage |= PROPERTY_USAGE_READ_ONLY
