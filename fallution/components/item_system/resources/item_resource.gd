
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

func _to_string() -> String:
	return "ItemResource[id=%s,name=%s,instance_id=%s]" % [id, name, get_instance_id()]
