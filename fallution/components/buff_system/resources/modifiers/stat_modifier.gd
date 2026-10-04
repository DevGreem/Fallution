extends Resource

class_name StatModifier

@export var type: BuffType
@export var mode: ModifierMode
@export var value: float
@export var priority: int = 0

func get_value_modified(raw_value: float) -> float:
	return mode.execute_buff(raw_value, value)
