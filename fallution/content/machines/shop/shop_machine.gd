extends Node2D

class_name ShopMachine

@export var inventory := ShopInventory.new()
var _ui: ShopUI

func _on_interacted(component: InteractComponent2D) -> void:
	
	if _ui:
		return
	
	_ui = UIManager.open_file("uid://clo47v5yf60c6")
	_ui.inventory = inventory
	_ui.interactor = component.actor
	_ui.update_shop_ui()
	
func _on_ui_unfocused() -> void:
	
	if not _ui:
		return
	
	UIManager.close(_ui)
