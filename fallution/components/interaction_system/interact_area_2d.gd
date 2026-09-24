extends Area2D

class_name InteractArea2D

signal interacted(component: InteractComponent2D)
signal focused
signal unfocused
signal status_changed

@export var interact_name: String = "interact"
@export var active: bool = true:
	set(value):
		
		if active == value:
			return
		
		active = value
		status_changed.emit()

func interact(component: InteractComponent2D) -> void:
	interacted.emit(component)

func focus() -> void:
	GameDebugger.debug_log(
		InteractArea2D,
		"Area focused"
	)
	focused.emit()

func unfocus() -> void:
	GameDebugger.debug_log(
		InteractArea2D,
		"Area unfocused"
	)
	unfocused.emit()
