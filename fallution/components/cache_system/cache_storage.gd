extends CacheComponent

class_name CacheStorage

func set_cache(...parameters: Array) -> bool:
	
	var size: int = parameters.size()
	
	if size == 0:
		return false
	
	if size == 1:
		cache.storage[parameters[0]] = {}
		return true
	
	var current_key: Variant = cache.storage
	
	for i: int in range(size-2):
		
		var key: Variant = parameters[i]
		
		if not current_key.has(key):
			current_key[key] = {}
		
		current_key = current_key[key]
	
	current_key[parameters[-2]] = parameters[-1]
	
	return true
