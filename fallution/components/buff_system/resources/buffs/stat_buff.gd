extends BuffEffect

class_name StatBuff

@export var stat_modifier: StatModifier

func _on_apply(context: BuffContext) -> void:
	
	if context.target is BuffManager:
		pass
	print("Applied stat buff to ", context.target, ": ", self)

func _on_remove(context: BuffContext) -> void:
	print("Stat buff removed from ", context.target, ": ", self)

func _to_string() -> String:
	return "StatBuffEffect[{0}]" % [stat_modifier]
