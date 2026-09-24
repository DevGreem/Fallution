extends CacheStorage

class_name ComponentCacheStorage

func add_component_cache(node: Node, type: Variant, component: Node) -> void:
	
	if not is_instance_valid(node) or not is_instance_valid(component):
		return
	
	var garbage: ComponentCacheGarbage = cache.garbage_manager()
	
	if not node.tree_exiting.is_connected(garbage.remove_node_cache.bind(node)):
		node.tree_exiting.connect(garbage.remove_node_cache.bind(node))
	
	if not cache.storage.has(node):
		cache.storage[node] = {}
	
	if not cache.storage[node].has(type):
		cache.storage[node][type] = []
	
	if component in cache.storage[node][type]:
		return
	
	if not component:
		return
		
	cache.storage[node][type].append(component)
	
	if not component.tree_exiting.is_connected(garbage.remove_component_cache.bind(node, type, component)):
		component.tree_exiting.connect(garbage.remove_component_cache.bind(node, type, component))
	
