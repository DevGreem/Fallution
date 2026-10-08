@tool
extends Control

class_name ShopItemNode

@export var item: ShopItem:
	set(value):
		
		if item == value:
			return
		
		item = value
		_update_data()

@export_group("Component Nodes")

@export var _texture: TextureRect
@export var _title: Control:
	set(value):
		
		if "text" not in value:
			return
		
		_title = value

@export var _description: Control:
	set(value):
		
		if "text" not in value:
			return
		
		_description = value

@export var _cost_label: Control:
	set(value):
		
		if "text" not in value:
			return
		
		_cost_label = value

var ui_invoker: ShopUI

func _update_data() -> void:
	_set_text(_title, item.title)
	_set_text(_description, item.description)
	_set_text(_cost_label, str(item.value))
	
	_texture.texture = item.icon

func _on_button_pressed() -> void:
	
	if not item.can_buy(ui_invoker):
		return
	
	item.buy(ui_invoker)

func _set_text(node: Control, text: String) -> void:
	
	if not node:
		return
	
	if "text" in node:
		node.text = text
