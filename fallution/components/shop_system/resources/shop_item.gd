@abstract
extends Resource

class_name ShopItem

signal buyed

@export var value: int

var title: String:
	get = get_title

var description: String:
	get = get_description

var icon: Texture2D:
	get = get_icon

@abstract
func get_title() -> String

@abstract
func get_description() -> String

@abstract
func get_icon() -> Texture2D

func buy(shop: ShopUI) -> Variant:
	
	_on_before_buy(shop)
	
	buyed.emit()
	return _on_buy(shop)

@abstract
func _on_buy(shop: ShopUI) -> Variant

func can_buy(shop: ShopUI) -> bool:
	
	var money_bag: MoneyBagComponent = ComponentManager.recursive_get_component(shop.interactor, shop.interactor, MoneyBagComponent)
	
	if not money_bag:
		return false
	
	if money_bag.money < value:
		return false
	
	return true

func _on_before_buy(shop: ShopUI) -> void:
	
	var money_bag: MoneyBagComponent = ComponentManager.recursive_get_component(shop.interactor, shop.interactor, MoneyBagComponent)
	
	if not money_bag:
		return
	
	money_bag.money -= value
