@tool
extends Node

class_name MoneyBagComponent

@export var save_as_int: bool = false:
	set(value):
		save_as_int = value
		notify_property_list_changed()

@export var max_value: float = INT64_MAX

@export var money: float = 0:
	set(value):
		
		if save_as_int:
			value = int(value)
		
		money = min(value, max_value)

func _validate_property(property: Dictionary) -> void:
	
	if property.name == "money":
		
		if save_as_int:
			property.type = TYPE_INT
			
