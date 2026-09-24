extends LimitRange

class_name LimitedValue

@export var current_value: float

func _init() -> void:
	
	if not min_value_changed.is_connected(_update_current):
		min_value_changed.connect(_update_current)
	
	if not max_value_changed.is_connected(_update_current):
		max_value_changed.connect(_update_current)

func _update_current() -> void:
	current_value = clampf(current_value, min_value, max_value)
