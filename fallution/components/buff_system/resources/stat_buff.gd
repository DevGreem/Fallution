extends Buff

class_name StatBuff

@export var type: BuffType
@export var value: float
@export var mode: BuffMode
@export var priority: int = 0

func _on_apply(context: BuffContext) -> void:
	
	if context.target is BuffManager:
		pass
	print("Applied stat buff to ", context.target, ": ", self)

func _on_remove(context: BuffContext) -> void:
	print("Stat buff removed from ", context.target, ": ", self)

func _to_string() -> String:
	return "StatBuff[{0},{1},{mode}]" % [ID, type, mode]
