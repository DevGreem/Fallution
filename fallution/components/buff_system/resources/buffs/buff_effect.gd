@abstract
extends Resource

class_name BuffEffect

signal applied()
signal removed()

func apply(context: BuffContext) -> void:
	_on_apply(context)
	applied.emit()

func remove(context: BuffContext) -> void:
	_on_remove(context)
	removed.emit()

@abstract
func _on_apply(context: BuffContext) -> void

@abstract
func _on_remove(context: BuffContext) -> void
