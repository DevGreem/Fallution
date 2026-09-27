extends Node2D

class_name SpawnContainer2D

signal node_spawned
signal node_despawned

func spawn_node(node: Node, deferred: bool = false) -> Node:
	
	if not is_instance_valid(node):
		return null
	
	if deferred:
		add_child.call_deferred(node)
	else:
		add_child(node)
	
	GameDebugger.debug_log(SpawnContainer2D, "Spawning node: " + node.name + " (" + str(node) + ")")
	node_spawned.emit(node)
	
	return node

func spawn_scene(scene: PackedScene, deferred: bool = false) -> Node:
	
	var instance: Node = scene.instantiate()
	
	return spawn_node(instance, deferred)

func despawn_node(node: Node, deferred: bool = false) -> bool:
	
	if not is_instance_valid(node):
		return false
	
	if deferred:
		remove_child.call_deferred(node)
	else:
		remove_child(node)
	
	node_despawned.emit()
	return true
