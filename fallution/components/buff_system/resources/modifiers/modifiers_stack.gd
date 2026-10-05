extends RefCounted

class_name ModifiersStack

@export var modifiers: Array[StatModifier] = []

func get_modifier_type() -> StringName:
	
	if modifiers.is_empty():
		return &""
	
	return modifiers[0].type.get_id()

func add_modifier(modifier: StatModifier) -> bool:
	
	if modifier.type.get_id() != get_modifier_type():
		return false
	
	return true
