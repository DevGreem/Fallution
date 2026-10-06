extends RefCounted

class_name ModifiersStack

@export var modifiers: Array[StatModifier] = []

var _cache: Dictionary[float, float] = {}

func get_modifier_type() -> StringName:
	
	if modifiers.is_empty():
		return &""
	
	return modifiers[0].type.get_id()

func add_modifier(modifier: StatModifier) -> bool:
	
	if not modifiers.is_empty() and modifier.type.get_id() != get_modifier_type():
		return false
	
	modifiers.append(modifier)
	_cache.clear()
	return true

func remove_modifier(modifier: StatModifier) -> bool:
	
	var idx := modifiers.find(modifier)
	
	if idx == -1:
		return false
	
	remove_modifier_at(idx)
	return true
	
func remove_modifier_at(idx: int) -> void:
	modifiers.remove_at(idx)
	_cache.clear()

func get_modified_value(raw_value: float) -> float:
	
	if _cache.has(raw_value):
		return _cache[raw_value]
	
	var result := raw_value
	
	for modifier: StatModifier in modifiers:
		
		if modifier.can_apply():
			result = modifier.get_value_modified(result)
	
	_cache[raw_value] = result
	return result
