@tool
extends Node

class_name MoneyBagComponent

signal money_changed
signal max_money_changed

@export var save_as_int: bool = false:
	set(value):
		save_as_int = value
		notify_property_list_changed()

@export var max_money: float = -1.0:
	set(value):
		
		if save_as_int:
			value = int(value)
		
		if max_money == value:
			return
		
		max_money = value
		max_money_changed.emit()

@export var money: float = 0:
	set(value):
		
		if save_as_int:
			value = int(value)
		
		if max_money != -1.0:
			value = min(value, max_money)
		
		if money == value:
			return
		
		money = value
		money_changed.emit()

func _validate_property(property: Dictionary) -> void:
	
	if property.name in ["money", "max_money"]:
		
		if save_as_int:
			property.type = TYPE_INT
			
