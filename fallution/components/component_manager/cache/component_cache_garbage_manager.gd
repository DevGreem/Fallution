extends CacheGarbage

class_name ComponentCacheGarbage

func remove_node_cache(node: Node) -> bool:
	return remove_cache(node)

func remove_type_cache(node: Node, type: Variant) -> bool:
	
	if not cache.storage.has(node):
		return false
	
	return remove_cache(node, type)

func remove_component_cache(node: Node, type: Variant, component: Node) -> bool:
	
	if not cache.storage.has(node):
		return false
	
	if not cache.storage[node].has(type):
		return false
	
	var arr: Array = cache.storage[node][type]
	
	var idx: int = arr.find(component)
	
	if idx == -1:
		return false
	
	return _remove_at_idx(arr, idx)

func remove_component_idx_cache(node: Node, type: Variant, idx: int) -> bool:
	
	if not cache.storage.has(node):
		return false
	
	if not cache.storage[node].has(type):
		return false
	
	var arr: Array = cache.storage[node][type]
	return _remove_at_idx(arr, idx)

func _remove_at_idx(arr: Array, idx: int) -> bool:
	
	if idx > arr.size():
		return false
	
	arr.remove_at(idx)
	return true
