extends ShareableResource

class_name LimitRange

signal max_value_changed(before: float, after: float)
signal min_value_changed(before: float, after: float)

@export var max_value: float = 1.0:
	set(value):
		
		if max_value == value:
			return
		
		if value < min_value:
			value = min_value
		
		max_value_changed.emit(max_value, value)
		max_value = value

@export var min_value: float = 0.0:
	set(value):
		
		if value == min_value:
			return
		
		if value > max_value:
			value = max_value
		
		min_value_changed.emit(min_value, value)
		min_value = value

func is_in_range(value: float) -> bool:
	return value >= min_value && value <= max_value
