extends ShopItem

class_name InteractorBuffShopItem

@export var buff: Buff

func _on_buy(buyer: Node) -> bool:
	var buff_manager: BuffManager = ComponentManager.recursive_get_component(buyer, buyer, BuffManager)
	
	buff_manager.add_buff(buff)
	print("Added buff to interactor")
	
	return true

func can_buy(buyer: Node) -> bool:
	
	if not ComponentManager.recursive_has_component(buyer, buyer, BuffManager):
		print("Interactor don't have a BuffManager!")
		return false
	
	return super.can_buy(buyer)
