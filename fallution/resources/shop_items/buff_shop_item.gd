@abstract
extends ShopItem

class_name BuffShopItem

@export var buff: Buff
@export var _custom_buff_title: String = ""
@export_multiline() var _buff_description: String = ""
@export var _buff_icon: Texture2D

func get_title() -> String:
	return _custom_buff_title if _custom_buff_title else buff.ID.to_pascal_case()

func get_description() -> String:
	return _buff_description

func get_icon() -> Texture2D:
	return _buff_icon
