extends Control

class_name ShopItemNode

@export var texture: TextureRect
@export var title: Label
@export var description: Label
@export var item: ShopItem

var ui_invoker: ShopUI

func _on_button_pressed() -> void:
	
	if not item.can_buy(ui_invoker.interactor):
		return
	
	item.buy(ui_invoker)
