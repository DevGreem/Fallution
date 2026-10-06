extends BuffEffect

class_name StatBuffEffect

@export var stat_modifier: StatModifier

func _on_apply(context: BuffContext) -> void:
	
	if context.target is BuffManager:
		_apply_to_buff_manager(context.target as BuffManager)
		return
	elif context.target is Node:
		_apply_to_node(context.target as Node)
	
	print("Applied stat buff to ", context.target, ": ", self)

func _on_remove(context: BuffContext) -> void:
	
	if context.target is BuffManager:
		_remove_to_buff_manager(context.target as BuffManager)
	elif context.target is Node:
		_remove_to_node(context.target as Node)
		
	print("Stat buff removed from ", context.target, ": ", self)

func _to_string() -> String:
	return "StatBuffEffect[{0}]" % [stat_modifier]

func _apply_to_buff_manager(buff_manager: BuffManager) -> void:
	buff_manager.add_modifier(stat_modifier)

func _apply_to_node(node: Node) -> void:
	
	var buff_manager: BuffManager = ComponentManager.recursive_get_component(node, node, BuffManager)
	
	if not buff_manager:
		return
	
	buff_manager.add_modifier(stat_modifier)

func _remove_to_buff_manager(buff_manager: BuffManager) -> void:
	
	buff_manager.remove_modifier(stat_modifier)

func _remove_to_node(node: Node) -> void:
	
	var buff_manager: BuffManager = ComponentManager.recursive_get_component(node, node, BuffManager)
	
	if not buff_manager:
		return
	
	buff_manager.remove_modifier(stat_modifier)
