extends Node

class_name ChangeVisibilityUINode

enum ChangeType {
	SHOW,
	HIDE,
	TOGGLE
}

@export var node: Control
@export var type: ChangeType

func change_visibility() -> void:
	
	if type == ChangeType.TOGGLE:
		node.visible = !node.visible
		return
	
	node.visible = type == ChangeType.SHOW
