extends ShopItem

class_name GlobalBuffShopItem

@export var buff: Buff

func _on_buy(_buyer: Node) -> Variant:
	GlobalBuffManager.add_buff(buff)
	print("Upgraded ", buff.type.get_id(), "!")
	
	return
