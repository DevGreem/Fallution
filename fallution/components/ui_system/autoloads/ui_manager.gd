extends Node

signal ui_opened(node: Control)
signal ui_closed(node: Control)

@export var root: Control

func open(node: Control) -> Control:
	
	if not is_instance_valid(node):
		GameDebugger.debug_error_string("UIManager", "The node " + str(node) + " is a invalid instance")
		return null
	
	if not root:
		GameDebugger.debug_error_string("UIManager", "A root is not setted")
		return null
	
	root.add_child(node)
	ui_opened.emit(node)
	
	return node

func open_scene(scene: PackedScene) -> Control:
	
	if not scene.can_instantiate():
		GameDebugger.debug_error_string("UIManager", "The scene " + str(scene) + " can't be instantiated")
		return null
	
	var node: Control = scene.instantiate()
	
	return open(node)

func open_file(path: String) -> Control:
	
	var packed: PackedScene = load(path)
	
	return open_scene(packed)

func close(node: Control) -> bool:
	
	if not is_instance_valid(node):
		GameDebugger.debug_warning_string("UIManager", "Trying to close invalid node")
		return false
	
	ui_closed.emit(node)
	node.queue_free()
	return true
