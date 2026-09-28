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

@abstract
func get_id() -> StringName

@warning_ignore("unused_parameter")
func can_execute(context: Context) -> bool:
	return true

func execute(context: Context) -> void:
	
	if not can_execute(context):
		return
	
	_execute(context)

@abstract
func _execute(context: Context) -> void
