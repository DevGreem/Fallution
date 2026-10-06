extends RefCounted

class_name ModifiersStack

@export var modifiers: Array[StatModifier] = []

func get_modifier_type() -> StringName:
	
	if modifiers.is_empty():
		return &""
	
	return modifiers[0].type.get_id()

func add_modifier(modifier: StatModifier) -> bool:
	
	if not modifiers.is_empty() and modifier.type.get_id() != get_modifier_type():
		return false
	
	modifiers.append(modifier)
	return true

func get_modified_value(raw_value: float) -> float:
	
	var result := raw_value
	
	for modifier: StatModifier in modifiers:
		
		if modifier.can_apply():
			result = modifier.get_value_modified(raw_value)
	
	return result
