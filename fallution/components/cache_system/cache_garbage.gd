extends CacheComponent

class_name CacheGarbage

func remove_cache(...parameters: Array) -> bool:
	
	if parameters.is_empty():
		return false
	
	var size: int = parameters.size()
	
	if size == 1:
		cache.storage.erase(parameters[0])
	
	var current: BaseCacheStatus = cache.getter_manager().get_cache.callv(parameters.slice(0, size-1))
	
	if not current.is_cached:
		return false
	
	var dict: Dictionary = current.value
	
	if dict.has(parameters[-1]):
		dict.erase(parameters[-1])
		return true
	
	return false

func clear_cache() -> void:
	cache.storage.clear()
	cache.cleared.emit()
