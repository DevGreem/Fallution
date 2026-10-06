extends Resource

class_name StatModifier

@export var type: ModifierType
@export var mode: ModifierMode
@export var value: float
@export var priority: int = 0

func can_apply() -> bool:
	return true

func get_value_modified(raw_value: float, modified_value: float = raw_value) -> float:
	return mode.execute_buff(raw_value, value)

func _to_string() -> String:
	return "StatModifier[%s,%s,%s]" % [type.get_id(), value, priority]
