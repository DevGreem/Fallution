@tool
extends Node

class_name MoneyBagComponent

signal money_changed
signal max_money_changed

@export var save_as_int: bool = false:
	set(value):
		save_as_int = value
		notify_property_list_changed()

@export var max_money: float = INT64_MAX:
	set(value):
		
		if save_as_int:
			value = int(value)
		
		if max_money == value:
			return
		
		max_money = value
		max_money_changed.emit()
		
		money = min(money, max_money)

@export var money: float = 0:
	set(value):
		
		if save_as_int:
			value = int(value)
		
		if money == value:
			return
		
		money = min(value, max_money)
		money_changed.emit()

func _validate_property(property: Dictionary) -> void:
	
	if property.name == "money":
		
		if save_as_int:
			property.type = TYPE_INT
			
