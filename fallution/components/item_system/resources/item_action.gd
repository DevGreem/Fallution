@abstract
extends Resource

class_name ItemAction

class Context:
	var item: ItemResource
	var actor: Node
	var target: Node
	
	func _init(_item: ItemResource, _actor: Node = null, _target: Node = null) -> void:
		item = _item
		actor = _actor
		target = _target

@export var show_in_gui: bool = true

@abstract
func get_id() -> StringName

@abstract
func get_action_title() -> String

@warning_ignore("unused_parameter")
func can_execute(context: Context) -> bool:
	return true

func execute(context: Context) -> Variant:
	
	if not can_execute(context):
		return
	
	return _execute(context)

@abstract
func _execute(context: Context) -> Variant
