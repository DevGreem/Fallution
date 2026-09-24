extends RefCounted

class_name BaseCacheStatus

var is_cached: bool
var value: Variant:
	get = get_value

func _init(_is_cached: bool = false, _value: Variant = null) -> void:
	is_cached = _is_cached
	value = _value

func get_value() -> Variant:
	return value
