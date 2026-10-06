@abstract
extends Resource

class_name ItemResource

@export var _ID: StringName
var id: StringName:
	get: return _ID
	set(value):
		
		push_error(
			"You can't change the ItemResource.id of an item on runtime!",
			" Resource trying to be changed: ",
			self
		)
		return

@export var name: String
@export_multiline() var description: String

@export var _inspector_actions: Array[ItemAction] = []:
	set(value):
		
		if not Engine.is_editor_hint():
			return
		_inspector_actions = value

var actions: Dictionary[StringName, ItemAction] = {}

func _init() -> void:
	
	for action: ItemAction in _inspector_actions:
		actions[action.get_id()] = action

func _to_string() -> String:
	return "[id={0},name={1},instance_id={2}]" % [id, name, get_instance_id()]
