extends BuffShopItem

class_name InteractorBuffShopItem

func _on_buy(shop: ShopUI) -> bool:
	var buff_manager: BuffManager = ComponentManager.recursive_get_component(shop.interactor, shop.interactor, BuffManager)
	
	buff_manager.add_buff(buff)
	print("Added buff to interactor")
	
	return true

func can_buy(shop: ShopUI) -> bool:
	
	if not ComponentManager.recursive_has_component(shop.interactor, shop.interactor, BuffManager):
		print("Interactor don't have a BuffManager!")
		return false
	
	return super.can_buy(shop)
