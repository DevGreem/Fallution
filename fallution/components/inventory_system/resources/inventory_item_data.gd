extends Resource

class_name InventoryItemData

signal stack_finished

@export var item_data: ItemResource

@export_group("Inventory Data")

## By default: First texture is the default frame
@export var icons: Array[Texture2D] = []
@export var max_stack: int = 1

@export_group("Behaviour")
@export var _inspector_actions: Array[ItemAction] = []:
	set(value):
		
		if not Engine.is_editor_hint():
			return
		_inspector_actions = value

@export var _stack_method: ItemStackMethod = DefaultItemStackMethod.new()

@export_storage
var actions: Dictionary[StringName, ItemAction] = {}

@export_storage
var current_stack: int = 1:
	set(value):
		current_stack = value
		
		if current_stack == 0:
			stack_finished.emit()

func _init() -> void:
	
	for action: ItemAction in _inspector_actions:
		actions[action.get_id()] = action
	
	_inspector_actions = []

func process_actions(delta: float) -> void:
	for id: StringName in actions:
		actions[id].process(delta)

func stack(item: InventoryItemData) -> void:
	_stack_method.stack(self, item)
