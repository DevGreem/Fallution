extends Control

class_name ShopItemNode

@export var texture: TextureRect
@export var title: Label
@export var description: Label
@export var buy_button: Button
@export var item: ShopItem:
	set(value):
		
		if item == value:
			return
		
		item = value
		_update_data()

var ui_invoker: ShopUI

func _update_data() -> void:
	texture.texture = item.icon
	title.text = item.name
	description.text = item.description

func _on_button_pressed() -> void:
	
	if not item.can_buy(ui_invoker):
		return
	
	item.buy(ui_invoker)
