extends Resource

class_name ShopItem

signal buyed

@export var id: String
@export var name: String
@export var description: String
@export var value: int

func buy(buyer: Node) -> Variant:
	
	_on_before_buy(buyer)
	
	buyed.emit()
	return _on_buy(buyer)

func _on_buy(buyer: Node) -> Variant:
	return

func can_buy(buyer: Node) -> bool:
	
	var money_bag: MoneyBagComponent = ComponentManager.get_component(buyer, MoneyBagComponent)
	
	if not money_bag:
		return false
	
	if money_bag.money < value:
		return false
	
	return true

func _on_before_buy(buyer: Node) -> void:
	
	var money_bag: MoneyBagComponent = ComponentManager.get_component(buyer, MoneyBagComponent)
	
	if not money_bag:
		return
	
	money_bag.money -= value
