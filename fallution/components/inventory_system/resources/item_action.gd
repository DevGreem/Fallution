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
@export var default_cooldown: float = -1.0

var cooldown: float
var has_started: bool = false

var id: StringName:
	get = get_id

var title: StringName:
	get = get_action_title

@abstract
func get_id() -> StringName

@abstract
func get_action_title() -> String

func start() -> void:
	
	if has_started:
		return
	
	has_started = true
	cooldown = default_cooldown

func process(delta: float) -> void:
	
	if default_cooldown == -1.0:
		return
	
	if cooldown > 0.0:
		cooldown -= delta

@warning_ignore("unused_parameter")
func can_execute(context: Context) -> bool:
	
	if cooldown > 0.0:
		return false
	
	return true

func execute(context: Context) -> Variant:
	
	if not can_execute(context):
		return
	
	cooldown = default_cooldown
	
	return _execute(context)

@abstract
func _execute(context: Context) -> Variant
