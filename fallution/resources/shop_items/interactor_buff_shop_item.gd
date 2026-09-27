extends ShopItem

class_name InteractorBuffShopItem

@export var buff: Buff

func _on_buy(buyer: Node) -> bool:
	var buff_manager: BuffManager = ComponentManager.get_component(buyer, BuffManager)
	
	if not buff_manager:
		return false
	
	buff_manager.add_buff(buff)
	
	super.buy(buyer)
	return true

func can_buy(buyer: Node) -> bool:
	
	super.can_buy(buyer)
	
	#if not ComponentManager.has
	#var buff_manager: BuffManager = ComponentManager
	return true
