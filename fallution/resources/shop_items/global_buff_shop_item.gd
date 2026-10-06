extends BuffShopItem

class_name GlobalBuffShopItem

func _on_buy(_buyer: ShopUI) -> Variant:
	GlobalBuffManager.add_buff(buff)
	print("Upgraded ", buff.type.get_id(), "!")
	
	return
