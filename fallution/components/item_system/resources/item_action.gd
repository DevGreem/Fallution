@abstract
extends Resource

class_name ItemAction

class Context:
	var item: InventoryItemData
	var actor: Node
	var target: Node
	
	func _init(_item: InventoryItemData, _actor: Node = null, _target: Node = null) -> void:
		item = _item
		actor = _actor
		target = _target

@export var show_in_gui: bool = true

## -1.0 = No cooldown
@export var cooldown: float = -1.0

var id: StringName:
	get = get_id

var title: StringName:
	get = get_action_title

@abstract
func get_id() -> StringName

@abstract
func get_action_title() -> String

func process(delta: float) -> void:
	cooldown -= delta

@warning_ignore("unused_parameter")
func can_execute(context: Context) -> bool:
	return true

func execute(context: Context) -> Variant:
	
	if not can_execute(context):
		return
	
	return _execute(context)

@abstract
func _execute(context: Context) -> Variant
